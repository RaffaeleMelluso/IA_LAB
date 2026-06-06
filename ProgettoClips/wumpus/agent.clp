;; =========================================================
;; AGENTE COMPLETO
;; Questo agente mette insieme percezione ragionamento e scelta dell azione usando una memoria interna del percorso
;; Quando entra in una cella legge i segnali ricevuti e aggiorna le credenze sui pericoli possibili nelle celle vicine
;; Tiene traccia di dove è passato con la cella di provenienza il comando usato e i target sicuri già individuati
;; Usa più livelli di cautela per evitare i muri ridurre i tentativi inutili e non fidarsi troppo presto di una sola ipotesi
;; Il gps non è un sistema esterno ma una parte del ragionamento che serve a guidare il movimento verso obiettivi già considerati sicuri
;; Funziona confrontando la posizione attuale con i target memorizzati e scegliendo la direzione che avvicina alla meta senza tornare subito indietro
;; In pratica prova prima a seguire una strada già ritenuta affidabile poi se serve usa il percorso memorizzato per rientrare con il backtracking
;; =========================================================
;; MODULO MAIN: Strutture e Memoria
;; =========================================================
(defmodule MAIN (export ?ALL))

(deftemplate percept (slot x) (slot y) (slot steps) (slot breeze) (slot stench) (slot glitter) (slot energy))
(deftemplate action (slot move))
(deftemplate counter (slot step))

(deftemplate cella
   (slot x) (slot y)
   (slot visitata (default FALSE))
   (slot da-x (default -1)) (slot da-y (default -1))
   (slot cf-pit (default 0.0))    
   (slot cf-wumpus (default 0.0))
   (slot esaurita (default FALSE)) ; <--- NUOVO: Flag per i vicoli ciechi!
)

(deftemplate muro (slot x) (slot y))
(deftemplate memoria-azione (slot comando) (slot da-x) (slot da-y))
(deftemplate stato-agente (slot oro-preso (default FALSE)) (slot fase (default esplorazione)))
(deftemplate intenzione-registrata)




;; Supporti per Ragionamento e GPS
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

;; Elimina i percept meno recenti e conserva solo quello piu aggiornato
(defrule MAIN::pulisci-percept-vecchi
   (declare (salience 10000))
   ?p1 <- (percept (steps ?s1))
   ?p2 <- (percept (steps ?s2&:(< ?s2 ?s1)))
   =>
   (retract ?p2))

;; Quando arriva un percept avvia il ciclo di percezione ragionamento e decisione
(defrule MAIN::deliberate
   (declare (salience -10))
   (percept)
   =>
   (focus PERCEZIONE RAGIONAMENTO DECISIONE))

;; =========================================================
;; MODULO PERCEZIONE: Aggiornamento Spaziale
;; =========================================================
(defmodule PERCEZIONE (import MAIN ?ALL))

;; Elimina eventuali azioni vecchie prima di calcolare la nuova mossa
(defrule PERCEZIONE::pulisci-azione
   (declare (salience 2000)) ?a <- (action) => (retract ?a))

;; Elimina la registrazione di intenzione della iterazione precedente
(defrule PERCEZIONE::pulisci-registrazione
   (declare (salience 2000)) ?r <- (intenzione-registrata) => (retract ?r))

;; Aggiorna una cella gia nota quando l agente vi arriva e salva da dove proviene
(defrule PERCEZIONE::aggiorna-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   ?c <- (cella (x ?x) (y ?y) (visitata FALSE))
   =>
   (modify ?c (visitata TRUE) (da-x ?px) (da-y ?py)))

;; Crea una nuova cella visitata quando il percorso la incontra per la prima volta
(defrule PERCEZIONE::crea-cella-mappa
   (percept (x ?x) (y ?y))
   (memoria-azione (da-x ?px) (da-y ?py))
   (not (cella (x ?x) (y ?y)))
   =>
   (assert (cella (x ?x) (y ?y) (visitata TRUE) (da-x ?px) (da-y ?py) (cf-pit -1.0) (cf-wumpus -1.0) (esaurita FALSE))))

;; Se la mossa non cambia posizione il passo precedente ha incontrato un muro
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
;; MODULO RAGIONAMENTO: L Intelligenza Matematica
;; =========================================================
(defmodule RAGIONAMENTO (import MAIN ?ALL))

