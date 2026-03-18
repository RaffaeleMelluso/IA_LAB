%===============================================================================
% ALGORITMI DI RICERCA A* E IDA* CON SUPPORTO PER LABIRINTI E GIOCO DELL'8
% File: search_algorithms.pl
%
% DESCRIZIONE GENERALE:
% Implementazione modulare di A* (A-Star) e IDA* (Iterative Deepening A*)
% per problemi di ricerca in spazio di stati. Include supporto per:
% - Labirinti generici
% - Gioco dell'8 (8-puzzle)
% Euristiche: Manhattan (per gioco dell'8), Euclidea (per labirinti)
%
% MODULI PRINCIPALI:
% 1. UTILITY GENERICHE - Operazioni su liste e insiemi
% 2. EURISTICHE - Funzioni di stima per A*
% 3. LABIRINTI - Gestione labirinti
% 4. GIOCO DELL'8 - Rappresentazione e azioni del puzzle
% 5. A* - Algoritmo A* per ricerca ottimale
% 6. IDA* - Algoritmo IDA* per ricerca iterativa
% 7. INTEGRAZIONE - Funzioni pubbliche e test
%
% USO:
% Ricerca labirinto: ricerca_labirinto_astar(Cammino, Costo)
%                     ricerca_labirinto_idastar(Cammino, Costo)
% Ricerca 8-puzzle:  ricerca_puzzle_astar(StatoIniziale, Cammino, Costo)
%                     ricerca_puzzle_idastar(StatoIniziale, Cammino, Costo)
%===============================================================================

%===============================================================================
% SEZIONE 1: MODULO UTILITY GENERICHE
%===============================================================================

%--- Inserimento in lista ordinata mantenendo ordine ---
% inserisci_ordinato(Elemento, Lista, Risultato)
% Inserisce Elemento in Lista mantenendo ordinamento per primo argomento
% Uso: inserisci_ordinato(f(5), [f(3), f(7)], Result) -> Result = [f(3), f(5), f(7)]

inserisci_ordinato(Elemento, [], [Elemento]) :- !.
inserisci_ordinato(Elemento, [Testa|Coda], [Elemento, Testa|Coda]) :-
    Elemento =.. [Functor1|ArgElemento],
    Testa =.. [Functor2|ArgTesta],
    Functor1 = Functor2,
    ArgElemento = [ValElement|RestElement],
    ArgTesta = [ValTesta|RestTesta],
    ValElement =< ValTesta, !.
inserisci_ordinato(Elemento, [Testa|Coda], [Testa|CodaRisultato]) :-
    inserisci_ordinato(Elemento, Coda, CodaRisultato).

%--- Ricerca elemento in lista ---
% membro(Elemento, Lista)
% Verifica se Elemento è membro di Lista

membro(Elemento, [Elemento|Resto]) :- !.
membro(Elemento, [Testa|Resto]) :-
    membro(Elemento, Resto).

%--- Lunghezza di lista ---
% lunghezza_lista(Lista, Lunghezza)

lunghezza_lista([], 0) :- !.
lunghezza_lista([H|T], Lunghezza) :-
    lunghezza_lista(T, LunghezzaCoda),
    Lunghezza is LunghezzaCoda + 1.

%--- Concatenazione liste ---
% concatena_liste(Lista1, Lista2, Risultato)

concatena_liste([], Lista2, Lista2) :- !.
concatena_liste([Testa|Coda], Lista2, [Testa|Risultato]) :-
    concatena_liste(Coda, Lista2, Risultato).

%--- Verifica appartenenza stato (con unificazione strutturale) ---
% contiene_stato(Stato, ListaStati)

contiene_stato(Stato, [Stato|Resto]) :- !.
contiene_stato(Stato, [H|Resto]) :-
    Stato \= H,
    contiene_stato(Stato, Resto).

%--- Ribalta cammino ---
% ribalta_cammino(Cammino, CamminoRibaltato)
% inverti ordine di una lista

ribalta_lista(Lista, Ribaltata) :-
    ribalta_lista_aux(Lista, [], Ribaltata).

ribalta_lista_aux([], Accum, Accum) :- !.
ribalta_lista_aux([H|T], Accum, Ribaltata) :-
    ribalta_lista_aux(T, [H|Accum], Ribaltata).

%===============================================================================
% SEZIONE 2: MODULO EURISTICHE
%===============================================================================

%--- Distanza Euclidea per labirinti ---
% euristica_euclidea(pos(R1,C1), pos(R2,C2), Distanza)

euristica_euclidea(pos(R1, C1), pos(R2, C2), Distanza) :- 
    DeltaR is R1 - R2,
    DeltaC is C1 - C2,
    DeltaR2 is DeltaR * DeltaR,
    DeltaC2 is DeltaC * DeltaC,
    Somma is DeltaR2 + DeltaC2,
    Distanza is sqrt(Somma).

%--- Distanza di Manhattan per gioco dell'8 ---
% euristica_manhattan(StatoPuzzle, Distanza)
% StatoPuzzle = puzzle([L1,L2,L3,L4,L5,L6,L7,L8,L9])
% Calcola somma distanze Manhattan di ogni tessera da posizione goal

euristica_manhattan(puzzle(Tessere), DistanzaTotale) :-
    calcola_manhattan_dello_stato(Tessere, 0, 0, DistanzaTotale).

%--- Helper: Calcolo ricorsivo Manhattan ---
% calcola_manhattan_dello_stato(ListaTessere, IndiceAttuale, Accumulatore, Totale)

calcola_manhattan_dello_stato([], Indice, Accumulatore, Accumulatore) :- !.
calcola_manhattan_dello_stato([Tessera|Resto], IndiceAttuale, Accumulatore, Totale) :-
    Tessera \= 0,  % Ignora il buco
    IndiceGoal is Tessera - 1,
    calcola_distanza_cella(IndiceAttuale, IndiceGoal, Distanza),
    NuovoAcc is Accumulatore + Distanza,
    IndiceSuccessivo is IndiceAttuale + 1,
    calcola_manhattan_dello_stato(Resto, IndiceSuccessivo, NuovoAcc, Totale).
calcola_manhattan_dello_stato([0|Resto], IndiceAttuale, Accumulatore, Totale) :-
    IndiceSuccessivo is IndiceAttuale + 1,
    calcola_manhattan_dello_stato(Resto, IndiceSuccessivo, Accumulatore, Totale).

%--- Helper: Distanza Manhattan tra celle (griglia 3x3) ---
% calcola_distanza_cella(Indice1, Indice2, Distanza)

calcola_distanza_cella(Idx1, Idx2, Distanza) :-
    Riga1 is Idx1 // 3,
    Col1 is Idx1 mod 3,
    Riga2 is Idx2 // 3,
    Col2 is Idx2 mod 3,
    DeltaRiga is abs(Riga1 - Riga2),
    DeltaCol is abs(Col1 - Col2),
    Distanza is DeltaRiga + DeltaCol.

%--- Euristica nulla (ricerca non informata) ---
% euristica_zero(Stato, 0)

euristica_zero(Stato, 0).

%===============================================================================
% SEZIONE 3: MODULO LABIRINTI
%===============================================================================

%--- Stato goal per labirinto ---
% stato_goal_labirinto(PosFinale)
% Verifica se una posizione è il goal (definito in labirinto.pl)

stato_goal_labirinto(PosFinale) :-
    finale(PosFinale).

%--- Stato iniziale per labirinto ---
% stato_iniziale_labirinto(PosIniziale)

stato_iniziale_labirinto(PosIniziale) :-
    iniziale(PosIniziale).

%===============================================================================
% SEZIONE 4: MODULO GIOCO DELL'8
%===============================================================================

%--- Rappresentazione dello stato puzzle ---
% puzzle([T1,T2,T3,T4,T5,T6,T7,T8,T9])
% Griglia 3x3 lineare: T1 T2 T3 / T4 T5 T6 / T7 T8 T9
% 0 = buco, 1-8 = tessere numerate

%--- Stato goal del gioco dell'8 ---
stato_goal_ottetto(puzzle([1,2,3,4,5,6,7,8,0])).

%--- Genera azioni applicabili dal puzzle ---
% azioni_puzzle(StatoCorrente, Azioni)
% Ritorna lista di azioni: [spostamento_nord, spostamento_sud, ...]

azioni_puzzle(puzzle(Tessere), Azioni) :-
    trova_buco(Tessere, 0, PosBuco),
    azioni_da_posizione_buco(PosBuco, Azioni).

%--- Helper: Trova posizione del buco (0) in lista ---
% trova_buco(Tessere, Indice, PosBuco)

trova_buco([0|Resto], IndiceAttuale, IndiceAttuale) :- !.
trova_buco([H|Resto], IndiceAttuale, PosBuco) :-
    IndiceSuccessivo is IndiceAttuale + 1,
    trova_buco(Resto, IndiceSuccessivo, PosBuco).

%--- Helper: Azioni valide da posizione del buco ---
% azioni_da_posizione_buco(PosBuco, Azioni)
% Ritorna azioni che muovono tessere verso il buco

azioni_da_posizione_buco(PosBuco, Azioni) :-
    trovazione_azioni_helper(PosBuco, ListaAzioniLibera, []),
    Azioni = ListaAzioniLibera, !.

azioni_da_posizione_buco(PosBuco, []) :- !.

%--- Versione alternativa: genera direttamente le azioni valide ---
% trovaazioni_puzzle(PosBuco, Azioni)

trovaazioni_puzzle(PosBuco, Azioni) :-
    AzioniBuco = [],
    (PosBuco >= 3 -> AzioniBuco1 = [spostamento_nord|AzioniBuco] ; AzioniBuco1 = AzioniBuco),
    (PosBuco < 6 -> AzioniBuco2 = [spostamento_sud|AzioniBuco1] ; AzioniBuco2 = AzioniBuco1),
    (PosBuco mod 3 > 0 -> AzioniBuco3 = [spostamento_est|AzioniBuco2] ; AzioniBuco3 = AzioniBuco2),
    (PosBuco mod 3 < 2 -> Azioni = [spostamento_ovest|AzioniBuco3] ; Azioni = AzioniBuco3).

%--- Simulazione azione (trasformazione dello stato) ---
% trasforma_puzzle(Azione, StatoAttuale, StatoNuovo)

trasforma_puzzle(spostamento_nord, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosToSwap is PosBuco - 3,
    PosToSwap >= 0,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

trasforma_puzzle(spostamento_sud, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosToSwap is PosBuco + 3,
    PosToSwap < 9,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

trasforma_puzzle(spostamento_est, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosModulo is PosBuco mod 3,
    PosModulo > 0,
    PosToSwap is PosBuco - 1,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

trasforma_puzzle(spostamento_ovest, puzzle(TessereVecchie), puzzle(TessereNuove)) :-
    trova_buco(TessereVecchie, 0, PosBuco),
    PosModulo is PosBuco mod 3,
    PosModulo < 2,
    PosToSwap is PosBuco + 1,
    scambia_elementi_lista(TessereVecchie, PosBuco, PosToSwap, TessereNuove).

%--- Helper: Scambia elementi in lista ---
% scambia_elementi_lista(ListaVecchia, Pos1, Pos2, ListaNuova)

scambia_elementi_lista(ListaVecchia, Pos1, Pos2, ListaNuova) :-
    elemento_a_indice_lista(ListaVecchia, Pos1, Elem1),
    elemento_a_indice_lista(ListaVecchia, Pos2, Elem2),
    riponi_elemento_lista(ListaVecchia, Pos1, Elem2, ListaTemp),
    riponi_elemento_lista(ListaTemp, Pos2, Elem1, ListaNuova).

%--- Helper: Accedi elemento per indice (0-based) ---
% elemento_a_indice_lista(Lista, Indice, Elemento)

elemento_a_indice_lista([Elemento|Resto], 0, Elemento) :- !.
elemento_a_indice_lista([H|Resto], Indice, Elemento) :-
    IndiceSuccessivo is Indice - 1,
    elemento_a_indice_lista(Resto, IndiceSuccessivo, Elemento).

%--- Helper: Riponi elemento a indice (0-based) ---
% riponi_elemento_lista(ListaVecchia, Indice, NuovoElemento, ListaNuova)

riponi_elemento_lista([H|Resto], 0, NuovoElemento, [NuovoElemento|Resto]) :- !.
riponi_elemento_lista([H|Resto], Indice, NuovoElemento, [H|ListaNuova]) :-
    IndiceSuccessivo is Indice - 1,
    riponi_elemento_lista(Resto, IndiceSuccessivo, NuovoElemento, ListaNuova).

%===============================================================================
% SEZIONE 5: ALGORITMO A* (A-STAR)
%===============================================================================

%--- Algoritmo A* con tracciamento completo del cammino ---
% astar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
%       Cammino, CostoTotale)
%
% PARAMETRI:
%  - StatoIniziale: stato di partenza
%  - PredicatoGoal: predicato per verificare goal es. stato_goal_labirinto/1
%  - PredicatoSuccessori: predicato per generare stati successori
%                        firma: Pre(Stato, ListaCoppie)
%                        ListaCoppie = [coppia(Nome, StatoNuovo, Costo), ...]
%  - PredicatoEuristica: predicato stima costo a goal
%                       firma: Pre(Stato, Stima)
%  - Cammino: lista di stati dal start al goal
%  - CostoTotale: costo reale della soluzione
%
% PREVENZIONE CICLI INFINITI:
%  - Lista chiusa di nodi visitati
%  - Lista aperta ordinata per f = g + h
%  - Limite massimo di iterazioni

astar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
      Cammino, CostoTotale) :-
    % Controllo goal iniziale
    call(PredicatoGoal, StatoIniziale), !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

astar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
      Cammino, CostoTotale) :-
    % Calcola euristica iniziale
    call(PredicatoEuristica, StatoIniziale, HIniziale),
    FIniziale is 0 + HIniziale,
    
    % Nodo = nodo(F, Stato, G, H, CamminoAccumulato)
    NodoIniziale = nodo(FIniziale, StatoIniziale, 0, HIniziale, [StatoIniziale]),
    
    % Ricerca iterativa
    astar_iterativo([NodoIniziale], [], PredicatoGoal, PredicatoSuccessori,
                   PredicatoEuristica, 0, 50000, Cammino, CostoTotale).

%--- Ricerca iterativa A* ---
% astar_iterativo(ListaAperta, ListaChiusa, PredicatoGoal, PredicatoSuccessori,
%                 PredicatoEuristica, Contatore, Limite, Cammino, Costo)

astar_iterativo([], ListaChiusa, PredicatoGoal, PredicatoSuccessori,
                PredicatoEuristica, Contatore, Limite, [], 999999) :- !.

astar_iterativo(ListaAperta, ListaChiusa, PredicatoGoal, PredicatoSuccessori,
                PredicatoEuristica, Contatore, Limite, [], 999999) :-
    Contatore >= Limite, !.

astar_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
               ListaChiusa, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
               Contatore, Limite, Cammino, CostoTotale) :-
    call(PredicatoGoal, StatoCorrente), !,
    Cammino = CamminoAccumulato,
    CostoTotale = GCorrente.

