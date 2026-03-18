# GUIDA COMPLETA: ALGORITMI A* E IDA* PER LABIRINTI E GIOCO DELL'8

## PARTE TEORIA: INTRODUZIONE

### Cos'è questo progetto?

Questo progetto implementa due algoritmi di ricerca in spazio di stati:

1. A* (A-Star): Ricerca best-first con memoria potenzialmente alta
2. IDA* (Iterative Deepening A*): Ricerca iterativa con memoria bassa

Questi algoritmi risolvono due tipi di problemi:
- Labirinti: navigazione in ambienti con ostacoli (usando euristica Euclidea)
- Gioco dell'8: puzzle numerico 3x3 (usando euristica Manhattan)

### Caratteristiche del codice

- No sort(): Ordinamento manuale con inserisci_ordinato/3
- No _Variabili: Tutti i nomi di variabili sono significativi
- Commenti in italiano: Chiari e senza formattazione fancy
- Modularità: 9 sezioni logiche indipendenti
- Senza call(): Predicati specifici per dominio invece di parametri


## PARTE 1: CONCETTI BASE

### Ricerca in spazio di stati

Un problema di ricerca ha:
- Stato iniziale (S0)
- Stato goal (SG)
- Azioni possibili da ogni stato
- Funzione successore: dato uno stato genera gli stati raggiungibili
- Funzione costo: ogni azione ha un costo

### Algoritmobase: Breadth-First Search (BFS)

Espande nodi in ordine FIFO. Trova soluzione ma non minima di costo.

```
Coda = [S0]
Visiti = []
Finchè Coda non è vuota:
  - Estrai primo elemento (S)
  - Se S = Goal: TROVATO
  - Se S in Visiti: scarta
  - Aggiungi S a Visiti
  - Genera successori e aggiungi a coda
```

### Idea euristica: orientare la ricerca

Euristica h(n) = stima del costo da n al goal

Esempio: distanza Euclidea tra posizione attuale e goal nel labirinto.

### A*: Ricerca best-first informata

Espande il nodo con f(n) minore, dove:
```
f(n) = g(n) + h(n)
g(n) = costo reale da start a n
h(n) = stima costo da n a goal
```

Proprietà:
- Se h(n) ammissibile (non sovrastima): A* trova costo minimo
- Se h(n) coerente: non rivisita nodi
- Mantiene lista aperta (open list) ordinata per f(n)
- Mantiene lista chiusa (closed list) di nodi visitati

### IDA*: Ricerca iterativa

Itera DFS con soglia crescente su f(n).

```
Iterazione 0:  soglia = h(start)
Iterazione 1:  soglia = min{f che ha superato soglia precedente}
Iterazione 2:  soglia = min{nuovo f}
...finche goal trovato
```

Proprietà:
- Memoria O(altezza albero) vs O(b^h) per A*
- Spesso più veloce di A* per grandi problemi
- Rivisita nodi ma in profondità controllata


## PARTE 2: ARCHITETTURA DEL PROGETTO

### Struttura generale

Il file main.pl carica:
1. labirinto.pl (definizioni del labirinto specifico)
2. labirinto_azioni.pl (azioni applicabili e trasformazioni)
3. search_algorithms.pl (algoritmi generali)

### File search_algorithms.pl: 9 sezioni

Sezione 1: UTILITY GENERICHE
- inserisci_ordinato/3: Inserisce elemento in lista mantenendo ordine
- membro/2: Verifica appartenenza
- lunghezza_lista/2: Calcola lunghezza lista
- concatena_liste/3: Concatena due liste
- contiene_stato/2: Verifica se stato è nella lista (ricerca strutturale)
- ribalta_lista/2: Inverte lista

Sezione 2: EURISTICHE
- euristica_euclidea/3: Calcola distanza euclidea tra pos(R1,C1) e pos(R2,C2)
- euristica_manhattan/2: Calcola distanza Manhattan per gioco dell'8
- euristica_zero/2: Euristica nulla (BFS pura)

Sezione 3: MODULO LABIRINTI
- stato_goal_labirinto/1: Verifica se posizione è il goal (usa finale/1 da labirinto.pl)
- stato_iniziale_labirinto/1: Ritorna posizione iniziale (usa iniziale/1)

Sezione 4: MODULO GIOCO DELL'8
- stato_goal_ottetto/1: Goal = puzzle([1,2,3,4,5,6,7,8,0])
- azioni_puzzle/2: Genera azioni valide dato uno stato
- trasforma_puzzle/3: Applica un'azione a uno stato
- Helper per manipolazione liste

