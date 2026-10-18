#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
nasm -f elf64 -g -F dwarf -o main.o src/main.asm
gcc -no-pie -o ayo-race main.o -lSDL2 -lGL -lGLU -lm
echo "Built: ./ayo-race"
