# calculate 2^0 + 5^0 using functions
.section .data

.section .text
.globl _start

_start:
  push $2
  push $2
  call power
  addl $8,%esp
  
  push %eax # first answer
  push $2 # push 2nd argument
  push $2 # push 1st argument 
  call power # call the function
  addl $8, %esp # move the stack pointer back

  pop %ebx # pop the saved answer of the first expression i.e. 2^3
  addl %eax,%ebx # add both answers
  movl $1,%eax # preparing for exit syscall
  int $0x80

# purpose: calculates the value of a number raised to it's power
# first agument: base number
# second agument: power the base is raised to
# %ebx: holds the base number 
# %ecx: holds the power
.type power,@function # function
power:
  push %ebp # base pointer
  movl %esp, %ebp # basepointer = stack pointer initially
  subl $4, %esp # decrement the esp by 4(1 word,byte) i.e. increasing size of the stack frame
  movl 8(%ebp),%ebx #putting first argument(base) into ebx ?
  movl 12(%ebp),%ecx # putting second argument(power) into ecx ?
  movl %ebx,-4(%ebp) # store current result ?
##########################
#  | 3 <-- 12(%ebp) 
#  | 2 <-- 8(%ebp)
#  | return address <-- 4(%ebp)
#  | old %ebp <-- (%ebp)
#  | current result -4(%ebp)
##########################

power_loop_start:
  cmpl $1,%ecx # check if the power is 1
  je end_power # end loop if true
  movl -4(%ebp),%eax # current result into %eax
  imull %ebx,%eax # multiply the current number by base number | equivalent to : eax=eax*ebx?

  movl %eax,-4(%ebp) # store the current result
  decl %ecx # decrease power
  jmp power_loop_start # again for next power

end_power:
  movl -4(%ebp),%eax # return value goes in %eax
  movl %ebp,%esp # restore the stack pointer
  pop %ebp # restore the base pointer
  ret
