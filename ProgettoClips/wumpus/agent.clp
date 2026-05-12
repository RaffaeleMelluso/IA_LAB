;; =========================================================
;; MODULO MAIN: Strutture Dati e Controllo
;; =========================================================
(defmodule MAIN (export ?ALL))

;; --- Dati del Simulatore ---
(deftemplate percept
   (slot x) (slot y)
   (slot steps)      
   (slot breeze) (slot stench) (slot glitter)
   (slot energy)
)
(deftemplate counter (slot step))
(deftemplate action (slot move))

;; --- Mappa Mentale dell'Agente ---
(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot da-x (default -1))      
   (slot da-y (default -1))      
   (slot cf-pit (default 0.0))    ; CF per il pozzo
   (slot cf-wumpus (default 0.0)) ; CF per il Wumpus
)

(deftemplate muro (slot x) (slot y))
(deftemplate memoria-azione (slot step) (slot comando) (slot da-x) (slot da-y))
(deftemplate stato-agente (slot fase (default esplorazione)) (slot oro-preso (default FALSE)))
(deftemplate scommessa-fatta (slot x) (slot y))

;; --- Variabili per i calcoli logici ---
(deftemplate valutata-no-brezza (slot x) (slot y))
(deftemplate valutata-brezza (slot x) (slot y))
(deftemplate valutata-no-puzza (slot x) (slot y))
(deftemplate valutata-puzza (slot x) (slot y))
(deftemplate richiesta-cf-pit (slot x) (slot y) (slot val))
(deftemplate richiesta-cf-wumpus (slot x) (slot y) (slot val))

(deffacts initial
   (counter (step 0))
   (stato-agente (fase esplorazione) (oro-preso FALSE))
)

(defrule MAIN::deliberate
   (declare (salience -10))
   (counter (step ?step))
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE)
)

;; =========================================================
;; MODULO PERCEZIONE: Aggiornamento Spaziale
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

(defrule PERCEZIONE::memorizza-partenza
   (percept (x 0) (y 0))
   (not (cella (x 0) (y 0)))
   =>
   (assert (cella (x 0) (y 0) (visitata TRUE) (da-x 0) (da-y 0) (cf-pit -1.0) (cf-wumpus -1.0)))
)

(defrule PERCEZIONE::aggiorna-cella-attuale
   (percept (x ?x) (y ?y))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   ?mem <- (memoria-azione (da-x ?px) (da-y ?py))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py) (cf-pit -1.0) (cf-wumpus -1.0))
)

(defrule PERCEZIONE::rileva-muro
   (percept (x ?x) (y ?y))
   ?mem <- (memoria-azione (comando ?c) (da-x ?vx) (da-y ?vy))
   (test (and (= ?x ?vx) (= ?y ?vy))) 
   (test (or (eq ?c "up") (eq ?c "down") (eq ?c "left") (eq ?c "right")))
   =>
   (retract ?mem)
   (bind ?mx ?x) (bind ?my ?y)
   (if (eq ?c "right") then (bind ?mx (+ ?x 1)))
   (if (eq ?c "left") then (bind ?mx (- ?x 1)))
   (if (eq ?c "up") then (bind ?my (- ?y 1)))
   (if (eq ?c "down") then (bind ?my (+ ?y 1)))
   (assert (muro (x ?mx) (y ?my)))
)

(defrule PERCEZIONE::movimento-riuscito
   (percept (x ?x) (y ?y))
   ?mem <- (memoria-azione (da-x ?vx) (da-y ?vy))
   (test (or (neq ?x ?vx) (neq ?y ?vy)))
   =>
   (retract ?mem)
)

;; =========================================================
;; MODULO RAGIONAMENTO: Valutazione dei Pericoli
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

;; --- DEDUZIONE POZZI ---
(defrule RAGIONAMENTO::analizza-assenza-brezza
   (percept (x ?x) (y ?y) (breeze FALSE))
   (not (valutata-no-brezza (x ?x) (y ?y)))
   =>
   (assert (valutata-no-brezza (x ?x) (y ?y)))
   (assert (richiesta-cf-pit (+ ?x 1) ?y -1.0))
   (assert (richiesta-cf-pit (- ?x 1) ?y -1.0))
   (assert (richiesta-cf-pit ?x (+ ?y 1) -1.0))
   (assert (richiesta-cf-pit ?x (- ?y 1) -1.0))
)

(defrule RAGIONAMENTO::analizza-presenza-brezza
   (percept (x ?x) (y ?y) (breeze TRUE))
   (not (valutata-brezza (x ?x) (y ?y)))
   =>
   (assert (valutata-brezza (x ?x) (y ?y)))
   (assert (richiesta-cf-pit (+ ?x 1) ?y 0.4))
   (assert (richiesta-cf-pit (- ?x 1) ?y 0.4))
   (assert (richiesta-cf-pit ?x (+ ?y 1) 0.4))
   (assert (richiesta-cf-pit ?x (- ?y 1) 0.4))
)

