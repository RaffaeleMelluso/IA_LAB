(deffacts stato-iniziale
   (semaforo rosso))

(defrule regola-fermati
   (semaforo rosso)
   =>
   (printout t "Fermati!" crlf))

(defrule regola-passa
    (semaforo verde)
    =>
    (printout t "Puoi passare!" crlf))