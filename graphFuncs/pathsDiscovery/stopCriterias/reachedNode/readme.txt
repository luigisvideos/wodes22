questo criterio di stop funziona solo settando skipCycles = true;
ovviamente, così facendo, non vengono ottenuti i path che passano attraverso
il nodo target e ritornano su di esso, pur contenendo tali path nodi mai
esplorati prima al di fuori del nodo target stesso (es, ciclo che si chiude
sul nodo target). 
per il calcolo del linguaggio del MSCG la mancanza di tali path non è un 
problema poiché i sistemi algebrici contengono già tutte le info con i 
soli path che partono dallo stato iniziale ed incontrano una sola volta
il nodo target