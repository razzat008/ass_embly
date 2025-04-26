    learning assembly, because why not?

## Running programs
First assemble your XX-bit source file into an object file using an assembler.\
I'm using the gnu assembler `as`, say if you have a 32-bit assembly source file then,\
the command to assemble would be:
```bash
as --32 <your_file>.s -o <your_object_file>.o
```
Use a linker to link your object file into a binary executable
```bash
ld -m elf_i386 <your_object_file>.o -o <your_binary>
```

Replace <your_file> with your source file and  <your_object_file> with object file.
