:- ensure_loaded('labirinto.pl'). 
:- ensure_loaded('labirinto_azioni.pl'). 
/*
    la ricerca in ampiezza (BFS) utilizza una coda per visitare i nodi, 
    in questo modo si garantisce che vengano esplorati tutti i nodi a una certa 
    profondità prima di passare a quella successiva
    Non lo facevamo nel dfs perchè per come è fatto prolog,
    utilizza la ricorsione come se fosse una pila.
    Qui devo farlo a mano.
*/
cercaBFS(ListaAzioni):-
    iniziale(S0),
    bfs([[S0,[]]], [], ListaInv),
    inverti(ListaInv, ListaAzioni).

inverti([],[]).
inverti([Head|Tail], Res):-
    inverti(Tail, InvT),
    append(InvT, [Head], Res).

%caso base, se il primo elemento della coda è finale, allora ho trovato la soluzione
%quando sono arrivato alla fine della coda
%lista To S è la lista delle azioni che ho fatto per arrivare ad S
bfs([[S,ListaToS]|_], _, ListaToS):-
    finale(S),!.

%caso ricorsivo, se il primo elemento della coda non è finale, allora lo espando e aggiungo i suoi figli alla coda
bfs([[S,ListaToS]|Tail], Visitati,ListaRisultato):-
    findall(Az,applicabile(Az,S),ListaAzioni),
    generaFigli(ListaAzioni,S,Visitati,ListaToS,ListaFigli),
    append(Tail,ListaFigli,NuovaCoda),
    bfs(NuovaCoda,[S|Visitati],ListaRisultato).
generaFigli([],_,_,_,[]).
%caso se abbiamo trovato un figlio valido, allora lo aggiungiamo alla coda 
%e passiamo al prossimo elemento della coda
generaFigli([Az|Tail], S, Visitati, ListaToS,[[SNuovo,[Az|ListaToS]]|AltriFigli]):-
    trasforma(Az,S,SNuovo),
    \+member(SNuovo,Visitati),!,
    generaFigli(Tail, S, Visitati, ListaToS, AltriFigli).

%caso se non abbiamo trovato un figlio valido, 
%allora non aggiungiamo nulla alla coda e passiamo al prossimo elemento della coda
generaFigli([_|Tail], S, Visitati, ListaToS, AltriFigli):-
    generaFigli(Tail,S,Visitati,ListaToS,AltriFigli).




