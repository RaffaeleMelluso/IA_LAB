%===============================================================================
% SPIEGAZIONE DETTAGLIATA SETTORIALIZZATA
% Documento: Descrizione Completa del Progetto
%===============================================================================

# SPIEGAZIONE SETTORIALIZZATA COMPLETA DEL PROGETTO

Questo documento spiega **in dettaglio cosa ho implementato**, settore per settore,
spiegando il funzionamento, le scelte implementative, e come usare ogni componente.

---

## 📑 INDICE SETTORI

1. **SETTORE 1**: Modulo Utilità Generiche
2. **SETTORE 2**: Modulo Euristiche  
3. **SETTORE 3**: Modulo Labirinti
4. **SETTORE 4**: Modulo Gioco dell'8
5. **SETTORE 5**: Algoritmo A*
6. **SETTORE 6**: Algoritmo IDA*
7. **SETTORE 7**: Generatori di Successori
8. **SETTORE 8**: Interfacce Pubbliche
9. **SETTORE 9**: Utilità di Stampa
10. **SETTORE 10**: Verifiche e Sicurezza

---

## 🔧 SETTORE 1: MODULO UTILITÀ GENERICHE

### Scopo
Fornire operazioni fondamentali su liste che NOR USANO `sort()` NE `_Variabili`.

### Implementazione

#### ✅ `inserisci_ordinato(Elemento, Lista, Risultato)`

**Cosa fa**: Inserisce un elemento in una lista mantenendo ordine crescente.

**Algoritmo**:
```
Se Lista vuota: Result = [Elemento]
Se Elemento ≤ primo della lista: Result = [Elemento | Lista]
Altrimenti: Result = [Primo | inserisci_ordinato(Elemento, Resto)]
```

**Codice**:
```prolog
inserisci_ordinato(Elemento, [], [Elemento]) :- !.
inserisci_ordinato(Elemento, [Testa|Coda], [Elemento, Testa|Coda]) :-
    Elemento =.. [Functor1|ArgElemento],
    Testa =.. [Functor2|ArgTesta],
    Functor1 = Functor2,
    ArgElemento = [ValElement|RestElement],
    ArgTesta = [ValTesta|RestTesta],
    ValElement =< ValTesta, !.
inserisci_ordinato(Elemento, [Testa|Coda], [Testa|CodaRisultato]) :-
    inserisci_ordinato(Elemento, Coda, CodaRisultato).
```

**Specifiche**:
- Estrarre i functor con `=..` (univ)
- Confrontare primo argomento con `=<`
- Cut per efficienza

**Uso**:
```prolog
?- inserisci_ordinato(nodo(3, s2), [nodo(1, s1), nodo(5, s3)], R).
R = [nodo(1, s1), nodo(3, s2), nodo(5, s3)].
```

#### ✅ `membro(Elemento, Lista)`
**Semplice**: Verifica unificazione con ricerca lineare.

#### ✅ `lunghezza_lista(Lista, Lunghezza)`
**Specifiche**:
- Accumulatore implicito ricorsione
- Costo O(n)

#### ✅ `concatena_liste(L1, L2, Risultato)`
**Specifiche**:
- Ricorsione su L1
- L2 rimane invariato

#### ✅ `contiene_stato(Stato, ListaStati)`
**Scopo**: Verifica if stato=stato in lista (ricerca strutturale).

**Differenza da membro**: Usa `\=` per skip falsi positivi.

```prolog
contiene_stato(Stato, [Stato|Resto]) :- !.
contiene_stato(Stato, [H|Resto]) :-
    Stato \= H,              % Skip se diverso
    contiene_stato(Stato, Resto).
```

#### ✅ `ribalta_lista(Lista, Ribaltata)`
Inverte ordine lista mantenendo accumulatore.

---

## 🎯 SETTORE 2: MODULO EURISTICHE

### Scopo
Fornire stime del costo rimante per guidare la ricerca.

### Proprieta Euristiche Implementate
- ✅ **Ammissibili**: Non sovrastimano mai
- ✅ **Coerenti**: h(n) ≤ costo(n→n') + h(n')

Garantiscono optimalità A*.

### Implementazione

#### 🔴 Euristica Euclidea (Labirinti)

**Formula**: 
```
d(A,B) = √[(x₁-x₂)² + (y₁-y₂)²]
```

**Codice**:
```prolog
euristica_euclidea(pos(R1, C1), pos(R2, C2), Distanza) :- 
    DeltaR is R1 - R2,
    DeltaC is C1 - C2,
    DeltaR2 is DeltaR * DeltaR,
    DeltaC2 is DeltaC * DeltaC,
    Somma is DeltaR2 + DeltaC2,
    Distanza is sqrt(Somma).
```

