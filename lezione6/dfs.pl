%wrapper per la ricerca in profondità
cercaDFS(ListaAzioni):-
    iniziale(S0),
    dfs(S0,[], ListaAzioni).
%ricerca in profondità, caso base
dfs(S, _, []):-
    finale(S).
%ricorsione per la ricerca in profondità, caso ricorsivo
dfs(S,Visitati, [Azione|ListaAzioni]):-
    applicabile(Azione, S),
    trasforma(Azione, S, SNuovo),
    \+member(SNuovo, Visitati),
    dfs(SNuovo, [S|Visitati], ListaAzioni).
