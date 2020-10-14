#=========================================================================
# Word Finder 
#=========================================================================
# Finds words in a given text.
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

input_text_file_name:         .asciiz  "input_words.txt"
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




# You can add your code here!

# What do I know: 		Everything is stored in the input_text
# What do I need to do: process every char and check whether it's a space

LOAD:
	
	la $t3, input_text				 				# get address of the input text
	 					# get char
	j CHECK 						# jump

CHECK:
	blez $s0, main_end
	lb $s0, 0($t3)						#end if no char
	li  $t1, 32 		   			# ascii value for space in $t1
	beq $t1, $s0, MODIFY 			# current char stored in $s1
	j PRINT
	
MODIFY:
	la $s0, 10 
	j PRINT

PRINT:
	li  $v0, 11
	add $a0, $0, $s0
	syscall

	addi $t3, $t3, 1
	
	
	 
	j CHECK

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