;; --- DEDUZIONE WUMPUS ---
(defrule RAGIONAMENTO::analizza-assenza-puzza
   (percept (x ?x) (y ?y) (stench FALSE))
   (not (valutata-no-puzza (x ?x) (y ?y)))
   =>
   (assert (valutata-no-puzza (x ?x) (y ?y)))
   (assert (richiesta-cf-wumpus (+ ?x 1) ?y -1.0))
   (assert (richiesta-cf-wumpus (- ?x 1) ?y -1.0))
   (assert (richiesta-cf-wumpus ?x (+ ?y 1) -1.0))
   (assert (richiesta-cf-wumpus ?x (- ?y 1) -1.0))
)

(defrule RAGIONAMENTO::analizza-presenza-puzza
   (percept (x ?x) (y ?y) (stench TRUE))
   (not (valutata-puzza (x ?x) (y ?y)))
   =>
   (assert (valutata-puzza (x ?x) (y ?y)))
   (assert (richiesta-cf-wumpus (+ ?x 1) ?y 0.4))
   (assert (richiesta-cf-wumpus (- ?x 1) ?y 0.4))
   (assert (richiesta-cf-wumpus ?x (+ ?y 1) 0.4))
   (assert (richiesta-cf-wumpus ?x (- ?y 1) 0.4))
)

;; --- CREAZIONE CELLE ---
(defrule RAGIONAMENTO::crea-cella-per-cf-pit
   (declare (salience 50))
   (richiesta-cf-pit (x ?x) (y ?y))
   (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y)))
)
(defrule RAGIONAMENTO::crea-cella-per-cf-wumpus
   (declare (salience 50))
   (richiesta-cf-wumpus (x ?x) (y ?y))
   (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y)))
)

;; --- APPLICAZIONE CF ---
(defrule RAGIONAMENTO::applica-cf-pit-sicuro
   ?req <- (richiesta-cf-pit (x ?x) (y ?y) (val -1.0))
   ?c <- (cella (x ?x) (y ?y))
   => (retract ?req) (modify ?c (cf-pit -1.0))
)
(defrule RAGIONAMENTO::applica-cf-wumpus-sicuro
   ?req <- (richiesta-cf-wumpus (x ?x) (y ?y) (val -1.0))
   ?c <- (cella (x ?x) (y ?y))
   => (retract ?req) (modify ?c (cf-wumpus -1.0))
)

(defrule RAGIONAMENTO::combina-cf-pit
   ?req <- (richiesta-cf-pit (x ?x) (y ?y) (val ?nuovo))
   (test (> ?nuovo 0.0))
   ?c <- (cella (x ?x) (y ?y) (cf-pit ?vecchio))
   (test (>= ?vecchio 0.0))
   =>
   (retract ?req)
   (bind ?combinato (- (+ ?vecchio ?nuovo) (* ?vecchio ?nuovo)))
   (modify ?c (cf-pit ?combinato))
)
(defrule RAGIONAMENTO::combina-cf-wumpus
   ?req <- (richiesta-cf-wumpus (x ?x) (y ?y) (val ?nuovo))
   (test (> ?nuovo 0.0))
   ?c <- (cella (x ?x) (y ?y) (cf-wumpus ?vecchio))
   (test (>= ?vecchio 0.0))
   =>
   (retract ?req)
   (bind ?combinato (- (+ ?vecchio ?nuovo) (* ?vecchio ?nuovo)))
   (modify ?c (cf-wumpus ?combinato))
)

(defrule RAGIONAMENTO::pulisci-richieste-residue-1
   (declare (salience -10)) ?req <- (richiesta-cf-pit) => (retract ?req))
(defrule RAGIONAMENTO::pulisci-richieste-residue-2
   (declare (salience -10)) ?req <- (richiesta-cf-wumpus) => (retract ?req))

;; =========================================================
;; MODULO DECISIONE: Scegliere l'Azione Migliore
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (counter (step ?s)) (percept (x ?x) (y ?y)) (action (move ?dir))
   (test (or (eq ?dir "up") (eq ?dir "down") (eq ?dir "left") (eq ?dir "right")))
   (not (memoria-azione (step ?s)))
   =>
   (assert (memoria-azione (step ?s) (comando ?dir) (da-x ?x) (da-y ?y)))
)

;; --- PRIORITÀ MASSIME (VITA O MORTE) ---
(defrule DECISIONE::game-over-energia
   (declare (salience 200))
   (percept (energy ?e) (x ?x) (y ?y))
   (test (<= ?e 0)) (test (or (neq ?x 0) (neq ?y 0)))
   =>
)

(defrule DECISIONE::esci-vincitore
   (declare (salience 150))
   (percept (x 0) (y 0))
   (stato-agente (fase fuga))
   =>
   (assert (action (move "quit")))
)

