%===============================================================================
% FILE DI TEST E ESEMPI D'USO
% File: test_examples.pl
%
% Questo file contiene esempi concreti di come usare gli algoritmi A* e IDA*
% per spiegare il funzionamento del progetto.
%===============================================================================

%===============================================================================
% TEST 1: UTILITÀ GENERICHE
%===============================================================================

% Test inserimento ordinato
test_inserimento_ordinato :-
    write('=== TEST 1: INSERIMENTO ORDINATO ==='), nl,
    
    % Creiamo nodi con valori f diversi
    N1 = nodo(5, stato1, 2, 3, []),
    N2 = nodo(3, stato2, 1, 2, []),
    N3 = nodo(7, stato3, 3, 4, []),
    
    % Inseriamo in lista ordinata
    inserisci_ordinato(N1, [], L1),
    write('Dopo primo inserimento: '), write(L1), nl,
    
    inserisci_ordinato(N2, L1, L2),
    write('Dopo secondo inserimento: '), write(L2), nl,
    
    inserisci_ordinato(N3, L2, L3),
    write('Dopo terzo inserimento: '), write(L3), nl, nl.

% Test lunghezza lista
test_lunghezza :-
    write('=== TEST 2: LUNGHEZZA LISTA ==='), nl,
    
    Lista = [pos(1,1), pos(2,2), pos(3,3)],
    lunghezza_lista(Lista, Lung),
    write('Lunghezza di '), write(Lista), write(' = '), write(Lung), nl, nl.

% Test concatenazione
test_concatenazione :-
    write('=== TEST 3: CONCATENAZIONE LISTE ==='), nl,
    
    L1 = [a, b, c],
    L2 = [d, e],
    concatena_liste(L1, L2, L3),
    write('Concatenazione di '), write(L1), write(' e '), write(L2),
    write(' = '), write(L3), nl, nl.

% Test member
test_membro :-
    write('=== TEST 4: VERIFICA APPARTENENZA ==='), nl,
    
    Lista = [pos(1,1), pos(2,2), pos(3,3)],
    (membro(pos(2,2), Lista) ->
        write('pos(2,2) è membro di '), write(Lista) ;
        write('pos(2,2) NON è membro di '), write(Lista)), nl,
    
    (membro(pos(5,5), Lista) ->
        write('pos(5,5) è membro di '), write(Lista) ;
        write('pos(5,5) NON è membro di '), write(Lista)), nl, nl.

%===============================================================================
% TEST 2: EURISTICHE
%===============================================================================

% Test euristica Euclidea
test_euristica_euclidea :-
    write('=== TEST 5: EURISTICA EUCLIDEA ==='), nl,
    
    % Distanza da pos(0,0) a pos(3,4)
    euristica_euclidea(pos(0, 0), pos(3, 4), Dist1),
    write('Distanza euclidea pos(0,0) -> pos(3,4): '),
    write(Dist1), nl,
    
    % Distanza da pos(1,1) a pos(1,1) (stessa posizione)
    euristica_euclidea(pos(1, 1), pos(1, 1), Dist2),
    write('Distanza euclidea pos(1,1) -> pos(1,1): '),
    write(Dist2), nl, nl.

% Test euristica Manhattan
test_euristica_manhattan :-
    write('=== TEST 6: EURISTICA MANHATTAN ==='), nl,
    
    % Stato goal
    State1 = puzzle([1,2,3,4,5,6,7,8,0]),
    euristica_manhattan(State1, H1),
    write('Manhattan di stato goal '), write(State1), nl,
    write('Euristica (deve essere 0): '), write(H1), nl,
    
    % Uno scambio
    State2 = puzzle([2,1,3,4,5,6,7,8,0]),
    euristica_manhattan(State2, H2),
    write('Manhattan di '), write(State2), nl,
    write('Euristica: '), write(H2), nl, nl.

%===============================================================================
% TEST 3: MODULO GIOCO DELL'8
%===============================================================================

