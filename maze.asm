	.data
file: .asciiz "maze.txt"
buffer: .space 1024 

blue: .word 0xff4083f0
black: .word 0xff000000
yellow: .word 0xfffbff00
green: .word 0xff0afe01
red: .word 0xffff0000
white: .word 0xffffffff


.globl main
.text
# Starting Point
main:
	jal load_file	# Load the file
	jal parse_file # Parse the file
exit:
	li   $v0, 10 		# system call for exit
	syscall      		# exit (back to operating system)
	
########################################################################
#PROCEDURE load the file data
load_file:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 12	# allocate 12 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers

	# Open file
	li $v0, 13 # Syscall to read file
	la $a0, file # File name
	la $a1, 0 # Read mode
	li $a2, 0 # Mode is ignored
	syscall
	
	# Save file descriptor
	move $s0, $v0

	# Read file data
	li $v0, 14 # system call for read from file
	move $a0, $s0 # file descriptor
	la $a1, buffer # address of buffer to which to load the contents
	li $a2, 1024 # hardcoded max number of characters (equal to size of buffer)
	syscall

	li $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall # close file

	lw	$s0, -8($fp)	# reset saved register $s0
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra

########################################################################
#PROCEDURE parse and store file data
parse_file:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 20	# allocate 12 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers
	sw	$s1, -12($fp)	# save locally used registers	
	sw	$s2, -16($fp)	# save locally used registers		
	
	move $s0, $zero # Load zero into both registers, x
	move $s1, $zero # Load zero into both registers, y
	move $s2, $zero # Width
	
	# Determine the width
	width_loop:
	# Load the current character from the buffer
	la $t0, buffer
	# Add the offset to the buffer address
	add $t0, $t0, $s0
	lb $t2, ($t0)
	
	# We're done here
	beq $t2, 10, after_width
	
	# Increment the count
	addi $s0, $s0, 1
	
	# Continue the loop
	j width_loop
	
	after_width:
	move $s2, $s0
	move $s0, $zero
	move $s1, $zero
	
	loop:
	# Load the current character from the buffer
	la $t0, buffer
	# Calculate the offset
	mul $t1, $s2, $s1 # Mutiply our row width by the row we're on 
	add $t1, $t1, $s0 # Add the column index
	add $t1, $t1, $s1 # Add the row index (newlines)
	# Add the offset to the buffer address
	add $t0, $t0, $t1
	lb $t2, ($t0)
	
	beq $t2, 0, continue
	beq $t2, 10, next_line
	
	# Convert the coordinate to a memory address
	# using the convert function we defined earlier
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal convert
	
	# Save the memory address while we determine the color
	move $t3, $v0

	# Select a color
	beq $t2, 119, set_blue # w - wall
	beq $t2, 112, set_black # p - passage
	beq $t2, 115, set_yellow # s - player position
	beq $t2, 117, set_green # u - exit
	beq $t2, 101, set_red # e - enemy
	beq $t2, 99, set_white # c - candy
	
	# Set the desired color
	set_blue:
	lw $t4, blue
	j continue_after_color
	set_black:
	lw $t4, black
	j continue_after_color
	set_yellow:
	lw $t4, yellow
	j continue_after_color
	set_green:
	lw $t4, green
	j continue_after_color
	set_red:
	lw $t4, red
	j continue_after_color
	set_white:
	lw $t4, white
	j continue_after_color
	
	continue_after_color:
	# Save the color
	sw $t4, ($t3)
	
	addi $s0, $s0, 1 # Increment the x value by one
	j loop
	
	# Helpers for loop
	next_line:
	addi $s1, $s1, 1
	move $s0, $zero
	
	j loop
		
	# Loop end	
	continue:
	
	lw	$s2, -16($fp)	# reset saved register $s2	
	lw	$s1, -12($fp)	# reset saved register $s1	
	lw	$s0, -8($fp)	# reset saved register $s0
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra

########################################################################
#PROCEDURE convert coordinates to memory location
convert:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 8	# allocate 12 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	# X coordinate in a0
	# Y coordinate in a1
	# Width in a2
	
	# Multiply by row width * 4
	mul $t0, $a1, $a2
	
	add $t0, $t0, $a0
	sll $t0, $t0, 2
	
	add $v0, $t0, $gp
		
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra
	
