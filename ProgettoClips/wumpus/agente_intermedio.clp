
;; =========================================================
;; AGENTE INTERMEDIO
;; Questo agente usa un ragionamento a rischio graduale invece di una semplice scelta sicuro o pericoloso
;; Ogni segnale percepito aggiorna delle credenze numeriche che rappresentano quanto una cella possa essere rischiosa
;; Nella memoria tiene il percorso già fatto i muri scoperti i target sicuri e i coefficienti di rischio associati alle ipotesi
;; Le precauzioni servono a non fidarsi di un solo segnale a ridurre i falsi positivi e a evitare inversioni immediate che fanno perdere tempo
;; Prima prova a raggiungere un target sicuro poi valuta mosse prudenti e se non ha alternative torna indietro seguendo la memoria del percorso
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

;; Elimina i percept meno recenti e conserva solo quello piu nuovo
(defrule MAIN::pulisci-percept-vecchi
   (declare (salience 10000))
   ?p1 <- (percept (steps ?s1))
   ?p2 <- (percept (steps ?s2&:(< ?s2 ?s1)))
   =>
   (retract ?p2))

;; Avvia il ciclo cognitivo quando arriva un percept nuovo
(defrule MAIN::deliberate
   (declare (salience -10))
   (percept)
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE))

;; =========================================================
;; PERCEZIONE
;; Aggiorna il mondo interno e riconosce i muri incontrati durante i tentativi di movimento
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

;; Elimina l azione della iterazione precedente prima di scegliere la prossima
(defrule PERCEZIONE::pulisci-azione
   (declare (salience 2000)) ?a <- (action) => (retract ?a))

;; Elimina la registrazione dell intenzione precedente
(defrule PERCEZIONE::pulisci-registrazione
   (declare (salience 2000)) ?r <- (intenzione-registrata) => (retract ?r))

;; Segna come visitata la cella corrente e collega il percorso al punto precedente
(defrule PERCEZIONE::aggiorna-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py)))

;; Crea una cella nuova gia visitata quando si entra in una posizione mai registrata
(defrule PERCEZIONE::crea-cella-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py) (cf-pit -1.0) (cf-wumpus -1.0) (esaurita FALSE))))

;; Registra il muro fisico quando il movimento previsto non sposta l agente
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
;; Traduce brezza e puzza in ipotesi quantitative e costruisce i target sicuri
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

;; Analizza i segnali della cella corrente e aggiorna le ipotesi sui vicini
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

;; Aggiorna il coefficiente di rischio per il pozzo quando arriva una richiesta
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

;; Aggiorna il coefficiente di rischio per il wumpus quando arriva una richiesta
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

;; Crea la cella necessaria prima di applicare un coefficiente di rischio
(defrule RAGIONAMENTO::crea-cella-per-cf
   (declare (salience 5))
   (or (richiesta-cf-pit (x ?x) (y ?y)) (richiesta-cf-wumpus (x ?x) (y ?y)))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y))))

;; Crea la cella sopra quando rientra nei limiti della mappa
(defrule RAGIONAMENTO::crea-cella-sopra
   (declare (salience 25))
   (percept (x ?x) (y ?y) (h ?h))
   (test (< (- ?y 1) ?h))
   (test (>= (- ?y 1) 0))
   (not (cella (x ?x) (y =(- ?y 1))))
   =>
   (assert (cella (x ?x) (y (- ?y 1)))))

;; Crea la cella sotto quando rientra nei limiti della mappa
(defrule RAGIONAMENTO::crea-cella-sotto
   (declare (salience 25))
   (percept (x ?x) (y ?y) (h ?h))
   (test (< (+ ?y 1) ?h))
   (not (cella (x ?x) (y =(+ ?y 1))))
   =>
   (assert (cella (x ?x) (y (+ ?y 1)))))