astar_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
               ListaChiusa, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
               Contatore, Limite, Cammino, CostoTotale) :-
    contiene_stato(StatoCorrente, ListaChiusa), !,
    ContatoreNuovo is Contatore + 1,
    astar_iterativo(RestoAperta, ListaChiusa, PredicatoGoal, PredicatoSuccessori,
                   PredicatoEuristica, ContatoreNuovo, Limite, Cammino, CostoTotale).

astar_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
               ListaChiusa, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
               Contatore, Limite, Cammino, CostoTotale) :-
    % Genera successori
    call(PredicatoSuccessori, StatoCorrente, Successori),
    
    % Elabora successori
    elabora_successori_astar(Successori, StatoCorrente, GCorrente, CamminoAccumulato,
                            RestoAperta, PredicatoEuristica, ListaApertaNuova),
    
    % Aggiorna lista chiusa e continua
    ListaChiusaNuova = [StatoCorrente|ListaChiusa],
    ContatoreNuovo is Contatore + 1,
    astar_iterativo(ListaApertaNuova, ListaChiusaNuova, PredicatoGoal,
                   PredicatoSuccessori, PredicatoEuristica, ContatoreNuovo,
                   Limite, Cammino, CostoTotale).

%--- Elaborazione successori A* ---
% elabora_successori_astar(Successori, StatoPadre, GPadre, CamminopadreAcc,
%                          ListaApertaVecchia, PredicatoEuristica, ListaApertaNuova)

