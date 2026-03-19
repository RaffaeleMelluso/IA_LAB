% ALGORITMI DI RICERCA A* E IDA* PER LABIRINTI E GIOCO DELL'8

% SEZIONE 1: UTILITY GENERICHE

% inserisci_ordinato(Elemento, Lista, Risultato)
inserisci_ordinato(nodo(F1, S1, G1, H1, C1), [], [nodo(F1, S1, G1, H1, C1)]) :- !.
inserisci_ordinato(nodo(F1, S1, G1, H1, C1), [nodo(F2, S2, G2, H2, C2)|Coda], 
                   [nodo(F1, S1, G1, H1, C1), nodo(F2, S2, G2, H2, C2)|Coda]) :-
    F1 =< F2, !.
inserisci_ordinato(nodo(F1, S1, G1, H1, C1), [nodo(F2, S2, G2, H2, C2)|Coda], 
                   [nodo(F2, S2, G2, H2, C2)|CodaRisultato]) :-
    inserisci_ordinato(nodo(F1, S1, G1, H1, C1), Coda, CodaRisultato).

% membro(Elemento, Lista)
membro(Elemento, [Elemento|Resto]) :- !.
membro(Elemento, [Testa|Resto]) :-
    membro(Elemento, Resto).

% contiene_stato(Stato, ListaStati)
contiene_stato(Stato, [Stato|Resto]) :- !.
contiene_stato(Stato, [H|Resto]) :-
    Stato \= H,
    contiene_stato(Stato, Resto).

% concatena_liste(Lista1, Lista2, Risultato)
concatena_liste([], Lista2, Lista2) :- !.
concatena_liste([Testa|Coda], Lista2, [Testa|Risultato]) :-
    concatena_liste(Coda, Lista2, Risultato).

% SEZIONE 2: EURISTICHE

% euristica_euclidea(Stato1, Stato2, Distanza)
euristica_euclidea(pos(R1, C1), pos(R2, C2), Distanza) :- 
    DeltaR is R1 - R2,
    DeltaC is C1 - C2,
    DeltaR2 is DeltaR * DeltaR,
    DeltaC2 is DeltaC * DeltaC,
    Somma is DeltaR2 + DeltaC2,
    Distanza is sqrt(Somma).

% euristica_manhattan(StatoPuzzle, Distanza)
euristica_manhattan(puzzle(Tessere), DistanzaTotale) :-
    calcola_manhattan_dello_stato(Tessere, 0, 0, DistanzaTotale).

calcola_manhattan_dello_stato([], Indice, Accumulatore, Accumulatore) :- !.
calcola_manhattan_dello_stato([Tessera|Resto], IndiceAttuale, Accumulatore, Totale) :-
    Tessera \= 0,
    IndiceGoal is Tessera - 1,
    calcola_distanza_cella(IndiceAttuale, IndiceGoal, Distanza),
    NuovoAcc is Accumulatore + Distanza,
    IndiceSuccessivo is IndiceAttuale + 1,
    calcola_manhattan_dello_stato(Resto, IndiceSuccessivo, NuovoAcc, Totale).
calcola_manhattan_dello_stato([0|Resto], IndiceAttuale, Accumulatore, Totale) :-
    IndiceSuccessivo is IndiceAttuale + 1,
    calcola_manhattan_dello_stato(Resto, IndiceSuccessivo, Accumulatore, Totale).

calcola_distanza_cella(Idx1, Idx2, Distanza) :-
    Riga1 is Idx1 // 3,
    Col1 is Idx1 mod 3,
    Riga2 is Idx2 // 3,
    Col2 is Idx2 mod 3,
    DeltaRiga is abs(Riga1 - Riga2),
    DeltaCol is abs(Col1 - Col2),
    Distanza is DeltaRiga + DeltaCol.

% SEZIONE 3: MODULO LABIRINTI

stato_goal_labirinto(PosFinale) :-
    finale(PosFinale).

stato_iniziale_labirinto(PosIniziale) :-
    iniziale(PosIniziale).

% SEZIONE 4: MODULO GIOCO DELL'8

stato_goal_puzzle(StatoGoal) :-
    puzzle_goal(StatoGoal).

stato_iniziale_puzzle(StatoIniziale) :-
    puzzle_iniziale(StatoIniziale).

stato_goal_ottetto(puzzle([1,2,3,4,5,6,7,8,0])).

