# purpose: read from one file and convert its lower-case into upper-case 
#          and write that into another file

.section .data
#constants#
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1


# /usr/include/asm/fcntl.h for references
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# standard file descriptors
.equ STDIN, 0 # input
.equ STDOUT, 1 # output
.equ STDERR, 2 # error

.equ LINUX_SYSCALL, 0x80 # syscall interrupt 

.equ END_OF_FILE, 0 # return value of read which mean we've hit the EOF
.equ NUMBER_ARGUMENTS, 2

# things that don't need initialization but only reserved space; in the memory
.section .bss
# Buffer - where the data is loaded into from the data file and written from 
# into the output file
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE # creating a buffer of size 500 ( BUFFER_SIZE->500 )

.section .text

.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0 
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

.globl _start

_start:
# save the stack pointer
movl %esp, %ebp

# allocate space for the file descriptors on the stack
subl $ST_SIZE_RESERVE, %esp # increases the size of the stack frame

open_files:
open_fd_in:
# open input file
# open syscall : syscall number 5 from the docs https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#i686_5
  movl $SYS_OPEN, %eax
# input filename into %ebx
  movl ST_ARGV_1(%ebp) , %ebx # this is equivalent to | movl valueof %ebp + offset(ST_ARGV_1), %ebx

# read-only flag
movl $O_RDONLY, %ecx

movl $0666, %edx

# call int syscall
int $LINUX_SYSCALL

store_fd_in:
  movl %eax, ST_FD_IN(%ebp)

open_fd_out:

movl $SYS_OPEN, %eax

movl ST_ARGV_2(%ebp),%ebx # output filname into %ebx

movl $O_CREAT_WRONLY_TRUNC, %ecx

movl $0666, %edx # mode for new file (if it's created)

int $LINUX_SYSCALL # interrupt syscall

store_fd_out:
  movl %eax, ST_FD_OUT(%ebp)

read_loop_begin:
  movl $SYS_READ, %eax # read in a block from the input file

  movl ST_FD_IN(%ebp), %ebx # get the input file descriptor
 
  movl $BUFFER_DATA, %ecx # the location to read into

  movl $BUFFER_SIZE, %edx # the size of the buffer

  int $LINUX_SYSCALL # invoke syscall

  cmpl $END_OF_FILE, %eax  # checking if we've reached the EOF

  jle end_loop

continue_read_loop:
  push $BUFFER_DATA # location of buffer
  push %eax # size of buffer
  
  call convert_to_upper

  pop %eax # get the size back
  addl $4, %esp # restore %esp

## write the block to the output file

  movl %eax, %edx # size of the buffer
  movl $SYS_WRITE, %eax # write mode

  movl ST_FD_OUT(%ebp), %ebx
  movl $BUFFER_DATA, %ecx # location of the buffer into %ecx
  int $LINUX_SYSCALL # interrupt syscall

## continue the loop
  jmp read_loop_begin

end_loop:
## close files
  movl $SYS_CLOSE, %eax
  movl ST_FD_OUT(%ebp), %ebx
  int $LINUX_SYSCALL # interrupt syscall

  movl $SYS_CLOSE, %eax
  movl ST_FD_IN(%ebp), %ebx
  int $LINUX_SYSCALL
  movl $SYS_EXIT, %eax
  movl $0, %ebx
  int $LINUX_SYSCALL


## purpose: conversion to uppper case for a block
## input: the first parameter is the location of the block of memory to convert
##        the second parameter is the length of that buffer
##
## output: overwrites the current buffer with the upper-casified version
## variables: %eax - begining of the buffer
##            %ebx - length of buffer
##            %edi - current buffer offset
##            %cl - current byte being examined (first part of %ecx register | lower part)

## constants
.equ LOWERCASE_A, 'a' # lower boundary of our search

.equ LOWERCASE_Z, 'z' # upper boundary of our search

.equ UPPER_CONVERSION, 'A' - 'a'

## stack stuffs

.equ ST_BUFFER_LEN, 8 # length of buffer
.equ ST_BUFFER, 12 # actual buffer

convert_to_upper:
  push %ebp
  movl %esp, %ebp

## setting up variables
  movl ST_BUFFER(%ebp), %eax
  movl ST_BUFFER_LEN(%ebp), %ebx
  movl $0, %edi

  cmpl $0, %ebx # if a buffer with 0 length was given
  je end_convert_loop # exit the conversion loop

convert_loop:
  movb (%eax,%edi,1), %cl # movb moves a single byte | start at %eax and go %edi locations forward with each location being 1 byte big

# go to the next byte unless it is between 'a' and 'z'
  cmpb $LOWERCASE_A, %cl
  jb next_byte

  cmpb $LOWERCASE_Z, %cl
  ja next_byte

# otherwise convert  the byte to uppercase
  addb $UPPER_CONVERSION, %cl 
# and store it back
  movb %cl, (%eax,%edi,1)

next_byte:
  incl %edi # increment the buffer offset (kinda like index)
  cmpl %ebx, %edi # checking if we've reached the end | if index == length of buffer

  jne convert_loop # re_run the loop if not

end_convert_loop:
  movl %ebp, %esp
  pop %ebp
  ret
#######################
# Reading and writing files in UNIX
# the `open` syscall is what handles this
# it takes following paramters
# %eax -> syscall number i.e. 5 | open | https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#i686_5
# %ebx -> pointer to a string that is the name of the file to open 
# %ecx -> mode with which to open the file | read-only, write-only, read&write
# %edx -> contains the permission that are used to open the file| used incase the file has to be created first, so the linux kernel know what permission to create the file with
# %eax -> after the syscall the fd(file descriptor) of the opened-file is stored in %eax register 
#######################
