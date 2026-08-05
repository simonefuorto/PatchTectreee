#!/bin/bash

DEST="gem5"
ARCH="X86"
PROTOCOL="TARDISTSO_TECTREE"
WORKLOAD="lu_bm"
SIZE=64 # Matrice sufficientemente grande da forzare i rimpiazzi (eviction) in L1 e scatenare il Livelock!

if [ ! -d "$DEST" ]; then
  echo "Gem5 directory not found!"
  exit 1
fi

cd "$DEST"

GEM5_EXE="./build/${ARCH}_${PROTOCOL}/gem5.opt"
if [ ! -f "$GEM5_EXE" ]; then
    echo "ERRORE: Eseguibile non trovato."
    exit 1
fi

echo "=========================================================="
echo "Avvio Debug Livelock: Matrice $SIZE x $SIZE"
echo "Protocollo: $PROTOCOL"
echo "Il test verrà forzatamente ucciso dopo 30 secondi per evitare log infiniti."
echo "=========================================================="

# Esecuzione con comando 'timeout' per evitare che il trace riempia il disco
# Genera il file di debug livelock_trace.txt dentro la cartella m5out
timeout 30s $GEM5_EXE \
    --debug-flags=RubySlicc,TectreeLLC \
    --debug-start=1973204000 \
    --debug-file=livelock_trace.txt \
    configs/deprecated/example/se.py \
    -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} \
    --options="-p 4 -n $SIZE -b 16 -t" \
    -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby --mem-size=4GB

echo ""
echo "Test terminato (o killato dal timeout)."
echo "Il file di tracciamento è stato salvato in: gem5/m5out/livelock_trace.txt"
echo "Ora possiamo esaminare le ultime righe per trovare il loop!"
