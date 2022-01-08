#=========================================================================
# Steganography
#=========================================================================
# Retrive a secret message from a given text.
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

input_text_file_name:         .asciiz  "input_steg.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
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

# opening file for reading

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
        la   $a1, input_text($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP         # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
la  $t2, input_text
li  $t7, 0
li  $t0, 0
# -------------------------
# this part would be getting the input 
# -------------------------
	la $t1, input_text


go:
	li $s3, 1 # line counter
	li $t4, 1 # space counter

read:
 	lb $t3, 0($t1)
 	beq $s3, $t4, beforeOutput
 	beq $t3, 10, checkEndline
	beq $t3, 32, addSpace
	beq $t3, $0, endexec
	addi $t1, $t1, 1
	j read
beforeOutput:

	bne $t7, 0, printspace
	j output

printspace:
	li $v0, 11
	li $a0, 32
	syscall
	li $t7, 1

output:
	lb $t3, 0($t1)
	beq $t3, 32, endOutput
	beq $t3, 10, endOutput
	beq $t3, $0, endexec	
	addi $t1, $t1, 1
	j print
	
print:
	li $v0, 11
	add $a0, $0,$t3
	syscall
	j output
	
endOutput:
 	li $t7, 1
 	li $t0, 1
 	beq $t3, 10, addEndline
 	beq $t3, 32, addSpace
 	addi $t1, $t1, 1
	j read 


checkEndline:
	beq $t0, 1, addEndline
	li $v0, 11
	li $a0, 10
	li $t7, 0
	syscall
	j addEndline


addEndline:
	addi $s3, $s3, 1
	li $t4, 1
	li $t0, 0
	addi $t1, $t1, 1
	j read
	
addSpace:
	addi $t4, $t4, 1
	addi $t1, $t1, 1
	j read

endexec:

	li $v0, 11
	li $a0, 10
	syscall
	j main_end

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#-----------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
