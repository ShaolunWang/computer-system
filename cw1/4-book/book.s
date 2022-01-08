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

la  $t2, input_text
li  $t0, 0
li  $t7, 0
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
	beq $s5, $0, endexec

	j getline
	
getline:

	lb   $s5, 0($t2)
	
	beq  $s5, 32, getpos
	beq  $s5, $0, endexec
	
	subi $s5, $s5, 48
	 
	sll  $t6, $s2, 1			#
 	sll  $t5, $s2, 3			#   $s2 * 10
 	add  $s2, $t6, $t5		#
	
	add  $s2, $s2, $s5
	
	addi $t2, $t2, 1
	j getline
	
getpos:
	
	addi $t2, $t2, 1
	lb  $s5, 0($t2)
	beq $s5, $0, endexec
	beq $s5, 10, go
	
	subi $s5, $s5, 48
	
	sll $t6, $s3, 1
	sll $t5, $s3, 3
	add $s3, $t6,$t5
	
	add $s3, $s5, $s3
	
	j getpos

back:
	jr $ra

go:
	addi $t2, $t2, 1
	li $s0, 1 # line counter
	li $t4, 1 # space counter
	
readbook:
	lb  $t3, 0($t1)
	jal checkCounter
	beq $s2, $s0, checkSpaceEqual
	
	addi $t1, $t1, 1
	j readbook
	
checkSpaceEqual:
	sub $t5, $t4, $s3
	beq $t5, $0, beforeoutput
	addi $t1, $t1, 1
	j readbook

beforeoutput:
	bne $t7, 0, printspace
	j output
	
printspace:
	li $v0, 11
	li $a0, 32
	syscall
	li $t7, 1

output:
	addi $t1, $t1, 1
	lb  $t3, 0($t1)
	
	beq $t3, 32, endOutput
	beq $t3, 10, endOutput
	beq $t3, $0, endOutput
	
	j print

print:
	li $v0, 11
	add $a0, $0,$t3
	syscall
	j output


beforeOutput_ten_Endfile:
	beq $s2, $s0, output_ten
	j start
beforeOutput_ten_Endline:
	beq $s2, $s0, output_ten
	j checkEndline
output_ten:

	addi $t1, $t1, 1
	li $t7, 0
	li $v0, 11
	li $a0, 10
	syscall
	
	addi $t1, $t1, 1
	
endOutput_ten:
	li $t7, 0
	j start
	
endOutput:
 	li $t7, 1
	j start 
	
checkCounter:
	beq $t3, $0, beforeOutput_ten_Endfile
	beq $t3, 10, beforeOutput_ten_Endline
checkEndline:
	beq $t3, 10, addendline
checkSpace:
	beq $t3, 32, addSpace
	
	j back
	
addendline:
	addi $s0, $s0, 1
	li $t4, 1
	j back
addSpace:
	addi $t4, $t4, 1
	j back

endexec:
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
