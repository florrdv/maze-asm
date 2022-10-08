.data
	enter: .asciiz "Please enter a character\n"
	newline: .asciiz "\n"
	upt: .asciiz "up"
	downt: .asciiz "down"
	leftt: .asciiz "left"
	rightt: .asciiz "right"
	
.text

main:
	# Pass
	
loop:
	# Check if input is available
	lw $t0, 4294901760
	beqz $t0, prompt
	
	# Get the most recent character
	lw $t0, 4294901764
	beq $t0, 119, up
	beq $t0, 115, down
	beq $t0, 97, left
	beq $t0, 100, right
	beq $t0, 120, exit
	
	j up
	

up:
	la $a0, upt
	li $v0, 4
	syscall
	
	j next
down:
	la $a0, downt
	li $v0, 4
	syscall
	
	j next
left:
	la $a0, leftt
	li $v0, 4
	syscall
	
	j next
right:
	la $a0, rightt
	li $v0, 4
	syscall
	
	j next
	
prompt:
	# Ask for user input
	la $a0, enter
	li $v0, 4
	syscall

	
next:
	# Print a newline character
	la $a0, newline
	li $v0, 4
	syscall
	
	# Sleep 2000 ms = 2 seconds
	li $a0, 2000
	li $v0, 32
	syscall
	# Sleep 2000 ms = 2 seconds
	j loop
	
exit:
	li $v0, 10
	syscall
