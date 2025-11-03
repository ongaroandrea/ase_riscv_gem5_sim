# LAB 4

The issue relates to how floating-point numbers are represented in IEEE 754 format and what happens when you manipulate them at the bit level.

## The Problem: Extracting the Exponent

In IEEE 754 single-precision format (32 bits):

- Bit 31: Sign bit
- Bits 30-23: Exponent (8 bits)
- Bits 22-0: Mantissa/Fraction (23 bits)

When you need to check if "the exponent part of x is equal to 0x7FF", you face these challenges:

### Challenge 1: 0x7FF requires 11 bits, but single-precision uses 8-bit exponents

- **0x7FF** = 11111111111 in binary (11 bits) - this is the NaN/Infinity exponent for **double-precision** (64-bit) floats
- Single-precision uses **0xFF** = 11111111 (8 bits) for NaN/Infinity

**Your tutor might be testing if you know the correct value for single-precision should be 0xFF, not 0x7FF!**

### Challenge 2: Extracting the Exponent Without Losing Bits

To check the exponent, you need to:

1. Load the floating-point value as an **integer** (bit pattern)
2. Shift and mask to extract bits 30-23
3. Compare with 0xFF (or 0x7FF if this is intentionally double-precision)

**The danger**: If you accidentally perform floating-point operations instead of integer bit manipulation, you could:

- Trigger floating-point exceptions
- Lose precision
- Get incorrect bit patterns

### Challenge 3: Preserving the Original Value

You need to:

- Extract exponent bits → requires viewing as integer
- Still use the original value for the "otherwise" case → requires keeping as float

**The trap**: If you move data between floating-point and integer registers incorrectly, you could corrupt either the exponent or mantissa.

## Solution Approach for RISC-V

```assembly
# Assuming x is in fa0 (floating-point register)
fmv.x.w t0, fa0      # Move float bits to integer register t0
                      # (doesn't convert, just copies bit pattern)

# Extract exponent (bits 30-23)
srli t1, t0, 23      # Shift right 23 bits
andi t1, t1, 0xFF    # Mask to get 8 bits (exponent)

# Check if exponent == 0xFF (NaN for single precision)
li t2, 0xFF
beq t1, t2, return_zero

# Otherwise, return x
fmv.s fa1, fa0       # Copy x to output
j done

return_zero:
fcvt.s.w fa1, zero   # Convert integer 0 to float 0.0

done:
# fa1 now contains y
```

## Key Instructions to Avoid Losing Bits

1. **fmv.x.w** - Move float bits to integer register (preserves all bits)
2. **fmv.w.x** - Move integer bits to float register (preserves all bits)
3. **Never use fcvt** when extracting bits (it converts values, not bit patterns)