;; Legge brezza e puzza della cella corrente e aggiorna le ipotesi sui vicini
(defrule RAGIONAMENTO::analizza-pericoli
   (percept (x ?x) (y ?y) (breeze ?b) (stench ?s))
   (not (valutata-cella (x ?x) (y ?y)))
   =>
   (assert (valutata-cella (x ?x) (y ?y)))
   
   (if (eq ?b TRUE) then (assert (brezza-rilevata (x ?x) (y ?y))))
   (if (eq ?s TRUE) then (assert (puzza-rilevata (x ?x) (y ?y))))
   
   (if (and (eq ?b FALSE) (eq ?s FALSE)) then (printout t "   [+] Dintorni sicuri da [" ?x "," ?y "]." crlf))
   (if (eq ?b TRUE) then (printout t "   [!] BREZZA in [" ?x "," ?y "]! Pericolo Pozzi (60%)." crlf))
   (if (eq ?s TRUE) then (printout t "   [!] PUZZA in [" ?x "," ?y "]! Pericolo Wumpus (60%)." crlf))
   
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

;; Se serve una cella per memorizzare il coefficiente la crea prima di applicare gli aggiornamenti
(defrule RAGIONAMENTO::crea-cella-per-cf
   (declare (salience 50))
   (or (richiesta-cf-pit (x ?x) (y ?y)) (richiesta-cf-wumpus (x ?x) (y ?y)))
   (not (cella (x ?x) (y ?y)))
   => (assert (cella (x ?x) (y ?y))))

;; Aggiorna il coefficiente di rischio per i pozzi usando le richieste generate dai segnali
(defrule RAGIONAMENTO::applica-cf-pit
   (declare (salience 10))
   ?r <- (richiesta-cf-pit (x ?x) (y ?y) (val ?n))
   ?c <- (cella (x ?x) (y ?y) (cf-pit ?v))
   =>
   (retract ?r)
   (if (= ?n -1.0) then (modify ?c (cf-pit -1.0))
    else (if (>= ?v 0.0) then (modify ?c (cf-pit (- (+ ?v ?n) (* ?v ?n)))))))

;; Aggiorna il coefficiente di rischio per il wumpus usando le richieste generate dai segnali
(defrule RAGIONAMENTO::applica-cf-wumpus
   (declare (salience 10))
   ?r <- (richiesta-cf-wumpus (x ?x) (y ?y) (val ?n))
   ?c <- (cella (x ?x) (y ?y) (cf-wumpus ?v))
   =>
   (retract ?r)
   (if (= ?n -1.0) then (modify ?c (cf-wumpus -1.0))
    else (if (>= ?v 0.0) then (modify ?c (cf-wumpus (- (+ ?v ?n) (* ?v ?n)))))))

;; Deduce che una cella vicina e sicura quando un vicino certo esclude un rischio e ne sposta uno plausibile
(defrule RAGIONAMENTO::eliminazione-pozzo
   (declare (salience 8))
   (brezza-rilevata (x ?bx) (y ?by)) 
   (cella (x ?sx) (y ?sy) (cf-pit ?cp&:(<= ?cp 0.0))) 
   (test (= (+ (abs (- ?bx ?sx)) (abs (- ?by ?sy))) 1)) 
   ?c-ignota <- (cella (x ?ix) (y ?iy) (cf-pit ?cf&:(and (> ?cf 0.0) (< ?cf 0.9))))
   (test (= (+ (abs (- ?bx ?ix)) (abs (- ?by ?iy))) 1)) 
   (test (or (neq ?sx ?ix) (neq ?sy ?iy))) 
   ;; Ora il post-it controlla anche la cella incognita specifica!
   (not (rischio-spostato (bx ?bx) (by ?by) (sx ?sx) (sy ?sy) (ix ?ix) (iy ?iy))) 
   =>
   (assert (rischio-spostato (bx ?bx) (by ?by) (sx ?sx) (sy ?sy) (ix ?ix) (iy ?iy)))
   (assert (richiesta-cf-pit (x ?ix) (y ?iy) (val 0.3)))
   (printout t "   [?] DEDUZIONE: [" ?sx "," ?sy "] e' sicura. Aumento il rischio di [" ?ix "," ?iy "]" crlf))

;; Deduce che una cella vicina e sicura quando il wumpus certo esclude un rischio e ne sposta uno plausibile
(defrule RAGIONAMENTO::eliminazione-wumpus
   (declare (salience 8))
   (puzza-rilevata (x ?wx) (y ?wy)) 
   (cella (x ?sx) (y ?sy) (cf-wumpus ?cw&:(<= ?cw 0.0))) 
   (test (= (+ (abs (- ?wx ?sx)) (abs (- ?wy ?sy))) 1))
   ?c-ignota <- (cella (x ?ix) (y ?iy) (cf-wumpus ?cf&:(and (> ?cf 0.0) (< ?cf 0.9))))
   (test (= (+ (abs (- ?wx ?ix)) (abs (- ?wy ?iy))) 1))
   (test (or (neq ?sx ?ix) (neq ?sy ?iy)))
   (not (rischio-spostato (bx ?wx) (by ?wy) (sx ?sx) (sy ?sy) (ix ?ix) (iy ?iy)))
   =>
   (assert (rischio-spostato (bx ?wx) (by ?wy) (sx ?sx) (sy ?sy) (ix ?ix) (iy ?iy)))
   (assert (richiesta-cf-wumpus (x ?ix) (y ?iy) (val 0.3)))
   (printout t "   [?] DEDUZIONE: [" ?sx "," ?sy "] e' sicura. Aumento il rischio di [" ?ix "," ?iy "]" crlf))


;; Quando un rischio supera la soglia di sicurezza azzera le ipotesi deboli sui vicini
(defrule RAGIONAMENTO::assoluzione-pozzo
   (declare (salience 5))
   (cella (x ?px) (y ?py) (cf-pit ?cf-p&:(> ?cf-p 0.9))) ; <--- ALZATO A 0.9! Niente più falsi positivi
   (valutata-cella (x ?bx) (y ?by)) 
   (test (= (+ (abs (- ?px ?bx)) (abs (- ?py ?by))) 1)) 
   ?c-inn <- (cella (x ?ix) (y ?iy) (cf-pit ?cf-i&:(and (> ?cf-i 0.0) (< ?cf-i 0.9))))
   (test (= (+ (abs (- ?ix ?bx)) (abs (- ?iy ?by))) 1)) 
   =>
   (modify ?c-inn (cf-pit 0.0)) 
   (printout t "   [i] ASSOLUZIONE: Pozzo confermato in [" ?px "," ?py "]. Cella [" ?ix "," ?iy "] dichiarata innocente!" crlf))

;; Quando un rischio sul wumpus supera la soglia di sicurezza azzera le ipotesi deboli sui vicini
(defrule RAGIONAMENTO::assoluzione-wumpus
   (declare (salience 5))
   (cella (x ?px) (y ?py) (cf-wumpus ?cf-w&:(> ?cf-w 0.9))) ; <--- ALZATO A 0.9!
   (valutata-cella (x ?bx) (y ?by)) 
   (test (= (+ (abs (- ?px ?bx)) (abs (- ?py ?by))) 1)) 
   ?c-inn <- (cella (x ?ix) (y ?iy) (cf-wumpus ?cf-i&:(and (> ?cf-i 0.0) (< ?cf-i 0.9))))
   (test (= (+ (abs (- ?ix ?bx)) (abs (- ?iy ?by))) 1)) 
   =>
   (modify ?c-inn (cf-wumpus 0.0)) 
   (printout t "   [i] ASSOLUZIONE: Wumpus confermato in [" ?px "," ?py "]. Cella [" ?ix "," ?iy "] dichiarata innocente!" crlf))


;; Segnala come target sicura ogni cella non visitata senza rischio e non muro
(defrule RAGIONAMENTO::segnala-target-sicuro
   (cella (x ?x) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (<= ?cp 0.0)) (test (<= ?cw 0.0))
   (not (muro (x ?x) (y ?y))) ; <--- L'ANTIDOTO AL LOOP! Se è un muro, ignoralo!
   (not (target-sicuro (x ?x) (y ?y)))
   =>
   (assert (target-sicuro (x ?x) (y ?y))))

;; Rimuove un target quando la cella e stata raggiunta e quindi non serve piu
(defrule RAGIONAMENTO::rimuovi-target-raggiunto
   ?t <- (target-sicuro (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (visitata TRUE))
   =>
   (retract ?t))

;; Elimina un target se viene scoperto che la cella e un muro
(defrule RAGIONAMENTO::rimuovi-target-muro
   (declare (salience 100))
   ?t <- (target-sicuro (x ?x) (y ?y))
   (muro (x ?x) (y ?y))
   =>
   (retract ?t)
   (printout t "   [x] Target [" ?x "," ?y "] annullato: e' un muro." crlf))

;; =========================================================
;; MODULO DECISIONE: Azione
;; =========================================================
(defmodule DECISIONE (import MAIN ?ALL))

;; Memorizza la mossa scelta per poter ricostruire il percorso in caso di ritorno
(defrule DECISIONE::registra-intenzione
   (declare (salience 1000))
   (percept (x ?x) (y ?y)) (action (move ?dir)) (not (intenzione-registrata))
   ?mem <- (memoria-azione)
   => 
   (modify ?mem (comando ?dir) (da-x ?x) (da-y ?y))
   (assert (intenzione-registrata)))

;; Se c e oro e l agente non ha ancora preso il tesoro lo raccoglie e passa alla fuga
(defrule DECISIONE::prendi-oro
   (declare (salience 150)) (not (action))
   (percept (glitter TRUE)) ?s <- (stato-agente (oro-preso FALSE))
   => (assert (action (move grab))) (modify ?s (oro-preso TRUE) (fase fuga)) (printout t ">>> ORO PRESO! Inizia la fuga!" crlf))

;; Se l agente con oro si trova all origine esce vincitore
(defrule DECISIONE::esci-vincitore
   (declare (salience 200)) (not (action))
   (percept (x 0) (y 0)) (stato-agente (oro-preso TRUE))
   => (assert (action (move quit))) (printout t ">>> VITTORIA! Uscito dalla tana!" crlf))


;; Ritorna verso la cella precedente quando la fase diventa fuga
(defrule DECISIONE::fuga-verso-casa
   (declare (salience 140)) (not (action))
   (stato-agente (fase fuga))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py))) ; Controlla di non essere già arrivato in [0,0]
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<<< FUGA VITTORIOSA: Corro a DESTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left)))  (printout t "<<< FUGA VITTORIOSA: Corro a SINISTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up)))    (printout t "<<< FUGA VITTORIOSA: Corro in ALTO verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))  (printout t "<<< FUGA VITTORIOSA: Corro in BASSO verso [" ?px "," ?py "]" crlf))
)

