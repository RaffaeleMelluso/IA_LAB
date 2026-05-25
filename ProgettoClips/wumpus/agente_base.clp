;; =========================================================
;; AGENTE BASE: esplorazione prudente e backtracking semplice
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept (slot x) (slot y) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy))
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
(deftemplate target-sicuro (slot x) (slot y))

(deffacts initial
   (counter (step 0))
   (stato-agente (oro-preso FALSE) (fase esplorazione))
   (cella (x 0) (y 0) (visitata TRUE) (da-x 0) (da-y 0))
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

(defrule PERCEZIONE::aggiorna-cella
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py)))

(defrule PERCEZIONE::crea-cella
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py))))

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
   (printout t "   !! Muro rilevato in [" ?mx "," ?my "]" crlf))

;; =========================================================
;; RAGIONAMENTO
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

(defrule RAGIONAMENTO::analizza-ambiente
   (percept (x ?x) (y ?y) (breeze ?b) (stench ?s))
   =>
   (if (and (eq ?b FALSE) (eq ?s FALSE)) then
      (progn
         (assert (target-sicuro (x (+ ?x 1)) (y ?y)))
         (assert (target-sicuro (x (- ?x 1)) (y ?y)))
         (assert (target-sicuro (x ?x) (y (+ ?y 1))))
         (assert (target-sicuro (x ?x) (y (- ?y 1))))
         (printout t "   [+] Nessun segnale: i vicini sono sicuri." crlf))
      else
      (printout t "   [i] Segnale presente: non esploro alla cieca." crlf)))

(defrule RAGIONAMENTO::crea-cella-vicino-destra
   (percept (x ?x) (y ?y))
   (not (cella (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (cella (x (+ ?x 1)) (y ?y))))

(defrule RAGIONAMENTO::crea-cella-vicino-sinistra
   (percept (x ?x) (y ?y))
   (not (cella (x =(- ?x 1)) (y ?y)))
   =>
   (assert (cella (x (- ?x 1)) (y ?y))))

(defrule RAGIONAMENTO::crea-cella-vicino-su
   (percept (x ?x) (y ?y))
   (not (cella (x ?x) (y =(- ?y 1))))
   =>
   (assert (cella (x ?x) (y (- ?y 1)))))

(defrule RAGIONAMENTO::crea-cella-vicino-giu
   (percept (x ?x) (y ?y))
   (not (cella (x ?x) (y =(+ ?y 1))))
   =>
   (assert (cella (x ?x) (y (+ ?y 1)))))

(defrule RAGIONAMENTO::crea-target-sicuro
   (cella (x ?x) (y ?y) (visitata FALSE))
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

(defrule DECISIONE::vai-destra
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x =(+ ?x 1)) (y ?y))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (action (move right)))
   (printout t "-> GPS base: vado a DESTRA verso un obiettivo sicuro." crlf))

(defrule DECISIONE::vai-sinistra
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x =(- ?x 1)) (y ?y))
   (not (muro (x =(- ?x 1)) (y ?y)))
   =>
   (assert (action (move left)))
   (printout t "-> GPS base: vado a SINISTRA verso un obiettivo sicuro." crlf))

(defrule DECISIONE::vai-su
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x ?x) (y =(- ?y 1)))
   (not (muro (x ?x) (y =(- ?y 1))))
   =>
   (assert (action (move up)))
   (printout t "-> GPS base: vado in ALTO verso un obiettivo sicuro." crlf))

(defrule DECISIONE::vai-giu
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x ?x) (y =(+ ?y 1)))
   (not (muro (x ?x) (y =(+ ?y 1))))
   =>
   (assert (action (move down)))
   (printout t "-> GPS base: vado in BASSO verso un obiettivo sicuro." crlf))

(defrule DECISIONE::cauto-destra
   (declare (salience 32))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (action (move right)))
   (printout t "!!! Scelta cauta a DESTRA." crlf))

(defrule DECISIONE::cauto-sinistra
   (declare (salience 32))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE))
   (not (muro (x =(- ?x 1)) (y ?y)))
   =>
   (assert (action (move left)))
   (printout t "!!! Scelta cauta a SINISTRA." crlf))

(defrule DECISIONE::cauto-su
   (declare (salience 32))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE))
   (not (muro (x ?x) (y =(- ?y 1))))
   =>
   (assert (action (move up)))
   (printout t "!!! Scelta cauta in ALTO." crlf))

(defrule DECISIONE::cauto-giu
   (declare (salience 32))
   (not (action))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (not (target-sicuro))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE))
   (not (muro (x ?x) (y =(+ ?y 1))))
   =>
   (assert (action (move down)))
   (printout t "!!! Scelta cauta in BASSO." crlf))

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
   (printout t "!!! Bloccato all'origine: rinuncio." crlf))