% SEZIONE 5: A* PER LABIRINTI

ricerca_labirinto_astar(Cammino, CostoTotale) :-
    stato_iniziale_labirinto(PosIniziale),
    astar_labirinto_esecuzione(PosIniziale, Cammino, CostoTotale).

astar_labirinto_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_labirinto(StatoIniziale), !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

astar_labirinto_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_labirinto(StatoGoal),
    euristica_euclidea(StatoIniziale, StatoGoal, HIniziale),
    FIniziale is 0 + HIniziale,
    NodoIniziale = nodo(FIniziale, StatoIniziale, 0, HIniziale, [StatoIniziale]),
    astar_labirinto_iterativo([NodoIniziale], [], StatoGoal, 0, 50000, Cammino, CostoTotale).

astar_labirinto_iterativo([], ListaChiusa, Goal, Contatore, Limite, [], 999999) :- !.

astar_labirinto_iterativo(ListaAperta, ListaChiusa, Goal, Contatore, Limite, [], 999999) :-
    Contatore >= Limite, !.

astar_labirinto_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
                          ListaChiusa, Goal, Contatore, Limite, Cammino, CostoTotale) :-
    StatoCorrente = Goal, !,
    Cammino = CamminoAccumulato,
    CostoTotale = GCorrente.

astar_labirinto_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
                          ListaChiusa, Goal, Contatore, Limite, Cammino, CostoTotale) :-
    contiene_stato(StatoCorrente, ListaChiusa), !,
    ContatoreNuovo is Contatore + 1,
    astar_labirinto_iterativo(RestoAperta, ListaChiusa, Goal, ContatoreNuovo, Limite, Cammino, CostoTotale).

astar_labirinto_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
                          ListaChiusa, Goal, Contatore, Limite, Cammino, CostoTotale) :-
    findall(coppia(Azione, PosNuova, 1),
            (applicabile(Azione, StatoCorrente),
             trasforma(Azione, StatoCorrente, PosNuova)),
            Successori),
    elabora_successori_labirinto_astar(Successori, StatoCorrente, GCorrente, CamminoAccumulato,
                                       RestoAperta, Goal, ListaApertaNuova),
    ListaChiusaNuova = [StatoCorrente|ListaChiusa],
    ContatoreNuovo is Contatore + 1,
    astar_labirinto_iterativo(ListaApertaNuova, ListaChiusaNuova, Goal,
                             ContatoreNuovo, Limite, Cammino, CostoTotale).

elabora_successori_labirinto_astar([], StatoPadre, GPadre, CamminopadreAcc, ListaAperta,
                                   Goal, ListaAperta) :- !.

elabora_successori_labirinto_astar([coppia(NomeAzione, StatoFiglio, CostoArco)|RestSuccessori],
                                   StatoPadre, GPadre, CamminopadreAcc, ListaApertaVecchia,
                                   Goal, ListaApertaNuova) :-
    GFiglio is GPadre + CostoArco,
    euristica_euclidea(StatoFiglio, Goal, HFiglio),
    FFiglio is GFiglio + HFiglio,
    concatena_liste(CamminopadreAcc, [StatoFiglio], CamminoNuovoAcc),
    NodoNuovo = nodo(FFiglio, StatoFiglio, GFiglio, HFiglio, CamminoNuovoAcc),
    inserisci_ordinato(NodoNuovo, ListaApertaVecchia, ListaApertaTemp),
    elabora_successori_labirinto_astar(RestSuccessori, StatoPadre, GPadre,
                                       CamminopadreAcc, ListaApertaTemp, Goal,
                                       ListaApertaNuova).

% SEZIONE 6: A* PER PUZZLE

ricerca_puzzle_astar(Cammino, CostoTotale) :-
    stato_iniziale_puzzle(StatoIniziale),
    astar_puzzle_esecuzione(StatoIniziale, Cammino, CostoTotale).

astar_puzzle_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_puzzle(StatoGoal),
    StatoIniziale = StatoGoal, !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

astar_puzzle_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_puzzle(StatoGoal),
    euristica_manhattan(StatoIniziale, HIniziale),
    FIniziale is 0 + HIniziale,
    NodoIniziale = nodo(FIniziale, StatoIniziale, 0, HIniziale, [StatoIniziale]),
    astar_puzzle_iterativo([NodoIniziale], [], StatoGoal, 0, 50000, Cammino, CostoTotale).

