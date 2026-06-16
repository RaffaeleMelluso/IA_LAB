%Genera gli incontri del prossimo turno senza rematch

%Due giocatori si sono già affrontati (controlla in entrambi gli ordini)
affrontato(A,B) :- giocato(A,B).
affrontato(A,B) :- giocato(B,A).

%Coppie di giocatori possibili per il nuovo turno: no rematch e sono in ordine
coppia(A,B):- giocatore(A), giocatore(B), A < B, not affrontato(A,B).

%Selezione libera degli incontri del turno
%genera tutti gli incontri tali che il dominio sono le coppie A e B
{ incontro(A,B) : coppia(A,B) }.

%Giocatori che partecipano al turno (tramite un incontro)
%un P è già sorteggiato in un turno se si trova a sx o dx nel 
%incontro
nelTurno(P):- incontro(P,_).
nelTurno(P):- incontro(_,P).

%Conta il numero di giocatori e verifica se dispari o pari
%utilizzo l'aggregatore che conta un N tale che ogni p che è un 
%giocatore
numGiocatori(N):- N = #count { P : giocatore(P) }.
dispari:- numGiocatori(N), N \ 2 = 1.
pari:- numGiocatori(N), N \ 2 = 0.

%Se dispari: esattamente un bye a chi non l'ha mai avuto
1 { bye(P) : giocatore(P), not avutobye(P) } 1 :- dispari.

%:- senza nulla a sx, vincolo
%scarta ogni soluzione tale che quello a dx

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

%Applica una penalità pari alla distanza dei punteggi con una etichetta D,A,B
%weak constraint è un modo più recente per scrivere minimize
:~ differenza(A,B,D). [D, A, B]

#show incontro/2.
#show bye/1.
