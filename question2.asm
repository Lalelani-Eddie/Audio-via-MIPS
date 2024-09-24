
.data
    prompt_wave: .asciiz "Enter a wave file name:\n"                 # Prompt for the wave file name
    prompt_size: .asciiz "Enter the file size (in bytes):\n"         # Request for file size in bytes
    info_wave: .asciiz "Information about the wave file:\n"          # Message indicating wave file info
    separator: .asciiz "================================"            # Visual separator
    label_max: .asciiz "\nMaximum amplitude: "                       # Label for maximum amplitude
    label_min: .asciiz "\nMinimum amplitude: "                       # Label for minimum amplitude
    err_msg: .asciiz "\nAn error has occurred "                      # Message for error
    .align 1
    buffer_filename: .space 256                                      # Buffer for the file name
    buffer_sample: .space 2                                          # Buffer for a 16-bit sample
    buffer_header: .space 44                                         # Buffer for the 44-byte WAVE header

.text
.globl main

main:
    li $v0, 4                                                       
    la $a0, prompt_wave                                               # Load wave prompt
    syscall                                                           # Execute system call

    li $v0, 8                                                        # Read string system call
    la $a0, buffer_filename                                           # Load buffer to store input
    li $a1, 256                                                      # Set max length to 256
    syscall                                                           # Execute system call
    la $t0, buffer_filename                                           # Load buffer address into $t0

RemoveNewline:
    lb $t1, ($t0)                                                    # Load byte from buffer
    bne $t1, 0x0A, Increment                                          # If it's not newline, go to Increment

    li $t1, 0                                                        # Replace newline with null terminator
    sb $t1, ($t0)                                                    # Store null terminator
    j next_action                                                    # Jump to next part of the program

Increment:
    addi $t0, $t0, 1                                                 # Move to the next byte in buffer
    j RemoveNewline                                                  # Repeat process

next_action:
    li $v0, 4                                                        # Print string system call
    la $a0, prompt_size                                              # Load file size prompt
    syscall                                                           # Execute system call

    li $v0, 5                                                        # Read integer system call
    syscall                                                           # Execute system call
    move $s1, $v0                                                    # Store file size in $s1

    li $v0, 4                                                        # Print string system call
    la $a0, info_wave                                                # Load info message
    syscall                                                           

    li $v0, 4                                                        # Print string system call
    la $a0, separator                                                # Load separator string
    syscall                                                           # Execute system call

    li $v0, 13                                                       # Open file system call
    la $a0, buffer_filename                                          # Load buffer with file name
    li $a1, 0                                                        # Open in read-only mode
    syscall                                                         
    bltz $v0, HandleError                                             # Jump to error handling if error
    move $s0, $v0                                                    # Store file descriptor in $s0

    li $v0, 14                                                       # Read file system call
    move $a0, $s0                                                    # Pass file descriptor
    la $a1, buffer_header                                            # Load header buffer
    li $a2, 44                                                       # Read 44 bytes (WAVE header size)
    syscall                                                           # Execute system call
    bltz $v0, HandleError                                             # Jump to error handling if error

    li $v0, 14                                                       # Read file system call
    move $a0, $s0                                                    # Pass file descriptor
    la $a1, buffer_sample                                            # Load sample buffer
    li $a2, 2                                                        # Read 2 bytes (16-bit sample)
    syscall                                                           # Execute system call
    bltz $v0, HandleError                                             # Jump to error handling if error

    li $t0, -32768                                                   # Max amplitude initialized
    li $t1, 32767                                                    # Min amplitude initialized
    la $t2, buffer_header + 44                                       # Track file position after header
    li $t3, 2                                                        # Sample size in bytes
    la $s2, buffer_header                                            # Calculate end of file
    add $s2, $s2, $s1                                                # End of file = header + file size

FindExtremes:
    lh $t4, buffer_sample                                            # Load 16-bit sample
    bgt $t4, $t0, UpdateMax                                           # If sample > max, update max
    blt $t4, $t1, UpdateMin                                           # If sample < min, update min
    j ReadNext                                                       # Continue to next sample

UpdateMax:
    move $t0, $t4                                                    # Update max with current sample
    j ReadNext                                                       # Jump to read next

UpdateMin:
    move $t1, $t4                                                    # Update min with current sample
    j ReadNext                                                       # Jump to read next

ReadNext:
    li $v0, 14                                                       # Read file system call
    move $a0, $s0                                                    # Pass file descriptor
    la $a1, buffer_sample                                            # Load sample buffer
    li $a2, 2                                                        # Read 2 bytes (16-bit sample)
    syscall                                                           # Execute system call
    bltz $v0, HandleError                                             # Jump to error handling if error

    add $t2, $t2, $t3                                                # Move to the next sample position
    bne $t2, $s2, FindExtremes                                        # Repeat if not at the end of the file

PrintResults:
    li $v0, 4                                                        # Print string system call
    la $a0, label_max                                                # Load label for max
    syscall                                                           # Execute system call

    li $v0, 1                                                        # Print integer system call
    move $a0, $t0                                                    # Pass max value for printing
    syscall                                                           # Execute system call

    li $v0, 4                                                        # Print string system call
    la $a0, label_min                                                # Load label for min
    syscall                                                           # Execute system call

    li $v0, 1                                                        # Print integer system call
    move $a0, $t1                                                    # Pass min value for printing
    syscall                                                           # Execute system call

    li $v0, 16                                                       # Close file system call
    move $a0, $s0                                                    # Pass file descriptor
    syscall                                                           # Execute system call

    j ExitProgram                                                    # Exit the program

HandleError:
    li $v0, 4                                                        # Print string system call
    la $a0, err_msg                                                  # Load error message
    syscall                                                           # Execute system call

ExitProgram:
    li $v0, 10                                                       # Exit system call
    syscall                                                          
