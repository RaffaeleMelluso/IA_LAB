; Agente Wumpus - scheletro modulare
; File: agent.clp
; Commenti in italiano e nomi estensivi

(defmodule PERCEPTS (export ?ALL))

; template per il percept fornito dal simulatore
(deftemplate percept
   (slot x)
   (slot y)
   (slot steps)
   (slot breeze)
   (slot stench)
   (slot glitter)
   (slot energy))

; template per il contatore di step (unico fatto aggiornato dal simulatore)
(deftemplate counter (slot step))

(defmodule MEMORIA (export ?ALL))

; template per memorizzare celle visitate
(deftemplate cella-visitata (slot x) (slot y))

; template per ipotesi su pozzi e wumpus con confidence semplice
(deftemplate ipotesi-pit (slot x) (slot y) (slot cf))
(deftemplate ipotesi-wumpus (slot x) (slot y) (slot cf))

; template per informazioni su oro e stato eroe
(deftemplate oro-raccolto (slot trovati))
(deftemplate stato-eroe (slot x) (slot y) (slot energia) (slot ha-oro))

; template per scegliere la modalita' dell'agente
(deftemplate modalita (slot nome))

; template per celle dichiarate sicure
(deftemplate cella-sicura (slot x) (slot y))

; template per evitare di reinviare la stessa azione sullo stesso step
(deftemplate azione-inviata (slot step))

; template per evitare di rieseguire inferenze multiple sullo stesso step
(deftemplate breeze-gia-gestita (slot step))
(deftemplate stench-gia-gestita (slot step))

; template per azione da eseguire
(deftemplate action (slot move))
 
; proposta di mossa generata per step (tx,ty sono target coords)
(deftemplate proposta (slot dir) (slot tx) (slot ty) (slot step))

