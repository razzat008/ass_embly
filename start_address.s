# to see where the _start is initialized
.section .text
.globl _start
_start:
movl $_start,%ebx

movl $1,%eax
int $0x80
