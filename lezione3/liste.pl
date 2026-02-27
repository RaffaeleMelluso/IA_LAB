/* positivi(Lista) 
    true se e solo se tutti gli elementi di Lista sono > 0
*/

% quando scriviamo un programma scriviamo tutto in positivo e lui ci scrive solo la prima soluzione che trova

%quando la lista è vuota fa parte della kb che siano tutti positivi, caso base
tuttiPositivi([]).


%chiamata ricorsiva, proteggiamo questo caso dalle liste per gestirle più avanti
tuttiPositivi([Head|Tail]):- 
    atomic(Head),
    Head>0,
    tuttiPositivi(Tail).

%se la head è una Lista allora fa la chiamata ricorsiva sulla Head, poi la fa sulla Tail
tuttiPositivi([Head|Tail]):-
    is_list(Head),
    tuttiPositivi(Head),
    tuttiPositivi(Tail).

/* contaPositivi(+Lista,-Quanti)*/
contaPositivi([],0).

%dobbiamo fare un assegnamento esplicito per aggiungere robe
contaPositivi([Head|Tail],Risultato):-
    Head > 0,
    contaPositivi(Tail,Tot),
    Risultato is Tot+1.

%caso negativo per elementi negativi, non lo contiamo nel risultato finale.
%attenzione non funziona con numeri e basta, dobbiamo fare [1] ad esempio per chiamarlo
contaPositivi([Head|Tail],Tot):-
    Head =< 0, %questo posso levarlo perchè se sono a questo punto dell'esecuzione Head è già =< 0
    contaPositivi(Tail,Tot).
%se quando lo eseguo non assegno una variabile, ma do una costante controlla se poi
%quella costante è vera o falsa
