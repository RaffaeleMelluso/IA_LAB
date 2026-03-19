:-ensure_loaded('inversionelista.pl').

/*
struttura del nodo per implementare A*
nodo(F, Stato, G, H, ListaAzioni)
dove F=G+H e ListaAzioni è la lista delle mosse fatte per arrivare a Stato
*/


%IMPLEMENTAZIONE DI A* E IDA*: GESTIONE ORDINAMENTO DEI NODI

%caso base
inserisci_ordinato(NodoNuovo, [], [NodoNuovo]):-!.

%caso di inserimento in testa alla lista
inserisci_ordinato(nodo(F1,S1,G1,H1,Az1), [nodo(F2,S2,G2,H2,Az2)|Tail], [nodo(F1, S1, G1, H1, Az1), nodo(F2, S2, G2, H2, Az2)|Tail] ) :-
    %il nodo da inserire (1) ha F minore o uguale a quello del nodo in testa alla lista (2)
    %se F1 è minore o uguale a F2, inserisco il nodo nuovo in testa alla lista e 
    %faccio il cut per evitare di cercare altre soluzioni
    F1 =< F2, !.

%caso di scorrimento della lista
inserisci_ordinato(nodo(F1,S1,G1,H1,Az1), [nodo(F2,S2,G2,H2,Az2)|Tail], [nodo(F2, S2, G2, H2, Az2)|TailNuova]) :-
    %altrimenti, se F1 è maggiore di F2, continuo a cercare la posizione corretta 
    %per inserire il nodo nuovo
    F1 > F2,
    inserisci_ordinato(nodo(F1,S1,G1,H1,Az1), Tail, TailNuova).



%PARTE RELATIVA AL CALSOCLO DELLA DISTANZA MANHATTAN

manhattan(pos(R,C), Distanza) :-
    finale(pos(R_GOAL, C_GOAL)),
    Distanza is abs(R - R_GOAL) + abs(C - C_GOAL).


%A* WRAPPER

astar(Inizio, Soluzione) :-
    %calcolo la distanza manhattan del nodo iniziale
    manhattan(Inizio, H),

    %creo il nodo iniziale con F=G+H, dove G=0
    NodoIniziale = nodo(H, Inizio, 0, H, []),

    %inizio la ricerca dei nodi da esplorare 
    astar_ricerca([NodoIniziale], [], SoluzioneInversa),
    inverti(SoluzioneInversa, Soluzione).

%A* RICERCA

%caso base: se il nodo in testa alla lista è un nodo finale, restituisco la soluzione
%in ordine i _ sono: F, Stato, G, H, Azioni|Tail, Essplorati, Soluzione
astar_ricerca([nodo(_, Stato, _, _, Azioni)|_], _, Azioni) :-
    finale(Stato), !.

%caso ricorsivo di esplorazione dei nodi
astar_ricerca([NodoAttuale|Tail], Esplorati, Soluzione) :-
    %in ordine i parametri sono: F, Stato, G, H, Azioni
    NodoAttuale = nodo(_, Stato, _, _, _),
    
    % Trova tutti i successori validi
    % chiama generasuccessore, lo mette in child e lo aggiunge alla lista dei figli 
    % se non è già stato esplorato
    findall(Child, genera_successore(NodoAttuale, Esplorati, Child), ListaFigli),
    
    % Inserisce la lista dei figli nella lista FigliAperti ordinata
    % n.b. Tail è la coda della lista dei nodi aperti, che non è stata ancora esplorata
    inserisci_lista_ordinata(ListaFigli, Tail, FigliAperti),
    
    % Continua la ricerca
    astar_ricerca(FigliAperti, [Stato|Esplorati], Soluzione).

% funzione che genera un nodo figlio a partire da un nodo padre, controllando che lo stato 
% figlio non sia già stato esplorato
% in ordine i parametri di nodo sono: F, Stato, G, H, Azioni
genera_successore(nodo(_, Stato, G, _, Azioni), Esplorati, NodoFiglio) :-
    %n.b. applicabile e trasforma si trovano nel labirinto_azioni.pl
    applicabile(Azione, Stato),
    trasforma(Azione, Stato, StatoFiglio),
    % Controllo che lo stato figlio non sia già stato esplorato per evitare cicli
    \+ member(StatoFiglio, Esplorati),  
    
    %aggiorno il costo del g aumentando di 1 rispetto al nodo padre,
    % calcolo l'euristica manhattan per il nodo figlio e
    % calcolo il costo totale F del nodo figlio come somma di G e H
    GFiglio is G + 1,
    manhattan(StatoFiglio, HFiglio),
    FFiglio is GFiglio + HFiglio,
    
    % Costruisco la lista azioni in testa [Azione|Azioni] (più efficiente)
    % Sarà invertita alla fine da reverse/2 nel wrapper astar
    NodoFiglio = nodo(FFiglio, StatoFiglio, GFiglio, HFiglio, [Azione|Azioni]).

% funzione che inserisce una lista di nodi ordinati in un'altra lista ordinata
% se la lista da inserire è vuota, restituisce la lista originale
inserisci_lista_ordinata([], L, L).
% se la lista da inserire non è vuota, inserisce il primo elemento in modo ordinato e poi 
%ricorsivamente il resto della lista
inserisci_lista_ordinata([H|T], L, Risultato) :-
    inserisci_ordinato(H, L, Temp),
    inserisci_lista_ordinata(T, Temp, Risultato).

