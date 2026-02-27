genitore(edoardo,gianni).
genitore(edoardo,clara).
genitore(edoardo,susanna).
genitore(edoardo,umberto).
genitore(edoardo,mariasole).
genitore(edoardo,giorgio).
genitore(edoardo,cristiana).
genitore(virginiaBourbon,gianni).
genitore(virginiaBourbon,clara).
genitore(virginiaBourbon,susanna).
genitore(virginiaBourbon,umberto).
genitore(virginiaBourbon,mariasole).
genitore(virginiaBourbon,giorgio).
genitore(virginiaBourbon,cristiana).
genitore(gianni,margherita).
genitore(marellaCaracciolo,margherita).
genitore(gianni,edoardo2).
genitore(marellaCaracciolo,edoardo2).
genitore(margherita,johnElkann).
genitore(alainElkann,johnElkann).
genitore(margherita,lapoElkann).
genitore(alainElkann,lapoElkann).
genitore(margherita,ginevraElkann).
genitore(alainElkann,ginevraElkann).
genitore(umberto,giovanni).
genitore(antonellaBechiPiaggio,giovanni).
genitore(umberto,andrea).
genitore(umberto,anna).
genitore(allegraCaracciolo,andrea).
genitore(allegraCaracciolo,anna).

nonno(X,Y):-genitore(X,Z),genitore(Z,Y).

antenato(X,Y):-genitore(X,Y). % se X è genitore di Y, allora X è anche antenato di Y
antenato(X,Y):-antenato(X,Z),genitore(Z,Y). % se X è antenato di Z e Z è genitore di Y, allora X è anche antenato di Y

% attenzione: possiamo riscontrare loop nella ricorsione, ad esempio se chiediamo se Edoardo è antenato di Edoardo, 
%o se chiediamo se Edoardo è antenato di Gianni. In questi casi, Prolog continuerà a cercare all'infinito,
% perché non c'è una condizione di terminazione che impedisca la ricorsione infinita.

%se scambiamo le due righe 34 e 35, otteniamo un loop infinito, perché Prolog cercherà di risolvere antenato(X,Y) chiamando 
%antenato(X,Z) che a sua volta chiamerà antenato(X,Y) e così via all'infinito.

fratello_germano(X,Y):-
    %posso inserire anche qui per sicurezza X\== Y così il controllo lo fa subito, il programma
    %è leggero quindi non serve
    genitore(Gen1,X),
    genitore(Gen2,X),

    Gen1 \== Gen2,
    genitore(Gen1,Y),
    genitore(Gen2,Y),
    X \== Y.

%qui c'è un problema, dare due nomi di variabili diversi non implica che abbiano valori per forza diversi
%infatti se ho due fratelli con madri diverse nell'esecuzione tratta ugualmente gen1 e gen2 come lo stesso
%genitore, ad esempio giovanni e andrea sono fratelli germano perchè sono entrambi figli di umberto e 
%di nuovo umberto
%questo vale lo stesso per x e y, infatti gianni è fratello di se stesso 
%fratello_germano(A,B). restituisce A = B, B = gianni
%risolviamo scrivendo \== impongo che due variabili siano diverse
%se scrivo fratello_germano(gianni,gianni) con questa aggiunta ci da falso
%se chiamo ancora fratello_germano(A,B) continua a restituirmi gianni,gianni. Il problema è dove metto X\==Y,
%perchè non ho ancora istanziato A e B, e il controllo lo faccio all'inizio della coda, mentre
%dovrei farlo quando sono sicuro che le variabili siano istanziate, cioè prendono valore
%quindi lo sposto alla fine, niente paura a duplicare le regole perchè quando il codice è grande
%non posso sapere tutto

fratelli_unilaterali(X,Y):-
    X\==Y,
    
    genitore(GenComune, X),
    genitore(GenComune, Y),

    genitore(GenX,X),
    GenX \== GenComune,

    genitore(GenY, Y),
    GenY \== GenComune,

    GenX \== GenY,
    X \== Y.

zio(X,Y):-
    genitore(Z,Y),
    fratello_germano(Z,X),
    X \== Y.

cugino(X,Y):-
    genitore(A,X),
    genitore(B,Y),

    A \== B,
    fratello_germano(A,B),
    X \== Y.

