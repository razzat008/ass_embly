# finding maximum number in a list
# %edi-> current index
# %ebx-> smallest value
# %eax-> current value

.section .data
 
value_list:
 .long 9,1,5,33,89,32,123,9,3,255

.section .text
.globl _start

_start:
 # initial conditions when index = 0
  movl $0,%edi # index=0
  movl value_list(,%edi,4),%eax # current value=first index of value_list
 # movl BEGINNINGADDRESS(,%INDEXREGISTER,WORDSIZE)
  movl %eax,%ebx # largest = current = first

start_loop:
  cmpl $255, %eax # checking if we've reached the end | eax==0
  je exit #exiting if we've reached the end
  incl %edi  #increment index by 1
  movl value_list(,%edi,4),%eax # current value=incremented index | indexed addressing mode
  cmpl %ebx, %eax #compare current value with the largest value we've found so far | ebx==eax
  jg start_loop #jump to begining of the loop if less than or equal to
  movl %eax, %ebx #assign ebx = eax
  jmp start_loop # jump to begining of the loop

exit:
  movl $1, %eax # syscall to exit
 # why not use %ebx here? because our largest value is stored in the "ebx" register so the exit code is itself the largest value of the list
  int $0x80  # interrupt and handle control over to the kernel