(defrule DECISIONE::prendi-oro
   (declare (salience 100))
   (percept (glitter TRUE))
   ?s <- (stato-agente (oro-preso FALSE))
   =>
   (assert (action (move "grab")))
   (modify ?s (oro-preso TRUE) (fase fuga))
)

;; --- PRIORITÀ 90: SCOMMESSA SUI POZZI (Solo se alto CF PIT) ---
(defrule DECISIONE::scommetti-pozzo-est
   (declare (salience 90)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (cf-pit ?cf)) (test (> ?cf 0.6)) (not (scommessa-fatta (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move "pit-east"))) (assert (scommessa-fatta (x =(+ ?x 1)) (y ?y))))

(defrule DECISIONE::scommetti-pozzo-ovest
   (declare (salience 90)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (cf-pit ?cf)) (test (> ?cf 0.6)) (not (scommessa-fatta (x =(- ?x 1)) (y ?y)))
   => (assert (action (move "pit-west"))) (assert (scommessa-fatta (x =(- ?x 1)) (y ?y))))

(defrule DECISIONE::scommetti-pozzo-sud
   (declare (salience 90)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (cf-pit ?cf)) (test (> ?cf 0.6)) (not (scommessa-fatta (x ?x) (y =(+ ?y 1))))
   => (assert (action (move "pit-south"))) (assert (scommessa-fatta (x ?x) (y =(+ ?y 1)))))

(defrule DECISIONE::scommetti-pozzo-nord
   (declare (salience 90)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (cf-pit ?cf)) (test (> ?cf 0.6)) (not (scommessa-fatta (x ?x) (y =(- ?y 1))))
   => (assert (action (move "pit-north"))) (assert (scommessa-fatta (x ?x) (y =(- ?y 1)))))

;; --- PRIORITÀ 80: FUGA VERSO CASA ---
(defrule DECISIONE::fuga-verso-casa
   (declare (salience 80))
   (stato-agente (fase fuga))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move "right"))))
   (if (= ?px (- ?x 1)) then (assert (action (move "left"))))
   (if (= ?py (- ?y 1)) then (assert (action (move "up"))))
   (if (= ?py (+ ?y 1)) then (assert (action (move "down"))))
)

;; --- PRIORITÀ 50: ESPLORAZIONE SICURA (Controlla SIA pit SIA wumpus) ---
(defrule DECISIONE::esplora-destra-sicura
   (declare (salience 50)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x =(+ ?x 1)) (y ?y))) => (assert (action (move "right"))))

(defrule DECISIONE::esplora-sinistra-sicura
   (declare (salience 50)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x =(- ?x 1)) (y ?y))) => (assert (action (move "left"))))

(defrule DECISIONE::esplora-su-sicura
   (declare (salience 50)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x ?x) (y =(- ?y 1)))) => (assert (action (move "up"))))

(defrule DECISIONE::esplora-giu-sicura
   (declare (salience 50)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit -1.0) (cf-wumpus -1.0))
   (not (muro (x ?x) (y =(+ ?y 1)))) => (assert (action (move "down"))))

;; --- PRIORITÀ 40: RISCHIO CALCOLATO (Deve essere < 0.5 per ENTRAMBI i pericoli) ---
(defrule DECISIONE::esplora-destra-rischio
   (declare (salience 40)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5))
   (not (muro (x =(+ ?x 1)) (y ?y))) => (assert (action (move "right"))))

(defrule DECISIONE::esplora-sinistra-rischio
   (declare (salience 40)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5))
   (not (muro (x =(- ?x 1)) (y ?y))) => (assert (action (move "left"))))

(defrule DECISIONE::esplora-su-rischio
   (declare (salience 40)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5))
   (not (muro (x ?x) (y =(- ?y 1)))) => (assert (action (move "up"))))

(defrule DECISIONE::esplora-giu-rischio
   (declare (salience 40)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (< ?cp 0.5)) (test (< ?cw 0.5))
   (not (muro (x ?x) (y =(+ ?y 1)))) => (assert (action (move "down"))))

;; --- PRIORITÀ 25: BACKTRACK ---
(defrule DECISIONE::backtrack-esplorazione
   (declare (salience 25))
   (stato-agente (fase esplorazione))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move "right"))))
   (if (= ?px (- ?x 1)) then (assert (action (move "left"))))
   (if (= ?py (- ?y 1)) then (assert (action (move "up"))))
   (if (= ?py (+ ?y 1)) then (assert (action (move "down"))))
)

;; --- PRIORITÀ 10: RINUNCIA ---
(defrule DECISIONE::rinuncia-esci
   (declare (salience 10))
   (percept (x 0) (y 0))
   (stato-agente (fase esplorazione))
   =>
   (assert (action (move "quit")))
)