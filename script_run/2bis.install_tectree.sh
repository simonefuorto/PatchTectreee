#!/bin/bash

# Folder definitions
DEST_DIR="gem5"
SRC_TECTREE="patch_tectree"

# Check if gem5 exists
if [ ! -d "$DEST_DIR" ]; then
    echo "Errore: la cartella gem5 non esiste. Esegui prima 2.install_gem5.sh per scaricare il simulatore."
    exit 1
fi

# Check if new patch exists
if [ ! -d "$SRC_TECTREE" ]; then
  echo "Errore: Patch TARDISTSO non trovata."
  exit 1;
fi

# Copy patch files into gem5
cp -r "$SRC_TECTREE"/. "$DEST_DIR"

echo "Installazione della patch TARDISTSO-TECTREE completata con successo."
