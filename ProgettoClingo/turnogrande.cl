% Turno con 20 giocatori (pari) divisi in fasce di punteggio. Nessun bye richiesto.

% --- Giocatori ---
giocatore(g1). giocatore(g2). giocatore(g3). giocatore(g4). giocatore(g5). 
giocatore(g6). giocatore(g7). giocatore(g8). giocatore(g9). giocatore(g10).
giocatore(g11). giocatore(g12). giocatore(g13). giocatore(g14). giocatore(g15). 
giocatore(g16). giocatore(g17). giocatore(g18). giocatore(g19). giocatore(g20).

% --- Punteggi ---
% Fascia 1 (I leader)
punteggio(g1,12). punteggio(g2,11). punteggio(g3,11). punteggio(g4,12).

% Fascia 2 (Gli inseguitori)
punteggio(g5,9). punteggio(g6,9). punteggio(g7,7). 
punteggio(g8,8). punteggio(g9,8). punteggio(g10,8).

% Fascia 3 (Metà bassa)
punteggio(g11,6). punteggio(g12,5). punteggio(g13,6). 
punteggio(g14,6). punteggio(g15,4). punteggio(g16,6).

% Fascia 4 (Ultimi)
punteggio(g17,2). punteggio(g18,2). punteggio(g19,1). punteggio(g20,0).

% --- Storico Incontri ---
% Aggiungiamo qualche match già giocato all'interno delle stesse fasce 
% per costringere il solver a incrociare in modo intelligente
giocato(g1,g2).
giocato(g3,g4).
giocato(g5,g6).
giocato(g17,g18).
giocato(g19,g20).