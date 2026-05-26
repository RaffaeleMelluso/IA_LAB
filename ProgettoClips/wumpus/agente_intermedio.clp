
;; =========================================================
;; AGENTE INTERMEDIO: inferenza per esclusione e navigazione base
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept (slot x) (slot y) (slot w) (slot h) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy))
(deftemplate action (slot move))
(deftemplate counter (slot step))

(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot da-x (default -1)) (slot da-y (default -1))
   (slot cf-pit (default 0.0))
   (slot cf-wumpus (default 0.0))
   (slot esaurita (default FALSE))
)

(deftemplate muro (slot x) (slot y))
(deftemplate memoria-azione (slot comando) (slot da-x) (slot da-y))
(deftemplate stato-agente (slot oro-preso (default FALSE)) (slot fase (default esplorazione)))
(deftemplate intenzione-registrata)
(deftemplate valutata-cella (slot x) (slot y))
(deftemplate richiesta-cf-pit (slot x) (slot y) (slot val))
(deftemplate richiesta-cf-wumpus (slot x) (slot y) (slot val))
(deftemplate brezza-rilevata (slot x) (slot y))
(deftemplate puzza-rilevata (slot x) (slot y))
(deftemplate rischio-spostato (slot bx) (slot by) (slot sx) (slot sy) (slot ix) (slot iy))
(deftemplate target-sicuro (slot x) (slot y))

(deffacts initial
   (counter (step 0))
   (stato-agente (oro-preso FALSE) (fase esplorazione))
   (cella (x 0) (y 0) (visitata TRUE) (da-x 0) (da-y 0) (cf-pit -1.0) (cf-wumpus -1.0) (esaurita FALSE))
   (memoria-azione (comando none) (da-x 0) (da-y 0))
)

(defrule MAIN::pulisci-percept-vecchi
   (declare (salience 10000))
   ?p1 <- (percept (steps ?s1))
   ?p2 <- (percept (steps ?s2&:(< ?s2 ?s1)))
   =>
   (retract ?p2))

(defrule MAIN::deliberate
   (declare (salience -10))
   (percept)
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE))

;; =========================================================
;; PERCEZIONE
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

(defrule PERCEZIONE::pulisci-azione
   (declare (salience 2000)) ?a <- (action) => (retract ?a))

(defrule PERCEZIONE::pulisci-registrazione
   (declare (salience 2000)) ?r <- (intenzione-registrata) => (retract ?r))

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
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py) (cf-pit -1.0) (cf-wumpus -1.0) (esaurita FALSE))))

(defrule PERCEZIONE::rileva-muro
   (declare (salience 100))
   (percept (x ?x) (y ?y))
   ?mem <- (memoria-azione (comando ?c) (da-x ?vx) (da-y ?vy))
   (test (and (= ?x ?vx) (= ?y ?vy)))
   (test (or (eq ?c up) (eq ?c down) (eq ?c left) (eq ?c right)))
   =>
   (bind ?mx ?x)
   (bind ?my ?y)
   (if (eq ?c right) then (bind ?mx (+ ?x 1)))
   (if (eq ?c left) then (bind ?mx (- ?x 1)))
   (if (eq ?c up) then (bind ?my (- ?y 1)))
   (if (eq ?c down) then (bind ?my (+ ?y 1)))
   (assert (muro (x ?mx) (y ?my)))
   (modify ?mem (comando none))
   (printout t "   !! Muro fisico in [" ?mx "," ?my "]" crlf))

;; =========================================================
;; RAGIONAMENTO
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

