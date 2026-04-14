# Progetto Clingo - Calendario Torneo Lega Pokemon

Questo progetto implementa in ASP (con Clingo) la generazione del **prossimo turno** del torneo, dato:
- elenco partecipanti,
- incontri gia avvenuti,
- classifica attuale.

## File del progetto

- `torneo.lp`: regole ASP generali (vincoli + ottimizzazione)
- `turno1.lp`: primo scenario di esempio
- `turno2.lp`: secondo scenario di esempio (con nuovi partecipanti)

## Come eseguire

Dalla cartella `ProgettoClingo`:

```bash
clingo torneo.lp turno1.lp 0
clingo torneo.lp turno2.lp 0
```

`0` significa: mostra tutte le soluzioni ottime.
Se vuoi una sola soluzione ottima:

```bash
clingo torneo.lp turno2.lp -n 1
```

## Spiegazione passo passo (cosa e perche)

### 1) Normalizzare gli scontri gia giocati
In `torneo.lp`:

- `met(A,B) :- played(A,B).`
- `met(A,B) :- played(B,A).`

Perche: l'input `played/2` puo essere scritto in qualunque ordine; cosi trattiamo `played(a,b)` e `played(b,a)` come lo stesso confronto.

### 2) Costruire solo coppie valide
- `pair(A,B) :- player(A), player(B), A < B, not met(A,B).`

Perche:
- `A < B` evita duplicati speculari (`a,b` e `b,a`),
- `not met(A,B)` impone il vincolo "si affrontano una sola volta nel torneo".

### 3) Scegliere le partite del nuovo turno
- `{ match(A,B) : pair(A,B) }.`

Perche: e una scelta non deterministica tra le coppie valide. I vincoli successivi filtrano le scelte sbagliate.

### 4) Gestire il BYE in base alla parita dei partecipanti
Calcoliamo il numero di giocatori:
- `num_players(N) :- N = #count { P : player(P) }.`
- `odd :- num_players(N), N \ 2 = 1.`
- `even :- num_players(N), N \ 2 = 0.`

Poi imponiamo:
- se dispari: `1 { bye(P) : player(P), not had_bye(P) } 1 :- odd.`
- se pari: `:- even, bye(_).`

Perche:
- con numero dispari serve esattamente un BYE,
- il BYE non puo andare a chi lo ha gia ricevuto (`not had_bye(P)`),
- con numero pari non ci deve essere BYE.

### 5) Garantire copertura completa del turno
Vincoli:
- `:- bye(P), in_round(P).` (niente BYE + partita insieme)
- `:- player(P), not in_round(P), not bye(P).` (nessuno resta fuori)
- `:- player(P), 2 <= #count { Q : match(P,Q); Q : match(Q,P) }.` (massimo una partita per giocatore)

Perche: ogni giocatore deve comparire esattamente una volta nel turno, o in una partita o come BYE.

### 6) Doppio controllo no-rematch
- `:- match(A,B), met(A,B).`

Perche: ulteriore sicurezza per impedire incontri gia avvenuti.

### 7) Preferire gli spareggi (stesso punteggio)
- `diff(A,B,D) :- match(A,B), score(A,SA), score(B,SB), D = |SA-SB|.`
- `:~ diff(A,B,D). [D@1,A,B]`

Perche: minimizziamo la somma delle differenze di punteggio tra avversari. Quindi Clingo privilegia partite tra giocatori con punteggio uguale o il piu vicino possibile.

## Formato input richiesto per nuovi turni

Per ogni nuovo turno crea un file `turnoX.lp` con fatti:

```prolog
player(nome).
score(nome,punti).
played(g1,g2).
had_bye(nome).
```

Note pratiche:
- `played/2`: tutti gli incontri storici fino a quel momento,
- `had_bye/1`: tutti i giocatori che hanno gia ricevuto BYE in passato,
- se un nuovo giocatore entra, basta aggiungere `player/1` e `score/2`.

## Output
Il solver mostra solo:
- `match(g1,g2)`
- `bye(g)`

perche nel file e presente:

```prolog
#show match/2.
#show bye/1.
```
