#=========================================================================
# Book Cipher Decryption
#=========================================================================
# Decrypts a given encrypted text with a given book.
# 
# Inf2C Computer Systems
# 
# Dmitrii Ustiugov
# 9 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_book_cipher.txt"
book_file_name:               .asciiz  "book.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
book:                         .space 10001       # Maximum size of book_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading (text)

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)


# opening file for reading (book)

        li   $v0, 13                    # system call for open file
        la   $a0, book_file_name        # book file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # book[idx] = c_input
        la   $a1, book($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(book_file);
        blez $v0, END_LOOP1             # if(feof(book_file)) { break }
        lb   $t1, book($t0)          
        beq  $t1, $0,  END_LOOP1        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  book($t0)             # book[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(book_file)
                    # fclose(book_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
#initialize some stuffs (globally)

la  $t1, book       # book address in $t1
la  $t2, input_text
li  $t0, 0
li  $s0, 0
# -------------------------
# this part would be getting the input 
# -------------------------

start:
	la  $t1, book       # book address in $t1
	# the start of the input read
	li  $s1, 1          # the line counter
	li $s2, 0
	li $s3, 0
	lb $s5, 0($t2)
	beq $s5, $0, checkend
	
	j getline
	
getline:

	lb  $s5, 0($t2)
	
	beq $s5, 32, getpos
	beq $s5, $0, checkend
	sll $s2, $s2,4
	subi $s5, $s5, 48
	or $s2, $s5, $s2
	addi $t2, $t2, 1
	
	j getline
	
getpos:
	
	addi $t2, $t2, 1
	lb  $s5, 0($t2)
	beq $s5, $0, checkend
	beq $s5, 10, go
	sll $s3, $s3, 4
	subi $s5, $s5, 48
	or $s3, $s3, $s5
	
	j getpos

back:
	jr $ra


go:
	addi $t2, $t2, 1
	addi $s0, $s0, 1
	beq $s4, $0, lastline
	j call
lastline:
	li $t0, 1
	
call:
	  li  $s1, 1          # the line counter
      jal init
      j read
     
init:
        li $s6, 0
        #init on every realine loop
        li  $t7, 1               # the space counter
        jr $ra
        
read:
        lb   $t5, 0($t1)            # load char at index ($t1)
        beq  $t5, $0, start
        beq  $t5, 10, printEnd       # a check for endl
        beq  $t5, 32, check		    # a normal check
       
        addi $t1, $t1, 1
        j read
        
check: 
		beq  $s1, $s2, output     # if line count equal we output	
		addi $t7, $t7, 1	
		addi $t1, $t1, 1
		j read
		
output:
		# the output branch
		addi $t7, $t7, 1
		addi $t1, $t1, 1
		lb   $t5, 0($t1)
		
	    sub $t6, $t7, $t3
        blt  $t6, $0, changeline
		
		
		beq $s3, $t7, beforeRead
		j read

beforeRead:
	beq $a0, 32, print
	beq $s0, 1, print
	beq $a0, 10, print
	li $v0, 11
    li $a0, 32
    syscall			
		
print:
		beq $t5, 10, cword           # handle exception
    	beq $t5, 32, cword
    	
		
		li $v0, 11
		add $a0, $t5, $0
		syscall
		
		addi $t1, $t1, 1
		lb   $t5, 0($t1)
		
		beq $t5, 32, afterRead
		beq $t5, 0,  afterRead
		j print
		
		j read		
		
		
afterRead:
		addi $t7, $t7, 1
		addi $t1, $t1, 1
		j read				

cword:
	
	lb $s5, 1($t2)
	beq $s5, $0, read
	
    li $v0, 11
    li $a0, 32
    syscall
    
    j read


printEnd:
		bne $s2, $s1, endadd
	    sub $t6, $t7, $s3
        blt $t6, $0, changeline
        j endadd
        
changeline:		
		li $v0, 11
		li $a0, 10
		syscall
		
		j endadd

endadd:
	addi $s1, $s1, 1
	addi $t1, $t1, 1
	li $t7, 1
	j read

checkend:
	
	li $v0, 11
	li $a0, 10
	syscall
	j main_end

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------

main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
