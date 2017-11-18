# file-write.s
# demonstrate how to open and write to a file
# there is a bug with spim on creating a file for writing - the kludge below
# solves the problem
   
      .data
fout: .asciiz "outfile" # output filename 
buffer: .asciiz "The quick brown fox jumps over the lazy dog."
errstr: .asciiz "File open error.\n"
   
      .text
.globl main
   
main:
   
   la $t0, buffer  # $t0 holds address of the string you wish to write 
   
   # create a file for writing
   li $v0, 13      # system call to open a file
   la $a0, fout    # output file name
   li $a1, 0x41C2  # RW | Create | Append 
   li $a2, 0x1A4   # set mode to 644
   syscall         # make the call - this creates the file

   move $s6, $v0   # save the file descriptor

   # close the file - you have to do this because of a bug in spim
   li $v0, 16      # system call to close file
   move $a0, $s6   # file descriptor to close
   syscall         # make the call 

   # now re-open the file you just created for writing
   li $v0, 13      # system call to open a file
   la $a0, fout    # output file name
   li $a1, 0x102   # flags 0: read, 1: write, 2: read/write; OR Create: 0x100 
   li $a2, 0       # ignore mode this time
   syscall         # make the call

   move $s6, $v0   # save the file descriptor
  
   # check for error condition
   bltz $v0, err 
 
   # write to file just opened
   li $v0, 15      # system call for write to file
   move $a0, $s6   # file descriptor
   move $a1, $t0   # address of buffer to write
   li $a2, 44      # hardcoded buffer length
   syscall         # write to file
   
   # close the file
   li $v0, 16      # system call to close file
   move $a0, $s6   # file descriptor to close
   syscall         # make the call 
   j exit
 
err:
   la $a0, errstr 
   li $v0, 4
   syscall
 
exit:
   li $v0, 10
   syscall
   
