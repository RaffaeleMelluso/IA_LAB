% Caricamento dei moduli
%ci sono veramente troppi modi per caricare i file, consult, ensure_loaded, use_module...
% ho scelto consult perchè forza il caricamento ogni volta, così se faccio modifiche ai file 
%non devo ricaricare manualmente
:- consult('algoritmi.pl').       
:- consult('labirinto_azioni.pl'). 
:- consult('otto_azioni.pl').


%MAPPE DI TEST


%LABIRINTI

%:- consult('labirinti/labirinto.pl').        % mappa
%:- consult('labirinti/labirinto_impossibile.pl'). % Un labirinto senza soluzione per testare il caso negativo
:- consult('labirinti/labirinto_grande.pl'). % Un labirinto più grande per testare le prestazioni
% attenzione ida* ci mette veramente tanto su labirinto gigante
%:- consult('labirinti/labirinto_gigante.pl'). % Un labirinto gigante 200x200 per testare le prestazioni estreme

:- consult('stampe.pl').         

%GIOCHI DELL'8
%Caso stupido (1 mossa)
%iniziale_otto(otto([1,2,3,4,5,6,7,0,8])).

%Caso medio
%iniziale_otto(otto([1,2,3,5,0,6,4,7,8])).

%Caso difficile
iniziale_otto(otto([8,6,7,2,5,4,3,0,1])).

%Caso impossibile (parita' inversa, nessuna soluzione)
%iniziale_otto(otto([1,2,3,4,5,6,8,7,0])).


%PREDICATI DI AVVIO

%Predicato principale di avvio
start_astar :-
    write('=========================================='), nl,
    write('   RISOLUTORE LABIRINTO CON PROLOG (A*)   '), nl,
    write('=========================================='), nl, nl,
    
    %Controlliamo che ci sia uno stato iniziale definito
    (iniziale(_) ->
        risolvi_e_stampa
    ;
        write('ERRORE: Nessuno stato iniziale definito in labirinto.pl'), nl
    ).

start_idastar :-
    write('============================================'), nl,
    write('   RISOLUTORE LABIRINTO CON PROLOG (IDA*)   '), nl,
    write('============================================'), nl, nl,

    (iniziale(_) ->
        risolvi_ida_e_stampa
    ;
        write('ERRORE: Nessuno stato iniziale definito in labirinto.pl'), nl
    ).

%Predicati di avvio per il gioco dell'8
start_otto_astar :-
    write('============================================'), nl,
    write('   RISOLUTORE GIOCO DELL''8 CON PROLOG (A*)'), nl,
    write('============================================'), nl, nl,

    (iniziale_otto(_) ->
        risolvi_otto_e_stampa
    ;
        write('ERRORE: Nessuno stato iniziale puzzle definito in main.pl'), nl
    ).

start_otto_idastar :-
    write('=============================================='), nl,
    write('   RISOLUTORE GIOCO DELL''8 CON PROLOG (IDA*)'), nl,
    write('=============================================='), nl, nl,

    (iniziale_otto(_) ->
        risolvi_otto_ida_e_stampa
    ;
        write('ERRORE: Nessuno stato iniziale puzzle definito in main.pl'), nl
    ).

% :- start_astar.
% :- start_idastar.
% :- start_otto_astar.
% :- start_otto_idastar.
