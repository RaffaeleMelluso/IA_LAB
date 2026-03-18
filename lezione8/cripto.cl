% criptoaritmetica
% S E N D +
% M O R E =
% -----------------
% M O N E Y

%modo compatto per scrivere cifra(1) cifra(2) ...
cifra(0..9).
%modo compatto per scrivere lettera(s) ...
lettera(s;e;n;d;m;o;r;y).

%per ogni lettera L assegno una cifra C
1 {assegna(L,C):cifra(C)} 1:- lettera(L).
0 {assegna(L,C):lettera(L)} 1:- cifra(C).

sono_contento:-cifra(S;E;N;D;M;O;R;Y),
    assegna(s,S), assegna(e,E), assegna(n,N), 
    assegna(d,D), assegna(m,M), assegna(o,O),
    assegna(r,R), assegna(y,Y),
    1000*S+100*E+10*N+D+1000*M+1000*O+10*R+E==
    10000*M+1000*O+100*N+10*E+Y, S>0, M>0.
:- not sono_contento.

#show assegna/2.
