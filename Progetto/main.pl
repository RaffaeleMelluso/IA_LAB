% main.pl
% File principale che carica tutti i moduli necesari

:- ensure_loaded('labirinto.pl').
:- ensure_loaded('labirinto_azioni.pl').
:- ensure_loaded('puzzle_azioni.pl').
:- ensure_loaded('puzzle_risolvibile.pl').
:- ensure_loaded('search_algorithms.pl').

% Predicati pubblici disponibili:
% ricerca_labirinto_astar(Cammino, Costo)
% ricerca_labirinto_idastar(Cammino, Costo)
% ricerca_puzzle_astar(Cammino, Costo)
% ricerca_puzzle_idastar(Cammino, Costo)

% Utility di stampa:
% stampa_cammino(Cammino)
% stampa_cammino_puzzle(Cammino)

% Programma caricato. Usa:
% ?- ricerca_labirinto_astar(C, K).
% ?- ricerca_labirinto_astar(C, K), stampa_cammino(C).
% ?- ricerca_puzzle_astar(C, K), stampa_cammino_puzzle(C).
% ?- ricerca_puzzle_idastar(C, K), stampa_cammino_puzzle(C).
