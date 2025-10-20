# RISC-V Assembly Program
# Implements:
# for (i = 31; i >= 0; i--) {
#     v4[i] = v1[i]*v1[i] - v2[i];
#     v5[i] = v4[i]/v3[i] - v2[i];
#     v6[i] = (v4[i]-v1[i])*v5[i];
# }

#Data section
.section .data
V1:     .float      1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
V2:     .float      1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
V3:     .float      1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

V4:     .space      128              # 32 * 4 bytes
V5:     .space      128     
V6:     .space      128

#Code section
.section .text
.globl _start

_start:

    # Initialize counter (i = 31)
    li x2, 31                   # Counter: i = 31

    # Load base addresses of vectors
    la x11, V1
    la x12, V2
    la x13, V3
    la x14, V4
    la x15, V5
    la x16, V6

loop:

    # Calculate current index address
    slli x3, x2, 2                      # x3 = i * 4

    # Calculate addresses for current index
    add x4, x11, x3                     # Address of V1[i] = x11 + i * 4
    add x5, x12, x3                     # Address of V2[i] = x12 + i * 4
    add x6, x13, x3                     # Address of V3[i] = x13 + i * 4
    add x7, x14, x3                     # Address of V4[i] = x14 + i * 4
    add x8, x15, x3                     # Address of V5[i] = x15 + i * 4
    add x9, x16, x3                     # Address of V6[i] = x16 + i * 4

    # Load values from V1, V2, V3
    flw f1, 0(x4)                       # Load V1[i] into f1
    flw f2, 0(x5)                       # Load V2[i] into f2
    flw f3, 0(x6)                       # Load V3[i] into f3

    # First operation
    fmsub.s f4, f1, f1, f2              # v1[i]*v1[i] – v2[i];
    fsw f4, 0(x14)                      # Store the result in V4

    # Second operation
    fdiv.s f5, f4, f3                   # v4[i]/v3[i]
    fsub.s f6, f5, f2                   # v4[i]/v3[i] – v2[i]
    fsw f6, 0(x15)                      # Store the result in V5

    # Third operation
    fsub.s f7, f4, f3                   # (v4[i]-v1[i])
    fmul.s f8, f7, f6                   # (v4[i]-v1[i])*v5[i];
    fsw f8, 0(x16)                      # Store the result in V6

    # Decrease counter
    li x21, 1
    sub x2, x2, x21                      # x2 = x2 - 1

    # Loop condition
    bge x2, x0, loop                     # If i >= 0, repeat loop                    

finish:
    li a7, 93                           # ecall for exit            
    li a0, 0                            # exit code 0
    ecall