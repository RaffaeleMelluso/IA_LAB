;; =========================================================
;; AGENTE SEMPLICE - Logica Base per Wumpus World
;; =========================================================
;; Strategia: Esplora celle non visitate, evita muri, 
;; torna indietro se bloccato. Niente calcoli probabilistici.
;; =========================================================

(defmodule MAIN (export ?ALL))

(deftemplate percept (slot x) (slot y) (slot w) (slot h) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy))
(deftemplate action (slot move))
(deftemplate counter (slot step))

(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot da-x (default -1)) (slot da-y (default -1))
)

(deftemplate muro (slot x) (slot y))
(deftemplate memoria-azione (slot comando) (slot da-x) (slot da-y))
(deftemplate stato-agente (slot oro-preso (default FALSE)) (slot fase (default esplorazione)))
(deftemplate intenzione-registrata)

(deffacts initial
   (counter (step 0))
   (stato-agente (oro-preso FALSE) (fase esplorazione))
   (cella (x 0) (y 0) (visitata TRUE) (da-x 0) (da-y 0))
   (memoria-azione (comando none) (da-x 0) (da-y 0))
)

;; Pulisci percetti vecchi
(defrule MAIN::pulisci-percept-vecchi
   (declare (salience 10000))
   ?p1 <- (percept (steps ?s1))
   ?p2 <- (percept (steps ?s2&:(< ?s2 ?s1)))
   =>
   (retract ?p2))

;; Avvia il ciclo di deliberazione
(defrule MAIN::deliberate
   (declare (salience -10))
   (percept)
   =>
   (focus PERCEZIONE DECISIONE))

;; =========================================================
;; MODULO PERCEZIONE: Aggiornamento Mappa Base
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

(defrule PERCEZIONE::pulisci-azione
   (declare (salience 2000)) ?a <- (action) => (retract ?a))

(defrule PERCEZIONE::pulisci-registrazione
   (declare (salience 2000)) ?r <- (intenzione-registrata) => (retract ?r))

;; Aggiorna cella visitata
(defrule PERCEZIONE::aggiorna-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py)))

;; Crea cella se non esiste
(defrule PERCEZIONE::crea-cella-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py))))

(defrule PERCEZIONE::crea-cella-sopra
   (declare (salience 25))
   (percept (x ?x) (y ?y) (h ?h))
   (test (< (- ?y 1) ?h))
   (test (>= (- ?y 1) 0))
   (not (cella (x ?x) (y =(- ?y 1))))
   =>
   (assert (cella (x ?x) (y (- ?y 1)))))

(defrule PERCEZIONE::crea-cella-sotto
   (declare (salience 25))
   (percept (x ?x) (y ?y) (h ?h))
   (test (< (+ ?y 1) ?h))
   (not (cella (x ?x) (y =(+ ?y 1))))
   =>
   (assert (cella (x ?x) (y (+ ?y 1)))))

(defrule PERCEZIONE::crea-cella-destra
   (declare (salience 25))
   (percept (x ?x) (y ?y) (w ?w))
   (test (< (+ ?x 1) ?w))
   (not (cella (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (cella (x (+ ?x 1)) (y ?y))))

(defrule PERCEZIONE::crea-cella-sinistra
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (test (>= (- ?x 1) 0))
   (not (cella (x =(- ?x 1)) (y ?y)))
   =>
   (assert (cella (x (- ?x 1)) (y ?y))))

;; Rileva muro (agente sbatte contro muro e non si muove)
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
   (printout t "   !! Muro rilevato in [" ?mx "," ?my "]" crlf))

;; =========================================================
;; MODULO DECISIONE: Logica Semplice
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (percept (x ?x) (y ?y)) (action (move ?dir)) (not (intenzione-registrata))
   ?mem <- (memoria-azione)
   => 
   (modify ?mem (comando ?dir) (da-x ?x) (da-y ?y))
   (assert (intenzione-registrata)))

;; Se vedi l'oro, prendilo!
(defrule DECISIONE::prendi-oro
   (declare (salience 150)) (not (action))
   (percept (glitter TRUE)) ?s <- (stato-agente (oro-preso FALSE))
   => (assert (action (move grab))) (modify ?s (oro-preso TRUE) (fase fuga)) (printout t ">>> ORO PRESO! Torno alla partenza!" crlf))

;; Se hai l'oro e sei al punto di partenza, esci
(defrule DECISIONE::esci-vincitore
   (declare (salience 200)) (not (action))
   (percept (x 0) (y 0)) (stato-agente (oro-preso TRUE))
   => (assert (action (move quit))) (printout t ">>> VITTORIA! Uscito con l'oro!" crlf))

;; --- FUGA: Torna sempre al punto di partenza seguendo il tracciato ---
(defrule DECISIONE::fuga-verso-casa
   (declare (salience 140)) (not (action))
   (stato-agente (fase fuga))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<<< Torno a destra verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left)))  (printout t "<<< Torno a sinistra verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up)))    (printout t "<<< Torno in alto verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))  (printout t "<<< Torno in basso verso [" ?px "," ?py "]" crlf))
)

;; --- ESPLORAZIONE: Preferisci celle non visitate (niente sensori) ---
(defrule DECISIONE::vai-destra
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "-> Esploro a destra [" (+ ?x 1) "," ?y "]" crlf))

(defrule DECISIONE::vai-sinistra
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE))
   (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "-> Esploro a sinistra [" (- ?x 1) "," ?y "]" crlf))

(defrule DECISIONE::vai-su
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE))
   (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "-> Esploro in alto [" ?x "," (- ?y 1) "]" crlf))

(defrule DECISIONE::vai-giu
   (declare (salience 60)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE))
   (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "-> Esploro in basso [" ?x "," (+ ?y 1) "]" crlf))

;; --- BACKTRACKING: Se non ci sono celle da esplorare, torna indietro ---
(defrule DECISIONE::torna-indietro
   (declare (salience 25)) (not (action))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<- Arretro a destra [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left)))  (printout t "<- Arretro a sinistra [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up)))    (printout t "<- Arretro in alto [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))  (printout t "<- Arretro in basso [" ?px "," ?py "]" crlf)))

;; --- RINUNCIA: Se completamente bloccato, esci ---
(defrule DECISIONE::rinuncia
   (declare (salience 10)) (not (action)) (percept (x 0) (y 0)) (stato-agente (fase esplorazione))
   => (assert (action (move quit))) (printout t "!!! Bloccato. Rinuncio." crlf))
