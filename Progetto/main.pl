% Caricamento dei moduli
%ci sono veramente troppi modi per caricare i file, consult, ensure_loaded, use_module...
% ho scelto consult perchè forza il caricamento ogni volta, così se faccio modifiche ai file 
%non devo ricaricare manualmente
:- consult('algoritmi.pl').       
:- consult('labirinto_azioni.pl'). 

%:- consult('labirinti/labirinto.pl').        % mappa
%:- consult('labirinti/labirinto_impossibile.pl'). % Un labirinto senza soluzione per testare il caso negativo
%:- consult('labirinti/labirinto_grande.pl'). % Un labirinto più grande per testare le prestazioni
:- consult('labirinti/labirinto_gigante.pl'). % Un labirinto gigante 200x200 per testare le prestazioni estreme

:- consult('stampe.pl').         

% Predicato principale di avvio
start_astar :-
    write('=========================================='), nl,
    write('   RISOLUTORE LABIRINTO CON PROLOG (A*)   '), nl,
    write('=========================================='), nl, nl,
    
    % Controlliamo che ci sia uno stato iniziale definito
    (iniziale(_) ->
        risolvi_e_stampa
    ;
        write('ERRORE: Nessuno stato iniziale definito in labirinto.pl'), nl
    ).

start_ida :-
    write('============================================'), nl,
    write('   RISOLUTORE LABIRINTO CON PROLOG (IDA*)   '), nl,
    write('============================================'), nl, nl,

    (iniziale(_) ->
        risolvi_ida_e_stampa
    ;
        write('ERRORE: Nessuno stato iniziale definito in labirinto.pl'), nl
    ).

% :- start_astar.
% :- start_ida.
