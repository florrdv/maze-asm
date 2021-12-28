.data
.text
main:
	# Load yellow for the first line
	li $s0, 16776960 	# Load yellow
	
	# Set first line
	jal set_row
	
	# Start counter at 1
	li $s1, 1 		# Count one
	li $s0, 4294901760 	# Load red
	
loop2:
	bgt $s1, 30, exit	# End if we are at line 30, line 31 will be filled later in yellow
	
	move $a0, $s1		# Load line number as argument
	jal set_row		# Set the row
	
	addi $s1, $s1, 1	# Add one to the row count
	j loop2			# Loop again
	
exit:
	li $s0, 16776960	# Load yellow
	li $a0, 31		# Fill last row
	jal set_row		# Fill
	
	li $v0, 10		# Load exit syscall
	syscall			# Exit
	
set_row:
	# Start = $GP + ROW INDEX * (32*4)
	sll $a0, $a0, 7
	add $a0, $gp, $a0

	# Start pointer is stored in $t0
	# Let's initialize a counter
	li $t1, 0
	
	# Start the loop	
loop:
	bgt $t1, 124, continue
	
	# X coordinate in a0
	# Y coordinate in a1
	
	# Let's calculate the desired values
	add $t2, $a0, $t1
	
	# Check if it has to be yellow
	beq $t1, 0, yellow
	beq $t1, 124, yellow
	# Has to be red (default color)
	j red
	
	yellow:
	# Load yellow to t3
	li $t3, 16776960
	# Let's set the value
	sw $t3, ($t2)
	j end
	
	
	red:
	# Let's set the value
	sw $s0, ($t2)
	
	end:
	
	# Increment address by 4 (32bits)
	addi $t1, $t1, 4
	j loop
	
	
continue: 
	jr $ra
