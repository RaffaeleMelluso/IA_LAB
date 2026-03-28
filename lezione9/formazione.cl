posizione(1..4).
giocatore(charlie; kirk; epstein; pdiddy; paolo; ruffini; trump).
resa(charlie, 4, 9).
resa(kirk, 4, 8).
resa(epstein, 1, 7).
resa(epstein, 2, 6).
resa(paolo, 1, 3).
resa(trump, 1, 0).
resa(trump, 3, 10).
resa(trump, 4, 8).
resa(epstein, 3, 9).
resa(epstein, 4, 7).
resa(kirk, 2, 10).
resa(ruffini, 2, 9).
resa(ruffini, 1, 8).
%problema, assegna a pdiddy ma noi non sappiamo la sua resa, quindi non possiamo assegnarlo a nessuna posizione
1 {assegna(G,P): giocatore(G)} 1 :- posizione(P).
%problema, mette un giocatore in 2 posizioni.
%soluzione, metto condizione con massimo 1 giocatore per posizione, e massimo 1 posizione per giocatore
{assegna(G,P): posizione(P)} 1 :- giocatore(G).
%soluzione, regola senza testa che dice che se assegno un giocatore a una posizione, 
%allora non è vero che quel giocatore ha quella resa in quella posizione
:- assegna(G,P), not resa(G,P,_).


%problema, non fa l'assegnazione con la resa più alta
%soluzione, faccio la somma di tutti gli R con dominio di assegna e resa.
resaTotale(RTot):- RTot = #sum{R: assegna(G,P), resa(G,P,R)}.
#maximize{RTot: resaTotale(RTot)}.
#show assegna/2.
#show resaTotale/1.
