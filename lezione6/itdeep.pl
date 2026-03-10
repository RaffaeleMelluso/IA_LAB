:- ensure_loaded('labirinto.pl'). 
:- ensure_loaded('labirinto_azioni.pl'). 
/*
    la soglia serve a fare un tot numero di chiamate ricorsive nell'algoritmo.
    impostiamo una soglia per la ricerca, in questo modo mettiamo un freno all'algoritmo 
    che altrimenti potrebbe non terminare, se il labirinto è troppo grande o se ci sono cicli,
    in questo modo invece, se la soglia è troppo bassa, l'algoritmo termina senza trovare una soluzione,
    se invece è troppo alta, l'algoritmo potrebbe impiegare molto tempo per terminare,
    quindi è importante scegliere una soglia adeguata.

*/
iterativeDeepening(ListaAzioni):-id(ListaAzioni, 1).
id(ListaAzioni, Soglia):-
    cercaDFS(ListaAzioni, Soglia),!.
id(ListaAzioni, Soglia):-
    S1 is Soglia+1,
    id(ListaAzioni, S1).
    

%wrapper per la ricerca in profondità
cercaDFS(ListaAzioni, Soglia):-
    iniziale(S0),
    dfs(S0,[],Soglia, ListaAzioni).
%ricerca in profondità, caso base, non mi importa nè dei visitati ne della soglia
dfs(S, _, _, []):-
    finale(S).
%ricorsione per la ricerca in profondità, caso ricorsivo
dfs(S,Visitati,Soglia, [Azione|ListaAzioni]):-
    Soglia>0,
    applicabile(Azione, S),
    trasforma(Azione, S, SNuovo),
    \+member(SNuovo, Visitati),
    S1 is Soglia-1,
    dfs(SNuovo, [S|Visitati], S1, ListaAzioni).

