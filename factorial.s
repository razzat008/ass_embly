# purpose: calculating the factorial of a specified number
# 3! = 3 * 2 * 1 = 6
.section .data # as we don't have anything to store; this can be empty


.section .text # the actual code
.globl _start # labeling entry point for out linker

_start: # program entry point (equivalent to main function of a generic C program)
  push $5 # push 3 into the stack frame 

  call factorial # create a stackframe for factorial function
  addl $4, %esp # clearing the stackframe off (removing the pushed argument i.e. $3)
  movl %eax, %ebx # as ebx register is the exit status storing the value in it and a function will return it's value into %eax register

  movl $1, %eax # preparing for syscall
  int $0x80

# factorial function
.type factorial,@function
factorial:
  push %ebp # base pointer
  movl %esp, %ebp # as the stackpointer(%esp) keeps on changing whenever push/pop instructions are given

  movl 8(%ebp),%eax # the first argument i.e. 3 into the eax register

  cmpl $1,%eax # if the argument==1
  je end_factorial 

  decl %eax # decrement the number i.e. if 5 then 4 (n-1)
  push %eax # push  (n-1) into the stackframe
  call factorial

  movl %eax,%ebx # value is return to %eax after function ends
  movl 8(%ebp),%eax # the original parameter
  imull %ebx,%eax # multiply (n-1)*n

end_factorial:
  movl %ebp, %esp # restoring %esp and %ebp (%esp varies , %ebp remains same)
  pop %ebp # (pops the return value too) pop operation as it was pushed in  line 22
  ret