elabora_successori_astar([], StatoPadre, GPadre, CamminopadreAcc, ListaAperta,
                        PredicatoEuristica, ListaAperta) :- !.

elabora_successori_astar([coppia(NomeAzione, StatoFiglio, CostoArco)|RestSuccessori],
                        StatoPadre, GPadre, CamminopadreAcc, ListaApertaVecchia,
                        PredicatoEuristica, ListaApertaNuova) :-
    % Calcola g e h
    GFiglio is GPadre + CostoArco,
    call(PredicatoEuristica, StatoFiglio, HFiglio),
    FFiglio is GFiglio + HFiglio,
    
    % Estendi cammino accumulato
    concatena_liste(CamminopadreAcc, [StatoFiglio], CamminoNuovoAcc),
    
    % Crea nodo e inserisci in lista aperta ordinata
    NodoNuovo = nodo(FFiglio, StatoFiglio, GFiglio, HFiglio, CamminoNuovoAcc),
    inserisci_ordinato(NodoNuovo, ListaApertaVecchia, ListaApertaTemp),
    
    % Processa rimanenti successori
    elabora_successori_astar(RestSuccessori, StatoPadre, GPadre,
                            CamminopadreAcc, ListaApertaTemp, PredicatoEuristica,
                            ListaApertaNuova).

