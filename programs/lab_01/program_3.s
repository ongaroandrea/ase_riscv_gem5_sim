# Data section
.section .data
V1:     .byte       2, 6, -3, 11, 9, 18, -13, 16, 5, 0
V2:     .byte       4, 2, -13, 3, 9, 9, 7, 16, 4, 7
V3:     .space      10
PREV:   .byte       -128                   # MaxMIN                         

#Flag 
FLAG1:  .byte       0
FLAG2:  .byte       0
FLAG3:  .byte       0

# Code section
.section .text

.globl _start
_start:
    li x5, 1                                # Set counter 0 - unsigned (or lbu x5, x0)
    li x7, 10                               # Save Lenght value in a register - it cannot be used directy the constant inside the code
    li x3, 0                                # Counter for lenght of vector 3
    li x21, 1                               # Increasing 
    li x22, 1                               # Decreasing
    
    la x26, PREV
    lb x27, 0(x26)                          # Value of lowest possible value
    la x29, V1                              # Base address of V1
    la x30, V2                              # Base address of V2
    la x31, V3                              # Base address of V3

Loop0_a:
    lb x1, 0(x29)                           # Read value from V1 
    la x30, V2                              # Reset address of V2
    li x6, 0                                # Set counter 0 - unsigned used for the second loop

Loop1_a:
    lb x2, 0(x30)                           # Read value from V2
    beq x1, x2, Save                        # Compare two values -> If V1[i] == V2[k]

Loop1_end: 
    addi x6, x6, 1                          # Increase the counter of second loop of one unit
    addi x30, x30, 1                        # Move to the next value to check in vector2
    bne  x6, x7, Loop1_a                    # Check if analyzed all values of the vector         
    bne  x5, x7, IncreaseV1                 # Continue with the next value of the V1 if x5 and x7 is different
    j End                                   # Jump to finish 

Save:
    sb x2, 0(x31)                           # Save value to V3
    addi x3, x3, 1                        # Increase counter of lenght vector 3
    addi x31, x31, 1                        # Move to the next value in the vector 3
    blt x2, x27, F_Flag2                    # If current value is lower than previous set flag2 to 1

Continue:
    bgt x2, x27, F_Flag3                    # If current value is bigger than previous set flag3 to 1
    mv x27, x2                              # Store x2 inside PREV
    j Loop1_end                             # Continue the loop

IncreaseV1:
    addi x29,x29, 1                         # Increase the address of V1
    addi x5, x5, 1                          # Increase the counter for V1
    j Loop0_a

F_Flag2:
    beq x3, x0, Continue                    # Check if vector doesn't contain any value
    beq x21, x0, Continue                    # Skip if increasing already broken
    li x13, 1                               # Load an immediate value
    la x14, FLAG2                           # Load the address of flag2 
    sb x13, 0(x14)                          # Store in FLAG2 the constant 1
    li x22, 0                               # Disable decreasing (x22 = 0)
    j Continue                              # Jump to continue 

F_Flag3:
    beq x3, x0, Continue                    # Check if vector doesn't contain any value
    beq x22, x0, Continue                    # Check if it's still decreasing
    li x13, 1                               # Load an immediate value
    la x14, FLAG3                           # Load the address of flag3 
    sb x13, 0(x14)                          # Store in FLAG3 the constant 1
    li x21, 0                               # Disable increasing (x21 = 0)
    mv x27, x2                              # Store x2 inside PREV
    j IncreaseV1                             # Jump to Loop1_end

End:
    beq x3, x0, checkFlag1                 # Check if length of the vector 3 is equal from 0 -> yes go to Flag1
    j checkLastFlags_2                      # Check  flags

checkFlag1:         
    li x13, 1
    la x14, FLAG1
    sb x13, 0(x14)                          # Store in FLAG1 the constant 0
    j checkLastFlags_2                      # Finish the program

checkLastFlags_2:
    beq x21, x0, Deflag2
checkLastFlags_3:
    beq x22, x0, Deflag3
    j Finish

Deflag2:
    li x13, 0                               # Load an immediate value
    la x14, FLAG2                           # Load the address of flag3 
    sb x13, 0(x14)                          # Reset to 0 Flag2
    j checkLastFlags_3
Deflag3:
    li x13, 0                               # Load an immediate value
    la x14, FLAG3                           # Load the address of flag3 
    sb x13, 0(x14)                          # Reset to 0 Flag1

Finish:
    beq x3, x0, lastCheck1                  # Check again for size 0
    li a7, 93                               # syscall number for exit
    li a0, 0                                # return code (exit 0)
    ecall

lastCheck1:
    li x13, 1
    la x14, FLAG1
    sb x13, 0(x14)                          # Store in FLAG1 the constant 1
    li a7, 93                               # syscall number for exit
    li a0, 0                                # return code (exit 0)
    ecall