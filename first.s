# simple program that exits and returns a status code back to the kernel
.section .data

.section .text
.globl _start

_start:
# preparing to exit the program
  movl $1,%eax # loading 1 to the eax register, the dollar sign indicate it's in immediate  addressing mode i.e. (the specified value is directly written into the said register)

  movl $9,%ebx # specifying the status code the program needs to exit in (can be any number)

  int $0x80