%===============================================================================
% SEZIONE 6: ALGORITMO IDA* (ITERATIVE DEEPENING A*)
%===============================================================================

%--- Algoritmo IDA* principale ---
% idastar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
%         Cammino, CostoTotale)
%
% ALGORITMO:
%  Iterazione 0: Soglia = h(start)
%  Iterazione n: Soglia = min{f > soglia_precedente}

idastar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
        Cammino, CostoTotale) :-
    % Controllo goal iniziale
    call(PredicatoGoal, StatoIniziale), !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

idastar(StatoIniziale, PredicatoGoal, PredicatoSuccessori, PredicatoEuristica,
        Cammino, CostoTotale) :-
    % Calcola soglia iniziale
    call(PredicatoEuristica, StatoIniziale, HIniziale),
    SogliaIniziale = HIniziale,
    
    % Esegui iterazioni
    idastar_iterazioni(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
                      PredicatoEuristica, [StatoIniziale], SogliaIniziale,
                      0, 100, Cammino, CostoTotale).

%--- Iterazioni IDA* ---
% idastar_iterazioni(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
%                    PredicatoEuristica, Cammino, SogliaAttuale,
%                    IterazioneCorrente, LimiteIterazioni, CamminoFinale, CostoFinale)

idastar_iterazioni(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
                  PredicatoEuristica, CamminoIniziale, SogliaAttuale,
                  IterazioneCorrente, LimiteIterazioni, [], 999999) :-
    IterazioneCorrente >= LimiteIterazioni, !.