;; Sceglie la cella a destra solo se e sconosciuta ma senza rischio e senza muro
(defrule DECISIONE::vai-destra
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (<= ?cp 0.0)) (test (<= ?cw 0.0)) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "-> Sicuro: DESTRA verso [" (+ ?x 1) "," ?y "]" crlf))

;; Sceglie la cella a sinistra solo se e sconosciuta ma senza rischio e senza muro
(defrule DECISIONE::vai-sinistra
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (<= ?cp 0.0)) (test (<= ?cw 0.0)) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "-> Sicuro: SINISTRA verso [" (- ?x 1) "," ?y "]" crlf))

;; Sceglie la cella sopra solo se e sconosciuta ma senza rischio e senza muro
(defrule DECISIONE::vai-su
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (<= ?cp 0.0)) (test (<= ?cw 0.0)) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "-> Sicuro: ALTO verso [" ?x "," (- ?y 1) "]" crlf))

;; Sceglie la cella sotto solo se e sconosciuta ma senza rischio e senza muro
(defrule DECISIONE::vai-giu
   (declare (salience 50)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y))
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp) (cf-wumpus ?cw))
   (test (<= ?cp 0.0)) (test (<= ?cw 0.0)) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "-> Sicuro: BASSO verso [" ?x "," (+ ?y 1) "]" crlf))

