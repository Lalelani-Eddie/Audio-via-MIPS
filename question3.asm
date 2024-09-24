.data
    filename: .space 256   # Buffer for file name
    output: .space 256     #output file name
    temp: .space 256
    
    #.align2 ---if there is an issue with loading the header again comment this out
    #prompt_filename: .asciiz "Enter a wave file name:\n"
    #prompt_filesize: .asciiz "Enter the file size (in bytes):\n"
    #prompt_introText: .asciiz "Information about the wave file:\n================================\n"
    #output_channels: .asciiz "Number of channels: "
    #output_samplerate: .asciiz "\nSample rate: "
    
    
.text
.globl main
main:
     # Get file name
        li $v0, 8
        la $a0, temp
        li $a1, 256
        syscall

        la $t0, temp
        la $t1, filename
        
        jal format

        li $v0, 8
        la $a0, temp
        li $a1, 256
        syscall

        la $t0, temp
        la $t1, output

        jal format

        li $v0, 5
        syscall
        move $s1, $v0  #storing file size in $s1

        # Open file for reading
        li $v0, 13         # Open file syscall
        la $a0, filename   # Pass file name
        li $a1, 0          # Read-only mode
        li $a2, 0          # No permissions needed
        syscall
        move $s0, $v0      # Store file descriptor in $s0

        move $a0, $s1       
        li $v0, 9           #allocating heap memory
        syscall
        move $s2, $v0       #storing heap in start address in $s2

        move $a0, $s1       
        li $v0, 9           #allocating heap memory
        syscall
        move $s3, $v0       #storing heap output start address in $s3

        # Read file
        li $v0, 14         # Read syscall
        move $a0, $s0      # File descriptor
        move $a1, $s2     # moving file data to heap
        move $a2, $s1         # Read bytes equal to file size
        syscall


        #closing file
        li $v0, 16
        move $a0, $s0
        syscall

        move $t0, $s2
        move $t1, $s3
        li $t2, 44

HeaderData:
        beqz $t2, Next
        lw $t4, 0($t0)
        sw $t4, 0($t1)
        addi $t0, $t0, 4
        addi $t1, $t1, 4
        addi $t2, $t2, -4
        j HeaderData

Next:
    add $t0, $s2, $s1
    addi $t5, $s1, -44

Reversal:
    beqz $t5, Write
    lb $t4, -1($t0)
    lb $t6, -2($t0)

    sb $t6, 0($t1)
    sb $t4, 1($t1)

    addi $t0, $t0, -2
    addi $t1, $t1, 2
    addi $t5, $t5, -2
    j Reversal 

Write:
     #Open file for reading
        li $v0, 13         # Open file syscall
        la $a0, output   # Pass file name
        li $a1, 0x41          # If file does not exist create it
        li $a2, 0x1FF          # Grant all permissions
        syscall
        move $s0, $v0      # Store file descriptor in $s0
    
    #Write to the file
        li $v0, 15
        move $a0, $s0
        move $a1, $s3
        move $a2, $s1
        syscall

        #closing file
        li $v0, 16
        move $a0, $s0
        syscall

        li $v0, 10
        syscall

format:
    lb $t2, 0($t0)
    beq $t2, 10, return
    sb $t2, 0($t1)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j format

return:
    sb $zero, 0($t1)
    j $ra

    
