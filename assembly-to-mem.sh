#!/bin/bash

# Assemble, link, and extract hex instructions into sequentially named testXX.mem files

for file in preprocessed/*.pre.S; do
  last_index=$(find test -name 'teste[0-9][0-9].mem' | sed -E 's/.*teste([0-9]{2})\.mem/\1/' | sort -n | tail -1)
  index=$((10#$last_index + 1))
  mem_out=$(printf "test/teste%02d.mem" "$index")

  riscv64-unknown-elf-as -o temp.o "$file"
  riscv64-unknown-elf-ld -Ttext=0x80000000 -o temp.elf temp.o

  riscv64-unknown-elf-objdump -d temp.elf | grep '^ ' | awk '{print $2}' > "$mem_out"

  echo "Generated memory hex file: $mem_out"
done

rm -f temp.o temp.elf

echo "All .mem files generated."
