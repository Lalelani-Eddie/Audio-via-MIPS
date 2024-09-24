
.data
    prompt_wave: .asciiz "Enter a wave file name:\n"                  # Prompt for the wave file name
    prompt_size: .asciiz "Enter the file size (in bytes):\n"          # Request for file size in bytes
    info_wave: .asciiz "Information about the wave file:\n"           # Message indicating wave file info
    separator: .asciiz "================================"             # Visual separator
    label_channels: .asciiz "\nNumber of channels: "                  # Label for number of channels
    label_sample_rate: .asciiz "\nSample rate: "                      # Label for the sample rate
    label_byte_rate: .asciiz "\nByte rate: "                          # Label for the byte rate
    label_bits_per_sample: .asciiz "\nBits per sample: "              # Label for bits per sample
    err_msg: .asciiz "An error has occurred\n"                        # Error message if something goes wrong
    .align 2
    buffer_filename: .space 256                                       # Buffer for the input file name
    buffer_header: .space 44                                          # Buffer for the 44-byte WAVE header

.text
.globl main

main:
    li $v0, 4                                                         # System call for printing a string
    la $a0, prompt_wave                                                # Load prompt for wave file name
    syscall                                                            # Execute system call

    li $v0, 8                                                         # System call for reading a string
    la $a0, buffer_filename                                            # Load buffer for file name
    li $a1, 256                                                       # Set max length to 256
    syscall                                                            
    la $t0, buffer_filename                                            # Load file name into temporary register

RemoveNewline:
    lb $t1, ($t0)                                                     # Load byte from current position in buffer
    bne $t1, 0x0A, Increment                                          # If byte is not newline, go to increment

    li $t1, 0                                                         # Replace newline with null terminator
    sb $t1, ($t0)                                                     # Store null terminator
    j NextStep                                                        # Jump to next part of the program

Increment:
    addi $t0, $t0, 1                                                  # Move to next byte in buffer
    j RemoveNewline                                                    # Repeat process

NextStep:
    li $v0, 4                                                         # System call for printing a string
    la $a0, prompt_size                                                # Load prompt for file size
    syscall                                                            # Execute system call

    li $v0, 5                                                         # System call for reading an integer
    syscall                                                            # Execute system call
    move $s2, $v0                                                     # Store file size in $s2

    li $v0, 4                                                         # Print string system call
    la $a0, info_wave                                                  # Load info message
    syscall                                                           

    li $v0, 4                                                         # Print string system call
    la $a0, separator                                                  # Load separator
    syscall                                                            

    li $v0, 13                                                        # Open file system call
    la $a0, buffer_filename                                            # Load buffer with file name
    li $a1, 0                                                         # Open file in read-only mode
    syscall                                                            
    bltz $v0, HandleError                                              # If error occurs, jump to error handling
    move $s0, $v0                                                     # Store file descriptor

    li $v0, 14                                                        # Read file system call
    move $a0, $s0                                                     # Pass file descriptor
    la $a1, buffer_header                                              # Load buffer to store header data
    li $a2, 44                                                        # Read 44 bytes (WAVE header)
    syscall                                                            # Execute system call
    bltz $v0, HandleError                                              # If error occurs, jump to error handling

    li $v0, 4                                                         # Print string system call
    la $a0, label_channels                                              # Load label for number of channels
    syscall                                                            # Execute system call

    li $v0, 1                                                         # Print integer system call
    lh $a0, buffer_header + 22                                         # Load 2-byte value from buffer (channels)
    syscall                                                            # Execute system call

    li $v0, 4                                                         # Print string system call
    la $a0, label_sample_rate                                           # Load label for sample rate
    syscall                                                            

    li $v0, 1                                                         # Print integer system call
    lw $a0, buffer_header + 24                                         # Load 4-byte value from buffer (sample rate)
    syscall                                                           

    li $v0, 4                                                         # Print string system call
    la $a0, label_byte_rate                                             # Load label for byte rate
    syscall                                                            

    li $v0, 1                                                         # Print integer system call
    lw $a0, buffer_header + 28                                         # Load 4-byte value from buffer (byte rate)
    syscall                                                            # Execute system call

    li $v0, 4                                                         # Print string system call
    la $a0, label_bits_per_sample                                       # Load label for bits per sample
    syscall                                                            

    li $v0, 1                                                         # Print integer system call
    lh $a0, buffer_header + 34                                         # Load 2-byte value from buffer (bits per sample)
    syscall                                                            # Execute system call

    li $v0, 16                                                        # Close file system call
    move $a0, $s0                                                     # Pass file descriptor
    syscall                                                         

    j ExitProgram                                                     

HandleError:
    li $v0, 4                                                         # Print string system call
    la $a0, err_msg                                                    # Load error message
    syscall                                                            # Execute system call

ExitProgram:
    li $v0, 10                                                        # Exit system call
    syscall                                                           
