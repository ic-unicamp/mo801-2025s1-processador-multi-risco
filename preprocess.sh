#!/bin/bash

# Pre-requisite:
# Clone the riscv-tests suite alongside this project (same parent directory)
# Example: if this project is in ./my-project/, clone riscv-tests into ../riscv-tests/

# riscv-tests source at https://github.com/riscv-software-src/riscv-tests

SRC_DIR="../riscv-tests/isa/rv32ui"
mkdir -p preprocessed

for file in "$SRC_DIR"/*.S; do
  name=$(echo "$file" | sed -E 's:.*/(.*)\.S$:\1:')
  output="preprocessed/${name}.pre.S"

  printf "%s\n" \
    "# Generated using the 'preprocess.sh' script located in the project root directory." \
    "# Source file from: https://github.com/riscv-software-src/riscv-tests" \
    "" > "$output"

  riscv64-unknown-elf-gcc -E -x assembler-with-cpp \
    -I../riscv-tests/env/p -I../riscv-tests/isa/macros/scalar -I../riscv-tests/isa/rv32ui \
    "$file" >> "$output"

  echo "Processed $file -> $output"
done

echo "All files preprocessed."

