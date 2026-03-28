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
    
    %Trova tutti i successori validi
    %chiama generasuccessore, lo mette in child e lo aggiunge alla lista dei figli 
    %se non è già stato esplorato
    findall(Child, genera_successore(NodoAttuale, Esplorati, Child), ListaFigli),
    
    %Inserisce la lista dei figli nella lista FigliAperti ordinata
    %n.b. Tail è la coda della lista dei nodi aperti, che non è stata ancora esplorata
    inserisci_lista_ordinata(ListaFigli, Tail, FigliAperti),
    
    %Continua la ricerca
    astar_ricerca(FigliAperti, [Stato|Esplorati], Soluzione).

%funzione che genera un nodo figlio a partire da un nodo padre, controllando che lo stato 
%figlio non sia già stato esplorato
%in ordine i parametri di nodo sono: F, Stato, G, H, Azioni
genera_successore(nodo(_, Stato, G, _, Azioni), Esplorati, NodoFiglio) :-
    %n.b. applicabile e trasforma si trovano nel labirinto_azioni.pl
    applicabile(Azione, Stato),
    trasforma(Azione, Stato, StatoFiglio),
    %Controllo che lo stato figlio non sia già stato esplorato per evitare cicli
    \+ member(StatoFiglio, Esplorati),  
    
    %aggiorno il costo del g aumentando di 1 rispetto al nodo padre,
    %calcolo l'euristica manhattan per il nodo figlio e
    %calcolo il costo totale F del nodo figlio come somma di G e H
    GFiglio is G + 1,
    manhattan(StatoFiglio, HFiglio),
    FFiglio is GFiglio + HFiglio,
    
    %Costruisco la lista azioni in testa [Azione|Azioni] (più efficiente)
    %Sarà invertita alla fine da reverse/2 nel wrapper astar
    NodoFiglio = nodo(FFiglio, StatoFiglio, GFiglio, HFiglio, [Azione|Azioni]).

%funzione che inserisce una lista di nodi ordinati in un'altra lista ordinata
%se la lista da inserire è vuota, restituisce la lista originale
inserisci_lista_ordinata([], L, L).
%se la lista da inserire non è vuota, inserisce il primo elemento in modo ordinato e poi 
%ricorsivamente il resto della lista
inserisci_lista_ordinata([H|T], L, Risultato) :-
    inserisci_ordinato(H, L, Temp),
    inserisci_lista_ordinata(T, Temp, Risultato).










%IDA*, è come A* ma con una profondità limite che viene aumentata ad ogni iterazione, 
%fino a quando non si trova la soluzione, inoltre non mantiene la lista dei nodi aperti
%perchè usa la ricerca in profondità.
idastar(Inizio, Soluzione) :-
    manhattan(Inizio, H),
    ida_star_ricerca(Inizio, H, H, SoluzioneInversa),
    inverti(SoluzioneInversa, Soluzione).

%creo un wrapper per discriminare i casi di soluzione trovata e di limite superato, 
%in modo da non dover gestire questi casi all'interno della funzione di ricerca in profondità

%Caso base: soluzione trovata
ida_star_ricerca(Inizio, Soglia, _, Soluzione) :-
    ida_dfs(Inizio, 0, Soglia, [Inizio], trovato(Soluzione)), !.

%Caso ricorsivo: nessuna soluzione, aggiorno la soglia
ida_star_ricerca(Inizio, Soglia, _, Soluzione) :-
    ida_dfs(Inizio, 0, Soglia, [Inizio], limite(NuovaSoglia)),
    NuovaSoglia \= infinito,
    NuovaSoglia > Soglia,
    ida_star_ricerca(Inizio, NuovaSoglia, Soglia, Soluzione).



%parte relativa alla ricerca in profondità con limite per IDA*
%caso base: nodo finale trovato nella soglia
ida_dfs(Stato, G, Soglia, _, trovato([])) :-
    %controllo se lo stato è finale
    finale(Stato),
    %calcolo la distanza di manhattan
    manhattan(Stato, H),
    F is G + H,
    %se F è nella soglia, allora ho trovato la soluzione
    F =< Soglia, !.

%caso soglia superata
ida_dfs(Stato, G, Soglia, _, limite(F)):-
    manhattan(Stato, H),
    F is G + H,
    %se F è maggiore della soglia, restituisco il costo F per aggiornare la soglia 
    %nella ricerca ricorsiva
    F > Soglia, !.

%caso f minore della soglia, continuo a esplorare i figli
ida_dfs(Stato, G, Soglia, Visitati, Esito):-
    %cerco tutti i successori validi
    findall(azione_stato(Azione, StatoFiglio), 
            successore_valido_ida(Stato, Visitati, Azione, StatoFiglio), 
            Successori),
    %esploro i successori uno alla volta
    esplora_successori_ida(Successori, G, Soglia, Visitati, Esito).

%controllo se un successore è valido, cioè se l'azione è applicabile, 
%se lo stato figlio è diverso da quelli già visitati per evitare cicli
%in quel caso, applico l'azione per ottenere lo stato figlio e 
%restituisco l'azione e lo stato figlio
successore_valido_ida(Stato, Visitati, Azione, StatoFiglio) :-
    applicabile(Azione, Stato),
    trasforma(Azione, Stato, StatoFiglio),
    \+ member(StatoFiglio, Visitati).
    

%caso in cui non ci sono successori da esplorare
%restituisco costo infinito
esplora_successori_ida([], _, _, _, limite(infinito)):- !.

%esplora un figlio e combina il suo esito con quello dei fratelli restanti
esplora_successori_ida([azione_stato(Azione, StatoFiglio)|Resto], G, Soglia, Visitati, Esito) :-
    GFiglio is G + 1,
    ida_dfs(StatoFiglio, GFiglio, Soglia, [StatoFiglio|Visitati], EsitoFiglio),
    combina_esito_successori(Azione, EsitoFiglio, Resto, G, Soglia, Visitati, Esito).

%se il figlio trova soluzione, aggiungo l'azione in testa e termino
combina_esito_successori(Azione, trovato(SoluzioneFiglio), _, _, _, _, trovato([Azione|SoluzioneFiglio])) :- !.

%se il figlio supera la soglia, esploro i fratelli e combino gli esiti
combina_esito_successori(_, limite(SogliaFiglio), Resto, G, Soglia, Visitati, Esito) :-
    esplora_successori_ida(Resto, G, Soglia, Visitati, EsitoResto),
    combina_limite_o_soluzione(SogliaFiglio, EsitoResto, Esito).

%se tra i fratelli c'è una soluzione, propago subito la soluzione
combina_limite_o_soluzione(_, trovato(Soluzione), trovato(Soluzione)) :- !.

%se non c'è soluzione tra i fratelli, tengo il minimo sforamento
combina_limite_o_soluzione(SogliaFiglio, limite(SogliaResto), Esito) :-
    min_esito_ida(SogliaFiglio, SogliaResto, Esito).

%parte relaticva al trovare il minimo tra due figli che hanno superato la soglia
min_esito_ida(infinito, S, limite(S)) :- !.
min_esito_ida(S, infinito, limite(S)) :- !.
min_esito_ida(S1, S2, limite(Min)) :- Min is min(S1, S2).


