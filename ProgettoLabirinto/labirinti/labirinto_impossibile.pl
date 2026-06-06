% LABIRINTO SENZA SOLUZIONE
% Il goal è completamente circondato da muri

num_righe(5).
num_col(5).

iniziale(pos(1,1)).
finale(pos(5,5)).

% Muro invalicabile attorno al goal
occupata(pos(4,5)).
occupata(pos(5,4)).
