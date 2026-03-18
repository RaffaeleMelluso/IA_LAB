inverti(Lista, LInv):-
    inv(Lista, [], LInv).
%caso base, ho considerato tutti gli elementi mettendoli in testa, temp è diventata la lista finale invertita
inv([],Temp, Temp).

%prendo la testa e la metto in cima alla lista, richiamo il metodo con la tail
inv([Head|Tail],Temp,LInv):-
    inv(Tail, [Head|Temp],LInv).


