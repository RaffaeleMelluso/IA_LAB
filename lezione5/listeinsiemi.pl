%intersezione di due set: intersez(+L1,+L2,-LI)

%caso base
intersez([],_,[]).
intersez(_,[],[]). %non è necessaria perchè copre già il caso nel ragionamento induttivo, magari è più efficiente
intersez([Head|Tail],L2,[Head|Itemp]):-
    %se so che Head fa parte di L2, allora creo una nuova lista che alla prossima chiamata avrà all'interno Head
    member(Head,L2), !,
    %faccio il cut nel caso di successo
    intersez(Tail,L2,Itemp).

%nel caso di fallimento vedo il prossimo elemento facendo la chiamata a intersez senza aggiungere la tail
intersez([_|Tail],L2,Itemp):-
    intersez(Tail,L2,Itemp).

%unione: unione(+L1,+L2,-LU)
%casi basi, ragioniamo consumando L1, quando sarà vuoto torniamo a questo caso base
%aggiungo dei cut per risparmiare tempo perchè sappiamo che quando questa si attiva siamo arrivati alla fine
unione([],L2,L2):-!.
unione(L1,[],L1):-!.

unione([Head|Tail],L2,Utemp):-
    %cut come prima
    member(Head,L2),!,
    unione(Tail,L2,Utemp).
unione([Head|Tail],L2,[Head|Utemp]):-
    unione(Tail,L2,Utemp).


%Differenza: diff(+L1,+L2,-LD)
diff([],_,[]):-!.
diff([Head|Tail],L2,[Head|Dtemp]):-
    %questo è l'operatore di not
    \+member(Head,L2),!,
    diff(Tail,L2,Dtemp).
diff([_|Tail],L2,Dtemp):-
    diff(Tail,L2,Dtemp).
