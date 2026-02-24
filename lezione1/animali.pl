/* Esempio animali 
   e ragionamento nonmonotono */
gatto(tom).
uccello(titty).
uccello(tux).
pinguino(tux).
pinguino(titty).
mangia(titty,pavesino).
mangia(tom,pavesino).
graffia(X):-gatto(X).
vola(X):-uccello(X),\+pinguino(X).
uccello(X):-pinguino(X).
felino(X):-gatto(X).


