% Esempio turno 2 (coerente con il testo)
%
% Turno precedente (un possibile risultato):
% - Lorenzo batte Emma
% - Simone batte Diego
% - Giada riceve BYE
%
% Nuovi partecipanti: Jacopo, Thomas, Desiree

player(lorenzo).
player(emma).
player(simone).
player(diego).
player(giada).
player(jacopo).
player(thomas).
player(desiree).

% Classifica attuale:
% Lorenzo, Simone, Giada: 2
% Emma, Diego: 0
% Nuovi arrivati: 0
score(lorenzo,2).
score(simone,2).
score(giada,2).
score(emma,0).
score(diego,0).
score(jacopo,0).
score(thomas,0).
score(desiree,0).

% Incontri gia disputati
played(lorenzo,emma).
played(simone,diego).

% BYE gia assegnato a Giada nel turno precedente
had_bye(giada).