astar_puzzle_iterativo([], ListaChiusa, Goal, Contatore, Limite, [], 999999) :- 
    format('A* puzzle: Esaurita lista aperta dopo ~w iterazioni~n', [Contatore]), !.

astar_puzzle_iterativo(ListaAperta, ListaChiusa, Goal, Contatore, Limite, [], 999999) :-
    Contatore >= Limite,
    format('A* puzzle: Raggiunto limite di ~w iterazioni~n', [Limite]), !.

astar_puzzle_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
                       ListaChiusa, Goal, Contatore, Limite, Cammino, CostoTotale) :-
    (Contatore mod 1000 = 0 -> format('   Iterazione: ~w, Aprta: ~w, Chiusa: ~w~n', [Contatore, RestoAperta, ListaChiusa]) ; true),
    StatoCorrente = Goal, !,
    Cammino = CamminoAccumulato,
    CostoTotale = GCorrente,
    format('A* puzzle: Soluzione trovata in ~w iterazioni~n', [Contatore]).

astar_puzzle_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
                       ListaChiusa, Goal, Contatore, Limite, Cammino, CostoTotale) :-
    contiene_stato(StatoCorrente, ListaChiusa), !,
    ContatoreNuovo is Contatore + 1,
    astar_puzzle_iterativo(RestoAperta, ListaChiusa, Goal, ContatoreNuovo, Limite, Cammino, CostoTotale).

astar_puzzle_iterativo([nodo(FCorrente, StatoCorrente, GCorrente, HCorrente, CamminoAccumulato)|RestoAperta],
                       ListaChiusa, Goal, Contatore, Limite, Cammino, CostoTotale) :-
    azioni_puzzle(StatoCorrente, Azioni),
    findall(coppia(Azione, StatoNuovo, 1),
            (membro(Azione, Azioni),
             trasforma_puzzle(Azione, StatoCorrente, StatoNuovo)),
            Successori),
    length(Successori, NumSucc),
    format('  Iter ~w: Stato ~w, Successori: ~w~n', [Contatore, StatoCorrente, NumSucc]),
    elabora_successori_puzzle_astar(Successori, StatoCorrente, GCorrente, CamminoAccumulato,
                                    RestoAperta, Goal, ListaApertaNuova),
    length(ListaApertaNuova, NumAperta),
    format('    Dopo: Lista aperta ha ~w elementi~n', [NumAperta]),
    ListaChiusaNuova = [StatoCorrente|ListaChiusa],
    ContatoreNuovo is Contatore + 1,
    astar_puzzle_iterativo(ListaApertaNuova, ListaChiusaNuova, Goal, ContatoreNuovo, Limite, Cammino, CostoTotale).

elabora_successori_puzzle_astar([], StatoPadre, GPadre, CamminopadreAcc, ListaAperta,
                                Goal, ListaAperta) :- !.

elabora_successori_puzzle_astar([coppia(NomeAzione, StatoFiglio, CostoArco)|RestSuccessori],
                                StatoPadre, GPadre, CamminopadreAcc, ListaApertaVecchia,
                                Goal, ListaApertaNuova) :-
    GFiglio is GPadre + CostoArco,
    euristica_manhattan(StatoFiglio, HFiglio),
    FFiglio is GFiglio + HFiglio,
    concatena_liste(CamminopadreAcc, [StatoFiglio], CamminoNuovoAcc),
    NodoNuovo = nodo(FFiglio, StatoFiglio, GFiglio, HFiglio, CamminoNuovoAcc),
    inserisci_ordinato(NodoNuovo, ListaApertaVecchia, ListaApertaTemp),
    elabora_successori_puzzle_astar(RestSuccessori, StatoPadre, GPadre,
                                    CamminopadreAcc, ListaApertaTemp, Goal,
                                    ListaApertaNuova).

% SEZIONE 7: IDA* PER LABIRINTI

ricerca_labirinto_idastar(Cammino, CostoTotale) :-
    stato_iniziale_labirinto(PosIniziale),
    idastar_labirinto_esecuzione(PosIniziale, Cammino, CostoTotale).

idastar_labirinto_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_labirinto(StatoGoal),
    StatoIniziale = StatoGoal, !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