**Quando è ottimale**:
- Movimento libero in 2D
- Labirinti senza costi differenziati

**Esempio**:
```
pos(1,1) → pos(4,5)
d = √[(1-4)² + (1-5)²]
  = √[9 + 16]
  = √25
  = 5.0
```

#### 🔴 Euristica Manhattan (Gioco dell'8)

**Formula**:
```
h(stato) = Σ |riga_attuale - riga_goal| + |col_attuale - col_goal|
           per ogni tessera ≠ buco
```

**Codice**:
```prolog
euristica_manhattan(puzzle(Tessere), DistanzaTotale) :-
    calcola_manhattan_dello_stato(Tessere, 0, 0, DistanzaTotale).

calcola_manhattan_dello_stato([], Indice, Accumulatore, Accumulatore) :- !.
calcola_manhattan_dello_stato([Tessera|Resto], IndiceAttuale, 
                             Accumulatore, Totale) :-
    Tessera \= 0,  % Ignora buco
    IndiceGoal is Tessera - 1,
    calcola_distanza_cella(IndiceAttuale, IndiceGoal, Distanza),
    NuovoAcc is Accumulatore + Distanza,
    IndiceSuccessivo is IndiceAttuale + 1,
    calcola_manhattan_dello_stato(Resto, IndiceSuccessivo, NuovoAcc, Totale).
```

**Calcolo Distanza Cella** (griglia 3x3):
```prolog
calcola_distanza_cella(Idx1, Idx2, Distanza) :-
    Riga1 is Idx1 // 3,      % Divisione intera
    Col1 is Idx1 mod 3,      % Resto
    Riga2 is Idx2 // 3,
    Col2 is Idx2 mod 3,
    DeltaRiga is abs(Riga1 - Riga2),
    DeltaCol is abs(Col1 - Col2),
    Distanza is DeltaRiga + DeltaCol.
```

**Esempio**:
```
Stato: [2,1,3,4,5,6,7,8,0]
Goal:  [1,2,3,4,5,6,7,8,0]

Tessera 1: pos_attuale=1, pos_goal=0
  Riga: |0-0|=0, Col: |1-0|=1 → dist=1
Tessera 2: pos_attuale=0, pos_goal=1  
  Riga: |0-0|=0, Col: |0-1|=1 → dist=1
...
Manhattan totale = 2 + (altre)
```

#### 🔴 Euristica Nulla
```prolog
euristica_zero(Stato, 0).
```
Usa per ricerca non informata (BFS).

---

## 🏘️ SETTORE 3: MODULO LABIRINTI

### Definizione (da labirinto.pl)
```prolog
num_col(10).
num_righe(10).
iniziale(pos(4,2)).
finale(pos(7,9)).
occupata(pos(2,5)).
occupata(pos(3,5)).
% ... altre celle occupate
```

### Implementazione in search_algorithms.pl

#### ✅ `stato_goal_labirinto(Posizione)`
```prolog
stato_goal_labirinto(PosFinale) :-
    finale(PosFinale).
```
Verifica che posizione sia il goal definito.

#### ✅ `stato_iniziale_labirinto(Posizione)`
```prolog
stato_iniziale_labirinto(PosIniziale) :-
    iniziale(PosIniziale).
```
Ritorna posizione iniziale.

#### ⚙️ Integrazione Azioni
Le azioni sono definite in `labirinto_azioni.pl`:
```prolog
applicabile(nord, pos(R,C)) :- R > 1, RNuova is R-1, \+occupata(pos(RNuova, C)).
trasforma(nord, pos(R,C), pos(RNuova,C)) :- RNuova is R-1.
```

`search_algorithms.pl` le usa direttamente in `successori_labirinto/2`.

---

## 🧩 SETTORE 4: MODULO GIOCO DELL'8

### Rappresentazione Stato
```
puzzle([1,2,3,4,5,6,7,8,0])
          ↑ ↑ ↑
          | | └─ Cella 2
          | └─── Cella 1
          └───── Cella 0

Griglia 3x3 lineare:
Indice:  0 1 2
         3 4 5
         6 7 8

Esempio: puzzle([2,1,3,4,5,6,7,8,0])
Visualizzazione:
[2][1][3]
[4][5][6]
[7][8][ ]  ← buco (0)
```

### Implementazione

