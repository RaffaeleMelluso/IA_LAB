;; =========================================================
;; MODULO MAIN
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept (slot x) (slot y) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy))
(deftemplate action (slot move))
(deftemplate counter (slot step))

(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot da-x (default -1)) (slot da-y (default -1))
   (slot cf-pit (default 0.0))    ; CF per i Pozzi (-1.0 = sicuro)   
   (slot cf-wumpus (default 0.0)) ; CF per il Wumpus (-1.0 = sicuro)
)

(deftemplate muro (slot x) (slot y))
(deftemplate memoria-azione (slot comando) (slot da-x) (slot da-y))
(deftemplate stato-agente (slot oro-preso (default FALSE)) (slot fase (default esplorazione)))
(deftemplate intenzione-registrata)

(deftemplate valutata-cella (slot x) (slot y))
(deftemplate richiesta-cf-pit (slot x) (slot y) (slot val))
(deftemplate richiesta-cf-wumpus (slot x) (slot y) (slot val))

(deffacts initial
   (counter (step 0))
   (stato-agente (oro-preso FALSE) (fase esplorazione))
   (cella (x 0) (y 0) (visitata TRUE) (da-x 0) (da-y 0) (cf-pit -1.0) (cf-wumpus -1.0))
   (memoria-azione (comando none) (da-x 0) (da-y 0))
)

;; ANTICORPO 1: Uccide i dati fantasma di Python (Confronta gli step)
(defrule MAIN::pulisci-percept-vecchi
   (declare (salience 10000))
   ?p1 <- (percept (steps ?s1))
   ?p2 <- (percept (steps ?s2&:(< ?s2 ?s1)))
   =>
   (retract ?p2)
)

(defrule MAIN::deliberate
   (declare (salience -10))
   (percept)
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE)
)

;; =========================================================
;; MODULO PERCEZIONE: Aggiorna e Rileva Ostacoli
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

(defrule PERCEZIONE::pulisci-azione
   (declare (salience 2000))
   ?a <- (action) => (retract ?a))

(defrule PERCEZIONE::pulisci-registrazione
   (declare (salience 2000))
   ?r <- (intenzione-registrata) => (retract ?r))

(defrule PERCEZIONE::aggiorna-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py)))

(defrule PERCEZIONE::crea-cella-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py) (cf-pit -1.0) (cf-wumpus -1.0))))

(defrule PERCEZIONE::rileva-muro
   (declare (salience 100))
   (percept (x ?x) (y ?y))
   ?mem <- (memoria-azione (comando ?c) (da-x ?vx) (da-y ?vy))
   (test (and (= ?x ?vx) (= ?y ?vy))) 
   (test (or (eq ?c up) (eq ?c down) (eq ?c left) (eq ?c right)))
   =>
   (bind ?mx ?x) (bind ?my ?y)
   (if (eq ?c right) then (bind ?mx (+ ?x 1)))
   (if (eq ?c left)  then (bind ?mx (- ?x 1)))
   (if (eq ?c up)    then (bind ?my (- ?y 1)))
   (if (eq ?c down)  then (bind ?my (+ ?y 1)))
   (assert (muro (x ?mx) (y ?my)))
   (modify ?mem (comando none))
   (printout t "   !! SBANG! Muro fisico rilevato in [" ?mx "," ?my "]" crlf))

;; =========================================================
;; MODULO RAGIONAMENTO: Logica Probabilistica (CF)
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

(defrule RAGIONAMENTO::analizza-pericoli
   (percept (x ?x) (y ?y) (breeze ?b) (stench ?s))
   (not (valutata-cella (x ?x) (y ?y)))
   =>
   (assert (valutata-cella (x ?x) (y ?y)))
   
   (if (and (eq ?b FALSE) (eq ?s FALSE)) then (printout t "   [+] Dintorni sicuri da [" ?x "," ?y "]." crlf))
   (if (eq ?b TRUE) then (printout t "   [!] BREZZA in [" ?x "," ?y "]! Pericolo Pozzi." crlf))
   (if (eq ?s TRUE) then (printout t "   [!] PUZZA in [" ?x "," ?y "]! Pericolo Wumpus." crlf))
   
   ;; PARAMETRI CF MODIFICATI: Ora una singola brezza/puzza terrorizza l'agente (0.6 > 0.5)
   
   (if (eq ?b TRUE) then (bind ?val-p 0.6) else (bind ?val-p -1.0))
   (assert (richiesta-cf-pit (x (+ ?x 1)) (y ?y) (val ?val-p)))
   (assert (richiesta-cf-pit (x (- ?x 1)) (y ?y) (val ?val-p)))
   (assert (richiesta-cf-pit (x ?x) (y (+ ?y 1)) (val ?val-p)))
   (assert (richiesta-cf-pit (x ?x) (y (- ?y 1)) (val ?val-p)))
   
   (if (eq ?s TRUE) then (bind ?val-w 0.6) else (bind ?val-w -1.0))
   (assert (richiesta-cf-wumpus (x (+ ?x 1)) (y ?y) (val ?val-w)))
   (assert (richiesta-cf-wumpus (x (- ?x 1)) (y ?y) (val ?val-w)))
   (assert (richiesta-cf-wumpus (x ?x) (y (+ ?y 1)) (val ?val-w)))
   (assert (richiesta-cf-wumpus (x ?x) (y (- ?y 1)) (val ?val-w))))