idastar_iterazioni(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
                  PredicatoEuristica, CamminoIniziale, SogliaAttuale,
                  IterazioneCorrente, LimiteIterazioni, CamminoFinale, CostoFinale) :-
    % Esegui ricerca DFS limitata
    idastar_ricerca_limitata(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
                            PredicatoEuristica, CamminoIniziale, 0, SogliaAttuale,
                            CamminoFinale, CostoFinale, SogliaProssima),
    
    % Se goal trovato, esci; altrimenti continua iterazione
    (CostoFinale \= 999999 -> true
    ;   IterazioneNuova is IterazioneCorrente + 1,
        idastar_iterazioni(StatoIniziale, PredicatoGoal, PredicatoSuccessori,
                          PredicatoEuristica, CamminoIniziale, SogliaProssima,
                          IterazioneNuova, LimiteIterazioni, CamminoFinale,
                          CostoFinale)).

%--- Ricerca DFS limitata per una iterazione IDA* ---
% idastar_ricerca_limitata(StatoCorrente, PredicatoGoal, PredicatoSuccessori,
%                          PredicatoEuristica, Cammino, GCorrente, SogliaCorrente,
%                          CamminoFinale, CostoFinale, SogliaProssima)

idastar_ricerca_limitata(StatoCorrente, PredicatoGoal, PredicatoSuccessori,
                        PredicatoEuristica, Cammino, GCorrente, SogliaCorrente,
                        Cammino, GCorrente, 999999) :-
    call(PredicatoGoal, StatoCorrente), !.