Sezione 5: ALGORITMO A*
- astar_labirinto/2: A* per labirinti
- astar_puzzle/3: A* per puzzle
- Usa lista aperta ordinata per f(n)
- Usa lista chiusa per evitare rivisita

Sezione 6: ALGORITMO IDA*
- idastar_labirinto/2: IDA* per labirinti
- idastar_puzzle/3: IDA* per puzzle
- Itera con soglia crescente
- Path checking per evitare cicli

Sezione 7: GENERATORI DI SUCCESSORI
- successori_labirinto/2: Genera successori usando applicabile/trasforma da labirinto_azioni.pl
- successori_puzzle/2: Genera successori usando azioni_puzzle/trasforma_puzzle

Sezione 8: INTERFACCE PUBBLICHE (questi chiama l'utente)
- ricerca_labirinto_astar/2
- ricerca_labirinto_idastar/2
- ricerca_puzzle_astar/3
- ricerca_puzzle_idastar/3

Sezione 9: UTILITY DI STAMPA
- stampa_cammino/1: Stampa cammino per labirinto
- stampa_cammino_puzzle/1: Stampa cammino per puzzle
- stampa_griglia_puzzle/2: Utility per stampa griglia 3x3


## PARTE 3: SPIEGAZIONE DETTAGLIATA ALGORITMI

### ALGORITMO A*

Struttura nodo:
```
nodo(F, Stato, G, H, CamminoAccumulato)
F = g + h (priorità)
Stato = stato attuale
G = costo reale accumulato
H = stima euristica
CamminoAccumulato = lista di stati visitati fino a qui
```

Flusso A* per labirinto:

1. Inizializzazione:
   - Se stato_iniziale = goal: SOLUZIONE TRIVIALE
   - Calcola h(stato_iniziale)
   - Crea nodo iniziale con f = 0 + h(stato_iniziale)
   - ListaAperta = [nodo_iniziale]
   - ListaChiusa = []
   - Contatore = 0

2. Iterazione principale:
   a) Se ListaAperta vuota: FALLIMENTO
   b) Se Contatore >= 50000: LIMITE RAGGIUNTO
   c) Estrai nodo con F minore dalla ListaAperta
   d) Se StatoCorrente = goal: TROVATO SOLUZIONE
   e) Se StatoCorrente in ListaChiusa: scarta e continua
   f) Aggiungi StatoCorrente a ListaChiusa
   g) Per ogni successore:
      - Calcola G_figlio = G_padre + 1
      - Calcola H_figlio = euristica_euclidea(successore, goal)
      - Calcola F_figlio = G_figlio + H_figlio
      - Crea nodo nuovo
      - Inserisci in ListaAperta (ordinato per F)
   h) Contatore += 1
   i) Continua iterazione

3. Fallimento controllato:
   - Ritorna Cammino = [], Costo = 999999

Prevenzione cicli in A*:
- Lista chiusa: non rielabora stati già visitati
- Limite iterazioni: sicurezza contro bug
- Ordinamento per F: garantisce optimalità

### ALGORITMO IDA*

Flusso IDA*:

1. Inizializzazione:
   - Se stato_iniziale = goal: SOLUZIONE TRIVIALE
   - Calcola h(stato_iniziale)
   - SogliaIniziale = h(stato_iniziale)
   - IterazioneCorrente = 0
   - LimiteIterazioni = 100

2. Per ogni iterazione K:
   a) Se IterazioneCorrente >= 100: LIMITE RAGGIUNTO
   b) Esegui DFS limitata con soglia = SogliaK
   c) Durante DFS traccia: min{f > SogliaK}
   d) Se goal trovato: SOLUZIONE
   e) SogliaK+1 = minimo tracciato
   f) IterazioneK+1

3. DFS limitata:
   a) Se StatoCorrente = goal: TROVATO
   b) Calcola f(corrente) = g(corrente) + h(corrente)
   c) Se f(corrente) > soglia: RITORNA (backtrack)
   d) Se StatoCorrente in cammino attuale: SKIP (path checking)
   e) Genera successori
   f) Per ogni successore: ricorsione DFS

4. Path checking (CRITICO):
   - Verifica StatoFiglio non sia nel cammino attuale
   - Previene cicli tipo: S0 -> S1 -> S0