(defrule RAGIONAMENTO::crea-cella-per-cf-p
   (declare (salience 50))
   (richiesta-cf-pit (x ?x) (y ?y)) (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y))))

(defrule RAGIONAMENTO::crea-cella-per-cf-w
   (declare (salience 50))
   (richiesta-cf-wumpus (x ?x) (y ?y)) (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y))))

;; La formula matematica del professore si applica qui
(defrule RAGIONAMENTO::applica-cf-pit
   (declare (salience 10))
   ?r <- (richiesta-cf-pit (x ?x) (y ?y) (val ?n))
   ?c <- (cella (x ?x) (y ?y) (cf-pit ?v))
   =>
   (retract ?r)
   (if (= ?n -1.0) then (modify ?c (cf-pit -1.0))
    else (if (>= ?v 0.0) then (modify ?c (cf-pit (- (+ ?v ?n) (* ?v ?n)))))))

(defrule RAGIONAMENTO::applica-cf-wumpus
   (declare (salience 10))
   ?r <- (richiesta-cf-wumpus (x ?x) (y ?y) (val ?n))
   ?c <- (cella (x ?x) (y ?y) (cf-wumpus ?v))
   =>
   (retract ?r)
   (if (= ?n -1.0) then (modify ?c (cf-wumpus -1.0))
    else (if (>= ?v 0.0) then (modify ?c (cf-wumpus (- (+ ?v ?n) (* ?v ?n)))))))

;; =========================================================
;; MODULO DECISIONE: Esplorazione o Ritirata
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

;; ANTICORPO 2: Aggiornamento memoria infallibile
(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (percept (x ?x) (y ?y)) (action (move ?dir))
   (not (intenzione-registrata))
   ?mem <- (memoria-azione)
   => 
   (modify ?mem (comando ?dir) (da-x ?x) (da-y ?y))
   (assert (intenzione-registrata)))

(defrule DECISIONE::prendi-oro
   (declare (salience 150)) (not (action))
   (percept (glitter TRUE)) ?s <- (stato-agente (oro-preso FALSE))
   => (assert (action (move grab))) (modify ?s (oro-preso TRUE) (fase fuga)) (printout t ">>> ORO PRESO! Fuga attivata!" crlf))

(defrule DECISIONE::esci-vincitore
   (declare (salience 200)) (not (action))
   (percept (x 0) (y 0)) (stato-agente (oro-preso TRUE))
   => (assert (action (move quit))) (printout t ">>> VITTORIA! Missione compiuta!" crlf))

;; --- ESPLORAZIONE SICURA AL 100% ---
(defrule DECISIONE::vai-destra
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0)) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "-> Sicuro: DESTRA verso [" (+ ?x 1) "," ?y "]" crlf))

(defrule DECISIONE::vai-sinistra
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0)) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "-> Sicuro: SINISTRA verso [" (- ?x 1) "," ?y "]" crlf))

(defrule DECISIONE::vai-su
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0)) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "-> Sicuro: ALTO verso [" ?x "," (- ?y 1) "]" crlf))

(defrule DECISIONE::vai-giu
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0)) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "-> Sicuro: BASSO verso [" ?x "," (+ ?y 1) "]" crlf))

;; --- RISCHIO CALCOLATO (Se non ci sono vie sicure al 100%, rischia se il CF < 50%) ---
(defrule DECISIONE::rischio-destra
   (declare (salience 40)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "?> Rischio accettabile: DESTRA (Pozzo:" ?cp " Wumpus:" ?cw ")" crlf))

(defrule DECISIONE::rischio-sinistra
   (declare (salience 40)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "?> Rischio accettabile: SINISTRA (Pozzo:" ?cp " Wumpus:" ?cw ")" crlf))

(defrule DECISIONE::rischio-su
   (declare (salience 40)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "?> Rischio accettabile: ALTO (Pozzo:" ?cp " Wumpus:" ?cw ")" crlf))

(defrule DECISIONE::rischio-giu
   (declare (salience 40)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "?> Rischio accettabile: BASSO (Pozzo:" ?cp " Wumpus:" ?cw ")" crlf))

;; --- RITIRATA E FUGA ---
(defrule DECISIONE::ritirata-o-fuga
   (declare (salience 25)) (not (action))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py)) (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<- Arretro a DESTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left)))  (printout t "<- Arretro a SINISTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up)))    (printout t "<- Arretro in ALTO verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))  (printout t "<- Arretro in BASSO verso [" ?px "," ?py "]" crlf)))

(defrule DECISIONE::rinuncia
   (declare (salience 10)) (not (action)) (percept (x 0) (y 0)) (stato-agente (fase esplorazione))
   => (assert (action (move quit))) (printout t "!!! Tana bloccata o troppo rischiosa. Rinuncio ed esco." crlf))