idastar_ricerca_limitata(StatoCorrente, PredicatoGoal, PredicatoSuccessori,
                        PredicatoEuristica, Cammino, GCorrente, SogliaCorrente,
                        [], 999999, SogliaCorrente) :-
    % f supera soglia: ritorna questa f come prossima soglia
    call(PredicatoEuristica, StatoCorrente, HCorrente),
    FCorrente is GCorrente + HCorrente,
    FCorrente > SogliaCorrente, !.

idastar_ricerca_limitata(StatoCorrente, PredicatoGoal, PredicatoSuccessori,
                        PredicatoEuristica, Cammino, GCorrente, SogliaCorrente,
                        CamminoFinale, CostoFinale, SogliaProssima) :-
    % Genera successori e elabora
    call(PredicatoSuccessori, StatoCorrente, Successori),
    GSuccessore is GCorrente + 1,
    idastar_elabora_successori(Successori, StatoCorrente, PredicatoGoal,
                              PredicatoSuccessori, PredicatoEuristica,
                              Cammino, GSuccessore, SogliaCorrente,
                              CamminoFinale, CostoFinale, SogliaProssima).

%--- Elaborazione successori IDA* con path checking ---
% idastar_elabora_successori(Successori, StatoPadre, PredicatoGoal,
%                            PredicatoSuccessori, PredicatoEuristica, Cammino,
%                            GSuccessore, SogliaCorrente, CamminoFinale,
%                            CostoFinale, SogliaProssima)

idastar_elabora_successori([], StatoPadre, PredicatoGoal, PredicatoSuccessori,
                          PredicatoEuristica, Cammino, GSuccessore, SogliaCorrente,
                          [], 999999, SogliaCorrente) :- !.

idastar_elabora_successori([coppia(NomeAzione, StatoFiglio, CostoArco)|RestSuccessori],
                          StatoPadre, PredicatoGoal, PredicatoSuccessori,
                          PredicatoEuristica, Cammino, GSuccessore, SogliaCorrente,
                          CamminoFinale, CostoFinale, SogliaProssima) :-
    % Path checking: evita cicli nel cammino
    contiene_stato(StatoFiglio, Cammino), !,
    idastar_elabora_successori(RestSuccessori, StatoPadre, PredicatoGoal,
                              PredicatoSuccessori, PredicatoEuristica, Cammino,
                              GSuccessore, SogliaCorrente, CamminoFinale,
                              CostoFinale, SogliaProssima).

idastar_elabora_successori([coppia(NomeAzione, StatoFiglio, CostoArco)|RestSuccessori],
                          StatoPadre, PredicatoGoal, PredicatoSuccessori,
                          PredicatoEuristica, Cammino, GSuccessore, SogliaCorrente,
                          CamminoFinale, CostoFinale, SogliaProssima) :-
    % Ricerca ricorsiva sul successore
    idastar_ricerca_limitata(StatoFiglio, PredicatoGoal, PredicatoSuccessori,
                            PredicatoEuristica, [StatoPadre|Cammino], GSuccessore,
                            SogliaCorrente, CamminoFinale, CostoFinale,
                            SogliaTempSuccessore), !.