% Test generazione azioni
test_azioni_puzzle :-
    write('=== TEST 7: GENERAZIONE AZIONI PUZZLE ==='), nl,
    
    % Buco in posizione centrale (4)
    State1 = puzzle([1,2,3,4,0,6,7,8,5]),
    azioni_puzzle(State1, Azioni1),
    write('Azioni da '), write(State1), nl,
    write('Azioni: '), write(Azioni1), nl, nl,
    
    % Buco in angolo (0)
    State2 = puzzle([0,1,2,3,4,5,6,7,8]),
    azioni_puzzle(State2, Azioni2),
    write('Azioni da '), write(State2), nl,
    write('Azioni: '), write(Azioni2), nl, nl.

% Test trasformazione puzzle
test_trasforma_puzzle :-
    write('=== TEST 8: TRASFORMAZIONE PUZZLE ==='), nl,
    
    State0 = puzzle([2,1,3,4,5,6,7,8,0]),
    write('Stato iniziale: '), write(State0), nl,
    
    % Applica spostamento nord (buco da 8 a 5)
    (trasforma_puzzle(spostamento_nord, State0, State1) ->
        write('Dopo spostamento_nord: '), write(State1), nl
    ;   write('Spostamento nord NON valido'), nl),
    
    % Applica spostamento ovest (buco da 8 a 7)
    (trasforma_puzzle(spostamento_ovest, State0, State2) ->
        write('Dopo spostamento_ovest: '), write(State2), nl
    ;   write('Spostamento ovest NON valido'), nl), nl.

%===============================================================================
% TEST 4: GENERATORI DI SUCCESSORI
%===============================================================================

% Test successori puzzle
test_successori_puzzle :-
    write('=== TEST 9: GENERATORI DI SUCCESSORI PUZZLE ==='), nl,
    
    State = puzzle([2,1,3,4,5,6,7,8,0]),
    successori_puzzle(State, Succ),
    write('Stato: '), write(State), nl,
    write('Numero successori: '),
    lunghezza_lista(Succ, NumSucc),
    write(NumSucc), nl,
    write('Successori:'), nl,
    stampa_successori(Succ), nl.

% Helper per stampare successori
stampa_successori([]).
stampa_successori([coppia(Azione, StatoNuovo, Costo)|Resto]) :-
    write('  Azione: '), write(Azione),
    write(' -> Stato: '), write(StatoNuovo),
    write(' (Costo: '), write(Costo), write(')'), nl,
    stampa_successori(Resto).

%===============================================================================
% TEST 5: ALGORITMI DI RICERCA (SIMULATI)
%===============================================================================

% Test simulato di A* su puzzle semplice
test_astar_puzzle_semplice :-
    write('=== TEST 10: A* SU PUZZLE SEMPLICE ==='), nl,
    
    % caso: due elementi scambiati
    State = puzzle([2,1,3,4,5,6,7,8,0]),
    write('Ricerca soluzione per: '), write(State), nl,
    
    (ricerca_puzzle_astar(State, Cammino, Costo) ->
        (
            write('Soluzione trovata!'), nl,
            write('Costo: '), write(Costo), nl,
            write('Numero stati nel cammino: '),
            lunghezza_lista(Cammino, Lung),
            write(Lung), nl,
            write('Primo stato: '),
            (Cammino = [Primo|_] -> write(Primo) ; write('N/A')), nl,
            write('Ultimo stato: '),
            (ultimo_elemento(Cammino, Ultimo) -> write(Ultimo) ; write('N/A')), nl
        )
    ;   write('Nessuna soluzione trovata'), nl), nl.

% Test simulato di IDA* su puzzle semplice
test_idastar_puzzle_semplice :-
    write('=== TEST 11: IDA* SU PUZZLE SEMPLICE ==='), nl,
    
    State = puzzle([2,1,3,4,5,6,7,8,0]),
    write('Ricerca soluzione per: '), write(State), nl,
    
    (ricerca_puzzle_idastar(State, Cammino, Costo) ->
        (
            write('Soluzione trovata con IDA*!'), nl,
            write('Costo: '), write(Costo), nl,
            write('Numero stati: '),
            lunghezza_lista(Cammino, Lung),
            write(Lung), nl
        )
    ;   write('Nessuna soluzione trovata'), nl), nl.

%===============================================================================
% TEST 6: COMPARAZIONE A* vs IDA*
%===============================================================================

