#=========================================================================
# XOR Cipher Cracking
#=========================================================================
# Finds the secret key for a given encrypted text with a given hint.
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

input_text_file_name:         .asciiz  "input_xor_crack.txt"
hint_file_name:                .asciiz  "hint.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
hint:                         .space 101         # Maximum size of key_file + NULL
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


# opening file for reading (hint)

        li   $v0, 13                    # system call for open file
        la   $a0, hint_file_name        # hint file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # hint[idx] = c_input
        la   $a1, hint($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, hint($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  hint($t0)             # hint[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)



#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
li $s0, 0 								
li $t7, 0
li $t0, 0 								# key
li $s3, 0 								# number of tries


init:
	li $s5, 0                           # start of the file
	la $s1, hint
	la $s2, input_text
	jal xorinit
	j call
	
xorinit:
	add $t0, $t0, $t6
	li $t6, 1
	jr $ra
call:
	j xorcrack
	
	# to check if they matches, we iterate through the input string(xored)
	# so double loop should be implemented 
	
xorcrack:
	lb $t1, 0($s1) 						# hint char
	lb $t2, 0($s2)   					# input char
	beq $t1, $0, endloop
	beq $t2, $0, endloop
	xor $t4, $t2, $t0					# xor 
	
	beq $s5, 0,  checkmatch
	beq $t1, 32, skip
	beq $t2, 32, checkInit
	beq $t2, 10, checkInit
	
	addi $s2, $s2, 1
	j xorcrack
checkInit:
	addi $s2, $s2, 1
	li $s5, 0
	
	j xorcrack
checkmatch:
	li $s5, 1
	beq $t1, 32, skip
	beq $t4, $t1,nextloop
	li  $t7, 0	
	addi $s2, $s2, 1
	la $s1, hint

	j xorcrack				# loop if matches 
	
nextloop:
	# counters ++ and we go to the next loop
	addi $s2, $s2, 1
	addi $s1, $s1, 1
	li $t7, 1	
	li $s5, 0
	j xorcrack
	
skip:
    beq $t2, 32, nextloop
    beq $t2, 10, nextloop
    li $s5, 0
    li $t7, 0
	addi $s2,$s2, 1
    la $s1, hint
	j xorcrack

endloop:
	# check if it's 1111 1111
	beq $t7, 1, printXor
	bne $t0, 255, init 
	li $v0, 11
	li $a0, 45
	syscall 
	li $a0, 49
	syscall
	j end


printXor:

	and $s0, $t0, 128
	srl $s0, $s0, 7
	jal print


	and $s0, $t0, 64
	srl $s0, $s0, 6
	jal print

	and $s0, $t0, 32
	srl $s0, $s0, 5
	jal print



	and $s0, $t0, 16
	srl $s0, $s0, 4
	jal print


	and $s0, $t0, 8
	srl $s0, $s0, 3
	jal print

	and $s0, $t0, 4
	srl $s0, $s0, 2
	jal print

	and $s0, $t0, 2
	srl $s0, $s0, 1
	jal print

	and $s0, $t0, 1
	jal print

	j end	

print:
	li $v0, 11
	
	addi $a0, $s0, 48
	syscall
	jr $ra

end:

	beq $a0, 10, main_end
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

