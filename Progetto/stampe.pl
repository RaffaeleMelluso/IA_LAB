% =================================================================================
% UTILITY E STAMPA
% =================================================================================

% stampa_percorso/2: Visualizza il percorso passo passo dal nodo Iniziale
stampa_percorso(_, []) :- 
    write(' -- FINE --'), nl.

stampa_percorso(StatoCorrente, [Azione|RestoAzioni]) :-
    write('Stato: '), write(StatoCorrente), 
    write(' -> Azione: '), write(Azione), nl,
    trasforma(Azione, StatoCorrente, NuovoStato),
    stampa_percorso(NuovoStato, RestoAzioni).

% risolvi_e_stampa/0: Lancia A*, misura il tempo e stampa le statistiche
risolvi_e_stampa :-
    iniziale(S),
    format('--- INIZIO RICERCA A* ---~nStato Iniziale: ~w~n', [S]),
    
    get_time(T_Inizio),        % Start timer
    astar(S, Soluzione),
    get_time(T_Fine),          % Stop timer
    
    length(Soluzione, NumPassi),
    Tempo is T_Fine - T_Inizio,
    
    format('~n--- RISULTATI ---~n'),
    format('Soluzione trovata!~n'),
    format('Tempo impiegato : ~3f secondi~n', [Tempo]),
    format('Numero passi    : ~d~n', [NumPassi]),
    format('-------------------~n'),
    
    (NumPassi =< 100 ->
        stampa_percorso(S, Soluzione)
    ;
        format('~n[AVVISO] Percorso troppo lungo (~d passi). Stampa omessa per leggibilita.~n', [NumPassi])
    ).

% risolvi_ida_e_stampa/0: Lancia IDA*, misura il tempo e stampa le statistiche
risolvi_ida_e_stampa :-
    iniziale(S),
    format('--- INIZIO RICERCA IDA* ---~nStato Iniziale: ~w~n', [S]),

    get_time(T_Inizio),
    idastar(S, Soluzione),
    get_time(T_Fine),

    length(Soluzione, NumPassi),
    Tempo is T_Fine - T_Inizio,

    format('~n--- RISULTATI ---~n'),
    format('Soluzione trovata!~n'),
    format('Tempo impiegato : ~3f secondi~n', [Tempo]),
    format('Numero passi    : ~d~n', [NumPassi]),
    format('-------------------~n'),

    (NumPassi =< 100 ->
        stampa_percorso(S, Soluzione)
    ;
        format('~n[AVVISO] Percorso troppo lungo (~d passi). Stampa omessa per leggibilita.~n', [NumPassi])
    ).

% risolvi_otto_e_stampa/0: Lancia A* sul gioco dell'8, misura il tempo e stampa le statistiche
risolvi_otto_e_stampa :-
    iniziale_otto(S),
    format('--- INIZIO RICERCA PUZZLE A* ---~nStato Iniziale: ~w~n', [S]),

    get_time(T_Inizio),
    astar(S, Soluzione),
    get_time(T_Fine),

    length(Soluzione, NumPassi),
    Tempo is T_Fine - T_Inizio,

    format('~n--- RISULTATI ---~n'),
    format('Soluzione trovata!~n'),
    format('Tempo impiegato : ~3f secondi~n', [Tempo]),
    format('Numero passi    : ~d~n', [NumPassi]),
    format('-------------------~n'),

    (NumPassi =< 100 ->
        stampa_percorso(S, Soluzione)
    ;
        format('~n[AVVISO] Percorso troppo lungo (~d passi). Stampa omessa per leggibilita.~n', [NumPassi])
    ).

% risolvi_otto_ida_e_stampa/0: Lancia IDA* sul gioco dell'8, misura il tempo e stampa le statistiche
risolvi_otto_ida_e_stampa :-
    iniziale_otto(S),
    format('--- INIZIO RICERCA PUZZLE IDA* ---~nStato Iniziale: ~w~n', [S]),

    get_time(T_Inizio),
    idastar(S, Soluzione),
    get_time(T_Fine),

    length(Soluzione, NumPassi),
    Tempo is T_Fine - T_Inizio,

    format('~n--- RISULTATI ---~n'),
    format('Soluzione trovata!~n'),
    format('Tempo impiegato : ~3f secondi~n', [Tempo]),
    format('Numero passi    : ~d~n', [NumPassi]),
    format('-------------------~n'),

    (NumPassi =< 100 ->
        stampa_percorso(S, Soluzione)
    ;
        format('~n[AVVISO] Percorso troppo lungo (~d passi). Stampa omessa per leggibilita.~n', [NumPassi])
    ).
    