Prevenzione cicli in IDA*:
- Path checking: non visita stesso stato nel cammino
- Limite iterazioni: sicurezza contro bug
- DFS naturale: profondità controllata


## PARTE 4: SPIEGAZIONE DOMINI

### Dominio: Labirinto

Rappresentazione in labirinto.pl:
```
num_col(10).
num_righe(10).
iniziale(pos(4,2)).
finale(pos(7,9)).
occupata(pos(2,5)).
occupata(pos(3,5)).
...
```

In labirinto_azioni.pl:
```
applicabile(nord, pos(R,C)) :- R > 1, RNuova is R-1, \+occupata(pos(RNuova, C)).
applicabile(sud, pos(R,C)) :- R < num_righe(MaxR), MaxR is MaxR+1, RNuova is R+1, \+occupata(pos(RNuova, C)).
applicabile(est, pos(R,C)) :- C < num_col(MaxC), CNuova is C+1, \+occupata(pos(R, CNuova)).
applicabile(ovest, pos(R,C)) :- C > 1, CNuova is C-1, \+occupata(pos(R, CNuova)).

trasforma(nord, pos(R,C), pos(RNuova,C)) :- RNuova is R - 1.
trasforma(sud, pos(R,C), pos(RNuova,C)) :- RNuova is R + 1.
trasforma(est, pos(R,C), pos(R,CNuova)) :- CNuova is C + 1.
trasforma(ovest, pos(R,C), pos(R,CNuova)) :- CNuova is C - 1.
```

Euristica: Euclidea
```
h(pos(R1,C1), pos(R2,C2)) = sqrt((R1-R2)^2 + (C1-C2)^2)
```

Proprietà:
- Ammissibile: non sovrastima mai
- Coerente: soddisfa disuguaglianza triangolare

### Dominio: Gioco dell'8

Rappresentazione:
```
puzzle([T0, T1, T2, T3, T4, T5, T6, T7, T8])
Mappa a griglia 3x3:
  0 1 2
  3 4 5
  6 7 8

Esempio: puzzle([2,1,3,4,5,6,7,8,0])
Visualizzazione:
[2][1][3]
[4][5][6]
[7][8][ ]  <- buco (0)
```

Goal:
```
puzzle([1,2,3,4,5,6,7,8,0])
[1][2][3]
[4][5][6]
[7][8][ ]
```

Azioni:
- spostamento_nord: sposta tessera in basso se buco può muoversi su
- spostamento_sud: sposta tessera in alto se buco può muoversi giù
- spostamento_est: sposta tessera sinistra se buco può muoversi destra
- spostamento_ovest: sposta tessera destra se buco può muoversi sinistra

Vincoli azioni:
- Nord: buco deve essere >= posizione 3
- Sud: buco deve essere < posizione 6
- Est: buco mod 3 > 0 (non colonna sinistra)
- Ovest: buco mod 3 < 2 (non colonna destra)

Euristica: Manhattan
```
h(stato) = somma delle distanze Manhattan di ogni tessera dalla posizione goal

Per tessera T ad indice I (0-based):
  - Riga attuale = I // 3
  - Col attuale = I mod 3
  - Riga goal = (T-1) // 3
  - Col goal = (T-1) mod 3
  - Distanza = |riga_attuale - riga_goal| + |col_attuale - col_goal|
  
h(stato) = somma per T = 1..8
```

Proprietà:
- Ammissibile per 8-puzzle
- Molto informativa


## PARTE 5: GUIDA PRATICA ALL'USO

### Caricamento programma

File: main.pl
```prolog
:- ensure_loaded('labirinto.pl').
:- ensure_loaded('labirinto_azioni.pl').
:- ensure_loaded('search_algorithms.pl').
```

Da terminale:
```
swipl
?- consult('main.pl').
```

Oppure:
```
swipl -l main.pl
```

### USO RAPIDO CON LABIRINTI FORNITI

Una volta caricato main.pl:

1. Ricerca labirinto con A*:
```
?- ricerca_labirinto_astar(Cammino, Costo).
```
Ritorna:
- Cammino: lista di stati [pos(4,2), pos(4,3), ..., pos(7,9)]
- Costo: numero di mosse

2. Vedere il cammino formattato:
```
?- ricerca_labirinto_astar(C, K), stampa_cammino(C).
```

3. Ricerca labirinto con IDA*:
```
?- ricerca_labirinto_idastar(Cammino, Costo).
```

