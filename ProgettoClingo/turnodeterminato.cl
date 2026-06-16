% Turno avanzato con 5 giocatori: 1 solo modello (soluzione) possibile.

giocatore(p1).
giocatore(p2).
giocatore(p3).
giocatore(p4).
giocatore(p5).

punteggio(p1,6).
punteggio(p2,6).
punteggio(p3,6).
punteggio(p4,6).
punteggio(p5,6).

% Vincolo 1: p1, p2, p3 e p4 hanno già riposato nei turni precedenti.
% Conseguenza: p5 DEVE obbligatoriamente ricevere il bye in questo turno.
avutobye(p1).
avutobye(p2).
avutobye(p3).
avutobye(p4).

% Vincolo 2: Di p1, p2, p3 e p4, quasi tutti si sono già affrontati.
% Le uniche coppie legali rimaste sono p1 contro p3, e p2 contro p4.
giocato(p1,p2).
giocato(p3,p4).
giocato(p1,p4).
giocato(p2,p3).

% Aspettativa: Clingo troverà esattamente 1 modello.
% bye(p5), incontro(p1,p3), incontro(p2,p4).