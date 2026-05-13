;; =========================================================
;; MODULO MAIN
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept
   (slot x) (slot y) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy)
)
(deftemplate counter (slot step))
(deftemplate action (slot move))

(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot sicura (default FALSE))
   (slot da-x (default -1))
   (slot da-y (default -1))
)

(deftemplate cella-precedente (slot x) (slot y))

(deffacts initial
   (counter (step 0))
   (cella-precedente (x 0) (y 0))
   ;; Dichiariamo [0,0] subito, così non ha valori sballati come -1
   (cella (x 0) (y 0) (visitata TRUE) (sicura TRUE) (da-x 0) (da-y 0))
)

(defrule MAIN::deliberate
   (counter (step ?step))
   =>
   (focus PERCEZIONE DECISIONE)
)

;; =========================================================
;; MODULO PERCEZIONE
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

(defrule PERCEZIONE::pulisci-azione-vecchia
   (declare (salience 2000))
   ?a <- (action (move ?))
   =>
   (retract ?a)
)

(defrule PERCEZIONE::aggiorna-cella-esistente
   (percept (x ?x) (y ?y))
   (cella-precedente (x ?px) (y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (sicura TRUE) (da-x ?px) (da-y ?py))
)

(defrule PERCEZIONE::crea-cella-nuova
   (percept (x ?x) (y ?y))
   (cella-precedente (x ?px) (y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (sicura TRUE) (da-x ?px) (da-y ?py)))
)

(defrule PERCEZIONE::deduci-celle-sicure
   (percept (x ?x) (y ?y) (breeze FALSE) (stench FALSE))
   =>
   (assert (cella (x (+ ?x 1)) (y ?y) (sicura TRUE)))
   (assert (cella (x (- ?x 1)) (y ?y) (sicura TRUE)))
   (assert (cella (x ?x) (y (+ ?y 1)) (sicura TRUE)))
   (assert (cella (x ?x) (y (- ?y 1)) (sicura TRUE)))
)

;; =========================================================
;; MODULO DECISIONE
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

(defrule DECISIONE::ricorda-prima-di-muovere
   (declare (salience 1000))
   (percept (x ?x) (y ?y))
   ?vecchia <- (cella-precedente (x ?vx) (y ?vy))
   (test (or (neq ?x ?vx) (neq ?y ?vy))) 
   =>
   (retract ?vecchia)
   (assert (cella-precedente (x ?x) (y ?y)))
)

;; --- PRIORITÀ 100: Esplora nuove celle SICURE ---
(defrule DECISIONE::esplora-destra-sicura
   (declare (salience 100))
   (not (action (move ?))) ; <-- EVITA LE MOSSE MULTIPLE
   (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (sicura TRUE))
   => 
   (assert (action (move right)))
   (printout t "-> Sicuro: Esploro a DESTRA verso [" (+ ?x 1) "," ?y "]" crlf)
)

(defrule DECISIONE::esplora-sinistra-sicura
   (declare (salience 100))
   (not (action (move ?))) ; <-- EVITA LE MOSSE MULTIPLE
   (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (sicura TRUE))
   => 
   (assert (action (move left)))
   (printout t "-> Sicuro: Esploro a SINISTRA verso [" (- ?x 1) "," ?y "]" crlf)
)

(defrule DECISIONE::esplora-su-sicura
   (declare (salience 100))
   (not (action (move ?))) ; <-- EVITA LE MOSSE MULTIPLE
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (sicura TRUE))
   => 
   (assert (action (move up)))
   (printout t "-> Sicuro: Esploro in ALTO verso [" ?x "," (- ?y 1) "]" crlf)
)

(defrule DECISIONE::esplora-giu-sicura
   (declare (salience 100))
   (not (action (move ?))) ; <-- EVITA LE MOSSE MULTIPLE
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (sicura TRUE))
   => 
   (assert (action (move down)))
   (printout t "-> Sicuro: Esploro in BASSO verso [" ?x "," (+ ?y 1) "]" crlf)
)

;; --- PRIORITÀ 50: Filo di Arianna (Ritirata se non ci sono vie sicure) ---
(defrule DECISIONE::torna-sui-tuoi-passi
   (declare (salience 50))
   (not (action (move ?))) ; <-- EVITA LE MOSSE MULTIPLE
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py)) 
   (test (or (neq ?x ?px) (neq ?y ?py))) 
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<- Pericolo! Arretro a DESTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left)))  (printout t "<- Pericolo! Arretro a SINISTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up)))    (printout t "<- Pericolo! Arretro in ALTO verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))  (printout t "<- Pericolo! Arretro in BASSO verso [" ?px "," ?py "]" crlf))
)