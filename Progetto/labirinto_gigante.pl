% Labirinto "Tre Vie" 200x200
% Include 3 lunghi percorsi paralleli a serpentina che si diramano all'inizio e si riuniscono alla fine.
% Ogni percorso richiede circa 12.000 passi.

:- dynamic(occupata/1).

num_righe(200).
num_col(200).

iniziale(pos(1,1)).
finale(pos(200,200)).

% Definiamo i muri tramite regole logiche

occupata(pos(R,C)) :-
    % 1. Muri Verticali (Separatori dei 3 settori)
    % C=60 e C=140 sono muri dalla riga 2 alla 198
    (C =:= 60 ; C =:= 140),
    R >= 2, R =< 198.

occupata(pos(R,C)) :-
    % 2. Muri Orizzontali (Serpentina)
    % Le righe pari sono muri, eccetto dove c'è il varco
    R > 1, R < 200,
    0 =:= R mod 2,
    \+ is_varco(R,C).  % Se è un varco, NON è occupata

% Logica dei Varchi per i 3 settori
% Settore 1: Colonne 1-59
% Settore 2: Colonne 61-139
% Settore 3: Colonne 141-200

% --- Settore 1 ---
is_varco(R, 1) :-   % Varco SX
    C < 60, 2 =:= R mod 4.
is_varco(R, 59) :-  % Varco DX (vicino al muro 60)
    C < 60, 0 =:= R mod 4.

% --- Settore 2 ---
is_varco(R, 61) :-  % Varco SX (vicino al muro 60)
    C > 60, C < 140, 2 =:= R mod 4.
is_varco(R, 139) :- % Varco DX (vicino al muro 140)
    C > 60, C < 140, 0 =:= R mod 4.

% --- Settore 3 ---
is_varco(R, 141) :- % Varco SX (vicino al muro 140)
    C > 140, 2 =:= R mod 4.
is_varco(R, 200) :- % Varco DX (Fine griglia)
    C > 140, 0 =:= R mod 4.

% Nota: 
% Riga 1 è tutta libera (permette di scegliere il settore).
% Riga 199/200 sono libere dai muri orizzontali (permettono di raggiungere l'uscita).