(defrule RAGIONAMENTO::analizza-pericoli
   (percept (x ?x) (y ?y) (breeze ?b) (stench ?s))
   (not (valutata-cella (x ?x) (y ?y)))
   =>
   (assert (valutata-cella (x ?x) (y ?y)))
   (if (eq ?b FALSE) then
      (assert (target-sicuro (x (+ ?x 1)) (y ?y)))
      (assert (target-sicuro (x (- ?x 1)) (y ?y)))
      (assert (target-sicuro (x ?x) (y (+ ?y 1))))
      (assert (target-sicuro (x ?x) (y (- ?y 1)))))
   (if (eq ?b TRUE) then
      (assert (richiesta-cf-pit (x (+ ?x 1)) (y ?y) (val 0.6)))
      (assert (richiesta-cf-pit (x (- ?x 1)) (y ?y) (val 0.6)))
      (assert (richiesta-cf-pit (x ?x) (y (+ ?y 1)) (val 0.6)))
      (assert (richiesta-cf-pit (x ?x) (y (- ?y 1)) (val 0.6))))
   (if (eq ?s TRUE) then
      (assert (richiesta-cf-wumpus (x (+ ?x 1)) (y ?y) (val 0.6)))
      (assert (richiesta-cf-wumpus (x (- ?x 1)) (y ?y) (val 0.6)))
      (assert (richiesta-cf-wumpus (x ?x) (y (+ ?y 1)) (val 0.6)))
      (assert (richiesta-cf-wumpus (x ?x) (y (- ?y 1)) (val 0.6))))
   (if (and (eq ?b FALSE) (eq ?s FALSE)) then
      (printout t "   [+] Nessun segnale: vicini candidati sicuri." crlf)
      else
      (printout t "   [i] Segnale presente: uso CF semplici sui vicini." crlf)))

(defrule RAGIONAMENTO::aggiorna-cf-pit
   (declare (salience 10))
   ?r <- (richiesta-cf-pit (x ?x) (y ?y) (val ?n))
   ?c <- (cella (x ?x) (y ?y) (cf-pit ?v))
   =>
   (retract ?r)
   (if (= ?n -1.0) then
      (modify ?c (cf-pit -1.0))
      else
      (if (>= ?v 0.0) then (modify ?c (cf-pit (- (+ ?v ?n) (* ?v ?n)))))))

(defrule RAGIONAMENTO::aggiorna-cf-wumpus
   (declare (salience 10))
   ?r <- (richiesta-cf-wumpus (x ?x) (y ?y) (val ?n))
   ?c <- (cella (x ?x) (y ?y) (cf-wumpus ?v))
   =>
   (retract ?r)
   (if (= ?n -1.0) then
      (modify ?c (cf-wumpus -1.0))
      else
      (if (>= ?v 0.0) then (modify ?c (cf-wumpus (- (+ ?v ?n) (* ?v ?n)))))))

(defrule RAGIONAMENTO::crea-cella-per-cf
   (declare (salience 5))
   (or (richiesta-cf-pit (x ?x) (y ?y)) (richiesta-cf-wumpus (x ?x) (y ?y)))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y))))

(defrule RAGIONAMENTO::crea-cella-sopra
   (declare (salience 25))
   (percept (x ?x) (y ?y) (h ?h))
   (test (< (- ?y 1) ?h))
   (test (>= (- ?y 1) 0))
   (not (cella (x ?x) (y =(- ?y 1))))
   =>
   (assert (cella (x ?x) (y (- ?y 1)))))

(defrule RAGIONAMENTO::crea-cella-sotto
   (declare (salience 25))
   (percept (x ?x) (y ?y) (h ?h))
   (test (< (+ ?y 1) ?h))
   (not (cella (x ?x) (y =(+ ?y 1))))
   =>
   (assert (cella (x ?x) (y (+ ?y 1)))))

(defrule RAGIONAMENTO::crea-cella-destra
   (declare (salience 25))
   (percept (x ?x) (y ?y) (w ?w))
   (test (< (+ ?x 1) ?w))
   (not (cella (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (cella (x (+ ?x 1)) (y ?y))))

(defrule RAGIONAMENTO::crea-cella-sinistra
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (test (>= (- ?x 1) 0))
   (not (cella (x =(- ?x 1)) (y ?y)))
   =>
   (assert (cella (x (- ?x 1)) (y ?y))))

(defrule RAGIONAMENTO::segnala-target-sicuro
   (cella (x ?x) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.0)) (cf-wumpus ?cw&:(<= ?cw 0.0)))
   (not (muro (x ?x) (y ?y)))
   (not (target-sicuro (x ?x) (y ?y)))
   =>
   (assert (target-sicuro (x ?x) (y ?y))))

(defrule RAGIONAMENTO::rimuovi-target-raggiunto
   ?t <- (target-sicuro (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (visitata TRUE))
   =>
   (retract ?t))

(defrule RAGIONAMENTO::rimuovi-target-muro
   (declare (salience 100))
   ?t <- (target-sicuro (x ?x) (y ?y))
   (muro (x ?x) (y ?y))
   =>
   (retract ?t)
   (printout t "   [x] Target annullato: muro in [" ?x "," ?y "]" crlf))

;; =========================================================
;; DECISIONE
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (percept (x ?x) (y ?y))
   (action (move ?dir))
   (not (intenzione-registrata))
   ?mem <- (memoria-azione)
   =>
   (modify ?mem (comando ?dir) (da-x ?x) (da-y ?y))
   (assert (intenzione-registrata)))

