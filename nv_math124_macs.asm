//////////////////////////////////////////////////////////////////////////////
// nv_math124_macs.asm
// Copyright(c) 2022 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Contains macros for fixed point 12.4 bit math operations
// importing this will not cause code or data to be allocated in the program
// unless nv_c64_util_data hasn't already been imported in which case it 
// will be.
// Signed FP124 numbers will be stored as follows within a 16 bit word:
//   Bit 15: sign bit, 1 is negative 0 is possitive
//   Bits 14-4: The whole number number portion (left of decimal)
//   Bits 3-0: The decimal part of the number (right of the decimal)
//   Examples:
//     $0048 = $004.8 (decmial is 4.5)
//     $8048 = -$004.8 (decimal is -4.5) note not twos compliment
//   Min Value: $FFF.F (decimal -2047.9375)
//   Max Value: $7FF.F (decimal +2047.9375)
// 
// Unsigned FP124 numbers will be stored as follows within a 16 bit word:
//   Bits 15-4: The whole number number portion (left of decimal)
//   Bits 3-0: The decimal part of the number (right of the decimal)
//   Examples:
//     $0048 = $004.8 (decmial is 4.5)
//     $8048 = $804.8 (decimal is 2052.5) note not twos compliment
//   Min Value: $000.0 (decimal 0)
//   Max Value: $FFF.F (decimal +4095.9375)


