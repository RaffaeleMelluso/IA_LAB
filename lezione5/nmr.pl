uccello(X):- pinguino(X).
vola(X):-uccello(X),\+pinguino(X).
%non posso scrivere /+vola(X):-pinguino(X). perchè non fa parte di prolog
uccello(titty).
pinguino(tux).

pinguino(titty).