; dimensione della mappa (inserita dal simulatore all'avvio)
(deftemplate map-dims (slot width) (slot height))

(defmodule DECISION (import PERCEPTS ?ALL) (import MEMORIA ?ALL))

; Regole di decisione minimal: due strategie a confronto

; STRATEGIA INGENUA: esplora a caso evitando muri conosciuti
(defrule strategia-ingenua-seleziona-azione
   ?p <- (percept (x ?x) (y ?y) (energy ?e))
   (not (action))
   =>
   ; azione di esempio: tentare di muoversi a destra
   (assert (action (move right)))
)

; STRATEGIA INFERENZIALE: placeholder per regole che usano breeze/stench per inferire
; Le regole specifiche sono definite sotto nel modulo UTIL

(defmodule ACTIONS (import PERCEPTS ?ALL) (import MEMORIA ?ALL))

; regole che trasformano la scelta in fatto riconosciuto dal simulatore
(defrule invia-azione-simulatore
   (percept (steps ?s))
   ?a <- (action (move ?m))
   (not (azione-inviata (step ?s)))
   =>
   ; il simulatore si aspetta un fatto (action (move ?label))
   ; questa regola lo stampa una sola volta per step
   (assert (azione-inviata (step ?s)))
   (printout t "[AGENTE] Invio azione: " ?m crlf)
)

; utilita` e regole ausiliarie
(defmodule UTIL (import PERCEPTS ?ALL) (import MEMORIA ?ALL) (export ?ALL))

; in questa prima versione evitiamo funzioni helper non usate

; -----------------------------
; Modalita' agente e strategie: ingenua vs inferenziale
; -----------------------------

; default: modalita` inferenziale (puoi cambiare a ingenua)
(defrule assert-modalita-di-default
   (not (modalita))
   =>
   (assert (modalita (nome inferenziale)))
)

; -----------------
; Agente ingenuo: comportamento semplice
; - se glitter: grab
; - altrimenti prova right, poi down, poi left, poi up (ordine fisso)
; -----------------
(defrule ingenuo-grab-se-glitter
   ?p <- (percept (glitter TRUE))
   ?m <- (modalita (nome ingenua))
   (not (action))
   =>
   (assert (action (move grab)))
   (printout t "[INGENUO] Glitter: eseguo grab" crlf)
)

(defrule ingenuo-move-right
   ?p <- (percept (breeze ?b) (stench ?s))
   ?m <- (modalita (nome ingenua))
   (not (action))
   =>
   (assert (action (move right)))
   (printout t "[INGENUO] Muovo right" crlf)
)

; -----------------
; Agente inferenziale: usa le percezioni per decisioni piu` caute
; - se glitter: grab
; - se ha-oro e in (0,0): quit
; - se breeze o stench TRUE: evita muovere verso direzioni rischiose (sceglie left)
; - se breeze e stench FALSE: muove right (approccio esplorativo)
; -----------------
(defrule inferenziale-fallback-pericolo
   (declare (salience 100))
   ?p <- (percept (breeze TRUE|FALSE) (stench TRUE|FALSE) (glitter FALSE))
   (test (or (eq (fact-slot-value ?p breeze) TRUE) (eq (fact-slot-value ?p stench) TRUE)))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move left)))
)

(defrule inferenziale-fallback-bordo-alto
   (declare (salience 95))
   (percept (y 0) (breeze FALSE) (stench FALSE) (glitter FALSE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move down)))
)

(defrule inferenziale-fallback-sicuro-mod0
   (declare (salience 90))
   (percept (steps ?t) (y ?y&:(> ?y 0)) (breeze FALSE) (stench FALSE) (glitter FALSE))
   (test (= (mod ?t 3) 0))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move down)))
)

(defrule inferenziale-fallback-sicuro-mod1
   (declare (salience 90))
   (percept (steps ?t) (y ?y&:(> ?y 0)) (breeze FALSE) (stench FALSE) (glitter FALSE))
   (test (= (mod ?t 3) 1))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move right)))
)

(defrule inferenziale-fallback-sicuro-mod2
   (declare (salience 90))
   (percept (steps ?t) (y ?y&:(> ?y 0)) (breeze FALSE) (stench FALSE) (glitter FALSE))
   (test (= (mod ?t 3) 2))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move left)))
)

(defrule inferenziale-grab-se-glitter
   ?p <- (percept (glitter TRUE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move grab)))
   (printout t "[INFERENZIALE] Glitter: eseguo grab" crlf)
)

(defrule inferenziale-quit-se-alla-partenza-con-oro
   ?st <- (stato-eroe (x 0) (y 0) (ha-oro TRUE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move quit)))
   (printout t "[INFERENZIALE] Ho l'oro e sono a (0,0): esco" crlf)
)

(defrule inferenziale-evita-se-pericoli
   ?p <- (percept (breeze TRUE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move left)))
   (printout t "[INFERENZIALE] Breeze TRUE: evito, muovo left" crlf)
)

(defrule inferenziale-evita-se-stench
   ?p <- (percept (stench TRUE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move left)))
   (printout t "[INFERENZIALE] Stench TRUE: evito, muovo left" crlf)
)

(defrule inferenziale-move-esplora-down-da-bordo
   ?p <- (percept (y 0) (breeze FALSE) (stench FALSE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   ; vicino al bordo superiore conviene prima scendere per evitare stalli su muri laterali
   (assert (action (move down)))
   (printout t "[INFERENZIALE] Nessun pericolo e y=0: esploro down" crlf)
)

(defrule inferenziale-move-esplora-se-sicuro
   ?p <- (percept (y ?y&:(> ?y 0)) (breeze FALSE) (stench FALSE))
   ?m <- (modalita (nome inferenziale))
   (not (action))
   =>
   (assert (action (move right)))
   (printout t "[INFERENZIALE] Nessun pericolo percepito: esploro right" crlf)
)

;; --- Proporre mosse verso celle adiacenti (una volta per step) ---
(defrule propose-neighbors
   (declare (salience 80))
   ?p <- (percept (x ?x) (y ?y) (steps ?s))
   (not (proposta (step ?s)))
   =>
   (bind ?r (+ ?x 1)) (bind ?l (- ?x 1)) (bind ?u (- ?y 1)) (bind ?d (+ ?y 1))
   (assert (proposta (dir right) (tx ?r) (ty ?y) (step ?s)))
   (assert (proposta (dir down)  (tx ?x) (ty ?d) (step ?s)))
   (assert (proposta (dir left)  (tx ?l) (ty ?y) (step ?s)))
   (assert (proposta (dir up)    (tx ?x) (ty ?u) (step ?s)))
)

;; --- Rimuove proposte vecchie quando cambia lo step ---
(defrule clear-old-proposte
   (declare (salience 5))
   ?p <- (percept (steps ?s))
   ?old <- (proposta (step ?oldStep&:(<> ?oldStep ?s)))
   =>
   (retract ?old)
)

;; --- Scegliere proposte verso celle non ancora visitate (priorita`: right, down, left, up) ---
(defrule choose-proposta-right
   (declare (salience 70))
   ?prop <- (proposta (dir right) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move right)))
)

;; preferisce celle sicure non visitate (maggiore priorita')
(defrule choose-proposta-right-safe
   (declare (salience 75))
   ?prop <- (proposta (dir right) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (cella-sicura (x ?tx) (y ?ty))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move right)))
)

