.data
.text
main:
	# Set red
	li $s0, 4294901760
	
	jal set_row
	
loop2:
	bgt $s1, 32, exit
	
	move $t0, $s1
	jal set_row
	
	addi $s1, $s1, 1
	j loop2
	
exit:
	li $v0, 10
	syscall
	
set_row:
	# Start = $GP + ROW INDEX * (32*4)
	sll $t0, $t0, 7
	add $t0, $gp, $t0

	# Start pointer is stored in $t0
	# Let's initialize a counter
	li $t1, 0
	
	# Start the loop	
loop:
	bgt $t1, 128, continue
	
	# X coordinate in a0
	# Y coordinate in a1
	
	# Let's calculate the desired values
	add $t2, $t0, $t1
	
	# Let's set the value
	sw $s0, ($t2)
	
	addi $t1, $t1, 4
	j loop
	
	
continue: 
	jr $ra
