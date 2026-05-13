;; =========================================================
;; MODULO MAIN: Strutture Dati e Controllo
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept (slot x) (slot y) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy))
(deftemplate action (slot move))
(deftemplate counter (slot step))

(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot da-x (default -1)) (slot da-y (default -1))      
   (slot cf-pit (default 0.0))    ; CF Pozzo (1.0 = certo, -1.0 = sicuro)
   (slot cf-wumpus (default 0.0)) ; CF Wumpus
)

(deftemplate muro (slot x) (slot y))
(deftemplate memoria-azione (slot step) (slot comando) (slot da-x) (slot da-y))
(deftemplate stato-agente (slot fase (default esplorazione)) (slot oro-preso (default FALSE)))

;; Supporto per il Ragionamento Matematico
(deftemplate valutata-cella (slot x) (slot y))
(deftemplate richiesta-cf-pit (slot x) (slot y) (slot val))
(deftemplate richiesta-cf-wumpus (slot x) (slot y) (slot val))

(deffacts initial
   (counter (step 0))
   (stato-agente (fase esplorazione) (oro-preso FALSE))
   ;; Inizializza la partenza [0,0]
   (cella (x 0) (y 0) (visitata TRUE) (da-x 0) (da-y 0) (cf-pit -1.0) (cf-wumpus -1.0))
   ;; Inizializza una memoria vuota per non far crashare le regole al turno 0
   (memoria-azione (step -1) (comando none) (da-x 0) (da-y 0))
)

(defrule MAIN::deliberate
   (declare (salience -10))
   (counter (step ?step))
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE)
)

;; =========================================================
;; MODULO PERCEZIONE: Memoria e Collisioni
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

(defrule PERCEZIONE::pulisci-azione-vecchia
   (declare (salience 2000))
   ?a <- (action)
   => (retract ?a))

;; REGOLA FONDAMENTALE RIPRISTINATA: Segna che sei entrato in una cella!
(defrule PERCEZIONE::aggiorna-cella
   (percept (x ?x) (y ?y))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   (memoria-azione (da-x ?px) (da-y ?py))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py))
   (printout t "-> Aggiorno cella [" ?x "," ?y "], provengo da [" ?px "," ?py "]" crlf))

(defrule PERCEZIONE::rileva-muro
   (declare (salience 100))
   (percept (x ?x) (y ?y))
   ?mem <- (memoria-azione (comando ?c) (da-x ?vx) (da-y ?vy))
   (test (and (= ?x ?vx) (= ?y ?vy))) ; Se non ci siamo mossi...
   (test (or (eq ?c up) (eq ?c down) (eq ?c left) (eq ?c right)))
   =>
   (bind ?mx ?x) (bind ?my ?y)
   (if (eq ?c right) then (bind ?mx (+ ?x 1)))
   (if (eq ?c left) then (bind ?mx (- ?x 1)))
   (if (eq ?c up) then (bind ?my (- ?y 1))) ; Ricorda: In Python l'alto è Y-1
   (if (eq ?c down) then (bind ?my (+ ?y 1)))
   (assert (muro (x ?mx) (y ?my)))
   (modify ?mem (comando none)) ; Resetta l'azione per non sbattere all'infinito
   (printout t "   !! SBANG! Muro rilevato e memorizzato in [" ?mx "," ?my "]" crlf))


;; =========================================================
;; MODULO RAGIONAMENTO: Certainty Factors (CF)
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

(defrule RAGIONAMENTO::analizza-pericoli
   (percept (x ?x) (y ?y) (breeze ?b) (stench ?s))
   (not (valutata-cella (x ?x) (y ?y)))
   =>
   (assert (valutata-cella (x ?x) (y ?y)))
   ;; Gestione Pozzi
   (bind ?val-p (if (eq ?b TRUE) then 0.4 else -1.0))
   (assert (richiesta-cf-pit (x (+ ?x 1)) (y ?y) (val ?val-p)))
   (assert (richiesta-cf-pit (x (- ?x 1)) (y ?y) (val ?val-p)))
   (assert (richiesta-cf-pit (x ?x) (y (+ ?y 1)) (val ?val-p)))
   (assert (richiesta-cf-pit (x ?x) (y (- ?y 1)) (val ?val-p)))
   ;; Gestione Wumpus
   (bind ?val-w (if (eq ?s TRUE) then 0.4 else -1.0))
   (assert (richiesta-cf-wumpus (x (+ ?x 1)) (y ?y) (val ?val-w)))
   (assert (richiesta-cf-wumpus (x (- ?x 1)) (y ?y) (val ?val-w)))
   (assert (richiesta-cf-wumpus (x ?x) (y (+ ?y 1)) (val ?val-w)))
   (assert (richiesta-cf-wumpus (x ?x) (y (- ?y 1)) (val ?val-w)))
   (if (or (eq ?b TRUE) (eq ?s TRUE)) then (printout t "   [!] PERICOLO avvertito in [" ?x "," ?y "]" crlf))
)

