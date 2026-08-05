#!/bin/bash

# Gem5 and Tardis repo
REPO_URL="https://github.com/gem5/gem5.git"
REPO_PATCH_URL="https://github.com/emanueledim/gem5_tardistso.git"
DEST_DIR="gem5"
OLD_VERSION="v23.1"

# Check git
if ! command -v git &> /dev/null; then
    echo "Git not found. Installation..."
    sudo apt update && sudo apt install -y git
fi

# Clone repository
if [ ! -d "$DEST_DIR" ]; then
    echo "Cloning gem5 repository..."
    git clone "$REPO_URL" "$DEST_DIR"
else
    echo "Gem5 repository already installed."
fi

# Switch to repo directory
cd "$DEST_DIR" || exit

# Checkout version
if git rev-parse --verify "$OLD_VERSION" &> /dev/null; then
    echo "Switching to version $OLD_VERSION..."
    git checkout "$OLD_VERSION"
	pip install -r requirements.txt
else
    echo "Error: bad version number ($OLD_VERSION not found)."
fi

# Patch folder
SRC="patch"

cd ..
if [ ! -d "$SRC" ]; then
  echo "Gem5 Tardis TSO Patch not found."
  exit 1;
fi

# Copy patch files into gem5
cp -r "$SRC"/. "$DEST_DIR"

echo "Installation and patch applied."