#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math124_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_processor_status_macs.asm"
#import "nv_math16_macs.asm"
#import "nv_branch16_macs.asm"
#import "nv_branch124_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// inline macro to set a signed FP124 value the absolute value of itself
// full name: nv_abs124s
// params:
//   addr is the address of the low byte of op1 (FP124s format)
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags are not affected
.macro nv_abs124s(addr)
{
    lda #$7F
    and addr+1
    sta addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to change an FP124 value to its opposite in place.
//        Opposite means flipping the sign in this case. 
// full name: nv_ops124s
// params:
//   addr is the address of the low byte of op1 (FP124s format)
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags are not reliably affected
.macro nv_ops124s(addr)
{
    lda #$80
    eor addr+1
    sta addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to xfer one FP124 value another location 
// 
// full name: nv_xfer124x_mem124x_mem124x
// params:
//   lsb_src_addr is the address of the LSB of the source FP124x value
//   lsb_dest_addr is the address of the LSB of the destination FP124x value
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags are not reliably set
.macro nv_xfer124_mem_mem(lsb_src_addr, lsb_dest_addr)
{
    nv_xfer16_mem_mem(lsb_src_addr, lsb_dest_addr)
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to add two fp124u bit values and store the result in another
// fp124u bit value.  Carry and overflow bits set appropriately
// full name: nv_adc124x_mem16x_mem16x
// params:
//   addr1 is the address of the low byte of op1 (FP124u format)
//   addr2 is the address of the low byte of op2 (FP124u format)
//   result_addr is the address to store the result. (FP124u format)
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags:
//   Carry set if carry from the MSB addition occured, ie if unsigned result
//             would exceed the max FP124 value of $FFF.F
//   Carry clear if no carry from MSB occured, ie if the unsigned result
//             does fit in an FP124 (0 - $FFF.F) 
//   Overflow: Is probably not logical to use for unsigned math, but
//             Set if both operands have same high bit value and result
//             has a different high bit value
//             For example: $7FF.F + $001.0 = $800.F    V=1
//                          $800.0 + $800.0 = $000.0    V=1, C=1
.macro nv_adc124u(addr1, addr2, result_addr)
{
    nv_adc16x(addr1, addr2, result_addr)
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to add two fp124s bit values and store the result in another
// fp124s bit value.  Overflow bit set appropriately
// full name: nv_adc124s_mem124s_mem124s
// params:
//   addr1 is the address of the LSB of op1 (FP124s format)
//   addr2 is the address of the LSB of op2 (FP124s format)
//   result_addr is the address to store the result. (FP124s format)
//   temp16a is a temporary 16bit location to use within macro
//   temp16b is another temporary 16 bit location to use within macro.
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags:
//   Carry not reliably set
//   Overflow: Set result would be outside the valid fp124s values.  Usually this
//             is when both operands have same high bit value and result
//             has a different high bit value
//             For example: $7FF.F + $001.0 = $800.F    V=1
//                          $800.0 + $800.0 = $000.0    V=1
//             
//             Note that when overflow is set, the result isn't very useful
.macro nv_adc124s(addr1, addr2, result_addr, temp16a, temp16b)
{
    .label temp_op1 = temp16a
    .label temp_op2 = temp16b

    //nv_xfer16_mem_mem(addr1, temp_op1)
    lda addr1+1
    bpl Op1Positive
Op1Negative:
    and #$7F                         // clear negative bit
    sta temp_op1+1                      // store it back in temp as cleared
    lda addr1
    sta temp_op1
    nv_twos_comp_16(temp_op1, temp_op1) // do twos compliment to get 16 bit signed int
    jmp DoneOp1

Op1Positive:
    nv_xfer16_mem_mem(addr1, temp_op1)

DoneOp1:    
    //nv_xfer16_mem_mem(addr2, temp_op2)
    lda addr2+1
    bpl Op2Positive

Op2Negative:
    and #$7F 
    sta temp_op2+1
    lda addr2
    sta temp_op2    
    nv_twos_comp_16(temp_op2, temp_op2)
    jmp DoneOp2

Op2Positive:
    nv_xfer16_mem_mem(addr2, temp_op2)

DoneOp2:

    nv_adc16x(temp_op1, temp_op2, result_addr)
    
    // save processor flags specifically overflow
    php

    lda result_addr+1
    bpl ResultPositive 
ResultNegative:
    nv_twos_comp_16(result_addr, result_addr)
    lda result_addr+1
    bpl ResultWasNot8000
    // result was $8000 which we know because its the the only neg num for which
    // twos compliment will return a negative number (itself)
    // This is a special case the overflow bit won't be set because its a 
    // valid 16bit signed result but its not valid FP124s value because its 
    // outside range of valid values.  To handle this case we'll set overflow flag 
    // manually and be done.
    plp                         // pull the status flags overflow not set
    nv_flags_set_overflow()     // manually set the overflow flag
    bvs DoneNoPullFlags         // branch over the rest to the end.
    
ResultWasNot8000:
    ora #$80
    sta result_addr+1

ResultPositive:
    plp

DoneNoPullFlags:

}

//////////////////////////////////////////////////////////////////////////////
// inline macro that expands the nv_adc124s macro with dedicated 
// temporary 16bit values and also adds an rts at the end
// see the nv_adc124s macro for details
.macro nv_adc124s_sr(addr1, addr2, result_addr)
{
    nv_adc124s(addr1, addr2, result_addr, temp_op1, temp_op2)
    rts

temp_op1: .word $0000
temp_op2: .word $0000
}


//////////////////////////////////////////////////////////////////////////////
// inline macro that does the same thing as nv_adc124s
// except the addr1 and addr1 locations will not be preserved, they
// will be ruined.
// If ruining the operand values can be tolerated this 
// will run a little faster than nv_adc124s
// params:
//   addr1 is the address of the low byte of op1 (FP124s format)
//         after the macro runs this value will be ruined
//   addr2 is the address of the low byte of op2 (FP124s format)
//         after the macro runs this value will be ruined
//   result_addr is the address to store the result. (FP124s format)
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags:
//   Carry not reliably set
//   Overflow: Set if both operands have same high bit value and result
//             has a different high bit value
//             For example: $7FF.F + $001.0 = $800.F    V=1
//                          $800.0 + $800.0 = $000.0    V=1
//             Note that when overflow is set, the result isnt very useful
.macro nv_adc124s_ruin_ops(addr1, addr2, result_addr)
{
    //nv_xfer16_mem_mem(addr1, temp_op1)
    lda addr1+1
    bpl Op1Positive
Op1Negative:
    and #$7F                      // clear negative bit
    sta addr1+1                   // store it back in temp as cleared
    nv_twos_comp_16(addr1, addr1) // do twos compliment to get 16 bit signed int
    jmp DoneOp1

Op1Positive:
    //nv_xfer16_mem_mem(addr1, addr1)

DoneOp1:    
    //nv_xfer16_mem_mem(addr2, temp_op2)
    lda addr2+1
    bpl Op2Positive

Op2Negative:
    and #$7F 
    sta addr2+1
    nv_twos_comp_16(addr2, addr2)
    jmp DoneOp2

Op2Positive:
    //nv_xfer16_mem_mem(addr2, addr2)

DoneOp2:

    nv_adc16x(addr1, addr2, result_addr)
    
    // save processor flags specifically overflow
    php

    lda result_addr+1
    bpl ResultPositive 
ResultNegative:
    nv_twos_comp_16(result_addr, result_addr)
    lda result_addr+1
    bpl ResultWasNot8000
    // result was $8000 which we know because its the the only neg num for which
    // twos compliment will return a negative number (itself)
    // This is a special case the overflow bit won't be set because its a 
    // valid 16bit signed result but its not valid FP124s value because its 
    // outside range of valid values.  To handle this case we'll set overflow flag 
    // manually and be done.
    plp                         // pull the status flags overflow not set
    nv_flags_set_overflow()     // manually set the overflow flag
    bvs DoneNoPullFlags         // branch over the rest to the end.
    
ResultWasNot8000:
    ora #$80
    sta result_addr+1

ResultPositive:
    plp

DoneNoPullFlags:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro that does the same as nv_adc124s_ruin_ops but also does 
// rts at the end.  
// See nv_adc124s_ruin_ops for details
.macro nv_adc124s_ruin_ops_sr(addr1, addr2, result_addr)
{
    nv_adc124s_ruin_ops(addr1, addr2, result_addr)
    rts
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to round an unsigned fp124 bit value in place to the closest
// whole number.
// Note this does not convert to 16 bit value, just a rounded FP124
// Flags: 
//   Overflow flag will be set if input would round beyond FP124u range
//            which is input that is $FFF.8 or above.
//            When overflow flag is set the result will be set to the max
//            FP124 unsigned whole number.
//   Carry flag will be set if addr1 contains $FFF.8 or above which will 
//      result in rounding up to a value out of range
.macro nv_rnd124u(addr1)
{
    // add 0.5 (decimal) to the number to force the whole number to left
    // of decimal point to be the rounded whole number
    nv_adc16x_mem_immed(addr1, $0008, addr1)

    // clear all the fractional digits
    lda addr1   // no change to carry flag
    and #$F0    // no change to carry flag
    sta addr1   // no change to carry flag

    clv         // clear overflow flag, will be set below if needed

    // carry flag still set from the addition above
    bcc Done
    // if here then carry flag set and we had an overflow
    // set result to max whole FP124u number and set overflow flag
    nv_store16_immed(addr1, $FFF0)
    nv_flags_set_overflow()

Done:
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to round a signed fp124 bit value in place to the closest
// whole number.
// Note: If would round beyond max magnitude value then set to max whole
//       number and the overflow flag will be set in processor status reg.
// Note: Does not convert to 16 bit value, just a rounded FP124
// Accum: changes
// X reg: ??
// Y reg: ??
// Flags: 
//   Overflow flag: will be set if result would round beyond max
.macro nv_rnd124s(addr)
{
    // load the high byte of the parameter to round
    lda addr+1
    pha                 // store this high byte on stack for later
    bpl PositiveInput
NegativeInput:
    and #$7F    // clear sign bit
    sta addr+1  // store cleared sign bit

PositiveInput:
    // add 0.5 (decimal) to the number to force the whole number to left
    // of decimal point to be the rounded whole number
    nv_adc16x_mem_immed(addr, $0008, addr)

    // clear all the fractional digits
    lda addr   
    and #$F0   
    sta addr   

    clv                  // clear overflow flag, will set later if needed

    lda addr+1           // load rounded value (no sign yet) MSB to Accum
    bpl ResultHiBitClear // if the hi bit is clear then no overflow

ResultHiBitSet:         // if here then addition overflowed into the sign bit.
    // set result to max
    nv_store16_immed(addr, $7FF0)
    nv_flags_set_overflow()

ResultHiBitClear:  // resulting value has hi bit clear, no overflow 
    pla            // pull the original high byte from stack to accum
    bpl Done       // if it was positive to start with then done

    // was negative to start with so set negative flag
    lda addr+1  // load rounded value MSB to Accum
    ora #$80    // set the sign bit for negative
    sta addr+1  // store it back to MSB of the result
Done:
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to convert and round an unsigned fp124 bit value and store  
// the result in an unsigned 16 bit int value.  The result will either be the
// truncated input value (ex $123.4 -> $0123)  or the next higher number
// (ex $234.8 -> $0235) depending on if the decimal part is >= half. 
// if the input value's whole number part is $FFF and it rounds up then the
// result will be $0000 and the carry flag will be set
// full name: nv_rnd124u_mem16u
// params:
//   addr1: is the address of the low byte of unsigned FP124 number to round
//   result_addr: is the address of an unsigned 16 bit word in which to 
//     store the result.
// Accum changes
// X Reg unchanged
// Y Reg changed
// Status flags:
//      Carry flag not reliably set
//      Negative flag is not reliably set but result will always be positive
//      Overflow flag is not reliably set
//      Zero flag is not reliably set
.macro nv_conv124u_mem16u(addr1, result_addr)
{
    // move operand into result
    nv_xfer16_mem_mem(addr1, result_addr)

    // shift result right to remove all but the most significant fraction digit
    nv_lsr16u_mem16u_immed8u(result_addr, 3)

    // add 0.5 (decimal) to the number.  There is now only one fraction digit
    // because shifted the rest off already
    nv_adc16x_mem_immed(result_addr, $0001, result_addr)

    // shift right to remove final fraction digit
    nv_lsr16u_mem16u_immed8u(result_addr, 1)
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to convert and round a signed fp124 bit value and store the 
// result in an signed 16 bit int value. The result will either be the
// truncated input value (ex $123.4 -> $0123)  or the next greater magnitude
// number in positive or negative direction  (ex $234.8 -> $0235) 
// depending on if the decimal part is >= half. 
// if the input value's whole number part is $FFF and it rounds up then the
// result will be $0000 and the carry flag will be set
// full name: nv_conv124s_mem16s
// params:
//   addr1: is the address of the low byte of unsigned FP124 number to round
//   result_addr: is the address of an signed 16 bit word in which to 
//     store the result.
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags: will not be reliably set.  will never cause overflow or carry
//               because will always fit in the 16 bit signed result
.macro nv_conv124s_mem16s(addr1, result_addr)
{
    // set N flag for high bit of operand
    bit addr1+1
    bpl ItsPositive

ItsNegative:
    // copy operand to result
    nv_xfer16_mem_mem(addr1, result_addr)

    // clear negative flag in result
    lda #$7F
    and result_addr+1
    sta result_addr+1

    // now do the unsigned conversion
    nv_conv124u_mem16u(result_addr, result_addr)

    // since the original number was negative the result will be negative
    // do a 2s comp to make result negative
    nv_twos_comp_16(result_addr, result_addr)

    jmp Done

ItsPositive: 
    // signed conversion for a positive value is same as unsigned 
    nv_conv124u_mem16u(addr1, result_addr)


Done:
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to convert an unsigned 16bit int to an unsigned fp124 
// and store the result 
// full name: nv_conv16u_mem124u
// params:
//   src_16u: is the address of the LSB of unsigned 16 bit unsigned to convert
//   dest_124u: is the address of an signed 16 bit word in which to 
//     store the result.
// Accum: Changes
// X Reg: Unchanged
// Y Reg: Changes
// Status flags: 
//    Overflow: will be set if the source value is too big to fit in the dest
.macro nv_conv16u_mem124u(src_16u, dest_124u)
{
    lda #$F0
    and src_16u+1
    beq ItFits
DoesNotFit:
    nv_store16_immed(dest_124u, 0)
    nv_flags_set_overflow()
    jmp Done

ItFits:
    nv_xfer16_mem_mem(src_16u, dest_124u)
    nv_asl16u_mem16u_immed8u(dest_124u, 4)
    clv
Done:
}
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// inline macro to create one fp124u value in memory location specified
// Accum: changes
// X Reg:
// Y Reg:  
.macro nv_create124u(left_of_pt, right_of_pt, addr)
{
    .if (left_of_pt > $0FFF)
    {
        .error "nv_create124u left of pt to big."
    }
    .if (right_of_pt > $0F)
    {
        .error "nv_create124u right of pt to big."
    }

    // Hi byte of the fp124u
    lda #((left_of_pt << 4) >> 8)
    sta addr+1

    // lo byte of fp124u
    lda #(right_of_pt | ((left_of_pt & $000F) << 4))
    sta addr
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to create one fp124u value in memory location specified
// Accum: changes
// X Reg:
// Y Reg:  
.macro nv_create124s(sign, left_of_pt, right_of_pt, addr)
{
    .if (sign != 0 && sign != 1)
    {
        .error "nv_create124s invalid sign"
    }
    .if (left_of_pt > $07FF)
    {
        .error "nv_create124s left of pt to big."
    }
    .if (right_of_pt > $0F)
    {
        .error "nv_create124s right of pt to big."
    }

    // Hi byte of the fp124s
    lda #(((left_of_pt << 4) >> 8) | (sign << 7))
    sta addr+1

    // lo byte of fp124s
    lda #(right_of_pt | ((left_of_pt & $000F) << 4))
    sta addr
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to find the closest fp124s value for a given float
// and put that value in the memory location given 
.macro nv_closest124s_immedflt(num, addr)
{
    .var sign = 0
    .if (num < 0)
    {
        .eval sign = 1
    }

    .var left = round(abs(num) * 16) >> 4
    .var right = round(abs(num) * 16) & $000F
    
    nv_create124s(sign, left, right, addr)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to find the closest fp124u value for a given float
// and put that value in the memory location given 
.macro nv_closest124u_immedflt(num, addr)
{
    .if (num < 0)
    {
        .error "closest124u_immedflt negative number passed"
    }
    .var left = round(num * 16) >> 4
    .var right = round(num * 16) & $000F
    
    nv_create124u(left, right, addr)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to set overflow flag in status register
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_flags_set_overflow()
{
    // set overflow here
    php         // push processor flags to stack
    pla         // pull stack to accum (accum now has flags)
    ora #$40    // set the overflow bit in accum
    pha         // push updated flags from accum to stack
    plp         // pull updated flags from stack to status register

}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline function that returns an fp124s value.  
.function NvBuildFp124s(sign, left_of_pt, right_of_pt)
{
    .var ret_val = $0000

    .if (sign != 0 && sign != 1)
    {
        .error "NvBuild124s invalid sign"
    }
    .if (left_of_pt > $07FF)
    {
        .error "NvBuild124s left of pt to big."
    }
    .if (right_of_pt > $0F)
    {
        .error "NvBuild124s right of pt to big."
    }

    // Hi byte of the fp124s
    .var hi_byte = (((left_of_pt << 4) >> 8) | (sign << 7))
    //lda #(((left_of_pt << 4) >> 8) | (sign << 7))
    //sta addr+1

    // lo byte of fp124s
    .var lo_byte = (right_of_pt | ((left_of_pt & $000F) << 4))
    //lda #(right_of_pt | ((left_of_pt & $000F) << 4))
    //sta addr

    .eval ret_val = hi_byte << 8 | lo_byte
    .return ret_val 
}

//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline function that returns an fp124u value.  
.function NvBuildFp124u(left_of_pt, right_of_pt)
{
    .if (left_of_pt > $0FFF)
    {
        .error "NvBuildFp124u left of pt to big."
    }
    .if (right_of_pt > $0F)
    {
        .error "NvBuildFp124u right of pt to big."
    }

    .var ret_val = $0000

    .var hi_byte = ((left_of_pt << 4) >> 8)
    .var lo_byte = (right_of_pt | ((left_of_pt & $000F) << 4))

    .eval ret_val = hi_byte << 8 | lo_byte
    .return ret_val 
}
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// inline function to find the closest fp124s value for a given float
// and return it 
.function NvBuildClosest124s(num)
{
    .var sign = 0
    .if (num < 0)
    {
        .eval sign = 1
    }

    .var left = round(abs(num) * 16) >> 4
    .var right = round(abs(num) * 16) & $000F
    
    .var ret_val = 0
    .eval ret_val = NvBuildFp124s(sign, left, right)

    .return ret_val
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline function to find the closest fp124u value for a given float
// and return it 
.function NvBuildClosest124u(num)
{
    .if (num < 0)
    {
        .error "NvBuildClosest124u negative number passed"
    }
    .var left = round(num * 16) >> 4
    .var right = round(num * 16) & $000F
    
    .var ret_val = 0
    .eval ret_val = NvBuildFp124u(left, right)

    .return ret_val
}
//
//////////////////////////////////////////////////////////////////////////////


