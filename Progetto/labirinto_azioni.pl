%applicabile (Az,S)
applicabile(nord,pos(R,C)):-
    R > 1,
    RNuova is R-1,
    \+occupata(pos(RNuova, C)).

applicabile(sud, pos(R,C)):-
    num_righe(N),
    R < N,
    RNuova is R+1,
    \+occupata(pos(RNuova, C)).
applicabile(ovest, pos(R,C)):-
    C > 1,
    CNuova is C-1,
    \+occupata(pos(R,CNuova)).
applicabile(est, pos(R,C)):-
    num_col(M),
    C < M,
    CNuova is C+1,
    \+occupata(pos(R,CNuova)).

%trasforma(Az, S, SNuovo)
trasforma(nord, pos(R,C),pos(RNuova,C)):-RNuova is R-1.
trasforma(sud, pos(R,C),pos(RNuova,C)):-RNuova is R+1.
trasforma(ovest, pos(R,C),pos(R,CNuova)):-CNuova is C-1.
trasforma(est, pos(R,C),pos(R,CNuova)):-CNuova is C+1.