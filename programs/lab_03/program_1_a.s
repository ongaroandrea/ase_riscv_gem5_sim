# RISC-V Assembly Program
# Implements:
# int m = 1;
# float a, b;
# for (i = 31; i >= 0; i--) {
#    if (i is a multiple of 3) {
#        a = v1[i] / ((float) m << i); /*logic shift */
#        m = (int) a;
#    } else { 
#        a = v1[i] * ((float) m * i);
#        m = (int) a;
#    }   
#    v4[i] = a * v1[i] - v2[i];
#    v5[i] = v4[i]/v3[i] - b;
#    v6[i] = (v4[i]-v1[i]) * v5[i];
# }


#Data section
.section .data
V1:     .float      1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
V2:     .float      1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
V3:     .float      1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

V4:     .space      128              # 32 * 4 bytes
V5:     .space      128     
V6:     .space      128

float_val: .float 1.0

#Code section
.section .text
.globl _start

_start:

    # Initialize counter (i = 31)
    li x1, 1                            # Variable m (integer) initialized to 1
    li x2, 31                           # Counter: i = 31
    li x20, 3                           # Constant 3 for modulo operation

    la x10, float_val
    flw f4, 0(x10) 	                    # Variable a (float) initialized to 1.0
    flw f5, 0(x10)                      # Variable b (float) initialized to 1.0

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
    rem x28, x2, x20                    # x21 = i % 3 -- anticipate for if condition

    # Calculate addresses for current index
    add x21, x11, x3                     # Address of V1[i] = x11 + i * 4
    add x22, x12, x3                     # Address of V2[i] = x12 + i * 4
    add x23, x13, x3                     # Address of V3[i] = x13 + i * 4
    add x24, x14, x3                     # Address of V4[i] = x14 + i * 4
    add x25, x15, x3                     # Address of V5[i] = x15 + i * 4
    add x26, x16, x3                     # Address of V6[i] = x16 + i * 4

    # Load values from V1, V2, V3
    flw f1, 0(x21)                       # Load V1[i] into f1
    flw f2, 0(x22)                       # Load V2[i] into f2
    flw f3, 0(x23)                       # Load V3[i] into f3

    # ------------------------------------------------
    # Check if i is a multiple of 3
    beq x28, x0, multiple_of_3          # If remainder is 0, branch to multiple_of_3

    # Not a multiple of 3
    # a = v1[i] * ((float) m * i);
    fcvt.s.w f10, x22                   # Convert m to float in f10
    fcvt.s.w f11, x2                    # Convert i to float in f11
    fmul.s f12, f10, f11                # f12 = m * i
    fmul.s f4, f1, f12                  # f4 = v1[i] * (m * i)
    fcvt.w.s x1, f4                     # m = (int) a
    j after_if

multiple_of_3:
    # a = v1[i] / ((float) m << i);
    sll x27, x1, x2                     # x27 = m << i
    fcvt.s.w f10, x27                   # Convert m to float in f10
    fdiv.s f4, f1, f10                  # f4 = v1[i] / (m << i)
    fcvt.w.s x1, f4                     # m = (int) a

after_if:
    # v4[i] = a * v1[i] - v2[i];
    fmul.s f6, f4, f1                    # f6 = a * v1[i]
    fsub.s f6, f6, f2                    # f6 = a * v1[i] - v2[i]
    fdiv.s f7, f6, f3                    # f7 = v4[i]/v3[i] -- anticipate for next step
    fsw f6, 0(x24)                       # Store the result in V4

    #v5[i] = v4[i]/v3[i] - b;
    fsub.s f9, f6, f1                    # f9 = v4[i]-v1[i] -- anticipate for next step
    fsub.s f8, f7, f5                    # f8 = v4[i]/v3[i] - b
    fsw f8, 0(x25)                       # V5[i] = v4[i]/v3[i] - b

    # Decrease counter
    add x2, x2, -1                      # x2 = x2 - 1

    # v6[i] = (v4[i]-v1[i]) * v5[i];
    fmul.s f10, f9, f8                   # f10 = (v4[i]-v1[i]) * v5[i]
    fsw f10, 0(x26)                      # Store the result in V6

    # Loop condition
    bge x2, x0, loop                     # If i >= 0, repeat loop                    

finish:
    li a7, 93                           # ecall for exit            
    li a0, 0                            # exit code 0
    ecall