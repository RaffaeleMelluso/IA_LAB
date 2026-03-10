:- ensure_loaded('labirinto.pl'). 
:- ensure_loaded('labirinto_azioni.pl'). 
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

/* non uso strutture dati a supporto per la ricerca, come code o stack, ma uso la ricorsione per tenere traccia dei visitati e della soglia,
    in questo modo evito di dover gestire manualmente queste strutture dati
*/