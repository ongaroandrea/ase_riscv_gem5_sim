
# for (i = 31; i >= 0; i--) {	
#	v4[i] = v1[i]*v1[i] – v2[i];
#	v5[i] = v4[i]/v3[i] – v2[i];
#   v6[i] = (v4[i]-v1[i])*v5[i];
# }

#Data section
.section .data
V1:     1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0 
V2:     1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
V3:     1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 1.0, 2.0, 3.1, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

V4:     .space      128              # 32 * 4 bytes
V5:     .space      128     
V6:     .space      128
COUNTER: .byte      31


#Code section
.section .text
.globl _start

_start:

    #Reading the data
    la x1, COUNTER              # Reading address of the counter
    lb x2, 0(x1)                # Setting the value of the counter to x2

    la x11, V1
    la x12, V2
    la x13, V3
    la x14, V4
    la x15, V5
    la x16, V6

loop:    
    flw x21, 0(x11)             # Read value for current address of V1
    flw x22, 0(x12)             # Read value for current address of V2
    flw x23, 0(x13)             # Read value for current address of V3

    # First operation
    fmsub.s x24, x21, x21, x22        # v1[i]*v1[i] – v2[i];
    fsw x24, 0(x14)                   # Store the result in V4
                                      # ----------------------
    fdiv.s x25, x24, x21              # v4[i]/v3[i]
    fsub.s x26, x25, x22              # v4[i]/v3[i] – v2[i]
    fsw x26, 0(x15)                   # Store the result in V5
                                      # ----------------------
    fsub.s x27, x24, x21                
    

    # Increase the addresses        
    add x11, x11, 4             # x11 = x11 - 4
    add x12, x12, 4             # x12 = x12 - 4
    add x13, x13, 4             # x13 = x13 - 4
    
    # Decrease counter 
    sub x2, x2, 1               # x2 = x2 - 1

    bne x2, 0, loop             # Check the current value of the counter

finish:
    li a7, 93
    li a0, 0
    ecall