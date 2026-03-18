% MODULO AZIONI DEL PUZZLE - Definizioni complete per il gioco dell'8
% Contiene tutte le operazioni e trasformazioni dello stato puzzle

% azioni_puzzle(StatoCorrente, Azioni)
% Genera lista azioni valide dato uno stato
azioni_puzzle(puzzle(Tessere), Azioni) :-
    trova_buco(Tessere, 0, PosBuco),
    trovaazioni_puzzle(PosBuco, Azioni).

% trova_buco(ListaTessere, Indice, PosBuco)
% Trova la posizione del buco (0)
trova_buco([0|Resto], Indice, PosBuco) :- !, PosBuco = Indice.
trova_buco([H|Resto], Indice, PosBuco) :-
    IndiceSuccessivo is Indice + 1,
    trova_buco(Resto, IndiceSuccessivo, PosBuco).

% trovaazioni_puzzle(PosBuco, Azioni)
% Determina quali azioni sono valide dato buco in posizione
trovaazioni_puzzle(PosBuco, Azioni) :-
    AzioniBuco = [],
    (PosBuco >= 3 -> AzioniBuco1 = [spostamento_nord|AzioniBuco] ; AzioniBuco1 = AzioniBuco),
    (PosBuco < 6 -> AzioniBuco2 = [spostamento_sud|AzioniBuco1] ; AzioniBuco2 = AzioniBuco1),
    (PosBuco mod 3 > 0 -> AzioniBuco3 = [spostamento_est|AzioniBuco2] ; AzioniBuco3 = AzioniBuco2),
    (PosBuco mod 3 < 2 -> Azioni = [spostamento_ovest|AzioniBuco3] ; Azioni = AzioniBuco3).

% trasforma_puzzle(Azione, StatoAttuale, StatoNuovo)
% Applica un'azione per trasformare lo stato
trasforma_puzzle(spostamento_nord, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosToSwap is PosBuco - 3,
    PosToSwap >= 0,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

trasforma_puzzle(spostamento_sud, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosToSwap is PosBuco + 3,
    PosToSwap < 9,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

trasforma_puzzle(spostamento_est, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosModulo is PosBuco mod 3,
    PosModulo > 0,
    PosToSwap is PosBuco - 1,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

trasforma_puzzle(spostamento_ovest, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosModulo is PosBuco mod 3,
    PosModulo < 2,
    PosToSwap is PosBuco + 1,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

% scambia_elementi_lista(ListaVecchia, Pos1, Pos2, ListaNuova)
% Scambia due elementi in una lista
scambia_elementi_lista(ListaVecchia, Pos1, Pos2, ListaNuova) :-
    elemento_a_indice_lista(ListaVecchia, Pos1, Elem1),
    elemento_a_indice_lista(ListaVecchia, Pos2, Elem2),
    riponi_elemento_lista(ListaVecchia, Pos1, Elem2, ListaTemp),
    riponi_elemento_lista(ListaTemp, Pos2, Elem1, ListaNuova).

% elemento_a_indice_lista(Lista, Indice, Elemento)
% Accede a un elemento per indice (0-based)
elemento_a_indice_lista([Elemento|Resto], 0, Elemento) :- !.
elemento_a_indice_lista([H|Resto], Indice, Elemento) :-
    IndiceSuccessivo is Indice - 1,
    elemento_a_indice_lista(Resto, IndiceSuccessivo, Elemento).

% riponi_elemento_lista(ListaVecchia, Indice, NuovoElemento, ListaNuova)
% Pone un elemento a un indice specifico
riponi_elemento_lista([H|Resto], 0, NuovoElemento, [NuovoElemento|Resto]) :- !.
riponi_elemento_lista([H|Resto], Indice, NuovoElemento, [H|ListaNuova]) :-
    IndiceSuccessivo is Indice - 1,
    riponi_elemento_lista(Resto, IndiceSuccessivo, NuovoElemento, ListaNuova).

% FINE MODULE PUZZLE_AZIONI
