#!/bin/bash
# Script per simulare i turni del torneo

echo "Quale turno vuoi simulare?"
echo "1) turno1"
echo "2) turno2"
read -p "Scelta (1 o 2): " choice

if [ "$choice" = "1" ]; then
    echo "Esecuzione turno1..."
    clingo torneo.cl turno1.cl -n 1
elif [ "$choice" = "2" ]; then
    echo "Esecuzione turno2..."
    clingo torneo.cl turno2.cl -n 1
else
    echo "Scelta non valida"
fi
