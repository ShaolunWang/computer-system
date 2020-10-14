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


#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

# what's the goal: decrypt
# how to decrypt: read it line by line, with a counter counting lines read
# 				  the number of the counter indicates which word to read
# More specifically: double loop + output

call:
	
	 li  $s1, 0          # the line counter
     la  $t1, input_text # input text address in $t1
   	 li  $t2, 10 		 # store \n here
   	 li  $t4, 0          # the space counter
	 add $t4, $t4, $t1   # the input file index 
 	 jal init
 
	 j readline
	 
	 j main_end
init:
		
		# the "init", to initialize
		
		li  $t3, 32 		# store space here

		jr $ra

readline:
		# this part only read one line, stopps at \n (ascii = 10)
		# part 1:
		# the counter = space before the word
		# cond 1 no space
		# cond 2 more spaces
		# 
		# part 2:
		# filter out the line if counter > space count
		# 
		# jump
		#---------------------------------------
		
	#	sw $s7, 4($sp)       # save a copy of our return address
	#	jr $s7               # jump to return address
		
			
	 	lb  $t5, 0($t4)      # load char at index ($t4)
		beqz $t5, main_end
		beq $t5, $t2, jumpcall   # it ends
		j adds
		addi $t4, $t4, 1     # pointer towards the next char

		
        #too big then end
		j call
adds:
		
		bne $t5, $t3, check
		
		# space counter add 1, lame name :)
		addi $t3, $t3, 1   # space counter +1
		j check

check:		
		sub  $t6, $s1, $t5    # check if too big :/
		bgez $t6, output
		li $v0, 11
		li $a0, 10
		syscall 
		j jumpcall

output:
		# once you finish output the word just jr $ra (jumpcall) 
		
		li  $v0, 11
		la, $a0, ($t5)
		beq $a0, 32, jumpcall
		syscall
		addi $t4, $t4, 1
		lb  $t5, 0($t4)      # load char at index ($t4)
		j output		
		
jumpcall:

	li $v0, 11
	li $a0, 10
	syscall
	
	j call

		



#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