;; Il gps prova a muoversi verso un target sicuro gia noto senza tornare subito indietro
(defrule DECISIONE::navigatore-destra
   (declare (salience 45)) (not (action)) (percept (x ?x) (y ?y))
   (target-sicuro (x ?tx) (y ?ty))
   (memoria-azione (da-x ?mx) (da-y ?my)) 
   (cella (x =(+ ?x 1)) (y ?y) (visitata TRUE)) (not (muro (x =(+ ?x 1)) (y ?y)))
   (test (<= (+ (abs (- (+ ?x 1) ?tx)) (abs (- ?y ?ty))) (+ (abs (- ?x ?tx)) (abs (- ?y ?ty)))))
   (test (or (neq ?mx (+ ?x 1)) (neq ?my ?y))) 
   => (assert (action (move right))) (printout t ">>> GPS: Navigo verso DESTRA per raggiungere [" ?tx "," ?ty "]" crlf))

;; Il gps prova a muoversi a sinistra verso un target sicuro gia noto senza tornare subito indietro
(defrule DECISIONE::navigatore-sinistra
   (declare (salience 45)) (not (action)) (percept (x ?x) (y ?y))
   (target-sicuro (x ?tx) (y ?ty))
   (memoria-azione (da-x ?mx) (da-y ?my))
   (cella (x =(- ?x 1)) (y ?y) (visitata TRUE)) (not (muro (x =(- ?x 1)) (y ?y)))
   (test (<= (+ (abs (- (- ?x 1) ?tx)) (abs (- ?y ?ty))) (+ (abs (- ?x ?tx)) (abs (- ?y ?ty)))))
   (test (or (neq ?mx (- ?x 1)) (neq ?my ?y))) 
   => (assert (action (move left))) (printout t ">>> GPS: Navigo verso SINISTRA per raggiungere [" ?tx "," ?ty "]" crlf))

