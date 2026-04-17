%Genera gli incontri del prossimo turno senza rematch

%Due giocatori si sono già affrontati (controlla in entrambi gli ordini)
affrontato(A,B) :- giocato(A,B).
affrontato(A,B) :- giocato(B,A).

%Coppie di giocatori possibili per il nuovo turno: no rematch e sono in ordine
coppia(A,B):- giocatore(A), giocatore(B), A < B, not affrontato(A,B).

%Selezione libera degli incontri del turno
{ incontro(A,B) : coppia(A,B) }.

%Giocatori che partecipano al turno (tramite un incontro)
nelTurno(P):- incontro(P,_).
nelTurno(P):- incontro(_,P).

%Conta il numero di giocatori e verifica se dispari o pari
numGiocatori(N):- N = #count { P : giocatore(P) }.
dispari:- numGiocatori(N), N \ 2 = 1.
pari:- numGiocatori(N), N \ 2 = 0.

%Se dispari: esattamente un bye a chi non l'ha mai avuto
1 { bye(P) : giocatore(P), not avutobye(P) } 1 :- dispari.

%Se pari: nessun bye
:- pari, bye(_).

%Un giocatore non può avere bye e incontro nello stesso turno
:- bye(P), nelTurno(P).

%ogni giocatore deve comparire esattamente una volta: incontro o bye
:- giocatore(P), not nelTurno(P), not bye(P).

%Nessuno può giocare più di un incontro nello stesso turno
:- giocatore(P), 2 <= #count { Q : incontro(P,Q); Q : incontro(Q,P) }.

%Controllo extra: no rematch assoluti
:- incontro(A,B), affrontato(A,B).

%Preferisci abbinamenti con punteggi simili
differenza(A,B,D):- incontro(A,B), punteggio(A,SA), punteggio(B,SB), D = |SA-SB|. %modulo


:~ differenza(A,B,D). [1]

#show incontro/2.
#show bye/1.
