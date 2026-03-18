%===============================================================================
% GUIDA RIFERIMENTO RAPIDO - API PUBBLICA  
%===============================================================================

# API PUBBLICA - FUNZIONI PRINCIPALI

## 🎯 ACCESSO RAPIDO

Questo file contiene la lista di TUTTE le funzioni che devi usare.

---

## 1️⃣ RICERCA LABIRINTO

### A* su Labirinto
```prolog
ricerca_labirinto_astar(Cammino, Costo)
```

**Descrizione**: Risolve il labirinto con algoritmo A* usando euristica Euclidea

**Parametri**:
- `Cammino`: Lista di posizioni dal start al goal
  - Esempio: `[pos(4,2), pos(3,2), pos(2,2), ..., pos(7,9)]`
- `Costo`: Numero di mosse (passi)
  - Esempio: `8` (8 passi)

**Precondizioni**:
- File `labirinto.pl` deve essere caricato
- File `labirinto_azioni.pl` deve essere caricato

**Esempio**:
```prolog
?- ricerca_labirinto_astar(C, K).
C = [pos(4,2), pos(3,2), pos(2,2), ...],
K = 8.
```

**Fallibile**: Sì (ritorna `Cammino = []`, `Costo = 999999` se nessuna soluzione)

---

### IDA* su Labirinto
```prolog
ricerca_labirinto_idastar(Cammino, Costo)
```

**Descrizione**: Risolve il labirinto con algoritmo IDA* (meno memoria di A*)

**Parametri**: Identici ad A*

**Differenze da A***:
- Usa memoria O(profondità) invece di O(numero nodi)
- Potrebbe eseguire ricerche multiple
- Garantisce stesso costo minimo di A*

**Quando usare**:
- Labirinti grandi
- Memoria limitata
- Labirinti molto complessi

---

## 2️⃣ RICERCA GIOCO DELL'8

### A* su Gioco dell'8
```prolog
ricerca_puzzle_astar(StatoIniziale, Cammino, Costo)
```

**Descrizione**: Risolve il puzzle 8x8 con A* e euristica Manhattan

**Parametri**:
- `StatoIniziale`: Stato iniziale puzzle
  - Formato: `puzzle([T1,T2,T3,T4,T5,T6,T7,T8,T9])`
  - Esempio: `puzzle([2,1,3,4,5,6,7,8,0])`
  - 0 = buco, 1-8 = tessere numerate
- `Cammino`: Sequenza di stati
  - Elemento finale è `puzzle([1,2,3,4,5,6,7,8,0])`
- `Costo`: Numero di mosse

**Vincoli su StatoIniziale**:
- Esattamente 9 elementi
- Elementi 0-8, ogni numero appare una volta
- Non modificare goal: `puzzle([1,2,3,4,5,6,7,8,0])`

**Esempio**:
```prolog
?- ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C, K).

C = [puzzle([2,1,3,4,5,6,7,8,0]),
     puzzle([2,1,3,4,5,6,7,0,8]),
     puzzle([2,1,3,4,5,6,0,7,8]),
     puzzle([2,1,3,4,0,6,5,7,8]),
     puzzle([2,0,3,4,1,6,5,7,8]),
     puzzle([0,2,3,4,1,6,5,7,8]),
     puzzle([1,2,3,4,0,6,5,7,8]),
     puzzle([1,2,3,4,5,6,7,8,0])],

K = 7.
```

---

### IDA* su Gioco dell'8
```prolog
ricerca_puzzle_idastar(StatoIniziale, Cammino, Costo)
```

**Descrizione**: Risolve il puzzle con IDA* (consigliato per puzzle difficili)

**Parametri**: Identici ad A*

**Quando preferire a A***:
- Puzzle con 100+ mosse (problema grande)
- Memoria del sistema limitata
- Accettabile che ricerca impieghi più tempo

---

## 3️⃣ UTILITY - STAMPA RISULTATI

### Stampa Cammino Labirinto
```prolog
stampa_cammino(Cammino)
```

**Descrizione**: Stampa prettily il cammino

**Uso**:
```prolog
?- ricerca_labirinto_astar(C, K), stampa_cammino(C).

Stato: pos(4,2)
Stato: pos(3,2)
Stato: pos(2,2)
...
Stato: pos(7,9)
```

---

### Stampa Cammino Puzzle
```prolog
stampa_cammino_puzzle(Cammino)
```

**Descrizione**: Stampa sequenza di griglie 3x3 del puzzle

**Uso**:
```prolog
?- ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C, _),
   stampa_cammino_puzzle(C).

Griglia:
2 1 3 
4 5 6 
7 8 0 

Griglia:
2 1 3 
4 5 6 
7 0 8 

...
```

---

## 4️⃣ UTILITY INTERNE

Queste sono per **debug/testing**, non uso normale:

### Verificare Euristiche
```prolog
euristica_euclidea(pos(R1,C1), pos(R2,C2), Distanza)
euristica_manhattan(puzzle([...]), Distanza)
```

