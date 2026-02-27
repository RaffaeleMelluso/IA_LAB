/*
    ";" serve quando vogliamo scorrere i vari valori che può assumere una variabile nel terminale
    ":-" è l'operatore di definizione, che viene usato per definire regole e fatti in Prolog.
    "\+" è l'operatore di negazione, che viene usato per negare una condizione in Prolog.
    "is" è l'operatore di assegnazione, che viene usato per assegnare un valore a una variabile in Prolog.
    "not" è un predicato che viene usato per negare una condizione in Prolog, ma è meno comune rispetto a "\+" 
    e viene usato principalmente in Prolog più vecchi.


    possiamo a volte riscontrare loop nella ricorsione, se scambiamo predicati o l'ordine di esecuzione di alcune regole
    che devono essere scritte una dopo l'altra, altrimenti Prolog cercherà di risolvere una regola chiamando se stessa all'infinito.
    
    "/==" serve quando voglio dire che due variabili siano diverse

    Quando non vado subito a capo dopo aver mandato un comando prolog mi dice che ci sono altre strade aperte, cioè c'è un punto di
    backtracking, posso mettere anche ; per vedere le altre opzioni, si vede bene con trace
    
    Se scrivo trace posso tracciare l'esecuzione delle dimostrazioni quando scrivo da terminale le prossime formule

    ecco una ascii art che rappresenta un pichu(pokemon):
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⡄⠀⠀⠀⠀⠀⢀⣠⡄⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣷⠀⢀⣠⣴⣾⣿⣿⠁⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣶⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤⣶⣶⠂⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀
        ⣠⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⡿⠟⠁⢸⣿⡿⠛⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⣿⣿⣿⣿⣿⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠛⠉⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⢸⣿⣿⣿⣿⣿⣿⡇⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠉⠛⢿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⢹⣿⣿⣿⡆⠉⠻⡄⠀⠀⠀⠀⠀⠀⠈⠙⠿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠘⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⡇⠀⠀⠀⠀⠀⢀⡀⠤⠤⠴⠶⠚⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⠿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⢹⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⡠⠔⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⡤⠤⠒⠒⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠈⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠸⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⢤⣤⡀⠀⠀⠀⠀⠈⢃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⢻⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣇⠀⣸⣿⣷⠀⠀⢀⡤⠔⠬⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠈⢿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⠀⢀⡞⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣷⣀⣀⡠⠔⠊⢩⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠿⠛⠁⠀⠸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠈⠛⠛⠋⠉⠉⠀⠀⠀⠀⡌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⢀⠀⠀⠀⢸⠷⠒⠉⠉⠉⠉⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⠀⠀⠀⡰⠋⡆⠀⠀⠀⠸⡀⠀⢀⠏⠀⠀⠀⠤⠛⢠⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⣠⠖⠛⠉⠁⠀⠀⠀⣀⡠⠞⠁⠀⢸⠀⠀⠀⠀⠙⠲⡎⠀⠀⠀⠀⠀⡔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠈⠁⠀⠀⠀⠀⠀⠺⣿⡉⠀⠀⠀⠀⠀⡆⠀⠀⠀⣠⣾⠀⣀⠀⠀⣠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢢⣀⣀⣀⠀⠀⢀⢤⠀⠀⠈⠑⢤⡀⠀⠀⣰⠀⠀⣠⣾⣿⣿⠻⠉⠋⢺⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣄⠀⠈⠑⡞⠈⠈⢆⠀⠀⠀⠀⠉⠉⢁⣠⣾⣿⣿⣿⣿⠀⠁⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠢⣤⠃⠀⠀⠘⡄⢀⣀⣠⣤⣶⣿⡿⣿⣿⠉⠻⣿⠀⠀⠀⠀⢸⡄⠀⠀⢀⣤⣴⣶⣾⣿⣿⣿⣿⣿⣿⣿
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠀⠀⠀⠩⠀⠀⢹⠿⣿⣿⠃⠀⠉⠀⠀⠘⡄⠀⠀⠀⢸⠛⡀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠤⣀⠀⠀⠀⠀⡜⠀⠹⡏⠀⠀⠀⠀⠀⠀⠑⣄⠀⠀⡸⠀⢷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠑⠒⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⠚⠁⠀⣼⡟⠁⠀⠀⠈⠉⠉⠛⠛⠿⠿⢿⡇
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠤⠼⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠈⠀⠀⠀⠈⠁⠂⠀⠀⠀⠀⠀⠀⠀⢀⡤⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢄⠀⠀⠀⠀⠀⠀⠀⣄⢀⣀⠤⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠢⠤⣀⣀⣀⡠⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    tutto in prolog è una lista, operatori per le liste:⠀⠀⠀
    [1,2,3] è la lista
    ma anche [1,2,X] oppure [1,[2,3],4]]] ecc ecc...
    la lista è fatta in un modo [Head|Tail], dove head è il primo elemento della lista e 
    tail è la lista che contiene tutti gli elementi tranne il primo
    member(3, [1,2,3,4,5]) controlla se il 3 è nella lista    
    se faccio member(X, [1,2,3]) il valore di X sarà 1 poi 2 poi 3, perchè X prende il valore degli elementi della lista
    uno alla volta.
    se faccio member(X, [1,[2,3],4]). X ad un punto diventerà la lista [2,3]
    se faccio member(3, [1,[2,3],4]). restituisce false perchè non c'è 3
    attenzione le liste non sono commutative.
    quando scriviamo un programma scriviamo tutto in positivo e lui ci scrive solo la prima soluzione che trova
    atomic(X) controlla che X non sia una Lista
*/