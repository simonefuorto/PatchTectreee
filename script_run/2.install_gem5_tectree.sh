#!/bin/bash

# Identifica automaticamente la directory dello script e la root del progetto Tectree
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."
GEM5_DIR="$REPO_ROOT/../gem5"
TEMP_TARDIS_DIR="$REPO_ROOT/../temp_tardistso"

# URL delle repository originali
REPO_GEM5_URL="https://github.com/gem5/gem5.git"
REPO_PATCH_URL="https://github.com/emanueledim/gem5_tardistso.git"
GEM5_VERSION="v23.1"

echo "=========================================================="
echo "Inizio Installazione Automatica: GEM5 + TARDIS + TECTREE"
echo "=========================================================="

# 1. Controllo Git
if ! command -v git &> /dev/null; then
    echo "Git non trovato. Installazione in corso..."
    sudo apt update && sudo apt install -y git
fi

# 2. Clona gem5 (se non esiste)
if [ ! -d "$GEM5_DIR" ]; then
    echo "[1/4] Clonazione della repository gem5 in $GEM5_DIR ..."
    git clone "$REPO_GEM5_URL" "$GEM5_DIR"
else
    echo "[1/4] Cartella gem5 già esistente, salto la clonazione."
fi

# 3. Checkout della versione gem5 corretta
cd "$GEM5_DIR" || exit
if git rev-parse --verify "$GEM5_VERSION" &> /dev/null; then
    echo "[2/4] Cambio alla versione gem5 $GEM5_VERSION..."
    git checkout "$GEM5_VERSION"
    pip install -r requirements.txt
else
    echo "ERRORE: Versione $GEM5_VERSION non trovata in gem5."
    exit 1
fi

# 4. Scarica e applica la patch originale TARDISTSO
echo "[3/4] Scaricamento della patch TARDISTSO originale..."
if [ ! -d "$TEMP_TARDIS_DIR" ]; then
    git clone "$REPO_PATCH_URL" "$TEMP_TARDIS_DIR"
fi

echo "      Applicazione della patch TARDISTSO su gem5..."
cp -r "$TEMP_TARDIS_DIR/patch/." "$GEM5_DIR"
rm -rf "$TEMP_TARDIS_DIR" # Pulizia cartella temporanea

# 5. Applica la patch Tectree (questa repository)
echo "[4/4] Applicazione della patch TECTREE (Tesi Simone Fuorto)..."
# Copiamo solo le cartelle necessarie alla simulazione (src, configs, tests) 
# per non sporcare gem5 con documenti di tesi o script esterni.
if [ -d "$REPO_ROOT/src" ]; then cp -r "$REPO_ROOT/src" "$GEM5_DIR/"; fi
if [ -d "$REPO_ROOT/configs" ]; then cp -r "$REPO_ROOT/configs" "$GEM5_DIR/"; fi
if [ -d "$REPO_ROOT/tests" ]; then cp -r "$REPO_ROOT/tests" "$GEM5_DIR/"; fi

echo "=========================================================="
echo "Installazione Completata con Successo!"
echo "L'ambiente gem5 è ora perfettamente patchato con Tectree."
echo "Prossimo step suggerito: eseguire lo script di build."
echo "=========================================================="
