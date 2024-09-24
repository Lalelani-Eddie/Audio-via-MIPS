.data
    output: .space 256     #output file name
    temp: .space 256
    zeros: .word 0x00000000
    lowtone: .half 0x8000
    hightone: .half 0x7fff
.text
.globl main
main:
        li $v0, 8
        la $a0, temp
        li $a1, 256
        syscall

        la $t0, temp
        la $t1, output

        jal format

        li $v0, 5
        syscall
        move $s3, $v0  #storing tone freq in s3

        li $v0, 5
        syscall
        move $s4, $v0  #storing sample freq in s4

        li $v0, 5
        syscall
        move $s5, $v0  #storing tone length in s5

        #calculating length of high and low tones
        mul $t0, $s3, 2
        div $s4, $t0
        mflo $s0


        #calculating size
        mul $t0, $s5, 2
        mul $s1, $t0, $s4
        addi $s1, $s1, 44  #accounting for header bytes

        #calculating wave length
        div $s4, $s3
        mflo $s8

        #creating heap
        move $a0, $s1       
        li $v0, 9           #allocating heap memory
        syscall
        move $s2, $v0       #storing heap in start address in $s2

        move $t0, $s2
        li $t1, 0
    
    Header:
        beq $t1, 11, Next
        lw $t2, zeros
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        j Header

    Next: 
        li $t1, 0

    SecondsLoop:
        beq $t1, $s5, writeOutput
        li $t4, 0
        j WaveLoop

    WaveLoop:
        beq $t4, $s4, returnToSecondsLoop
        li $t2, 0
        jal Hightone
        add $t4, $t4, $s0
        li $t2, 0
        jal Lowtone
        add $t4, $t4, $s0
        j WaveLoop
    
    Hightone:
        beq $t2, $s0, Back
        lh $t5, hightone
        sh $t5, 0($t0)
        add $t0, $t0, 2
        add $t2, $t2, 1
        j Hightone

    Lowtone:
        beq $t2, $s0, Back
        lh $t5, lowtone
        sh $t5, 0($t0)
        add $t0, $t0, 2
        add $t2, $t2, 1
        j Lowtone
    
    Back:
        j $ra

    returnToSecondsLoop:    
        addi $t1, $t1, 1
        j SecondsLoop
    
    
    writeOutput:
        #Open file for writting
        li $v0, 13         # Open file syscall
        la $a0, output   # Pass file name
        li $a1, 0x41          # If file does not exist create it
        li $a2, 0x1FF          # Grant all permissions
        syscall
        move $s0, $v0      # Store file descriptor in $s0
    
    #Write to the file
        li $v0, 15
        move $a0, $s0
        move $a1, $s2
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