idastar_elabora_successori([coppia(NomeAzione, StatoFiglio, CostoArco)|RestSuccessori],
                          StatoPadre, PredicatoGoal, PredicatoSuccessori,
                          PredicatoEuristica, Cammino, GSuccessore, SogliaCorrente,
                          CamminoFinale, CostoFinale, SogliaProssima) :-
    % Continua con il prossimo successore
    call(PredicatoEuristica, StatoFiglio, HFiglio),
    FFiglio is GSuccessore + HFiglio,
    idastar_elabora_successori(RestSuccessori, StatoPadre, PredicatoGoal,
                              PredicatoSuccessori, PredicatoEuristica, Cammino,
                              GSuccessore, SogliaCorrente, CamminoFinale,
                              CostoFinale, SogliaProssimaResto),
    (FFiglio < SogliaProssimaResto -> SogliaProssima = FFiglio
    ;                                  SogliaProssima = SogliaProssimaResto).

%===============================================================================
% SEZIONE 7: GENERATORI DI SUCCESSORI
%===============================================================================

%--- Successori per labirinto ---
% successori_labirinto(StatoCorrente, ListaSuccessori)

successori_labirinto(PosCorrente, Successori) :-
    findall(coppia(Azione, PosNuova, 1),
            (applicabile(Azione, PosCorrente),
             trasforma(Azione, PosCorrente, PosNuova)),
            Successori).

%--- Successori per gioco dell'8 ---
% successori_puzzle(StatoCorrente, ListaSuccessori)

successori_puzzle(StatoCorrente, Successori) :-
    azioni_puzzle(StatoCorrente, Azioni),
    findall(coppia(Azione, StatoNuovo, 1),
            (membro(Azione, Azioni),
             trasforma_puzzle(Azione, StatoCorrente, StatoNuovo)),
            Successori).

%===============================================================================
% SEZIONE 8: INTERFACCE PUBBLICHE
%===============================================================================

%--- Ricerca labirinto con A* ---
ricerca_labirinto_astar(Cammino, Costo) :-
    stato_iniziale_labirinto(PosIniziale),
    astar(PosIniziale, stato_goal_labirinto, successori_labirinto,
          euristica_euclidea, Cammino, Costo).

%--- Ricerca labirinto con IDA* ---
ricerca_labirinto_idastar(Cammino, Costo) :-
    stato_iniziale_labirinto(PosIniziale),
    idastar(PosIniziale, stato_goal_labirinto, successori_labirinto,
            euristica_euclidea, Cammino, Costo).

%--- Ricerca 8-puzzle con A* ---
ricerca_puzzle_astar(StatoIniziale, Cammino, Costo) :-
    astar(StatoIniziale, stato_goal_ottetto, successori_puzzle,
          euristica_manhattan, Cammino, Costo).

%--- Ricerca 8-puzzle con IDA* ---
ricerca_puzzle_idastar(StatoIniziale, Cammino, Costo) :-
    idastar(StatoIniziale, stato_goal_ottetto, successori_puzzle,
            euristica_manhattan, Cammino, Costo).

%===============================================================================
% SEZIONE 9: UTILITÀ DI STAMPA E DEBUG
%===============================================================================

%--- Stampa cammino in modo leggibile ---
stampa_cammino([]) :- !.
stampa_cammino([Stato|Resto]) :-
    write('  '), write(Stato), nl,
    stampa_cammino(Resto).

%--- Stampa cammino puzzle in modo leggibile ---
stampa_cammino_puzzle([]) :- !.
stampa_cammino_puzzle([puzzle(Tessere)|Resto]) :-
    write('Griglia:'), nl,
    stampa_griglia_puzzle(Tessere, 0),
    nl,
    stampa_cammino_puzzle(Resto).

%--- Helper: Stampa griglia puzzle ---
stampa_griglia_puzzle([], Indice) :- !.
stampa_griglia_puzzle([H|T], Indice) :-
    write(H), write(' '),
    IndiceSuccessivo is Indice + 1,
    (IndiceSuccessivo mod 3 =:= 0 -> nl ; true),
    stampa_griglia_puzzle(T, IndiceSuccessivo).

%===============================================================================
% FINE FILE
%===============================================================================