#### ✅ `stato_goal_ottetto(Stato)`
```prolog
stato_goal_ottetto(puzzle([1,2,3,4,5,6,7,8,0])).
```
Goal unico e fisso.

#### ✅ `azioni_puzzle(StatoCorrente, Azioni)`

**Algoritmo**:
1. Trova posizione del buco (0)
2. Determina quali tessere possono muoversi verso buco
3. Ritorna lista di azioni valide

```prolog
azioni_puzzle(puzzle(Tessere), Azioni) :-
    trova_buco(Tessere, 0, PosBuco),
    trovaazioni_puzzle(PosBuco, Azioni).
```

**Logica trovaazioni_puzzle**:
```
Se PosBuco >= 3: spostamento_nord valido
Se PosBuco < 6:  spostamento_sud valido  
Se PosBuco mod 3 > 0: spostamento_est valido
Se PosBuco mod 3 < 2: spostamento_ovest valido
```

**Esempio**:
```
Buco in pos 4 (centro):
├─ Nord: pos 1 può scendere (pos 1 >= 3) ✓
├─ Sud:  pos 7 può salire (pos 4 < 6) ✓
├─ Est:  pos 3 può spostarsi (4 mod 3 = 1 > 0) ✓
└─ Ovest: pos 5 può spostarsi (4 mod 3 = 1 < 2) ✓
Azioni = [spostamento_nord, spostamento_sud, 
          spostamento_est, spostamento_ovest]
```

#### ✅ `trasforma_puzzle(Azione, StatoAttuale, StatoNuovo)`

**Implementazione**:
Scambia buco con tessera adiacente.

```prolog
trasforma_puzzle(spostamento_nord, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosToSwap is PosBuco - 3,      % Tessera sopra
    PosToSwap >= 0,                % Vinc: dentro griglia
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).
```

**Vincoli**:
- Nord: PosToSwap = PosBuco - 3, deve essere ≥ 0
- Sud: PosToSwap = PosBuco + 3, deve essere < 9
- Est: PosToSwap = PosBuco - 1, PosBuco mod 3 > 0 (non colonna sinistra)
- Ovest: PosToSwap = PosBuco + 1, PosBuco mod 3 < 2 (non colonna destra)

#### ✅ `scambia_elementi_lista(ListaVecchia, Pos1, Pos2, ListaNuova)`

```prolog
scambia_elementi_lista(ListaVecchia, Pos1, Pos2, ListaNuova) :-
    elemento_a_indice_lista(ListaVecchia, Pos1, Elem1),
    elemento_a_indice_lista(ListaVecchia, Pos2, Elem2),
    riponi_elemento_lista(ListaVecchia, Pos1, Elem2, ListaTemp),
    riponi_elemento_lista(ListaTemp, Pos2, Elem1, ListaNuova).
```

Scambia leggendo → inserendo → leggendo → inserendo.

---

## ⭐ SETTORE 5: ALGORITMO A*

### Concetto Fondamentale

A* combina costo reale (g) e stima (h):
```
f(n) = g(n) + h(n)

g(n) = costo effettivo da start a n
h(n) = stima euristica da n a goal
f(n) = priorità per espansione
```

### Struttura Dati Nodo

```prolog
nodo(F, Stato, G, H, CamminoAccumulato)
```

**Componenti**:
- `F`: f(n) = g + h (valore di ordinamento)
- `Stato`: Lo stato specifico (pos(...) o puzzle(...))
- `G`: Costo reale accumulato
- `H`: Euristica per questo stato
- `CamminoAccumulato`: [S0, S1, ..., Sn] traccia del percorso

### Algoritmo Principale

#### Flusso:
```
1. INIZIALIZZAZIONE:
   a) Se stato_iniziale = goal → SOLUZIONE [S0], COSTO 0
   b) Calcola h(S0)
   c) F0 = 0 + h(S0)
   d) ListaAperta = [nodo(F0, S0, 0, h(S0), [S0])]
   e) ListaChiusa = []
   f) Contatore = 0

2. ITERAZIONE (astar_iterativo):
   Mentre ListaAperta ≠ ∅:
   
   a) Estrai nodo con F minore (primo della lista ordinata)
   b) Se Contatore >= 50000 → FALLIMENTO
   c) Se StatoCorrente = goal → SOLUZIONE trovata ✅
   d) Se StatoCorrente in ListaChiusa → Scarta, continua
   e) Aggiungi StatoCorrente a ListaChiusa
   f) Genera successori con predicato StatiSuccessori
   g) Per ogni successore: (elabora_successori_astar)
      i) Calcola GSuccessore = GCorrente + CostoArco
      ii) Calcola HSuccessore = Euristica(StatoSuccessore)
      iii) Calcola FSuccessore = GSuccessore + HSuccessore
      iv) Estendi CamminoAccumulato → [... + StatoSuccessore]
      v) CreaNodonodo(FSuccessore, StatoSuccessore, GSuccessore,
                      HSuccessore, CamminoNuovo)
      vi) Inserisci nodo in ListaAperta (ordinato per F)
   h) Contatore += 1
   i) Continuaiterazione

3. FALLIMENTO:
   ListaAperta = ∅ → NO SOLUZIONE → return [], 999999
```

