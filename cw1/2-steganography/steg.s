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


li  $s1, 0          # the line counter
la  $t1, input_text # input text address in $t1
add $t4, $0, $t1    # the input file index 

call:
      jal init
     j readline
     
init:
        li  $s0, 0                # 0 = not printed, 1 = printed
        
        #init on every realine loop
        li  $t7, 0                # the space counter
        jr $ra
        
readline:

        lb   $t5, 0($t4)          # load char at index ($t4)
        j check
        
check:
<<<<<<< HEAD
		beq  $t5, $0, checkend    # if null finish reading the file
		beq  $t5, 10, pAddj  # if \n, line counter +1, index pointer +1, and we read the next line 
		beq  $t5, 32, space  # if space, check if line count == space count
		beq  $s1, $0 , output # print the first word in the first line
		
		addi $t4, $t4, 1
		j readline
=======
        beq  $t5, $0, main_end    # if null finish reading the file
        beq  $t5, 10, pAddj       # if \n, line counter +1, index pointer +1, and we read the next line 
        beq  $t5, 32, space       # if space, check if line count == space count
        beq  $s1, $0 , output     # print the first word in the first line
        
        addi $t4, $t4, 1
        j readline
>>>>>>> b85d6025c403f277cc62c07fe0443c24da4cc066


        
space:
    
    addi $t7, $t7, 1             # space counter +1
    addi $t4, $t4, 1
    
    j output
        
output:
    lb   $t5, 0($t4)             #load char at index ($t4)
    beq $s0, 1, pword

    bne $s1, $t7, readline       # if space != line count then keep reading    
    beq $t5, 10, cword           # handle exception
    beq $t5, 32, pword           # handle exception
    
    li  $v0, 11
    add $a0, $0, $t5
    syscall
    addi $t4, $t4, 1
    j output

pword:
    li $s0, 1
    addi $t4, $t4, 1
    j check
cword:
    li $v0, 11
    li $a0, 10
    syscall
    
    j call

pAddj:
        
        # I didn't call output here
        addi $t4, $t4, 1
        addi $s1, $s1, 1
        beq  $a0, 32, call
        beq  $a0, 10, call  
        
        lb $s3, 1($t4)
        beq $s3, $0, checkend
        
        sub $t6, $t7, $s1
        blt $t6, $0, changeline
        
        li   $v0, 11
        addi $a0, $0, 32
        syscall
        
        j call
        
changeline:
    li   $v0, 11
    addi $a0, $0, 32
    syscall
    j call
    
checkend:
<<<<<<< HEAD
	li $v0, 11
	li $a0, 10
	syscall
	j main_end
=======
    j main_end
>>>>>>> b85d6025c403f277cc62c07fe0443c24da4cc066

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#-----------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
