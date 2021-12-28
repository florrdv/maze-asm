.data
.text
main:
	# This program assumes that the row width is 512
	li $a0, 1
	li $a1, 1
	
	jal convert
	
	move $s0, $v0
	
	li $v0, 10
	syscall
	
convert:
	# X coordinate in a0
	# Y coordinate in a1
	
	# Let's calculate the desired values
	# Base + x
	add $t0, $gp, $a0
	
	# Multiply by 512 * 4
	# Row width * y
	sll $t1, $a1, 11
	
	# Add together
	add $v0, $t0, $t1
		
	# Jump back to where the function was called
	jr $ra
	
