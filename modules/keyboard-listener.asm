.data
	enter: .asciiz "Please enter a character\n"
	newline: .asciiz "\n"
.text

main:
	# Pass
	
loop:
	# Check if input is available
	lw $t0, 4294901760
	beqz $t0, prompt
	
	# Get the most recent character
	la $a0, 4294901764
	
	# Print the char
	li $v0, 4
	syscall
	
	# Print a newline character
	la $a0, newline
	li $v0, 4
	syscall
	
	j cleanup
	
prompt:
	# Ask for user input
	la $a0, enter
	li $v0, 4
	syscall
	
	
cleanup:
	
	# Sleep 2000 ms = 2 seconds
	li $a0, 2000
	li $v0, 32
	syscall
	
	j loop