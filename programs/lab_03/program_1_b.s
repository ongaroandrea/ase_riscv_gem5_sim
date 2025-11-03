# RISC-V Assembly Program - 2x Loop Unrolled with Hazard Reduction
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
    li x29, 1                           # Constant 1 for loop check (loaded once)

    la x10, float_val
    flw f4, 0(x10)                      # Variable a (float) initialized to 1.0
    flw f5, 0(x10)                      # Variable b (float) initialized to 1.0

    # Load base addresses of vectors
    la x11, V1
    la x12, V2
    la x13, V3
    la x14, V4
    la x15, V5
    la x16, V6

loop:
    # Calculate addresses and remainder for FIRST iteration
    slli x3, x2, 2                      # x3 = i * 4
    rem x28, x2, x20                    # x28 = i % 3
    
    # Calculate addresses for SECOND iteration (i-1)
    addi x4, x2, -1                     # x4 = i - 1
    slli x5, x4, 2                      # x5 = (i-1) * 4
    rem x30, x4, x20                    # x30 = (i-1) % 3

    # Calculate all addresses for FIRST iteration
    add x21, x11, x3                    # Address of V1[i]
    add x22, x12, x3                    # Address of V2[i]
    add x23, x13, x3                    # Address of V3[i]
    add x24, x14, x3                    # Address of V4[i]
    add x25, x15, x3                    # Address of V5[i]
    add x26, x16, x3                    # Address of V6[i]

    # Load values for FIRST iteration
    flw f1, 0(x21)                      # Load V1[i]
    add x6, x11, x5                     # Address of V1[i-1]
    flw f2, 0(x22)                      # Load V2[i]
    add x7, x12, x5                     # Address of V2[i-1]
    flw f3, 0(x23)                      # Load V3[i]
    add x8, x13, x5                     # Address of V3[i-1]
    
    # Complete address calculations for SECOND iteration
    add x9, x14, x5                     # Address of V4[i-1]
    add x17, x15, x5                    # Address of V5[i-1]
    add x18, x16, x5                    # Address of V6[i-1]

    # First Iteration
    bne x28, x0, iter1_not_multiple     # Branch if NOT multiple of 3

iter1_multiple_of_3:
    # a = v1[i] / ((float) m << i);
    sll x27, x1, x2                     # x27 = m << i
    fcvt.s.w f10, x27                   # Convert to float (multi-cycle)
    fdiv.s f4, f1, f10                  # f4 = v1[i] / (m << i) (multi-cycle)
    flw f11, 0(x6)                      # Prefetch V1[i-1] for iteration 2
    flw f12, 0(x7)                      # Prefetch V2[i-1] for iteration 2
    fcvt.w.s x1, f4                     # m = (int) a
    j iter1_after_if

iter1_not_multiple:
    # a = v1[i] * ((float) m * i);
    fcvt.s.w f10, x1                    # Convert m to float
    fcvt.s.w f13, x2                    # Convert i to float (parallel)
    flw f11, 0(x6)                      # Prefetch V1[i-1]
    fmul.s f14, f10, f13                # f14 = m * i
    flw f12, 0(x7)                      # Prefetch V2[i-1]
    fmul.s f4, f1, f14                  # f4 = v1[i] * (m * i)
    flw f15, 0(x8)                      # Prefetch V3[i-1]
    fcvt.w.s x1, f4                     # m = (int) a

iter1_after_if:
    # v4[i] = a * v1[i] - v2[i];
    fmul.s f6, f4, f1                   # f6 = a * v1[i] (multi-cycle)
    flw f15, 0(x8)                      # Load V3[i-1] if not already loaded
    fsub.s f6, f6, f2                   # f6 = a * v1[i] - v2[i]
    
    # v5[i] = v4[i]/v3[i] - b; and prepare v6[i]
    fdiv.s f7, f6, f3                   # f7 = v4[i]/v3[i] (multi-cycle)
    fsub.s f9, f6, f1                   # f9 = v4[i] - v1[i] (independent)
    fsw f6, 0(x24)                      # Store V4[i] (can happen early)
    
    fsub.s f8, f7, f5                   # f8 = v4[i]/v3[i] - b
    fsw f8, 0(x25)                      # Store V5[i]
    
    # v6[i] = (v4[i]-v1[i]) * v5[i];
    fmul.s f10, f9, f8                  # f10 = (v4[i]-v1[i]) * v5[i]
    addi x2, x2, -2                     # Decrement by 2
    fsw f10, 0(x26)                     # Store V6[i]

    # Second Iteration
    bne x30, x0, iter2_not_multiple     # Branch if NOT multiple of 3

iter2_multiple_of_3:
    # a = v1[i-1] / ((float) m << (i-1));
    sll x27, x1, x4                     # x27 = m << (i-1)
    fcvt.s.w f10, x27                   # Convert to float
    fdiv.s f4, f11, f10                 # f4 = v1[i-1] / (m << (i-1))
    fcvt.w.s x1, f4                     # m = (int) a
    j iter2_after_if

iter2_not_multiple:
    # a = v1[i-1] * ((float) m * (i-1));
    fcvt.s.w f10, x1                    # Convert m to float
    fcvt.s.w f13, x4                    # Convert (i-1) to float
    fmul.s f14, f10, f13                # f14 = m * (i-1)
    fmul.s f4, f11, f14                 # f4 = v1[i-1] * (m * (i-1))
    fcvt.w.s x1, f4                     # m = (int) a

iter2_after_if:
    # v4[i-1] = a * v1[i-1] - v2[i-1];
    fmul.s f6, f4, f11                  # f6 = a * v1[i-1]
    fsub.s f6, f6, f12                  # f6 = a * v1[i-1] - v2[i-1]
    
    # v5[i-1] = v4[i-1]/v3[i-1] - b;
    fdiv.s f7, f6, f15                  # f7 = v4[i-1]/v3[i-1]
    fsub.s f9, f6, f11                  # f9 = v4[i-1] - v1[i-1]
    fsw f6, 0(x9)                       # Store V4[i-1]
    
    fsub.s f8, f7, f5                   # f8 = v4[i-1]/v3[i-1] - b
    fsw f8, 0(x17)                      # Store V5[i-1]
    
    # v6[i-1] = (v4[i-1]-v1[i-1]) * v5[i-1];
    fmul.s f10, f9, f8                  # f10 = (v4[i-1]-v1[i-1]) * v5[i-1]
    fsw f10, 0(x18)                     # Store V6[i-1]

    # Loop condition - continue if i >= 0
    bge x2, x0, loop                     # If i >= 0, repeat loop

finish:
    li a7, 93                           # ecall for exit
    li a0, 0                            # exit code 0
    ecall