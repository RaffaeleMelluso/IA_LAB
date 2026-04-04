:- multifile applicabile/2.
:- multifile trasforma/3.

/*
    struttura indice di PosVuoto
    0 1 2
    3 4 5
    6 7 8

    struttura colonna
    0 1 2
*/
%concettualmente la colonna ci serve per capire se possiamo spostare a destra o a sinistra,
%se siamo nella colonna 0 non possiamo spostare a sinistra, se siamo
%nella colonna 2 non possiamo spostare a destra, forza giuve se me ne scordo sono fesso
applicabile(nord, otto(Tessere)):-
    posizioneVuoto(Tessere, PosVuoto),
    PosVuoto>2.

applicabile(sud, otto(Tessere)):-
    posizioneVuoto(Tessere, PosVuoto),
    PosVuoto<6.
applicabile(ovest, otto(Tessere)):-
    posizioneVuoto(Tessere, PosVuoto),
    Colonna is PosVuoto mod 3,
    Colonna>0.

applicabile(est, otto(Tessere)):-
    posizioneVuoto(Tessere, PosVuoto),
    Colonna is PosVuoto mod 3,
    Colonna<2.

trasforma(nord, otto(Tessere), otto(Nuove)):-
    posizioneVuoto(Tessere, PosVuoto),
    Scambio is PosVuoto-3,
    scambia(Tessere, PosVuoto, Scambio, Nuove).

trasforma(sud, otto(Tessere), otto(Nuove)):-
    posizioneVuoto(Tessere, PosVuoto),
    Scambio is PosVuoto+3,
    scambia(Tessere, PosVuoto, Scambio, Nuove).

trasforma(ovest, otto(Tessere), otto(Nuove)):-
    posizioneVuoto(Tessere, PosVuoto),
    Scambio is PosVuoto-1,
    scambia(Tessere, PosVuoto, Scambio, Nuove).

trasforma(est, otto(Tessere), otto(Nuove)):-
    posizioneVuoto(Tessere, PosVuoto),
    Scambio is PosVuoto+1,
    scambia(Tessere, PosVuoto, Scambio, Nuove).
%predicati che restituiscono in che posizione si trova il buco
posizioneVuoto([0|_], 0):- !.
posizioneVuoto([_|Tail], Posizione):-
    posizioneVuoto(Tail, PosTail),
    Posizione is PosTail+1.
%restituisce l'elemento nella posizione desiderata
elemento_in_posizione([H|_], 0, H):-!.
elemento_in_posizione([_|Tail], Pos, Elem):-
    Pos>0,
    PosNuova is Pos-1,
    elemento_in_posizione(Tail, PosNuova, Elem).
%sostituisce l'elemento nella posizione desiderata con un nuovo elemento
sostituisci_in_posizione([_|Tail], 0, Nuovo, [Nuovo|Tail]):- !.
sostituisci_in_posizione([H|Tail], Pos, Nuovo, [H|Ris]):-
    Pos>0,
    PosNuova is Pos-1,
    sostituisci_in_posizione(Tail, PosNuova, Nuovo, Ris).
%scambia l'elemento nella posizione 1 con quello nella posizione 2, restituisce la nuova lista
scambia(Lista, Pos1, Pos2, ListaNuova):-
    elemento_in_posizione(Lista, Pos1, Elem1),
    elemento_in_posizione(Lista, Pos2, Elem2),
    sostituisci_in_posizione(Lista, Pos1, Elem2, Temp),
    sostituisci_in_posizione(Temp, Pos2, Elem1, ListaNuova).