(defrule choose-proposta-down
   (declare (salience 69))
   ?prop <- (proposta (dir down) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move down)))
)

;; preferisce celle sicure non visitate (down)
(defrule choose-proposta-down-safe
   (declare (salience 74))
   ?prop <- (proposta (dir down) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (cella-sicura (x ?tx) (y ?ty))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move down)))
)

(defrule choose-proposta-left
   (declare (salience 68))
   ?prop <- (proposta (dir left) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move left)))
)

;; preferisce celle sicure non visitate (left)
(defrule choose-proposta-left-safe
   (declare (salience 73))
   ?prop <- (proposta (dir left) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (cella-sicura (x ?tx) (y ?ty))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move left)))
)

(defrule choose-proposta-up
   (declare (salience 67))
   ?prop <- (proposta (dir up) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move up)))
)

;; preferisce celle sicure non visitate (up)
(defrule choose-proposta-up-safe
   (declare (salience 72))
   ?prop <- (proposta (dir up) (tx ?tx) (ty ?ty) (step ?s))
   (map-dims (width ?W) (height ?H))
   (test (>= ?tx 0)) (test (<= ?tx (- ?W 1)))
   (test (>= ?ty 0)) (test (<= ?ty (- ?H 1)))
   (cella-sicura (x ?tx) (y ?ty))
   (not (cella-visitata (x ?tx) (y ?ty)))
   (not (action))
   =>
   (retract ?prop)
   (assert (action (move up)))
)


; -----------------------------
; Regole di parsing dei percept e gestione stato-eroe
; -----------------------------

; Quando arriva un nuovo percept, rimuovo i percept con step diverso (evito accumulo)
(defrule pulisci-percept-obsoleti
   ?pnew <- (percept (steps ?s))
   ?pold <- (percept (steps ?s2&:(<> ?s ?s2)))
   =>
   (retract ?pold)
)

; Aggiorna lo stato dell'eroe a partire dal percept corrente
(defrule aggiorna-stato-eroe-da-percept
   ?p <- (percept (x ?x) (y ?y) (energy ?e) (glitter ?g))
   ?s <- (stato-eroe)
   =>
   (retract ?s)
   (assert (stato-eroe (x ?x) (y ?y) (energia ?e) (ha-oro ?g)))
)

; Se non esiste ancora uno stato-eroe, lo asserto dal percept
(defrule crea-stato-eroe-iniziale
   ?p <- (percept (x ?x) (y ?y) (energy ?e) (glitter ?g))
   (not (stato-eroe))
   =>
   (assert (stato-eroe (x ?x) (y ?y) (energia ?e) (ha-oro ?g)))
)

; Marca la cella corrente come visitata
(defrule marca-cella-visitata
   ?p <- (percept (x ?x) (y ?y))
   (not (cella-visitata (x ?x) (y ?y)))
   =>
   (assert (cella-visitata (x ?x) (y ?y)))
)

; Se glitter vero, segnalo che c'è oro nella cella corrente (template oro-raccolto mantiene conteggio)
(defrule segnala-oro-se-glitter
   ?p <- (percept (x ?x) (y ?y) (glitter TRUE))
   =>
   (printout t "[MEMORIA] Brillantezza rilevata in posizione: (" ?x "," ?y ")" crlf)
   (assert (oro-raccolto (trovati 0)))
)

; -----------------------------
; Regole inferenziali per breeze e stench
; -----------------------------

; Se percepisco breeze TRUE, allora almeno una delle celle adiacenti contiene un pozzo
(defrule breeze-implica-ipotesi-pit
   (percept (x ?x) (y ?y) (steps ?s) (breeze TRUE))
   (not (breeze-gia-gestita (step ?s)))
   =>
   (bind ?nx1 (- ?x 1)) (bind ?nx2 (+ ?x 1)) (bind ?ny1 (- ?y 1)) (bind ?ny2 (+ ?y 1))
   (assert (breeze-gia-gestita (step ?s)))
   (assert (ipotesi-pit (x ?nx1) (y ?y) (cf 0.8)))
   (assert (ipotesi-pit (x ?nx2) (y ?y) (cf 0.8)))
   (assert (ipotesi-pit (x ?x) (y ?ny1) (cf 0.8)))
   (assert (ipotesi-pit (x ?x) (y ?ny2) (cf 0.8)))
   (printout t "[INFERENZA] Breeze TRUE: ipotesi pozzi attorno a (" ?x "," ?y ")" crlf)
)

