# finding maximum number in a list
# %edi-> current index
# %ebx-> largest value
# %eax-> current value

.section .data
 
value_list:
 .long 1,5,33,89,32,123,9,3,0

.section .text
.globl _start

_start:
# initial conditions when index = 0
  movl $0,%edi # index=0
  movl value_list(,%edi,4),%eax # current value=first index of value_list
  movl %eax,%ebx # largest = current = first

start_loop:
  cmpl $0, %eax # checking if we've reached the end
  je exit #exiting if we've reached the end
  incl %edi 
  movl value_list(,%edi,4),%eax # current value=incremented index
  cmpl %ebx, %eax
  jle start_loop
  movl %eax, %ebx
  jmp start_loop

exit:
 movl $1, %eax
# why not use %ebx here? because our largest value is stored in the "ebx" register so the exit code is itself the largest value of the list
  int $0x80 
