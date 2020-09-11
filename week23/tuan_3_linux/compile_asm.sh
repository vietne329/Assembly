#!/bin/bash

file="$1"
file_name=$(echo "$file" | cut -d "." -f1)
nasm -f elf32 "$file"
gcc -m32 "$file_name".o -o "$file_name" -nostartfiles
echo "$file_name".o | xargs rm -rf
