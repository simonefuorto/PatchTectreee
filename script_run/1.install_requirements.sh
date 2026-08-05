#!/bin/bash

echo "Installing requirements..."

sudo apt update
sudo apt install build-essential git m4 scons zlib1g zlib1g-dev libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev python3-dev python3 -y

echo "Done."