;; Crea la cella a destra quando rientra nei limiti della mappa
(defrule RAGIONAMENTO::crea-cella-destra
   (declare (salience 25))
   (percept (x ?x) (y ?y) (w ?w))
   (test (< (+ ?x 1) ?w))
   (not (cella (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (cella (x (+ ?x 1)) (y ?y))))

;; Crea la cella a sinistra quando rientra nei limiti della mappa
(defrule RAGIONAMENTO::crea-cella-sinistra
   (declare (salience 25))
   (percept (x ?x) (y ?y))
   (test (>= (- ?x 1) 0))
   (not (cella (x =(- ?x 1)) (y ?y)))
   =>
   (assert (cella (x (- ?x 1)) (y ?y))))

;; Segnala come target sicuro ogni cella non visitata con rischio nullo
(defrule RAGIONAMENTO::segnala-target-sicuro
   (cella (x ?x) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.0)) (cf-wumpus ?cw&:(<= ?cw 0.0)))
   (not (muro (x ?x) (y ?y)))
   (not (target-sicuro (x ?x) (y ?y)))
   =>
   (assert (target-sicuro (x ?x) (y ?y))))

;; Rimuove un target quando quella cella e stata raggiunta
(defrule RAGIONAMENTO::rimuovi-target-raggiunto
   ?t <- (target-sicuro (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (visitata TRUE))
   =>
   (retract ?t))

;; Rimuove un target quando si scopre che corrisponde a un muro
(defrule RAGIONAMENTO::rimuovi-target-muro
   (declare (salience 100))
   ?t <- (target-sicuro (x ?x) (y ?y))
   (muro (x ?x) (y ?y))
   =>
   (retract ?t)
   (printout t "   [x] Target annullato: muro in [" ?x "," ?y "]" crlf))

;; =========================================================
;; DECISIONE
;; Sceglie tra fuga ritorno al percorso target sicuri e mosse prudenti
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

;; Registra la direzione scelta per ricostruire il percorso in seguito
(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (percept (x ?x) (y ?y))
   (action (move ?dir))
   (not (intenzione-registrata))
   ?mem <- (memoria-azione)
   =>
   (modify ?mem (comando ?dir) (da-x ?x) (da-y ?y))
   (assert (intenzione-registrata)))

;; Se compare l oro lo prende e cambia subito fase in fuga
(defrule DECISIONE::prendi-oro
   (declare (salience 150))
   (not (action))
   (percept (glitter TRUE))
   ?s <- (stato-agente (oro-preso FALSE))
   =>
   (assert (action (move grab)))
   (modify ?s (oro-preso TRUE) (fase fuga))
   (printout t ">>> Oro trovato: parte la fuga." crlf))

;; Se con l oro rientra all origine termina la missione
(defrule DECISIONE::esci-vincitore
   (declare (salience 200))
   (not (action))
   (percept (x 0) (y 0))
   (stato-agente (oro-preso TRUE))
   =>
   (assert (action (move quit)))
   (printout t ">>> Vittoria: uscito con l'oro." crlf))

;; Durante la fuga usa la cella precedente come guida per tornare indietro
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

;; Usa un target sicuro a destra solo se la cella e ancora non visitata e con rischio basso
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

;; Usa un target sicuro a sinistra solo se la cella e ancora non visitata e con rischio basso
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

;; Usa un target sicuro sopra solo se la cella e ancora non visitata e con rischio basso
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

;; Usa un target sicuro sotto solo se la cella e ancora non visitata e con rischio basso
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

;; Scelta prudente a destra quando il rischio e molto basso e non esiste un target migliore
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

;; Scelta prudente a sinistra quando il rischio e molto basso e non esiste un target migliore
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

;; Scelta prudente verso l alto quando il rischio e molto basso e non esiste un target migliore
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

;; Scelta prudente verso il basso quando il rischio e molto basso e non esiste un target migliore
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

;; Se non ci sono mosse migliori torna alla cella precedente della memoria
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

;; Se l agente e all origine e non ha alternative utili rinuncia
(defrule DECISIONE::rinuncia
   (declare (salience 10))
   (not (action))
   (percept (x 0) (y 0))
   (stato-agente (fase esplorazione))
   =>
   (assert (action (move quit)))
   (printout t "!!! Nessuna mossa utile: rinuncio." crlf))
