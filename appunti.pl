/*
    make. per ricompilare al volo
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

    il carattere "_" serve come segnaposto per le variabili dummy che non uso, come su python

    in prolog il carattere ! serve per il cut, che è un operatore che viene usato per limitare il backtracking in Prolog.
    quando viene incontrato un cut, Prolog non tornerà indietro per cercare altre soluzioni per le regole 
    che sono state eseguite prima del cut. Così possiamo evitare di esplorare altri rami che non ci interessano.
    cut si occupa di tagliare il backtracking quando incontriamo un elemento che soddisfa una certa condizione,
    saltando tutte le altre alternative che potrebbero essere esplorate per quella regola.



    come funziona il run-time di prolog:
    stack di esecuzione, record di attivazione delle clausole
    stack di backtracking, record di backtracking per i choice point
    (nella realtà è solo uno stack)
    nel record di backtracking le clausole sono messe al contrario perchè tiriamo fuori prima quelle scritte prima
    l'aggiunta allo stack di backtracking è dinamica per i punti di scelta e non li mette tutti insieme subito
    es:
     (cl11) a:- p,b.
     (cl12) a:- -r.
     (cl13) p:- q.
     (cl14) p:- r.
     (cl15) r.
    quando costruiamo lo stack dei choice point mettiamo prima cl12 e cl11 con cl11 sopra, poi mettiamo cl13 e cl14 con cl13 sopra.
    quindi lo stack diventa dall'alto verso il basso:
    (cl13)
    (cl14)
    cl(11)
    cl(12)

    il carattere "\+" serve per fare la negazione


    Ricerca nello spazio degli stati:
    il problema di ricerca è definito da stato iniziale, inseme delle azioni, specifica degli obiettivi e costo per ogni azione.
    Insieme azioni raggiungibili da uno stato= stato iniziale + insieme delle azioni
    il cammino è una sequenza di stati collegati da una sequenza di azioni
    il costo del cammino è la somma dei costi delle azioni che compongono il cammino
    si usa una funzione euristica h(n) che stima il costo del cammino più economico da n a un obiettivo
    associamo ad ogni azione un costo e g(n) è il costo del cammino più economico da stato iniziale a n
    f(n)=g(n)+h(n) è il costo stimato del cammino più economico da stato iniziale a un obiettivo passando per n
    se h(n) è ammissibile, cioè non sovrastima il costo reale del cammino più economico da n a un obiettivo è ottimale,
    cioè trova sempre il cammino più economico da stato iniziale a un obiettivo.

    però spesso si diventa matti a cercare euristiche ammissibili, si cercano delle euristiche ragionevoli,
    che non sovrastimano troppo il costo reale del cammino più economico da n a un obiettivo, ma che non sono necessariamente ammissibili.
    
    esempio di un labirinto con prolog:
    stato iniziale: posizione di partenza
    insieme delle azioni: muoversi in una delle quattro direzioni (nord, sud, est, ovest)
    specifica degli obiettivi: raggiungere la posizione di arrivo
    costo per ogni azione: 1
    per sapere in che posizione siamo usiamo pos(Riga, Colonna)
    quando c'è un muro usiamo occupata(pos(Riga, Colonna))
    
*/