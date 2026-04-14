% Torneo Lega Pokemon - Scheduler ASP (Clingo)
% Regole generali per generare gli incontri del prossimo turno.

% -----------------------
% INPUT ATTESO (fatti)
% -----------------------
% player(nome).
% score(nome,punti).
% played(giocatore1,giocatore2).
% had_bye(nome).
%
% Note:
% - played/2 rappresenta incontri gia disputati (ordine libero).
% - had_bye/1 indica chi ha gia ricevuto il BYE in turni precedenti.

% Due giocatori si sono gia affrontati (normalizzazione ordine).
met(A,B) :- played(A,B).
met(A,B) :- played(B,A).

% Coppie candidate per il nuovo turno: nessun rematch e ordine canonico A < B.
pair(A,B) :- player(A), player(B), A < B, not met(A,B).

% Selezione libera delle partite del turno corrente.
{ match(A,B) : pair(A,B) }.

% Partecipazione al turno (tramite match).
in_round(P) :- match(P,_).
in_round(P) :- match(_,P).

% Numero partecipanti e parita.
num_players(N) :- N = #count { P : player(P) }.
odd  :- num_players(N), N \ 2 = 1.
even :- num_players(N), N \ 2 = 0.

% Se dispari: esattamente un BYE, ma solo tra chi non ha gia avuto BYE.
1 { bye(P) : player(P), not had_bye(P) } 1 :- odd.

% Se pari: nessun BYE.
:- even, bye(_).

% Un giocatore non puo avere BYE e match nello stesso turno.
:- bye(P), in_round(P).

% Ogni giocatore deve comparire esattamente una volta nel turno:
% o in un match o come BYE.
:- player(P), not in_round(P), not bye(P).

% Nessun giocatore puo giocare piu di un match nello stesso turno.
:- player(P), 2 <= #count { Q : match(P,Q); Q : match(Q,P) }.

% Sicurezza extra: non si puo schedulare un rematch.
:- match(A,B), met(A,B).

% -----------------------
% OTTIMIZZAZIONE
% -----------------------
% Preferisci accoppiamenti con punteggi uguali/simili.
% Minimizza la somma delle differenze di classifica nelle partite.
diff(A,B,D) :- match(A,B), score(A,SA), score(B,SB), D = |SA-SB|.
:~ diff(A,B,D). [D@1,A,B]

#show match/2.
#show bye/1.
