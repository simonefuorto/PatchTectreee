#!/bin/bash

DEST="gem5"

if [ ! -d "$DEST" ]; then
  echo "Gem5 directory not found!"
  exit 1
fi

cd "$DEST"

time ./build/X86_TARDISTSO/gem5.opt configs/tardis_tso/x86-ubuntu-run-timing-tardistso.py