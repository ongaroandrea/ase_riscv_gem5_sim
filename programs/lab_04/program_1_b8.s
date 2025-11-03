/*
INTEGER_ALU_LATENCY = 1 
INTEGER_MUL_LATENCY = 1 
INTEGER_DIV_LATENCY = 1 
FLOAT_ALU_LATENCY = 4 
FLOAT_MUL_LATENCY = 8 
FLOAT_DIV_LATENCY = 20

Compute the output (y) of a neural computation
Given:
    N: size of input and weight vectors
    input vector i of size N
    weight vector w of size N

    x = sum(i[j] * w[j]) + b for j in 0 to N-1
    b = 0xab
    y = f(x) where f is the activation function

Activation function f(x):
    if the exponent part of x is equal to 0x7FF
        y = 0.0
    else 
        y = x
*/

#Data section
.section .data

#N:      .byte       16
I:      .float      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
W:      .float      1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0  
RESULT: .float      0.0

#Code section
.section .text
.globl _start

_start:

    # Load N
    li x1, 16                           # Size of the vectors
    li x2, 0                            # Counter for the loop
    la x21, RESULT                      # f0 = 0.0 (accumulator for sum)
    flw f0, 0(x21)                      # Initialize f0 to 0.0

    # Load addresses 
    la x10, I                           # Load base address of input vector I
    la x11, W                           # Load base address of weight vector W
    li x12, 0xAB                        # Load bias B
    li x13, 0xFF                        # Load exponent part for float infinity
    fcvt.s.w f1, x12                    # Convert bias B to float in f1

#Starting the loop
loop:

    # FIRST ITERATION LOAD AND MULTIPLY
    flw f2, 0(x10)                      # Load in memory input vector I[i]
    flw f3, 0(x11)                      # Load in memory weight vector W[I]
    fmul.s f4, f2, f3                   # Multiply I[i] and W[i]
    
    # SECOND ITERATION LOAD AND MULTIPLY
    flw f5, 4(x10)                      # Load in memory input vector I[i + 1]
    flw f6, 4(x11)                      # Load in memory weight vector W[I + 1]
    fmul.s f7, f5, f6                   # Multiply I[i + 1] and W[i + 1]
    fadd.s f0, f0, f4                   # Add FIRST multiplication in result

    # THIRD ITERATION LOAD AND MULTIPLY
    flw f8, 8(x10)                      # Load in memory input vector I[i]
    flw f9, 8(x11)                      # Load in memory weight vector W[I]
    fmul.s f10, f8, f9                  # Multiply I[i] and W[I]
    fadd.s f0, f0, f7                   # Add SECOND multiplication in result

    # FOURTH ITERATION LOAD AND MULTIPLY
    flw f11, 16(x10)                    # Load in memory input vector I[i + 1]
    flw f12, 16(x11)                    # Load in memory weight vector W[I + 1]
    fmul.s f13, f11, f12                # Multiply I[i + 1] and W[i + 1]
    fadd.s f0, f0, f10                  # Add THIRD multiplication in result

    # FIFTH ITERATION LOAD AND MULTIPLY
    flw f14, 20(x10)                    # Load in memory input vector I[i + 1]
    flw f15, 20(x11)                    # Load in memory weight vector W[I + 1]
    fmul.s f16, f14, f15                # Multiply I[i + 1] and W[i + 1]
    fadd.s f0, f0, f13                  # Add FOURTH multiplication in result

    # SIXTH ITERATION LOAD AND MULTIPLY
    flw f17, 24(x10)                    # Load in memory input vector I[i + 1]
    flw f18, 24(x11)                    # Load in memory weight vector W[I + 1]
    fmul.s f19, f17, f18                # Multiply I[i + 1] and W[i + 1]
    fadd.s f0, f0, f16                  # Add FIFTH multiplication in result

    # SEVENTH ITERATION LOAD AND MULTIPLY
    flw f20, 28(x10)                    # Load in memory input vector I[i + 1]
    flw f21, 28(x11)                    # Load in memory weight vector W[I + 1]
    fmul.s f22, f20, f21                # Multiply I[i + 1] and W[i + 1]
    fadd.s f0, f0, f19                  # Add SIXTH multiplication in result

    # EIGHTH ITERATION LOAD AND MULTIPLY
    flw f23, 32(x10)                    # Load in memory input vector I[i + 1]
    flw f24, 32(x11)                    # Load in memory weight vector W[I + 1]
    fmul.s f25, f23, f24                # Multiply I[i + 1] and W[i + 1]
    fadd.s f0, f0, f25                  # Add EIGHTH multiplication in result

    # INCREMENT COUNTER AND POINTERS
    addi x2, x2, 8                      # Increase the counter
    addi x10, x10, 36                   # Move to next element in I
    addi x11, x11, 36                   # Move to next element in W
    fadd.s f0, f0, f25                   # Add FOURTH multiplication in result

    bne x2, x1, loop                    # if counter == size of vectors

end_loop:
    # Sum is in f0, now add bias B before converting to 
    fadd.s f0, f0, f1                   # f0 = f0 + B

    # Assuming x is in f0 (floating-point register)
    fmv.x.w x3, f0                      # Move float bits to integer register x3
                                        # (doesn't convert, just copies bit pattern)
    # Extract exponent (bits 30-23)
    srli x3, x3, 23                     # Shift right 23 bits
    andi x4, x3, 0xFF                   # Mask to get 8 bits (exponent)

    # Check if exponent == 0xFF (NaN for single precision)
    bne x4, x13, finish                  # If not equal, skip setting to zero

set_zero:
    li x17, 0                           # Load 0 into integer register
    fmv.w.x f0, x17                     # Set result to 0.0 if condition met

finish:
    # Store final result
    fsw f0, 0(x21)                      # Store result
    li a7, 93                           # ecall for exit            
    li a0, 0                            # exit code 0
    ecall