;; Il gps prova a muoversi in alto verso un target sicuro gia noto senza tornare subito indietro
(defrule DECISIONE::navigatore-su
   (declare (salience 45)) (not (action)) (percept (x ?x) (y ?y))
   (target-sicuro (x ?tx) (y ?ty))
   (memoria-azione (da-x ?mx) (da-y ?my))
   (cella (x ?x) (y =(- ?y 1)) (visitata TRUE)) (not (muro (x ?x) (y =(- ?y 1))))
   (test (<= (+ (abs (- ?x ?tx)) (abs (- (- ?y 1) ?ty))) (+ (abs (- ?x ?tx)) (abs (- ?y ?ty)))))
   (test (or (neq ?mx ?x) (neq ?my (- ?y 1)))) 
   => (assert (action (move up))) (printout t ">>> GPS: Navigo in ALTO per raggiungere [" ?tx "," ?ty "]" crlf))

;; Il gps prova a muoversi in basso verso un target sicuro gia noto senza tornare subito indietro
(defrule DECISIONE::navigatore-giu
   (declare (salience 45)) (not (action)) (percept (x ?x) (y ?y))
   (target-sicuro (x ?tx) (y ?ty))
   (memoria-azione (da-x ?mx) (da-y ?my))
   (cella (x ?x) (y =(+ ?y 1)) (visitata TRUE)) (not (muro (x ?x) (y =(+ ?y 1))))
   (test (<= (+ (abs (- ?x ?tx)) (abs (- (+ ?y 1) ?ty))) (+ (abs (- ?x ?tx)) (abs (- ?y ?ty)))))
   (test (or (neq ?mx ?x) (neq ?my (+ ?y 1)))) 
   => (assert (action (move down))) (printout t ">>> GPS: Navigo in BASSO per raggiungere [" ?tx "," ?ty "]" crlf))

;; Se non esiste una scelta migliore torna sulla cella precedente salvata in memoria
(defrule DECISIONE::ritirata-o-fuga
   (declare (salience 25)) (not (action))
   (percept (x ?x) (y ?y))
   (cella (x ?x) (y ?y) (da-x ?px) (da-y ?py))
   (test (or (neq ?x ?px) (neq ?y ?py)))
   =>
   (if (= ?px (+ ?x 1)) then (assert (action (move right))) (printout t "<- Strada bloccata! Arretro a DESTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?px (- ?x 1)) then (assert (action (move left)))  (printout t "<- Strada bloccata! Arretro a SINISTRA verso [" ?px "," ?py "]" crlf))
   (if (= ?py (- ?y 1)) then (assert (action (move up)))    (printout t "<- Strada bloccata! Arretro in ALTO verso [" ?px "," ?py "]" crlf))
   (if (= ?py (+ ?y 1)) then (assert (action (move down)))  (printout t "<- Strada bloccata! Arretro in BASSO verso [" ?px "," ?py "]" crlf)))

;; =========================================================
;; GESTIONE DEL RISCHIO A STRATI RICALIBRATA
;; =========================================================

;; Primo livello di rischio calcolato per mosse ancora abbastanza sicure
(defrule DECISIONE::scommessa-calcolata-destra
   (declare (salience 28)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.65)) (cf-wumpus ?cw&:(<= ?cw 0.65))) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "!!! SCOMMESSA CALCOLATA A DESTRA (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Primo livello di rischio calcolato verso sinistra
(defrule DECISIONE::scommessa-calcolata-sinistra
   (declare (salience 28)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.65)) (cf-wumpus ?cw&:(<= ?cw 0.65))) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "!!! SCOMMESSA CALCOLATA A SINISTRA (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Primo livello di rischio calcolato verso l alto