### Codice Principale

```prolog
astar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
      Cammino, CostoTotale) :-
    call(PredicatoGoal, StatoIniziale), !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

astar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
      Cammino, CostoTotale) :-
    call(PredicatoEuristica, StatoIniziale, HIniziale),
    FIniziale is 0 + HIniziale,
    
    NodoIniziale = nodo(FIniziale, StatoIniziale, 0, HIniziale, [StatoIniziale]),
    
    astar_iterativo([NodoIniziale], [], PredicatoGoal, PredicatoSuccessori,
                   PredicatoEuristica, 0, 50000, Cammino, CostoTotale).
```

### Proprietà

| Proprietà | Valore |
|-----------|--------|
| **Completezza** | ✅ Sì (se h ammissibile) |
| **Optimalità** | ✅ Sì (se h coerente) |
| **Memoria** | O(b^h) - PUÒ ESSERE MOLTO |
| **Tempo** | O(b^h) |
| **Espansi** | Minimo possibile con euristica |

---

## 🔄 SETTORE 6: ALGORITMO IDA*

### Concetto Fondamentale

IDA* esegue DFS *iterate* con limite crescente su f = g + h.

```
Iterazione 0: f_limite = h(start)
             Visita solo nodi con f ≤ f_limite
             
Iterazione 1: f_limite = min{f che superava limite precedente}
             Ripeti tutto da start
             
... finché goal trovato
```

### Vantaggio vs A*

| Aspetto | A* | IDA* |
|---------|-----|------|
| **Memoria** | O(b^h) | **O(h)** ✅ |
| **Tempo** | O(b^h) | O(b^h) (ma iterazioni multiple) |
| **Optimalità** | ✅ | ✅ |
| **Completezza** | ✅ | ✅ |

Per problemi grandi O(h) >> O(b^h) quindi **IDA* è superiore**.

### Algoritmo Principale

#### Flusso:
```
1. PREPARAZIONE:
   a) Se stato_iniziale = goal → SOLUZIONE
   b) Calcola SogliaIniziale = h(start)
   c) Inizia iterazioni

2. PER OGNI ITERAZIONE K:
   a) Esegui DFS(SogliaK) con path checking
   b) Durante DFS traccia: min{f > SogliaK}
   c) Se goal trovato → SOLUZIONE ✅
   d) Se f > SogliaK si ferma (backtrack)
   e) Calcola SogliaK+1 = min tracciato
   f) Iterazione K+1

3. TERMINAZIONE:
   Quando goal trovato oppure Iterazione >= 100
```

#### Path Checking (CRITICO):
```prolog
% Verifica che StatoFiglio NON sia nel cammino attuale
contiene_stato(StatoFiglio, [S0, S1, ..., Sn])
```

Previene cicli infiniti tipo: S0 → S1 → S0 (ok, backtrack)

### Codice Principale

```prolog
idastar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
        Cammino, CostoTotale) :-
    call(PredicatoGoal, StatoIniziale), !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

idastar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
        Cammino, CostoTotale) :-
    call(PredicatoEuristica, StatoIniziale, HIniziale),
    SogliaIniziale = HIniziale,
    
    idastar_iterazioni(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
                      PredicatoEuristica, [StatoIniziale], SogliaIniziale,
                      0, 100, Cammino, CostoTotale).
```

#### Iterazioni IDA*:
```prolog
idastar_iterazioni(..., SogliaAttuale, IterazioneCorrente, ...) :-
    % Esegui DFS limitata a questa soglia
    idastar_ricerca_limitata(..., SogliaAttuale, ..., SogliaProssima),
    
    % Se goal trovato, esci; altrimenti iterazione successiva
    (CostoFinale \= 999999 → SUCCESSO
    ;   IterazioneNuova is IterazioneCorrente + 1,
        idastar_iterazioni(..., SogliaProssima, IterazioneNuova, ...)).
```

