#=========================================================================
# XOR Cipher Encryption
#=========================================================================
# Encrypts a given text with a given key.
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

input_text_file_name:         .asciiz  "input_xor.txt"
key_file_name:                .asciiz  "key_xor.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
key:                          .space 33          # Maximum size of key_file + NULL
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


# opening file for reading (key)

        li   $v0, 13                    # system call for open file
        la   $a0, key_file_name         # key file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # key[idx] = c_input
        la   $a1, key($t0)              # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, key($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  key($t0)              # key[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
LOAD:
	
	la $s7, key		       	# load key address
	la $s6, input_text      # load input text address
	li $t1, 1 				# pointer of the current xor byte index (key)
	li $t3, 0 				# length of the key
	
	
	jal LENGTH
	la $s7, key		       	# load key address
	
CALL:
	# every loop starts here
	j CHECK

CHECK:
	
	lb $t0, 0($s6)  			# first char of input text
	lb $s0, 0($s7)
	beq $t0, $0, END
	beq $t0, 32, OUTPUT
	beq $t0, 10, OUTPUT
	j XORC

XORC:
	xor $t4, $t0, $s0
	j PRINT

PRINT:
	# if xor'd we use this to output
	li   $v0, 11
	add  $a0, $t4, $0 
	syscall
	j ADDC

OUTPUT:
	# if no xor performed we use this to output
	li $v0, 11
	add $a0, $t0, $0
	syscall 
	j ADDC          #add counter

	
END:
	li $v0, 11
	li $a0, 10

	syscall
	j main_end

# --------------
# End of the xor main block, below is helper functions
#---------------

LENGTH:
	
	lb $s0, 0($s7)           # load key, moves 1 bytes at a time
	
	beq $s0,$0, BACK 		# back to call
	
	addi $t3,$t3,1 			# t3++
	addi $s7,$s7,1   
	j LENGTH

ADDC:
	addi $s6, $s6, 1
	jal KEYCHECK
	addi $s7, $s7, 1
	j CALL

KEYCHECK:
	sub  $t2, $t1, $t3
	bltz $t2, BACK
	sub  $s7, $s7, $t1
	li   $t1, 1
	j CALL

BACK:
	jr $ra


#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
