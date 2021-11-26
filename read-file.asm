	.data
file: .asciiz "example.txt"
buffer: .space 1024

	.text
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
	
# File reading
# Print the string
la $t1, buffer
	
li $v0, 4
move $a0, $t1
syscall
	
	
exit:
	li $v0, 10
	syscall