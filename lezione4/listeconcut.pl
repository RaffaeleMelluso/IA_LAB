contaPositivi([],0).

contaPositivi([Head|Tail],Risultato):-
    Head > 0,!, 
    %quando incontro un elemento positivo, lo conto e poi faccio cut per evitare 
    %tutte le altre alternative di contaPositivi, così se incontro un elemento positivo 
    %non vado a controllare se è negativo o altro, vado direttamente alla chiamata ricorsiva successiva
    contaPositivi(Tail,Tot),
    Risultato is Tot+1.

contaPositivi([_|Tail],Tot):-
    %con il cut nell'altra definizione se head > 0 
    %non vado a controllare se è <= 0, 
    %quindi se sono qui è perchè head è <= 0,
    % e quindi se è >0 chiude questo ramo fino alla prossima chiamata
    % cioè quella di un altro elemento della lista.
    contaPositivi(Tail,Tot).


prova(X):-
    !,
    member(X,[1,2,3,4,5]),
    member(X,[4,5,10,50]).
prova(127).

%usato così il cut trova la prima soluzione, cioè 4, e poi non torna indietro per cercare altre soluzioni,
%quindi se faccio prova(X) restituisce X=4 e non X=5, perchè quando trova 4 fa cut e non torna indietro per cercare altre soluzioni
%se faccio prova(127) restituisce false, perchè quando arriva a prova(127) fa cut e non torna indietro per cercare altre soluzioni
%CUT ci permette di limitare le guardie nelle regole.