(defrule DECISIONE::prendi-oro
   (declare (salience 150))
   (not (action))
   (percept (glitter TRUE))
   ?s <- (stato-agente (oro-preso FALSE))
   =>
   (assert (action (move grab)))
   (modify ?s (oro-preso TRUE) (fase fuga))
   (printout t ">>> Oro trovato: parte la fuga." crlf))

(defrule DECISIONE::esci-vincitore
   (declare (salience 200))
   (not (action))
   (percept (x 0) (y 0))
   (stato-agente (oro-preso TRUE))
   =>
   (assert (action (move quit)))
   (printout t ">>> Vittoria: uscito con l'oro." crlf))

(defrule DECISIONE::fuga-verso-casa
   (declare (salience 140))
   (not (action))
   (stato-agente (fase fuga))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))))
   (if (= ?px (- ?x 1)) then (assert (action (move left))))
   (if (= ?py (- ?y 1)) then (assert (action (move up))))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))))

(defrule DECISIONE::vai-sicuro-destra
   (declare (salience 50))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x =(+ ?x 1)) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.6)) (cf-wumpus ?cw&:(<= ?cw 0.6)))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (action (move right)))
   (printout t "-> CF semplice: vado a DESTRA." crlf))

(defrule DECISIONE::vai-sicuro-sinistra
   (declare (salience 50))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x =(- ?x 1)) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.6)) (cf-wumpus ?cw&:(<= ?cw 0.6)))
   (not (muro (x =(- ?x 1)) (y ?y)))
   =>
   (assert (action (move left)))
   (printout t "-> CF semplice: vado a SINISTRA." crlf))

(defrule DECISIONE::vai-sicuro-su
   (declare (salience 50))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x ?x) (y =(- ?y 1)))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.6)) (cf-wumpus ?cw&:(<= ?cw 0.6)))
   (not (muro (x ?x) (y =(- ?y 1))))
   =>
   (assert (action (move up)))
   (printout t "-> CF semplice: vado in ALTO." crlf))

(defrule DECISIONE::vai-sicuro-giu
   (declare (salience 60))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x ?x) (y =(+ ?y 1)))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.6)) (cf-wumpus ?cw&:(<= ?cw 0.6)))
   (not (muro (x ?x) (y =(+ ?y 1))))
   =>
   (assert (action (move down)))
   (printout t "-> CF semplice: vado in BASSO." crlf))

(defrule DECISIONE::scelta-prudente-destra
   (declare (salience 35))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.3)) (cf-wumpus ?cw&:(<= ?cw 0.3)))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (action (move right)))
   (printout t "!!! Scelta prudente a DESTRA." crlf))

(defrule DECISIONE::scelta-prudente-sinistra
   (declare (salience 35))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.3)) (cf-wumpus ?cw&:(<= ?cw 0.3)))
   (not (muro (x =(- ?x 1)) (y ?y)))
   =>
   (assert (action (move left)))
   (printout t "!!! Scelta prudente a SINISTRA." crlf))

(defrule DECISIONE::scelta-prudente-su
   (declare (salience 35))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.3)) (cf-wumpus ?cw&:(<= ?cw 0.3)))
   (not (muro (x ?x) (y =(- ?y 1))))
   =>
   (assert (action (move up)))
   (printout t "!!! Scelta prudente in ALTO." crlf))

(defrule DECISIONE::scelta-prudente-giu
   (declare (salience 35))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.3)) (cf-wumpus ?cw&:(<= ?cw 0.3)))
   (not (muro (x ?x) (y =(+ ?y 1))))
   =>
   (assert (action (move down)))
   (printout t "!!! Scelta prudente in BASSO." crlf))

(defrule DECISIONE::ritirata-o-fuga
   (declare (salience 20))
   (not (action))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))))
   (if (= ?px (- ?x 1)) then (assert (action (move left))))
   (if (= ?py (- ?y 1)) then (assert (action (move up))))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))))

(defrule DECISIONE::rinuncia
   (declare (salience 10))
   (not (action))
   (percept (x 0) (y 0))
   (stato-agente (fase esplorazione))
   =>
   (assert (action (move quit)))
   (printout t "!!! Nessuna mossa utile: rinuncio." crlf))
