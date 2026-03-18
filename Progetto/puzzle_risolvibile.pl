% PUZZLE COMPLESSO RISOLVIBILE IN PIU' DI 10 MOSSE
% Puzzle 8 pre-configurato che richiede almeno 11 mosse per la soluzione
% Strutturato come labirinto.pl con fatti semplici

% puzzle_goal/1
% Lo stato obiettivo da raggiungere
puzzle_goal(puzzle([1,2,3,4,5,6,7,8,0])).

% puzzle_iniziale/1
% Puzzle risolvibile in 11+ mosse
% Stato iniziale: buco (0) in posizione 1
puzzle_iniziale(puzzle([1,0,3,4,2,5,7,8,6])).
