;; =========================================================
;; AGENTE BASE
;; Prima di ragionare elimina le percezioni vecchie e lascia solo quella attuale cosi evita di prendere decisioni su dati superati
;; Questo agente usa un ragionamento semplice e diretto basato sulla sicurezza immediata delle celle vicine
;; La decisione parte dalla cella corrente e controlla se le celle adiacenti sono visitate libere da muri e prive di rischio noto
;; Il muro viene riconosciuto quando il comando scelto non produce avanzamento e la posizione percepita resta identica a quella di partenza
;; Il processo di ragionamento avanza solo quando trova una cella non visitata senza rischio noto altrimenti si ferma o torna indietro usando la memoria del percorso
;; Sono utili anche le parti che trasformano le celle non visitate in target sicuri e quelle che rimuovono i target quando vengono raggiunti o diventano muri
;; Anche qui l ordine delle regole e importante perche prima si pulisce lo stato interno poi si aggiorna la mappa e solo dopo si sceglie se andare avanti o tornare indietro
;; Il target sicuro serve a ricordare le celle che meritano di essere visitate mentre la memoria del percorso serve a ritrovare la strada se non ci sono mosse migliori
;; Le soglie qui sono piu semplici ma servono comunque a separare una cella davvero affidabile da una che non conviene ancora attraversare
;; Si ricorda dove è passato prima e conserva i target sicuri che possono aiutare a tornare indietro o continuare l esplorazione
;; Le informazioni memorizzate restano poche ma utili cella visitata muro scoperto e punto da cui è arrivato
;; Le precauzioni servono a non entrare nei muri a non scegliere mosse senza senso e a fermarsi quando non c è una strada ragionevole
;; La sua strategia è cercare prima le celle non visitate che non mostrano rischio noto e usare la memoria del percorso per fare backtracking
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

;; Elimina le percezioni meno recenti in base al campo steps e mantiene solo la piu aggiornata prima di ragionare
(defrule MAIN::pulisci-percept-vecchi
   (declare (salience 10000))
   ?p1 <- (percept (steps ?s1))
   ?p2 <- (percept (steps ?s2&:(< ?s2 ?s1)))
   =>
   (retract ?p2))

;; Avvia il ciclo di ragionamento appena arriva un percept
(defrule MAIN::deliberate
   (declare (salience -10))
   (percept)
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE))

;; =========================================================
;; PERCEZIONE
;; Aggiorna la mappa locale e riconosce i muri incontrati
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

;; Rimuove la vecchia azione prima di calcolare la successiva
(defrule PERCEZIONE::pulisci-azione
   (declare (salience 2000)) ?a <- (action) => (retract ?a))

;; Rimuove la vecchia intenzione registrata
(defrule PERCEZIONE::pulisci-registrazione
   (declare (salience 2000)) ?r <- (intenzione-registrata) => (retract ?r))

;; Segna come visitata la cella corrente e salva il punto di provenienza
(defrule PERCEZIONE::aggiorna-cella
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py)))

;; Crea una nuova cella visitata quando l agente entra in una posizione mai vista
(defrule PERCEZIONE::crea-cella
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py))))

;; Registra il muro incontrato quando il movimento non produce spostamento
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
;; Marca i vicini come candidati sicuri e prepara le celle da visitare
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

;; Se non ci sono segnali marca i vicini come target sicuri altrimenti lascia un avviso
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

