persona(a).
persona(b).
persona(c).
tipo(onesto).
tipo(bugiardo).
%ogni persona deve avere un tipo
%l'oggetto ha nimimo 1 e massimo 1 oggetto
1 {ha_tipo(P,T):tipo(T)} 1:-persona(P).


%a dice che sia b che c sono onesti
dice_il_vero(a):-ha_tipo(b, onesto), ha_tipo(c, onesto).

% b dice che a è bugiardo, mentre c è onesto
dice_il_vero(b):-ha_tipo(a,bugiardo), ha_tipo(c, onesto).

%gli onesti dicono sempre la verità
:-ha_tipo(P, onesto), not dice_il_vero(P).

%i bugiardi mentono sempre
:-ha_tipo(P, bugiardo), dice_il_vero(P).

#show ha_tipo/2.