---

## 🎯 SETTORE 7: GENERATORI DI SUCCESSORI

### `successori_labirinto(StatoCorrente, ListaSuccessori)`

```prolog
successori_labirinto(PosCorrente, Successori) :-
    findall(coppia(Azione, PosNuova, 1),
            (applicabile(Azione, PosCorrente),
             trasforma(Azione, PosCorrente, PosNuova)),
            Successori).
```

**Usa**:
- `applicabile(Azione, Posiz)` da `labirinto_azioni.pl`
- `trasforma(Azione, Posiz1, Posiz2)` da `labirinto_azioni.pl`
- Costo sempre 1

**Output**:
```prolog
[coppia(nord, pos(3,2), 1), coppia(sud, pos(5,2), 1), ...]
```

### `successori_puzzle(StatoCorrente, ListaSuccessori)`

```prolog
successori_puzzle(StatoCorrente, Successori) :-
    azioni_puzzle(StatoCorrente, Azioni),
    findall(coppia(Azione, StatoNuovo, 1),
            (membro(Azione, Azioni),
             trasforma_puzzle(Azione, StatoCorrente, StatoNuovo)),
            Successori).
```

**Usa**:
- `azioni_puzzle` generato internamente
- `trasforma_puzzle` generato internamente
- Costo sempre 1

---

## 🎪 SETTORE 8: INTERFACCE PUBBLICHE

Questi sono i predicati che **l'utente chiama**.

### `ricerca_labirinto_astar(Cammino, Costo)`

```prolog
ricerca_labirinto_astar(Cammino, Costo) :-
    stato_iniziale_labirinto(PosIniziale),
    astar(PosIniziale, stato_goal_labirinto, successori_labirinto,
          euristica_euclidea, Cammino, Costo).
```

Wrapper che configura:
- Start da `labirinto.pl`
- Goal checkpoint
- Generatore successori
- Euristica Euclidea

### `ricerca_labirinto_idastar(Cammino, Costo)`

Identico ma usa `idastar` invece di `astar`.

### `ricerca_puzzle_astar(StatoIniziale, Cammino, Costo)`

```prolog
ricerca_puzzle_astar(StatoIniziale, Cammino, Costo) :-
    astar(StatoIniziale, stato_goal_ottetto, successori_puzzle,
          euristica_manhattan, Cammino, Costo).
```

Accetta state iniziale come parametro.

### `ricerca_puzzle_idastar(StatoIniziale, Cammino, Costo)`

Identico ma usa `idastar`.

---

## 📊 SETTORE 9: UTILITÀ DI STAMPA

### `stampa_cammino(Cammino)`
```
Stampa ogni stato su riga separata:
  pos(4,2)
  pos(3,2)
  ...
```

### `stampa_cammino_puzzle(Cammino)`
```
Stampa griglia 3x3 per ogni stato:
Griglia:
2 1 3 
4 5 6 
7 8 0

Griglia:
2 1 3 
...
```

### `stampa_griglia_puzzle(Tessere, Indice)`
Helper che stampa line per line con newline ogni 3 elementi.

---

## ✅ SETTORE 10: PREVENZIONE CICLI E SICUREZZA

### Meccanismo 1: A* Lista Chiusa

```prolog
% Non rielabora stati già processati
contiene_stato(StatoCorrente, ListaChiusa)
```

### Meccanismo 2: IDA* Path Checking

```prolog
% Verifica non sia nel cammino attuale
contiene_stato(StatoFiglio, CamminoAttuale)
```

### Meccanismo 3: Limiti Iterazioni

```prolog
% A*: 50000 iterazioni
% IDA*: 100 iterazioni
%
% Fallimento controllato se superato
```

### Fallimento Controllato

```prolog
Cammino = []
CostoTotale = 999999
```

Indica "nessuna soluzione trovata" vs crash.

---

## 🎓 RIASSUNTO FINALE

**Ho implementato**:

✅ **A***: Ricerca ottimale con memoria potenzialmente alta  
✅ **IDA***: Ricerca ottimale con memoria bassa  
✅ **Labirinti**: Navigazione con euristica Euclidea  
✅ **Gioco dell'8**: Puzzle con euristica Manhattan  
✅ **Prevenzione cicli**: 3 meccanismi indipendenti  
✅ **Modularità**: 9 sezioni  
✅ **Documentazione**: Commenti italiani completi  
✅ **No sort()**: Ordinamento manuale  
✅ **No _X**: Nomi significativi  

**Tutto pronto per l'uso!**