;; Crea la cella a destra quando serve per costruire la mappa locale
(defrule RAGIONAMENTO::crea-cella-vicino-destra
   (percept (x ?x) (y ?y))
   (not (cella (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (cella (x (+ ?x 1)) (y ?y))))

;; Crea la cella a sinistra quando serve per costruire la mappa locale
(defrule RAGIONAMENTO::crea-cella-vicino-sinistra
   (percept (x ?x) (y ?y))
   (not (cella (x =(- ?x 1)) (y ?y)))
   =>
   (assert (cella (x (- ?x 1)) (y ?y))))

;; Crea la cella sopra quando serve per costruire la mappa locale
(defrule RAGIONAMENTO::crea-cella-vicino-su
   (percept (x ?x) (y ?y))
   (not (cella (x ?x) (y =(- ?y 1))))
   =>
   (assert (cella (x ?x) (y (- ?y 1)))))

;; Crea la cella sotto quando serve per costruire la mappa locale
(defrule RAGIONAMENTO::crea-cella-vicino-giu
   (percept (x ?x) (y ?y))
   (not (cella (x ?x) (y =(+ ?y 1))))
   =>
   (assert (cella (x ?x) (y (+ ?y 1)))))

;; Registra come target sicuro ogni cella non visitata e non muro
(defrule RAGIONAMENTO::crea-target-sicuro
   (cella (x ?x) (y ?y) (visitata FALSE))
   (not (muro (x ?x) (y ?y)))
   (not (target-sicuro (x ?x) (y ?y)))
   =>
   (assert (target-sicuro (x ?x) (y ?y))))

;; Rimuove il target quando la cella e stata effettivamente visitata
(defrule RAGIONAMENTO::rimuovi-target-raggiunto
   ?t <- (target-sicuro (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (visitata TRUE))
   =>
   (retract ?t))

;; Rimuove il target se viene scoperto che corrisponde a un muro
(defrule RAGIONAMENTO::rimuovi-target-muro
   (declare (salience 100))
   ?t <- (target-sicuro (x ?x) (y ?y))
   (muro (x ?x) (y ?y))
   =>
   (retract ?t)
   (printout t "   [x] Target annullato: muro in [" ?x "," ?y "]" crlf))

;; =========================================================
;; DECISIONE
;; Sceglie l oro la fuga il gps base oppure il backtracking semplice
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

;; Salva la direzione decisa per poterla usare nella memoria del percorso
(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (percept (x ?x) (y ?y))
   (action (move ?dir))
   (not (intenzione-registrata))
   ?mem <- (memoria-azione)
   =>
   (modify ?mem (comando ?dir) (da-x ?x) (da-y ?y))
   (assert (intenzione-registrata)))

;; Se c e oro lo prende e passa alla fase di fuga
(defrule DECISIONE::prendi-oro
   (declare (salience 150))
   (not (action))
   (percept (glitter TRUE))
   ?s <- (stato-agente (oro-preso FALSE))
   =>
   (assert (action (move grab)))
   (modify ?s (oro-preso TRUE) (fase fuga))
   (printout t ">>> Oro trovato: parte la fuga." crlf))

;; Se l agente con oro torna all origine conclude la partita
(defrule DECISIONE::esci-vincitore
   (declare (salience 200))
   (not (action))
   (percept (x 0) (y 0))
   (stato-agente (oro-preso TRUE))
   =>
   (assert (action (move quit)))
   (printout t ">>> Vittoria: uscito con l'oro." crlf))

;; Durante la fuga torna verso la cella precedente memorizzata
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

;; Se esiste un target sicuro a destra e la cella e libera lo raggiunge
(defrule DECISIONE::vai-destra
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x =(+ ?x 1)) (y ?y))
   (not (muro (x =(+ ?x 1)) (y ?y)))
   =>
   (assert (action (move right)))
   (printout t "-> GPS base: vado a DESTRA verso un obiettivo sicuro." crlf))

;; Se esiste un target sicuro a sinistra e la cella e libera lo raggiunge
(defrule DECISIONE::vai-sinistra
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x =(- ?x 1)) (y ?y))
   (not (muro (x =(- ?x 1)) (y ?y)))
   =>
   (assert (action (move left)))
   (printout t "-> GPS base: vado a SINISTRA verso un obiettivo sicuro." crlf))

;; Se esiste un target sicuro sopra e la cella e libera lo raggiunge
(defrule DECISIONE::vai-su
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x ?x) (y =(- ?y 1)))
   (not (muro (x ?x) (y =(- ?y 1))))
   =>
   (assert (action (move up)))
   (printout t "-> GPS base: vado in ALTO verso un obiettivo sicuro." crlf))

;; Se esiste un target sicuro sotto e la cella e libera lo raggiunge
(defrule DECISIONE::vai-giu
   (declare (salience 55))
   (not (action))
   (percept (x ?x) (y ?y))
   (target-sicuro (x ?x) (y =(+ ?y 1)))
   (not (muro (x ?x) (y =(+ ?y 1))))
   =>
   (assert (action (move down)))
   (printout t "-> GPS base: vado in BASSO verso un obiettivo sicuro." crlf))

;; Scelta prudente a destra quando la cella e nuova e senza rischio
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

;; Scelta prudente a sinistra quando la cella e nuova e senza rischio
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

;; Scelta prudente verso l alto quando la cella e nuova e senza rischio
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

;; Scelta prudente verso il basso quando la cella e nuova e senza rischio
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

;; Se la strada termina torna sulla cella precedente salvata in memoria
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

;; Se non resta alcuna mossa utile e l agente si trova all origine rinuncia
(defrule DECISIONE::rinuncia
   (declare (salience 10))
   (not (action))
   (percept (x 0) (y 0))
   (stato-agente (fase esplorazione))
   =>
   (assert (action (move quit)))
   (printout t "!!! Bloccato all'origine: rinuncio." crlf))