### Generare Successori
```prolog
successori_labirinto(Stato, ListaSuccessori)
successori_puzzle(Stato, ListaSuccessori)
```

### Verificare Azioni
```prolog
azioni_puzzle(Stato, ListaAzioni)
trasforma_puzzle(Azione, StatoIn, StatoOut)
```

---

## 🎓 PATTERN DI USO COMPLETO

### Pattern 1: Ricerca + Stampa
```prolog
% Labirinto con stampa
?- ricerca_labirinto_astar(Cammino, Costo),
   write('Soluzione trovata!'), nl,
   write('Costo: '), write(Costo), nl,
   write('Cammino:'), nl,
   stampa_cammino(Cammino).
```

### Pattern 2: Comparazione Algoritmi
```prolog
% Compara A* e IDA*  
?- 
  % A*
  write('A*:'), nl,
  ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C1, K1),
  write('  Costo: '), write(K1), nl,
  
  % IDA*
  write('IDA*:'), nl,
  ricerca_puzzle_idastar(puzzle([2,1,3,4,5,6,7,8,0]), C2, K2),
  write('  Costo: '), write(K2), nl.
```

### Pattern 3: Processo Iterativo
```prolog
% Definizione predicato per testare stati
test_stati(Strato0) :-
    ricerca_puzzle_astar(Strato0, Cammino, Costo),
    length(Cammino, Lunghezza),
    write('Stato: '), write(Strato0), nl,
    write('Passi: '), write(Costo), nl,
    write('Lunghezza cammino: '), write(Lunghezza), nl, nl.

% Uso:
?- test_stati(puzzle([2,1,3,4,5,6,7,8,0])).
?- test_stati(puzzle([1,2,3,4,5,6,7,0,8])).
?- test_stati(puzzle([2,1,3,4,0,6,5,7,8])).
```

---

## ⚠️ COME LEGGERE OUTPUT

### Output Successo
```
C = [pos(...), pos(...), ..., pos(...)]
K = 8
```
✅ Soluzione trovata in 8 mosse

### Output Fallimento  
```
C = []
K = 999999
```
❌ Nessuna soluzione trovata (goal irraggiungibile o limite raggiunto)

### Output Parziale
```
C = [pos(4,2), pos(3,2)|_] ?
```
⚠️ Premi `;` per più soluzioni (nota: A* trova una sola soluzione ottimale)

---

## 🔍 DEBUGGING - COMANDI UTILI

### Verificare Stato Goal
```prolog
?- stato_goal_labirinto(pos(7,9)).  % true se è goal
?- stato_goal_ottetto(puzzle([1,2,3,4,5,6,7,8,0])).

?- stato_goal_labirinto(pos(1,1)).  % false se non goal
```

### Verificare Azioni
```prolog
?- azioni_puzzle(puzzle([2,1,3,4,5,6,7,8,0]), Azioni).
Azioni = [spostamento_nord, spostamento_ovest].
```

### Verificare Applicabilità Azione
```prolog
?- applicabile(nord, pos(4,2)).  % Verifica se nord è valido
true.
```

### Attivare Trace (Debug Completo)
```prolog
?- trace.
?- ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C, K).
% Mostra ogni unificazione
?- notrace.
```

---

## 📊 REFERENCE RAPIDO PARAMETRI

### Stati Labirinto
```
pos(Riga, Colonna)

Esempio di Riga: 1 a 10
Esempio di Colonna: 1 a 10
```

### Stati Puzzle
```
puzzle([T0, T1, T2, T3, T4, T5, T6, T7, T8])

Indici griglia 3x3:
0 1 2
3 4 5
6 7 8

T0-T8 ∈ {0, 1, 2, 3, 4, 5, 6, 7, 8} (ogni numero una volta)
0 = buco
```

### Successori
```
Formato: coppia(NomeAzione, StatoNuovo, Costo)

Costo è sempre 1 per:
- nord, sud, ovest, est (movimenti)
- spostamento_nord, spostamento_sud, 
  spostamento_est, spostamento_ovest (puzzle)
```

---

## 🚀 QUICK START (3 RIGHE)

```prolog
?- consult('search_algorithms.pl'), 
   consult('labirinto.pl'),
   consult('labirinto_azioni.pl').

?- ricerca_puzzle_astar(puzzle([2,1,3,4,5,6,7,8,0]), C, K),
   write('Soluzione in '), write(K), write(' mosse'), nl.
```

---

## 📌 FUNZIONI NON DISPONIBILI

❌ `sort(L, Sorted)` - Usa sistema interno `inserisci_ordinato`  
❌ `_X` variabili - Sistema interno nomina variabili significativamente  
❌ `findall(X, Goal, L)` - Non necessario per questo progetto  
❌ `forall(Goal1, Goal2)` - Non necessario  

---

**TUTTO PRONTO! Inizia a usare l'API!** ✨