idastar_labirinto_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_labirinto(StatoGoal),
    euristica_euclidea(StatoIniziale, StatoGoal, HIniziale),
    SogliaIniziale = HIniziale,
    idastar_labirinto_loop(StatoIniziale, [StatoIniziale], SogliaIniziale, StatoGoal,
                           0, 20, Cammino, CostoTotale).

idastar_labirinto_loop(StatoIniziale, CamminoIniziale, SogliaAttuale, Goal,
                       IterazioneCorrente, LimiteIterazioni, [], 999999) :-
    IterazioneCorrente >= LimiteIterazioni, !.

idastar_labirinto_loop(StatoIniziale, CamminoIniziale, SogliaAttuale, Goal,
                       IterazioneCorrente, LimiteIterazioni, CamminoFinale, CostoFinale) :-
    idastar_labirinto_search(StatoIniziale, CamminoIniziale, 0, SogliaAttuale, Goal,
                             CamminoFinale, CostoFinale, SogliaProssima),
    (SogliaProssima = -1 -> ! ; (IterazioneNuova is IterazioneCorrente + 1,
        idastar_labirinto_loop(StatoIniziale, CamminoIniziale, SogliaProssima, Goal,
                              IterazioneNuova, LimiteIterazioni, CamminoFinale, CostoFinale))).

idastar_labirinto_search(StatoCorrente, Cammino, GCorrente, SogliaCorrente, Goal,
                         Cammino, GCorrente, -1) :-
    StatoCorrente = Goal, !.

idastar_labirinto_search(StatoCorrente, Cammino, GCorrente, SogliaCorrente, Goal,
                         [], 999999, FCorrente) :-
    euristica_euclidea(StatoCorrente, Goal, HCorrente),
    FCorrente is GCorrente + HCorrente,
    FCorrente > SogliaCorrente, !.

idastar_labirinto_search(StatoCorrente, Cammino, GCorrente, SogliaCorrente, Goal,
                         CamminoFinale, CostoFinale, SogliaProssima) :-
    findall(coppia(Az, PosFiglio, 1),
            (applicabile(Az, StatoCorrente),
             trasforma(Az, StatoCorrente, PosFiglio),
             \+contiene_stato(PosFiglio, Cammino)),
            Successori),
    GSuccessore is GCorrente + 1,
    idastar_labirinto_search_successori(Successori, StatoCorrente, Cammino, GSuccessore,
                                        SogliaCorrente, Goal, CamminoFinale, CostoFinale,
                                        SogliaProssima).

idastar_labirinto_search_successori([], StatoPadre, Cammino, GSuccessore, SogliaCorrente, Goal,
                                    [], 999999, SogliaCorrente) :- !.

idastar_labirinto_search_successori([coppia(Az, PosFiglio, Cost)|RestSuccessori], StatoPadre, Cammino,
                                    GSuccessore, SogliaCorrente, Goal, CamminoFinale, CostoFinale,
                                    SogliaProssima) :-
    idastar_labirinto_search(PosFiglio, [PosFiglio|Cammino], GSuccessore, SogliaCorrente, Goal,
                             CamminoFinale, CostoFinale, SogliaTempSuccessore),
    (SogliaTempSuccessore = -1 -> SogliaProssima = -1
    ;   idastar_labirinto_search_successori(RestSuccessori, StatoPadre, Cammino, GSuccessore,
                                            SogliaCorrente, Goal, CamminoFinaleRest, CostoFinaleRest,
                                            SogliaProssimaResto),
        (SogliaTempSuccessore < SogliaProssimaResto -> SogliaProssima = SogliaTempSuccessore
        ;                                               SogliaProssima = SogliaProssimaResto)).

% SEZIONE 8: IDA* PER PUZZLE

ricerca_puzzle_idastar(Cammino, CostoTotale) :-
    stato_iniziale_puzzle(StatoIniziale),
    idastar_puzzle_esecuzione(StatoIniziale, Cammino, CostoTotale).

idastar_puzzle_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_puzzle(StatoGoal),
    StatoIniziale = StatoGoal, !,
    Cammino = [StatoIniziale],
    CostoTotale = 0.

idastar_puzzle_esecuzione(StatoIniziale, Cammino, CostoTotale) :-
    stato_goal_puzzle(StatoGoal),
    euristica_manhattan(StatoIniziale, HIniziale),
    SogliaIniziale = HIniziale,
    idastar_puzzle_loop(StatoIniziale, [StatoIniziale], SogliaIniziale, StatoGoal,
                        0, 20, Cammino, CostoTotale).

