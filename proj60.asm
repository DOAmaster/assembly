# author: Derrick Alden
# date: 2017
# This program displays an image on a test display.
# usage: spim -f proj60.s <ppmfile>
# assumes a file named data exists in the current directory
#
# file_open   $v0 = 13   
#             $a0 = full path (null terminated string)
#             $a1 = flags, use 0 for reading 
#             $a2 = UNIX octal file mode (0644 for rw-r--r--)   
#             returns $v0 = file descriptor   
#
# file_read   $v0 = 14   
#             $a0 = file descriptor
#             $a1 = buffer address 
#             $a2 = amount to read in bytes 
#             returns $v0= amount of data in buffer from file (-1=error, 0=EOF) 
#
# file_write  $v0 = 15 
#             $a0 = file descriptor
#             $a1 = buffer address 
#             $a2 = amount to write in bytes
#             returns $v0 = amount of data in buffer to file (-1=error, 0=EOF)  
#
# file_close  $v0 = 16   
#             $a0 = file descriptor
#
#           .space  1 '\0'      # stuff a null character at the end of the buffer

.data
filename: .asciiz "csub3.ppm"     # filename
          .word   0          # do this to align things
buffer:   .space  4          # a buffer of size 4 bytes 

          .word   0          # do this to align things
errormsg: .asciiz "file open or read error\n"
foundmsg: .asciiz "Good P3 file found.\n"
foundcomment: .asciiz "Found a comment: "
heightmsg: .asciiz "Image height: "
widthmsg: .asciiz "Image width: "
colormsg: .asciiz "Maximum color value: "
linefeed: .asciiz "\n"
var1:     .asciiz "P3"

.text
.globl main
.globl b1 # do this to set a debugging break point
 
main:
	                     # allow for optional comman-line parameter
	                     # holding the a file name.
	la $s0, filename     # default to file named "data"
	li $t0, 2            # is the parameter count < 2
	blt $a0, $t0, lab1   # 
	lw $s0, 4($a1)       # get file name from command-line
lab1:
	                     # open file for reading
	li $v0, 13           # 13 is file open syscall  
	##la  $a0, filename    # filename
	move $a0, $s0        # filename
	add $a1, $0, $0      # flags=O_RDONLY=0 - (like a move $0)
	add $a2, $0, $0      # mode=0
	syscall
	                     # file is open
	add $s0, $v0, $0     # store fd in $s0 before you overwrite it

	                     # check value of file descriptor in $s0;
	                     # -1 means a file open error occurred
	bltz  $s0, error
	                     # read 4 bytes from file, storing in buffer
	li   $v0, 14         # 14=read from  file
	move $a0, $s0        # $s0 holds fd - load this into $a0
	la   $a1, buffer     # load the address to the buffer 
	li   $a2, 4          # load the size of buffer
	syscall
	                     # check error condition
	bltz $v0, error      # amount of data read is in v0 
b1:                      # put in break point for debugging purposes
	                     # do this to display number of bytes read -
	                     # when $v0 = 0 you have hit EOF
	                     # this code is useful for debugging -
	                     # uncomment if you wish
	# move $a0, $v0     
	# li   $v0, 1      
	# syscall
	                     # print the buffer
	                     # print string syscall will stop at \0
 	la $t3, var1



  jal goodppm
#	beq $v0, $t3, goodppm  
  jal comment

  jal height

  jal width

	# ------------------------------------------------------------------
top:
  li $v0, 4            # 4=print string



# prints char by line
	la   $a0, buffer     # buffer is 4 bytes followed by a null byte
	syscall    
 
	
	#li   $v0, 11         # print a star in second char
	#li   $a0, '*'
	#syscall

	                     # read 4 more bytes
	li   $v0, 14         # 14=read from file
	add  $a0, $s0, $0    # $s0 holds fd


  li  $t0, '#'
  beq $v0, $t0, comment

  syscall

	bltz $v0, error      # amount of data read is in v0
	bgtz $v0, top
	#-------------------------------------------------------------------
	                     # EOF was reached.
	                     # print a final line feed
	                     # useful for debugging so you know where you end
eof:

	li   $a0, 10
	li   $v0, 11
	syscall

	                   # close file
	li  $v0, 16        # 16=close file
	add  $a0, $s0, $0  # $s0 holds fd
	syscall            # close file
	b exit

height:
	li $v0, 4
	la $a0, heightmsg
	syscall


  
  j $ra

width: 
	li $v0, 4
	la $a0, widthmsg
	syscall



  j $ra


comment:
	li $v0, 4
	la $a0, foundcomment
	syscall

comment2:

  li $v0, 4            # 4=print string
                       # prints char by line
	la   $a0, buffer     # buffer is 4 bytes followed by a null byte
	syscall    
	                     # read 4 more bytes
#	li   $v0, 14         # 14=read from file
#	add  $a0, $s0, $0    # $s0 holds fd
 # syscall

  li  $t0, 'A'
  beq $v0, $t0, comment2

  j $ra

 # bltz $v0, error
 # bgtz $v0, top       #branch if $v0 is not 0 back to top

goodppm:
	li $v0, 4
	la $a0, foundmsg
	syscall

  j $ra
	bltz $v0, error      # amount of data read is in v0
	bgtz $v0, top

error:                 # file i/o error 
	li $v0, 4
	la $a0, errormsg
	syscall
   
exit:  
	li  $v0, 10        # exit 
	syscall