(defrule DECISIONE::scommessa-calcolata-su
   (declare (salience 28)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.65)) (cf-wumpus ?cw&:(<= ?cw 0.65))) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "!!! SCOMMESSA CALCOLATA IN ALTO (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Primo livello di rischio calcolato verso il basso
(defrule DECISIONE::scommessa-calcolata-giu
   (declare (salience 28)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.65)) (cf-wumpus ?cw&:(<= ?cw 0.65))) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "!!! SCOMMESSA CALCOLATA IN BASSO (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Secondo livello di rischio per scelte piu azzardate ma ancora non estreme
(defrule DECISIONE::scommessa-azzardata-destra
   (declare (salience 23)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.85)) (cf-wumpus ?cw&:(<= ?cw 0.85))) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "!!! SCOMMESSA AZZARDATA A DESTRA (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Secondo livello di rischio verso sinistra
(defrule DECISIONE::scommessa-azzardata-sinistra
   (declare (salience 23)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.85)) (cf-wumpus ?cw&:(<= ?cw 0.85))) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "!!! SCOMMESSA AZZARDATA A SINISTRA (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Secondo livello di rischio verso l alto
(defrule DECISIONE::scommessa-azzardata-su
   (declare (salience 23)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.85)) (cf-wumpus ?cw&:(<= ?cw 0.85))) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "!!! SCOMMESSA AZZARDATA IN ALTO (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Secondo livello di rischio verso il basso
(defrule DECISIONE::scommessa-azzardata-giu
   (declare (salience 23)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp&:(<= ?cp 0.85)) (cf-wumpus ?cw&:(<= ?cw 0.85))) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "!!! SCOMMESSA AZZARDATA IN BASSO (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Terzo livello di rischio per tentare una cella quasi completamente non risolta
(defrule DECISIONE::scommessa-estrema-destra
   (declare (salience 20)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x =(+ ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(< ?cp 1.0)) (cf-wumpus ?cw&:(< ?cw 1.0))) (not (muro (x =(+ ?x 1)) (y ?y)))
   => (assert (action (move right))) (printout t "!!! SCOMMESSA ESTREMA A DESTRA (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Terzo livello di rischio verso sinistra
(defrule DECISIONE::scommessa-estrema-sinistra
   (declare (salience 20)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x =(- ?x 1)) (y ?y) (visitata FALSE) (cf-pit ?cp&:(< ?cp 1.0)) (cf-wumpus ?cw&:(< ?cw 1.0))) (not (muro (x =(- ?x 1)) (y ?y)))
   => (assert (action (move left))) (printout t "!!! SCOMMESSA ESTREMA A SINISTRA (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Terzo livello di rischio verso l alto
(defrule DECISIONE::scommessa-estrema-su
   (declare (salience 20)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x ?x) (y =(- ?y 1)) (visitata FALSE) (cf-pit ?cp&:(< ?cp 1.0)) (cf-wumpus ?cw&:(< ?cw 1.0))) (not (muro (x ?x) (y =(- ?y 1))))
   => (assert (action (move up))) (printout t "!!! SCOMMESSA ESTREMA IN ALTO (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Terzo livello di rischio verso il basso
(defrule DECISIONE::scommessa-estrema-giu
   (declare (salience 20)) (not (action)) (stato-agente (fase esplorazione)) (percept (x ?x) (y ?y)) (not (target-sicuro)) 
   (cella (x ?x) (y =(+ ?y 1)) (visitata FALSE) (cf-pit ?cp&:(< ?cp 1.0)) (cf-wumpus ?cw&:(< ?cw 1.0))) (not (muro (x ?x) (y =(+ ?y 1))))
   => (assert (action (move down))) (printout t "!!! SCOMMESSA ESTREMA IN BASSO (Rischio P:" ?cp ", W:" ?cw ")" crlf))

;; Se nessuna strategia e possibile e l agente si trova all origine rinuncia alla partita
(defrule DECISIONE::rinuncia
   (declare (salience 10)) (not (action)) (percept (x 0) (y 0)) (stato-agente (fase esplorazione))
   => (assert (action (move quit))) (printout t "!!! TUTTE LE VIE SONO MORTE CERTA (100%). Rinuncio." crlf))