4. Confrontare:
```
?- ricerca_labirinto_astar(C1, K1), 
   ricerca_labirinto_idastar(C2, K2),
   format('A*: ~w passi~n', [K1]),
   format('IDA*: ~w passi~n', [K2]).
```

### USO CON GIOCO DELL'8

1. Stato iniziale semplice:
```
?- ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C, K).
```

2. Stampa della soluzione:
```
?- ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C, K),
   stampa_cammino_puzzle(C).
```

3. Stato iniziale difficile (10 mosse da goal):
```
?- ricerca_puzzle_idastar(puzzle([1,2,3,4,5,6,8,7,0]), C, K).
```

4. Query interattiva:
```
?- StatoIniziale = puzzle([0,1,2,3,4,5,6,7,8]),
   ricerca_puzzle_astar(StatoIniziale, Cammino, Costo),
   format('Trovata soluzione in ~w mosse~n', [Costo]).
```


## PARTE 6: ESEMPI CONCETTI

### Esempio 1: Come funziona euristica_euclidea

Labirinto 10x10, start = pos(4,2), goal = pos(7,9)

Calcolo:
```
DeltaR = 4 - 7 = -3
DeltaC = 2 - 9 = -7
DeltaR^2 = 9
DeltaC^2 = 49
Somma = 58
sqrt(58) ≈ 7.62

h(pos(4,2)) ≈ 7.62
```

Se costo reale è 8 passi:
- f(4,2) = 0 + 7.62 = 7.62
- Se esamino pos(4,3): g = 1, h ≈ 7.35, f ≈ 8.35 (meno promettente)
- Se esamino pos(5,2): g = 1, h ≈ 6.08, f ≈ 7.08 (più promettente)

A* sceglie pos(5,2) perché ha f minore!

### Esempio 2: Come funziona Manhattan per 8-puzzle

Stato: puzzle([2,1,3,4,5,6,7,8,0])
Goal: puzzle([1,2,3,4,5,6,7,8,0])

Calcolo distanza per ogni tessera:
```
Tessera 1: pos_attuale = 1, pos_goal = 0
  Riga_att = 1//3 = 0, Col_att = 1%3 = 1
  Riga_goal = 0//3 = 0, Col_goal = 0%3 = 0
  Dist = |0-0| + |1-0| = 1

Tessera 2: pos_attuale = 0, pos_goal = 1
  Riga_att = 0//3 = 0, Col_att = 0%3 = 0
  Riga_goal = 1//3 = 0, Col_goal = 1%3 = 1
  Dist = |0-0| + |0-1| = 1

Tessera 3..8: Dist = 0 (già in posto)

Tessera 0 (buco): ignorato

Manhattan totale = 1 + 1 = 2
```

Questo stato ha due mosse a goal (scambia 1 con 2). Manhattan = 2 è perfetto!

### Esempio 3: IDA* vs A*

Problema: SolidIntegral 8-puzzle da [2,1,3] (3 mosse)

IDA* iterazioni:
```
Iter 0: soglia = h(start) = 2
  Esplora solo stati con f <= 2
  Non trova goal

Iter 1: soglia = min{f che ha superato 2} = 3
  Esplora stati con f <= 3
  Non trova goal

Iter 2: soglia = 4
  Continua...

Iter 3: soglia = 5 (fatto)
```

A* una sola volta:
```
Aperta = [nodo(2, start, 0, 2, [start])]
Espande sequenzialmente
Trova goal in una sola volta
```

A* più veloce qui. Ma se memoria è limitata, IDA* è migliore.


## PARTE 7: TROUBLESHOOTING

### Problema: "no match predicates" su applicabile
Causa: labirinto_azioni.pl non caricato
Soluzione: Verificare che main.pl ha ensure_loaded('labirinto_azioni.pl')

### Problema: Programma molto lento
Causa: Labirinto molto grande o stato iniziale lontano da goal
Soluzione: Provare IDA* invece di A*, o controllare che euristica sia buona

### Problema: "Limite raggiunto" (Contatore >= 50000)
Causa: A* non converge, possibile bug in logica
Soluzione: Controllare che stato_goal sia corretto e stato_iniziale raggiungibile

### Problema: Cammino non fa sense (ritorna [])
Causa: No soluzione trovata oppure state goal non raggiungibile
Soluzione: Verificare che stato_iniziale e goal siano validi


## FINE GUIDA
