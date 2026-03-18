% Test per debug del puzzle

test_astar :-
    puzzle_iniziale(I),
    puzzle_goal(G),
    format('Stato iniziale: ~w~n', [I]),
    format('Stato goal: ~w~n', [G]),
    euristica_manhattan(I, H),
    format('Euristica iniziale: ~w~n', [H]),
    azioni_puzzle(I, Az),
    format('Azioni disponibili: ~w~n', [Az]),
    member(Az1, Az),
    trasforma_puzzle(Az1, I, S1),
    format('Dopo ~w: ~w~n', [Az1, S1]),
    fail.

test_astar :- write('Fine test'), nl.

:- [main].
:- test_astar.
:- halt.