% Comparazione su puzzle
test_comparazione_astar_vs_idastar :-
    write('=== TEST 12: COMPARAZIONE A* vs IDA* ==='), nl,
    
    State = puzzle([2,1,3,4,5,6,7,8,0]),
    
    write('Test sul puzzle: '), write(State), nl, nl,
    
    write('Esecuzione A*...'), nl,
    ricerca_puzzle_astar(State, C1, K1),
    lunghezza_lista(C1, L1),
    write('  - Costo: '), write(K1), nl,
    write('  - Lunghezza cammino: '), write(L1), nl,
    
    write('Esecuzione IDA*...'), nl,
    ricerca_puzzle_idastar(State, C2, K2),
    lunghezza_lista(C2, L2),
    write('  - Costo: '), write(K2), nl,
    write('  - Lunghezza cammino: '), write(L2), nl,
    
    write('Confronto:'), nl,
    (K1 =:= K2 ->
        write('  - Stessi costi (algoritmi ottimali): OK'), nl
    ;   write('  - ERRORE: costi diversi!'), nl),
    
    (L1 =:= L2 ->
        write('  - Stesse lunghezze: OK'), nl
    ;   write('  - Lunghezze diverse (potrebbe essere ok)'), nl), nl.

%===============================================================================
% TEST 7: PREVENZIONE CICLI
%===============================================================================

% Test path checking
test_path_checking :-
    write('=== TEST 13: PATH CHECKING ==='), nl,
    
    Cammino = [pos(1,1), pos(2,2), pos(3,3), pos(4,4)],
    StatoDentro = pos(2,2),
    StatoFuori = pos(5,5),
    
    write('Cammino: '), write(Cammino), nl,
    
    (contiene_stato(StatoDentro, Cammino) ->
        write(StatoDentro), write(' è nel cammino'), nl
    ;   write(StatoDentro), write(' NON è nel cammino'), nl),
    
    (contiene_stato(StatoFuori, Cammino) ->
        write(StatoFuori), write(' è nel cammino'), nl
    ;   write(StatoFuori), write(' NON è nel cammino'), nl), nl.

%===============================================================================
% SUITE DI TEST COMPLETA
%===============================================================================

% Esegui tutti i test
esegui_tutti_test :-
    write('==============================================='), nl,
    write('  SUITE COMPLETA DI TEST'), nl,
    write('==============================================='), nl, nl,
    
    test_inserimento_ordinato,
    test_lunghezza,
    test_concatenazione,
    test_membro,
    test_euristica_euclidea,
    test_euristica_manhattan,
    test_azioni_puzzle,
    test_trasforma_puzzle,
    test_successori_puzzle,
    test_astar_puzzle_semplice,
    test_idastar_puzzle_semplice,
    test_comparazione_astar_vs_idastar,
    test_path_checking,
    
    write('==============================================='), nl,
    write('  FINE TEST'), nl,
    write('==============================================='), nl.

% Esegui un test singolo
esegui_test(Nome) :-
    write('Esecuzione test: '), write(Nome), nl, nl,
    call(Nome),
    write('Test completato.'), nl.

%===============================================================================
% GUIDA ALL'USO DEL FILE
%===============================================================================

% Istruzioni di uso
guida :-
    write('==============================================='), nl,
    write('  GUIDA ALL\'USO DEI TEST'), nl,
    write('==============================================='), nl, nl,
    write('Comandi disponibili:'), nl, nl,
    write('1. esegui_tutti_test.'), nl,
    write('   -> Esegue tutti i test della suite'), nl, nl,
    write('2. esegui_test(test_inserimento_ordinato).'), nl,
    write('   -> Esegue un singolo test'), nl, nl,
    write('Test disponibili:'), nl,
    write('   - test_inserimento_ordinato'), nl,
    write('   - test_lunghezza'), nl,
    write('   - test_concatenazione'), nl,
    write('   - test_membro'), nl,
    write('   - test_euristica_euclidea'), nl,
    write('   - test_euristica_manhattan'), nl,
    write('   - test_azioni_puzzle'), nl,
    write('   - test_trasforma_puzzle'), nl,
    write('   - test_successori_puzzle'), nl,
    write('   - test_astar_puzzle_semplice'), nl,
    write('   - test_idastar_puzzle_semplice'), nl,
    write('   - test_comparazione_astar_vs_idastar'), nl,
    write('   - test_path_checking'), nl, nl,
    write('==============================================='), nl.

%===============================================================================
% FINE FILE TEST
%===============================================================================
