########################################
# Maze game by Flor Ronsmans De Vry    #
########################################
# ! THIS PROJECT USES WASD CONTROLS    #
########################################

.data
# General
file: .asciiz "maze.txt"
buffer: .space 4096
victory_message: .asciiz "Congratulations, you won!"

# Maze info
width: .word 0

.align 2
visited: .space 4096

# Colors
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
	# Well store the player coordinates in s0 and s1
	jal load_file			# Load the file
	jal parse_file 			# Parse the file
	
	# Update the player coordinates
	move $s0, $v0 			# Store player_x
	move $s1, $v1 			# Store player_y
	
	# Start DFS
	move $a0, $s0 			# Pass player_x 
	move $a1, $s1 			# Pass player_y
	jal dfs       			# Start procedure
	
	# Exit
	li $v0, 10 			# Load 10 which refers to clean exit
	syscall 			# Execute syscall
	
###################
# MAP LOADING
##################
########################################################################
#PROCEDURE load the file data
load_file:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 12	# allocate 12 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers

	# Open file
	li $v0, 13 		# Syscall to read file
	la $a0, file 		# File name
	la $a1, 0 		# Read mode
	li $a2, 0 		# Mode is ignored
	syscall
	
	# Save file descriptor
	move $s0, $v0

	# Read file data
	li $v0, 14 		# system call for read from file
	move $a0, $s0 		# file descriptor
	la $a1, buffer 		# address of buffer to which to load the contents
	li $a2, 4096 		# hardcoded max number of characters (equal to size of buffer)
	syscall

	li $v0, 16 		# system call for close file
	move $a0, $s6 		# file descriptor to close
	syscall 		# close file

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
	subu	$sp, $sp, 28	# allocate 20 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers
	sw	$s1, -12($fp)	# save locally used registers	
	sw	$s2, -16($fp)	# save locally used registers	
	sw	$s3, -20($fp)	# save locally used registers
	sw	$s4, -24($fp)	# save locally used registers	
	
	move $s0, $zero 	# Load zero into both registers, x
	move $s1, $zero 	# Load zero into both registers, y
	move $s2, $zero 	# Width
	move $s3, $zero 	# Player x
	move $s4, $zero 	# Player y
	
	# Determine the width
	width_loop:
	# Load the current character from the buffer
	la $t0, buffer 
	# Add the offset to the buffer address
	add $t0, $t0, $s0
	# Load the byte
	lb $t2, ($t0)
	
	# Branch if weve reached the end of a line
	beq $t2, 10, after_width
	
	# Increment the count
	addi $s0, $s0, 1
	
	# Continue the loop
	j width_loop
	
	after_width:
	# Save the row width
	move $s2, $s0
	sw $s2, width
	
	# Reset the registers
	move $s0, $zero
	move $s1, $zero
	
	loop:
	# Load the current character from the buffer
	la $t0, buffer
	# Calculate the offset
	mul $t1, $s2, $s1 	# Mutiply our row width by the row we're on 
	add $t1, $t1, $s0 	# Add the column index
	add $t1, $t1, $s1 	# Add the row index (newlines)
	# Add the offset to the buffer address
	add $t0, $t0, $t1
	# Load the byte
	lb $t2, ($t0)
	
	# Stop when we reach a zero byte
	beq $t2, 0, continue
	# Go to the next line when we reach a newline character
	beq $t2, 10, next_line
	
	# Convert the coordinate to a memory address
	# using the convert function we defined earlier
	move $a0, $s0
	move $a1, $s1
	jal convert
	
	# Save the memory address while we determine the color
	move $t3, $v0

	# Select a color
	beq $t2, 119, set_blue 	# w - wall
	beq $t2, 112, set_black # p - passage
	beq $t2, 115, set_yellow# s - player position
	beq $t2, 117, set_green # u - exit
	beq $t2, 101, set_red 	# e - enemy
	beq $t2, 99, set_white 	# c - candy
	
	# Set the desired color
	set_blue:
	lw $t4, blue
	j continue_after_color
	set_black:
	lw $t4, black
	j continue_after_color
	set_yellow:
	lw $t4, yellow
	# Save the players location to the appropriate registers
	move $s3,  $s0
	move $s4,  $s1
	# Continue
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
	
	addi $s0, $s0, 1 	# Increment the x value by one
	j loop
	
	# Helpers for loop
	next_line:
	addi $s1, $s1, 1
	move $s0, $zero
	
	j loop
		
	# Loop end	
	continue:
	# Return player coordinates
	move $v0, $s3
	move $v1, $s4
	
	lw	$s4, -24($fp)	# reset saved register $s4
	lw	$s3, -20($fp)	# reset saved register $s3
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
	
	# Load width
	lw $t0, width
	
	# Multiply by row width * row
	mul $t0, $a1, $t0
	
	add $t0, $t0, $a0
	sll $t0, $t0, 2
	
	add $v0, $t0, $gp
		
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra
	