(defrule RAGIONAMENTO::crea-cella-per-cf-p
   (declare (salience 50))
   (richiesta-cf-pit (x ?x) (y ?y)) (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y))))

(defrule RAGIONAMENTO::crea-cella-per-cf-w
   (declare (salience 50))
   (richiesta-cf-wumpus (x ?x) (y ?y)) (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y))))

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
;; MODULO DECISIONE: Esplorazione e Fuga
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

(defrule DECISIONE::registra-azione
   (declare (salience 1000))
   (counter (step ?s)) (percept (x ?x) (y ?y)) (action (move ?dir))
   ?mem <- (memoria-azione (step ?old-s))
   (test (neq ?s ?old-s)) ; Memorizza una sola volta a turno
   =>
   (modify ?mem (step ?s) (comando ?dir) (da-x ?x) (da-y ?y)))

(defrule DECISIONE::prendi-oro
   (declare (salience 100)) (not (action (move ?)))
   (percept (glitter TRUE)) ?s <- (stato-agente (oro-preso FALSE))
   => (assert (action (move grab))) (modify ?s (oro-preso TRUE) (fase fuga)) (printout t ">>> ORO PRESO! Inizia la fuga!" crlf))

(defrule DECISIONE::esci
   (declare (salience 150)) (not (action (move ?)))
   (percept (x 0) (y 0)) (stato-agente (oro-preso TRUE))
   => (assert (action (move quit))) (printout t ">>> VITTORIA! Uscito dalla tana!" crlf))

(defrule DECISIONE::fuga-verso-casa
   (declare (salience 80)) (not (action (move ?)))
   (stato-agente (fase fuga)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "Fuga: DESTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left))) (printout t "Fuga: SINISTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up))) (printout t "Fuga: ALTO verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down))) (printout t "Fuga: BASSO verso [" ?px "," ?py "]" crlf)))

;; --- ESPLORAZIONE SICURA (Priorità 50) ---
(defrule DECISIONE::vai-destra-sicuro
   (declare (salience 50)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "-> Sicuro: vado a DESTRA in [" (+ ?x 1) "," ?y "]" crlf))

(defrule DECISIONE::vai-sinistra-sicuro
   (declare (salience 50)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "-> Sicuro: vado a SINISTRA in [" (- ?x 1) "," ?y "]" crlf))

(defrule DECISIONE::vai-su-sicuro
   (declare (salience 50)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "-> Sicuro: vado in ALTO in [" ?x "," (- ?y 1) "]" crlf))

(defrule DECISIONE::vai-giu-sicuro
   (declare (salience 50)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "-> Sicuro: vado in BASSO in [" ?x "," (+ ?y 1) "]" crlf))

;; --- RISCHIO CALCOLATO (Priorità 40) ---
(defrule DECISIONE::vai-destra-rischio
   (declare (salience 40)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "?> Rischio accettabile: DESTRA [" (+ ?x 1) "," ?y "] (P:" ?cp " W:" ?cw ")" crlf))

(defrule DECISIONE::vai-sinistra-rischio
   (declare (salience 40)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "?> Rischio accettabile: SINISTRA [" (- ?x 1) "," ?y "] (P:" ?cp " W:" ?cw ")" crlf))

(defrule DECISIONE::vai-su-rischio
   (declare (salience 40)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "?> Rischio accettabile: ALTO [" ?x "," (- ?y 1) "] (P:" ?cp " W:" ?cw ")" crlf))

(defrule DECISIONE::vai-giu-rischio
   (declare (salience 40)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5)) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "?> Rischio accettabile: BASSO [" ?x "," (+ ?y 1) "] (P:" ?cp " W:" ?cw ")" crlf))

;; --- RITIRATA (Priorità 25) ---
(defrule DECISIONE::ritirata
   (declare (salience 25)) (not (action (move ?)))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<- Strada bloccata. Ritirata a DESTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left))) (printout t "<- Strada bloccata. Ritirata a SINISTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up))) (printout t "<- Strada bloccata. Ritirata in ALTO verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down))) (printout t "<- Strada bloccata. Ritirata in BASSO verso [" ?px "," ?py "]" crlf))
)