idastar_puzzle_loop(StatoIniziale, CamminoIniziale, SogliaAttuale, Goal,
                    IterazioneCorrente, LimiteIterazioni, [], 999999) :-
    IterazioneCorrente >= LimiteIterazioni, !.

idastar_puzzle_loop(StatoIniziale, CamminoIniziale, SogliaAttuale, Goal,
                    IterazioneCorrente, LimiteIterazioni, CamminoFinale, CostoFinale) :-
    idastar_puzzle_search(StatoIniziale, CamminoIniziale, 0, SogliaAttuale, Goal,
                          CamminoFinale, CostoFinale, SogliaProssima),
    (SogliaProssima = -1 -> ! ; (IterazioneNuova is IterazioneCorrente + 1,
        idastar_puzzle_loop(StatoIniziale, CamminoIniziale, SogliaProssima, Goal,
                           IterazioneNuova, LimiteIterazioni, CamminoFinale, CostoFinale))).

idastar_puzzle_search(StatoCorrente, Cammino, GCorrente, SogliaCorrente, Goal,
                      Cammino, GCorrente, -1) :-
    StatoCorrente = Goal, !.

idastar_puzzle_search(StatoCorrente, Cammino, GCorrente, SogliaCorrente, Goal,
                      [], 999999, FCorrente) :-
    euristica_manhattan(StatoCorrente, HCorrente),
    FCorrente is GCorrente + HCorrente,
    FCorrente > SogliaCorrente, !.

idastar_puzzle_search(StatoCorrente, Cammino, GCorrente, SogliaCorrente, Goal,
                      CamminoFinale, CostoFinale, SogliaProssima) :-
    azioni_puzzle(StatoCorrente, Azioni),
    findall(coppia(Az, StatoFiglio, 1),
            (membro(Az, Azioni),
             trasforma_puzzle(Az, StatoCorrente, StatoFiglio),
             \+contiene_stato(StatoFiglio, Cammino)),
            Successori),
    GSuccessore is GCorrente + 1,
    idastar_puzzle_search_successori(Successori, StatoCorrente, Cammino, GSuccessore,
                                     SogliaCorrente, Goal, CamminoFinale, CostoFinale,
                                     SogliaProssima).

idastar_puzzle_search_successori([], StatoPadre, Cammino, GSuccessore, SogliaCorrente, Goal,
                                 [], 999999, SogliaCorrente) :- !.

idastar_puzzle_search_successori([coppia(Az, StatoFiglio, Cost)|RestSuccessori], StatoPadre, Cammino,
                                 GSuccessore, SogliaCorrente, Goal, CamminoFinale, CostoFinale,
                                 SogliaProssima) :-
    idastar_puzzle_search(StatoFiglio, [StatoFiglio|Cammino], GSuccessore, SogliaCorrente, Goal,
                          CamminoFinale, CostoFinale, SogliaTempSuccessore),
    (SogliaTempSuccessore = -1 -> SogliaProssima = -1
    ;   idastar_puzzle_search_successori(RestSuccessori, StatoPadre, Cammino, GSuccessore,
                                         SogliaCorrente, Goal, CamminoFinaleRest, CostoFinaleRest,
                                         SogliaProssimaResto),
        (SogliaTempSuccessore < SogliaProssimaResto -> SogliaProssima = SogliaTempSuccessore
        ;                                               SogliaProssima = SogliaProssimaResto)).

% SEZIONE 9: UTILITY DI STAMPA

stampa_cammino([]) :- !.
stampa_cammino([Stato|Resto]) :-
    write('  '), write(Stato), nl,
    stampa_cammino(Resto).

stampa_cammino_puzzle([]) :- !.
stampa_cammino_puzzle([puzzle(Tessere)|Resto]) :-
    write('Griglia:'), nl,
    stampa_griglia_puzzle(Tessere, 0),
    nl,
    stampa_cammino_puzzle(Resto).

stampa_griglia_puzzle([], Indice) :- !.
stampa_griglia_puzzle([H|T], Indice) :-
    write(H), write(' '),
    IndiceSuccessivo is Indice + 1,
    (IndiceSuccessivo mod 3 =:= 0 -> nl ; true),
    stampa_griglia_puzzle(T, IndiceSuccessivo).

% FINE FILE