###################
# Player movement
##################
########################################################################
# PROCEDURE load the file data
# Write a function (with stackframe!) that has four arguments (current player row,
# current player column, new player row, new player column) that updates the position
# of the player in the displayed maze and returns its (possibly new) current position
# using registers $v0 and $v1. Make sure the update is only executed when the given
# move is a valid move within the maze. In order to calculate the memory address for a
# particular location use the function (with stackframe!) from the previous assignment
# to convert logical coordinates to memory addresses.
update_position:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 32	# allocate 20 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers
	sw	$s1, -12($fp)	# save locally used registers	
	sw	$s2, -16($fp)	# save locally used registers
	sw	$s3, -20($fp)	# save locally used registers
	sw	$s4, -24($fp)	# save locally used registers
	sw	$s5, -28($fp)	# save locally used registers
	
	# a0 contains the current player row
	# a1 contains the current player column
	# a2 contains the new player row
	# a3 contains the new player column
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# Lets store the current player position memory address in $s4
	move $a0, $s0
	move $a1, $s1
	jal convert
	
	move $s4, $v0
	
	# Lets store the new player position memory address in $s5
	move $a0, $s2
	move $a1, $s3
	jal convert
	
	move $s5, $v0
	
	# s4 now contains our previous player position and s5 has our new position
	# Lets check if the player has won
	lw $t0, green
	lw $t1, ($s5)
	beq $t1, $t0, victory
	
	
	# Lets make sure the position in s5 is valid to move to
	lw $t0, black
	
	bne $t1, $t0, invalid_position
	
	# Valid position
	valid_position:
	lw $t2, yellow # Load yellow
	sw $t2, ($s5) # Set to yellow
	sw $t0, ($s4) # Set to black
	
	# Place new coordinates in return registers
	move $v0, $s2
	move $v1, $s3	
	
	j end_position_update
	# Invalid position detected
	invalid_position:
	# Place the initial coordinates in the return registers
	move $v0, $s0
	move $v1, $s1
	j end_position_update
	
	# Cleanup
	end_position_update:
	lw	$s5, -28($fp)	# reset saved register $s5
	lw	$s4, -24($fp)	# reset saved register $s4
	lw	$s3, -20($fp)	# reset saved register $s3
	lw	$s2, -16($fp)	# reset saved register $s2	
	lw	$s1, -12($fp)	# reset saved register $s1	
	lw	$s0, -8($fp)	# reset saved register $s0
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra
########################################################################
# PROCEDURE dfs
dfs:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 32	# allocate 8 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers
	sw	$s1, -12($fp)	# save locally used registers
	sw	$s2, -16($fp)	# save locally used registers
	sw	$s3, -20($fp)	# save locally used registers
	sw	$s4, -24($fp)	# save locally used registers
	sw	$s5, -28($fp)	# save locally used registers
			
	move $s0, $a0 		# Player x
	move $s1, $a1 		# Player y
	
	move $s2, $s0 		# New player x
	move $s3, $s1 		# New player y
	
	addi $s2, $s2, -1 	# Set offset
	
	move $s4, $zero
	move $s5, $zero		# New address
	
	# START LOOP
	dfs_loop:
	bge $s4, 4, dfs_end
	
	# Check if the location has been visited yet
	move $a0, $s2 		# Move new location x
	move $a1, $s3 		# Move new location y
	jal convert 		# Convert
	
	move $s5, $v0
	
	move $a0, $s5 		# Load memory address
	jal is_visited 		# Check if visited
	
	bnez $v0, dfs_loop_end 	# Continue if already visited
	
	# Update position
	move $a0, $s0 # Load old_x
	move $a1, $s1 # Load old_y
	
	move $a2, $s2 # Load new_x
	move $a3, $s3 # Load new_y
	jal update_position # Attempt to opdate the users position
	
	bne $v0, $s2, dfs_location_update # Check if x matches
	bne $v1, $s3, dfs_location_update # Check if y matches
	
	# Player moved, prepare to call dfs recursively
	move $a0, $s5
	jal push_visited
	
	# Call dfs recursively
	move $a0, $s2
	move $a1, $s3
	jal dfs
	
	dfs_location_update:
	move $a0, $s0 # Load old_x
	move $a1, $s1 # Load old_y
	
	move $a2, $s2 # Load new_x
	move $a3, $s3 # Load new_y
	jal update_position # Attempt to opdate the users position
	
	dfs_loop_end:
	addi $s4, $s4, 1
	# (-1, 0), (1, 0), (0, -1), (0, 1)
	
	beq $s4, 1, dfs_one
	beq $s4, 2, dfs_two
	beq $s4, 3, dfs_three
	
	dfs_one:
	move $s2, $s0 # Reset player x
	move $s3, $s1 # Reset player y
	
	addi $s2, $s2, 1
	j dfs_loop
	dfs_two:
	move $s2, $s0 # Reset player x
	move $s3, $s1 # Reset player y
	
	addi $s3, $s3, -1
	j dfs_loop
	dfs_three:
	move $s2, $s0 # Reset player x
	move $s3, $s1 # Reset player y
	
	addi $s3, $s3, 1
	j dfs_loop
	
	dfs_end:
	lw	$s5, -32($fp)	# reset saved register $s1
	lw	$s4, -28($fp)	# reset saved register $s1
	lw	$s4, -24($fp)	# reset saved register $s1
	lw	$s3, -20($fp)	# reset saved register $s1
	lw	$s2, -16($fp)	# reset saved register $s1
	lw	$s1, -12($fp)	# reset saved register $s1	
	lw	$s0, -8($fp)	# reset saved register $s0
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra

push_visited:
	sw	$fp, 0($sp)		# push old frame pointer (dynamic link)
	move	$fp, $sp		# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 12		# allocate 8 bytes on the stack
	sw	$ra, -4($fp)		# store the value of the return address
	sw	$s0, -8($fp)		# save locally used registers
	
	la $s0, visited 			# Initialize the array pointer
	
	push_visited_loop:
	lw $t0, ($s0) 			# Load the value 
	beqz $t0, push_visited_set 	# Stop if its zero
	
	addi $s0, $s0, 4 		# Increment the address
	j push_visited_loop 		# Loop again
	
	push_visited_set:
	sw $a0, ($s0)       		# Store the item
	
	lw	$s0, -8($fp)		# reset saved register $s0
	lw	$ra, -4($fp)    	# get return address from frame
	move	$sp, $fp        	# get old frame pointer from current fra
	lw	$fp, ($sp)		# restore old frame pointer
	jr	$ra

is_visited:
	sw	$fp, 0($sp)		# push old frame pointer (dynamic link)
	move	$fp, $sp		# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 12		# allocate 8 bytes on the stack
	sw	$ra, -4($fp)		# store the value of the return address
	sw	$s0, -8($fp)		# save locally used registers
	
	la $s0, visited 		# Initialize the array pointer
	li $v0, 0 			# Initialize return value
	
	is_visited_loop:
	lw $t0, ($s0) 			# Load the value 
	beqz $t0, is_visited_end 	# Stop if its zero
	
	bne $t0, $a0, is_visited_not_equal
	li $v0, 1
	j is_visited_end
	
	is_visited_not_equal:
	
	addi $s0, $s0, 4 		# Increment the address
	j is_visited_loop 		# Loop again
	
	is_visited_end:
	
	lw	$s0, -8($fp)		# reset saved register $s0
	lw	$ra, -4($fp)    	# get return address from frame
	move	$sp, $fp        	# get old frame pointer from current fra
	lw	$fp, ($sp)		# restore old frame pointer
	jr	$ra

########################################################################
# PROCEDURE victory notification
victory:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 8	# allocate 8 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	
	# Print a message
	li $v0, 4
	la $a0, victory_message
	syscall
	
	# Exit
	li $v0, 10 		# system call for exit
	syscall      		# exit (back to operating system)
	
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra
	
########################################################################
# PROCEDURE victory notification
is_victory:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 8	# allocate 8 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	
	# a0 and a1 are already set accordingly
	jal convert 		# Convert to address
	lw $t0, ($v0) 		# Load the color at coord address
	
	lw $t1, green 		# Load the finish color
	
	li $v0, 0 		# Return false by default
	
	bne $t0, $t1, end_is_victory
	li $v0, 1 		# Set to true as they are equal
	
	end_is_victory:
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