; Se percepisco breeze FALSE, allora tutte le celle adiacenti sono sicure rispetto ai pozzi
(defrule breeze-false-implica-sicurezza
   (percept (x ?x) (y ?y) (steps ?s) (breeze FALSE))
   (not (breeze-gia-gestita (step ?s)))
   =>
   (bind ?nx1 (- ?x 1)) (bind ?nx2 (+ ?x 1)) (bind ?ny1 (- ?y 1)) (bind ?ny2 (+ ?y 1))
   (assert (breeze-gia-gestita (step ?s)))
   (assert (cella-sicura (x ?nx1) (y ?y)))
   (assert (cella-sicura (x ?nx2) (y ?y)))
   (assert (cella-sicura (x ?x) (y ?ny1)))
   (assert (cella-sicura (x ?x) (y ?ny2)))
   (printout t "[INFERENZA] Breeze FALSE: celle adiacenti marcate sicure attorno a (" ?x "," ?y ")" crlf)
)

; Se percepisco stench TRUE, allora almeno una delle celle adiacenti contiene il Wumpus
(defrule stench-implica-ipotesi-wumpus
   (percept (x ?x) (y ?y) (steps ?s) (stench TRUE))
   (not (stench-gia-gestita (step ?s)))
   =>
   (bind ?nx1 (- ?x 1)) (bind ?nx2 (+ ?x 1)) (bind ?ny1 (- ?y 1)) (bind ?ny2 (+ ?y 1))
   (assert (stench-gia-gestita (step ?s)))
   (assert (ipotesi-wumpus (x ?nx1) (y ?y) (cf 0.8)))
   (assert (ipotesi-wumpus (x ?nx2) (y ?y) (cf 0.8)))
   (assert (ipotesi-wumpus (x ?x) (y ?ny1) (cf 0.8)))
   (assert (ipotesi-wumpus (x ?x) (y ?ny2) (cf 0.8)))
   (printout t "[INFERENZA] Stench TRUE: ipotesi Wumpus attorno a (" ?x "," ?y ")" crlf)
)

; Se percepisco stench FALSE, allora tutte le celle adiacenti sono sicure rispetto al Wumpus
(defrule stench-false-implica-sicurezza
   (percept (x ?x) (y ?y) (steps ?s) (stench FALSE))
   (not (stench-gia-gestita (step ?s)))
   =>
   (bind ?nx1 (- ?x 1)) (bind ?nx2 (+ ?x 1)) (bind ?ny1 (- ?y 1)) (bind ?ny2 (+ ?y 1))
   (assert (stench-gia-gestita (step ?s)))
   (assert (cella-sicura (x ?nx1) (y ?y)))
   (assert (cella-sicura (x ?nx2) (y ?y)))
   (assert (cella-sicura (x ?x) (y ?ny1)))
   (assert (cella-sicura (x ?x) (y ?ny2)))
   (printout t "[INFERENZA] Stench FALSE: celle adiacenti marcate sicure attorno a (" ?x "," ?y ")" crlf)
)

; Se troviamo una ipotesi-pit per una cella che e` anche dichiarata sicura, la ritiriamo
(defrule rimuovi-ipotesi-contraddette
   ?h <- (ipotesi-pit (x ?x) (y ?y) (cf ?cf))
   ?s <- (cella-sicura (x ?x) (y ?y))
   =>
   (printout t "[MEMORIA] Contraddizione: rimuovo ipotesi-pit in cella sicura (" ?x "," ?y ")" crlf)
   (retract ?h)
)

; Analogo per ipotesi-wumpus vs cella-sicura
(defrule rimuovi-ipotesi-wumpus-contraddette
   ?h <- (ipotesi-wumpus (x ?x) (y ?y) (cf ?cf))
   ?s <- (cella-sicura (x ?x) (y ?y))
   =>
   (printout t "[MEMORIA] Contraddizione: rimuovo ipotesi-wumpus in cella sicura (" ?x "," ?y ")" crlf)
   (retract ?h)
)

; -----------------------------
; Modulo MAIN: importa tutto e avvia la pila dei moduli al reset
; -----------------------------

(defmodule MAIN (import PERCEPTS ?ALL) (import MEMORIA ?ALL) (import UTIL ?ALL) (export ?ALL))

(deffacts bootstrap
   (avvia-moduli)
   (modalita (nome inferenziale))
)

(defrule avvia-moduli
   ?f <- (avvia-moduli)
   =>
   (retract ?f)
   (printout t "[BOOT] Attivazione moduli agente" crlf)
)

(defrule attiva-moduli-per-step
   (counter (step ?s))
   =>
   ; ad ogni nuovo step facciamo girare prima inferenza, poi decisione, poi output
   (focus UTIL DECISION ACTIONS)
)


; fine del file scheletro
