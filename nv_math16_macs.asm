//////////////////////////////////////////////////////////////////////////////
// nv_math16_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Contains macros for 16 bit math operations
// importing this will not cause code or data to be allocated in the program
// unless nv_c64_util_data hasn't already been imported in which case it 
// will be.


#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math16_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_branch16_macs.asm"
#import "nv_processor_status_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// inline macro to add two 16 bit values and store the result in another
// 16bit value.  Carry and overflow bits set appropriately
// full name: nv_adc16x_mem16x_mem16x
// params:
//   addr1 is the address of the low byte of op1
//   addr2 is the address of the low byte of op2
//   result_addr is the address to store the result.
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags:
//   Carry set if carry from the MSB addition occured, ie if unsigned result
//             would exceed 16 bit unsigned max (65535).
//   Carry clear if no carry from MSB occured, ie if the unsigned result
//             does fit in a 16 bit unsigned int (0 - 65535) 
//   Overflow set: if signed result outside bound of 
//                 16 bit signed int (-32768 and +32767)
//   Overflow clear if signed result falls within the bound of
//                 16 bit signed int 
.macro nv_adc16x(addr1, addr2, result_addr)
{
    lda addr1
    clc
    adc addr2
    sta result_addr
    lda addr1+1
    adc addr2+1
    sta result_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to add a signed 8 bit value in memory to a 16 bit value 
// in memory and store the result in another 16bit value.  
// full name: nv_adc16x_mem16x_mem8s
// params:
//   addr16 is the address of the low byte of 16 bit operand.
//          whether signed or unsigned the result will be the same
//   addr8 is the address of the signed 8 bit operand.  As an 8 bit
//         signed number, if the sign bit is 1 then it will be 
//         extended to create a 16bit value that will be added to the
//         value at addr16.  The created 16 bit value will have all 8 high
//         bits set to match the sign bit from the original 8 bit value.
//         For example,  if the 8 bit value at addr8 is $FF (-1)  then
//         instead of adding $00FF to the 16 bit number we'll be adding 
//         $FFFF which is -1 so that the result will be as expected.   
//   result16_addr is the address to store the 16bit result.
// Accum changes
// X Reg changes
// Y Reg unchanged
// Status flags:
//   Carry set if carry from the MSB addition occured, ie if unsigned result
//             after sign extending addr8 would exceed 16 bit unsigned 
//             max (65535).
//   Carry clear if no carry from MSB occured, ie if the unsigned result
//             after sign extending addr8 does fit in a 16 bit 
//             unsigned int (0 - 65535) 
//   Overflow set: if signed result outside bound of 
//                 16 bit signed int (-32768 and +32767)
//   Overflow clear if signed result falls within the bound of
//                 16 bit signed int 
.macro nv_adc16x_mem16x_mem8s(addr16, addr8, result16_addr)
{
    ldx #0
    lda addr8
    bpl Op2Positive
    ldx #$ff
Op2Positive:
    stx scratch_byte
    clc
    adc addr16
    sta result16_addr
    lda addr16+1
    adc scratch_byte
    sta result16_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to add an unsigned 8 bit value in memory to a 16 bit value 
// (signed or unsigned) in memory and store 16bit result in memory. 
// full name: nv_adc16x_mem16x_mem8u
// params:
//   addr16 is the address of the LSB of 16 bit operand
//   addr8 is the address of the unsigned 8 bit operand (0-255).  Since its
//         unsigned, when the value is $FF, the result won't be to
//         adding a negative 1 but will be adding 255 to the 16 bit value.    
//   result16_addr is the address to store the result.
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags:
//   Carry set if carry from the MSB addition occured, ie if unsigned result
//             after sign extending addr8 would exceed 16 bit unsigned 
//             max (65535).
//   Carry clear if no carry from MSB addition occured, ie if unsigned result
//             does fit in a 16 bit unsigned int (0 - 65535) 
//   Overflow set: if signed result outside bounds of 
//                 16 bit signed int (-32768 and +32767)
//   Overflow clear if signed result falls within the bound of
//                 16 bit signed int (-32768 and +32767)
.macro nv_adc16x_mem16x_mem8u(addr16, addr8, result16_addr)
{
    lda addr16
    clc
    adc addr8
    sta result16_addr
    lda addr16+1
bcc SkipAddition
    adc #0
SkipAddition:
    sta result16_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to add the accum (as an unsigned byte) to a 16 bit 
// word in memory and store the result to a 16 bit word in memory.
// result16_addr = addr16 + accum
// full name: nv_adc16x_mem16x_a8u
// params:
//   addr16: is the address of the LSB of 16 bit operand
//   accum: contains the value to add to addr16  Since this is an
//         unsigned operation, when the value is $FF, the result won't be to
//         adding a negative 1 but will be adding 255 to the 16 bit value.    
//   result16_addr is the address to store the result.
// accum: changes
// x reg: unchanged
// y reg: unchanged
// Status flags:
//   Carry set if carry from the MSB addition occured, ie if unsigned result
//             after sign extending addr8 would exceed 16 bit unsigned 
//             max (65535).
//   Carry clear if no carry from MSB addition occured, ie if unsigned result
//             does fit in a 16 bit unsigned int (0 - 65535) 
//   Overflow set: if signed result outside bounds of 
//                 16 bit signed int (-32768 and +32767)
//   Overflow clear if signed result falls within the bound of
//                 16 bit signed int (-32768 and +32767)
// old name: nv_adc16_a_unsigned
.macro nv_adc16x_mem16x_a8u(addr16, result16_addr)
{
    clc
    adc addr16          // add LSB of addr16 with accum
    sta result16_addr   // above addition is LSB of result
    lda addr16+1        // load MSB of addr16 to update 
    bcc SkipAdd         // carry is clear, we are done MSB is unchanged
    adc #0              // add 0, carry will be set if appropriate
SkipAdd:
    sta result16_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to add one 16 bit values in memory to an immediate value
// and store the result in another 16bit value.  
// result_addr = addr1 + num
// full name: nv_adc16x_mem16x_immed16x
// params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   num is the 16 bit immeidate number to add
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
// Accum changes
// X Reg unchanged
// Y Reg unchanged
// Status flags:
//   Carry set if carry from the MSB addition occured, ie if unsigned result
//             would exceed 16 bit unsigned max (65535).
//   Carry clear if no carry from MSB occured, ie if the unsigned result
//             does fit in a 16 bit unsigned int (0 - 65535) 
//   Overflow set: if signed result outside bound of 
//                 16 bit signed int (-32768 and +32767)
//   Overflow clear if signed result falls within the bound of
//                 16 bit signed int 
.macro nv_adc16x_mem_immed(addr1, num, result_addr)
{
    lda addr1
    clc
    adc #(num & $00FF)
    sta result_addr
    lda addr1+1
    adc #((num >> 8) & $00FF)
    sta result_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to multiply one unsigned 16 bit value by an 8 bit immed value
// and store the result in another 16bit value.  
// result16_addr = addr1 * num8
// full name: nv_mul16u_mem16u_immed8u
// params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   num is the immeidate 8 bit number to multiply addr1 by 
//   result16_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
//   proc_flags is a bit mask specifying which processor status 
//              flags will be set.  see nv_mul16_x for more info.
// Accum: changes
// X Reg: changes
// Y Reg: unchanged.
.macro nv_mul16u_mem16u_immed8u(addr1, num8, result16_addr, proc_flags)
{
    .if (num8 > 255)
    {
        .error "ERROR - nv_mul16_immed8: num8 too large"
    }
    ldx #num8
    nv_mul16u_mem16u_x8u(addr1, result16_addr, proc_flags)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to multiply one unsigned16 bit value by an 8 bit unsigned
// value in x reg and store result in a 16bit word in memory.  
// This is an unsigned  multiplication.  For example if an operand 
// is $FF its multiplying by 255 not by -1
// full name: nv_mul16u_mem16u_x8u
// Can optionally set overflow and/or zero processor status flags
// macro params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   result16_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
//   proc_flags  set the bits in this 8 bit value to be 
//               one or more (ORed together) of the NV_PROCSTAT_XXX consts
//               The following bits can be checked, and if they 
//               are then the corresponding flag will be set if appropriate
//                  NV_PROCSTAT_OVERFLOW: pass value with this bit set if 
//                                        you want overflow flag to be set
//                                        in the case that the result overflows
//                                        16 bits.  If overflow in status register
//                                        is set after this executes that means 
//                                        the reslt only has the low 16 bits
//                                        of the multiplication result and the
//                                        rest is lost
//                  NV_PROCSTAT_ZERO:     pass value with this bit set if you 
//                                        want the zero flag set in the case 
//                                        were multiplication result is zero.
// params:
//   x reg should be set to the 8 bit number to multiply by prior to 
//         this macro
// Accum: changes
// X Reg: changes
// Y Reg: unchanged
// old name: nv_mul16_x
.macro nv_mul16u_mem16u_x8u(addr1, result16_addr, proc_flags)
{
    .if ((proc_flags & NV_PROCSTAT_OVERFLOW) != 0)
    {   // clear overflow flag 
        clv 
    }
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag then push the flags on stack
        // later we can them off and set appropriately.   
        php  // push on the stack the proc status flags
    }

    cpx #$00
    beq MultByZero
    lda addr1
    beq MultByZero
    nv_store16_immed(scratch_word, $0000)
LoopTop:
    nv_adc16x(addr1, scratch_word, scratch_word)
    .if ((proc_flags & NV_PROCSTAT_OVERFLOW) !=0)
    {   // user cares about overflow so check the carry flag
        bcc NoCarry
        // if there was a carry then we had an overflow
        pla                         // pull proc status from stack to accum
        ora #NV_PROCSTAT_OVERFLOW   // set overflow flag
        pha                         // push updated proc status to stack
    NoCarry:
    }
    dex
    bne LoopTop
 
    nv_xfer16_mem_mem(scratch_word, result16_addr)
    jmp Done

MultByZero:
    nv_store16_immed(result16_addr, $0000)
    .if ((proc_flags & NV_PROCSTAT_ZERO) != 0)
    {
        pla                   // pull the flags from stack
        ora #NV_PROCSTAT_ZERO // set zero flag
        pha                   // push updated flags back to stack
    }
Done:
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag then push the flags on stack
        // later we can them off and set appropriately.   
        plp  // pull new flags from the stack
    }
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to multiply one 16 bit value by an 8 bit value in y reg
// and store the result in another 16bit value.  This is an unsigned
// multiplication.  For example if an operand is $FF its multiplying
// by 255 not by -1
// full name: nv_mul16u_mem16u_y8u
// Can optionally set overflow and/or zero processor status flags
// macro params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
//   proc_flags  set the bits in this 8 bit value to be 
//               one or more (ORed together) of the NV_PROCSTAT_XXX consts
//               The following bits can be checked, and if they 
//               are then the corresponding flag will be set if appropriate
//                  NV_PROCSTAT_OVERFLOW: pass value with this bit set if 
//                                        you want overflow flag to be set
//                                        in the case that the result overflows
//                                        16 bits.  If overflow in status register
//                                        is set after this executes that means 
//                                        the reslt only has the low 16 bits
//                                        of the multiplication result and the
//                                        rest is lost
//                  NV_PROCSTAT_ZERO:     pass value with this bit set if you 
//                                        want the zero flag set in the case 
//                                        were multiplication result is zero.
// params:
//   x reg should be set to the 8 bit number to multiply by prior to 
//         this macro
// Accum: changes
// X Reg: unchanged
// Y Reg: changes
// old name: nv_mul16_y
.macro nv_mul16u_mem16u_y8u(addr1, result_addr, proc_flags)
{
    .if ((proc_flags & NV_PROCSTAT_OVERFLOW) != 0)
    {   // clear overflow flag 
        clv 
    }
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag then push the flags on stack
        // later we can them off and set appropriately.   
        php  // push on the stack the proc status flags
    }

    cpy #$00
    beq MultByZero
    lda addr1
    beq MultByZero
    nv_store16_immed(scratch_word, $0000)
LoopTop:
    nv_adc16x(addr1, scratch_word, scratch_word)
    .if ((proc_flags & NV_PROCSTAT_OVERFLOW) !=0)
    {   // user cares about overflow so check the carry flag
        bcc NoCarry
        // if there was a carry then we had an overflow
        pla                         // pull proc status from stack to accum
        ora #NV_PROCSTAT_OVERFLOW   // set overflow flag
        pha                         // push updated proc status to stack
    NoCarry:
    }
    dey
    bne LoopTop
 
    nv_xfer16_mem_mem(scratch_word, result_addr)
    jmp Done

MultByZero:
    nv_store16_immed(result_addr, $0000)
    .if ((proc_flags & NV_PROCSTAT_ZERO) != 0)
    {
        pla                   // pull the flags from stack
        ora #NV_PROCSTAT_ZERO // set zero flag
        pha                   // push updated flags back to stack
    }
Done:
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag then push the flags on stack
        // later we can them off and set appropriately.   
        plp  // pull new flags from the stack
    }
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// rotate bits right in a 16 bit location in memory
// addr = addr >> num
// full name: nv_lsr16u_mem16u_immed8u
// params: 
//   addr is the address of the lo byte and addr+1 is the MSB
//   num is the nubmer of rotations to do.
// zeros will be rotated in to the high bits
// status flags:
// Carry flag will be set if the last rotation rotated off a 1 from low bit
// Carry flag will be clear if the last rotation rotated off a 0 from low bit
// Use this to divide by 2 or any power of two.
// Accum: unchanged
// X Reg: unchanged
// Y Reg: changes
// status flags: flags change but not reliably set
.macro nv_lsr16u_mem16u_immed8u(addr, num)
{
    .if (num > $FF)
    {
        .error "ERROR - nv_lsr16u_mem16u_immed8u: num8 too large"
    }
    clc
    ldy #num
    beq Done
Loop:
    lsr addr+1
    ror addr
    dey
    bne Loop
Done:
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Rotate bits left in a 16 bit location in memory.
// full name: nv_asl16u_mem16u_immed8u
// params:
//   addr is the address of the LSB and addr+1 is the MSB of the 
//        16 bit unsigned word to rotate
//   num is an immediate value that is the nubmer of rotations to do.
// zeros will be rotated in to the low bits
// Use this to multiply by 2 or any power of two.
// Accum: unchanged
// X Reg: unchanged
// Y Reg: changes see nv_asl16u_mem16u_y8u
// old name: nv_asl16_immed
.macro nv_asl16u_mem16u_immed8u(addr, num)
{
    .if (num > $FF)
    {
        .error "ERROR - nv_asl16u_mem16u_immed8u: num8 too large"
    }
    ldy #num
    nv_asl16u_mem16u_y8u(addr)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Rotate bits left in a 16 bit word in memory.
// Full name: nv_asl16u_mem16u_y8u
// params:
//   addr: is the address of the LSB and addr+1 is the MSB of the
//         word on which to perform the rotation.
//   y reg: must be loaded with the nubmer of rotations to do.
// Zeros will be rotated in to the low bits of 
// Use this to multiply by 2 or any power of two.
// Status Flags:
//   Carry flag set if last rotate from bit high bit of addr's MSB was a 1
//   Carry flag clear if last rotate from bit high bit of addr's MSB was a 0
// Accum: unchanged
// Y reg: changes, will be zero after macro executes
// X reg: unchanged
// old name nv_asl16_y
.macro nv_asl16u_mem16u_y8u(addr)
{
    cpy #0 
    clc       // must clear after the cpy above because cpy changes carry
    beq Done
Loop:
    asl addr
    rol addr+1
    dey
    bne Loop
Done:
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to negate a 16 bit number at addr specified
.macro negate16(addr16, result_addr16)
{
    lda addr16
    eor #$FF
    sta result_addr16

    lda addr16+1
    eor #$FF
    sta result_addr16+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to do twos compliment on a 16 but number in memory
// and place result in specified memory location.
.macro nv_twos_comp_16(addr16, result_addr16)
{
    negate16(addr16, result_addr16)
    nv_adc16x_mem_immed(result_addr16, 1, result_addr16)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline mcaro to subtract contents at addr2 from those at addr1
// result16_adder = addr1 - addr2
// full name: nv_sbc16x_mem16x_mem16x
// Status flags:
//   Carry set if unsigned result is greater than zero, or more generally
//             it does fit in the unsigned 16bit int range (0 - 65535)
//   Carry clear if no carry from MSB occured, ie if the unsigned result
//             is less than zero or more generally does not
//             fit in a 16 bit unsigned int (0 - 65535) 
//   Overflow set: if signed result outside bound of 
//                 16 bit signed int (-32768 and +32767)
//   Overflow clear if signed result falls within the bound of
//                 16 bit signed int 
//   Neg set if result has sign/high bit set
//   Neg clear if result has sign/high bit clear
.macro nv_sbc16(addr1, addr2, result16_addr)
{
    sec
    lda addr1
    sbc addr2
    sta result16_addr
    lda addr1+1
    sbc addr2+1
    sta result16_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inlne macro to store 16 bit immediate value into the word with LSB 
// at lsb_addr
.macro nv_store16_immed(lsb_addr, value)
{
    lda #(value & $00FF)
    sta lsb_addr
    lda #(value >> 8)
    sta lsb_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to move one 16 bit word in memory to another location
// in memory.
// Macro Params:
//   lsb_src_addr: LSB of the source for the copy
//   lsb_dest_addr: LSB of the destination for the copy
// Note: Accum will be modified
//       X and Y registers will be unchanged
.macro nv_xfer16_mem_mem(lsb_src_addr, lsb_dest_addr)
{
    lda lsb_src_addr
    sta lsb_dest_addr
    lda lsb_src_addr+1
    sta lsb_dest_addr+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to add two 16 bit BCD values and store the result in another
// 16bit BCD value.  Carry bit will be set if carry occured.
// full name: nv_bcd_adc16u_mem16u_mem16u
// params:
//   addr1 is the address of the LSB of op1
//   addr2 is the address of the LSB of op2
//   result_addr is the address to store the result.
// Note: clears decimal mode after the addition is done 
// Processor Status flags: 
//   Carry flag will be set if carry from MSB addition (decimal addition)
//           causee carry.  ie if MSB addition was $99 + $01, carry is set
//   Carry flag will be clear if carry from MSB addition (decimal addition)
//           did not cause carry.
//   No other flags are reliably set.
// Accum: changes
// X Reg: No change
// Y Reg: No Change
.macro nv_bcd_adc16(addr1, addr2, result_addr)
{
    sed
    lda addr1
    clc
    adc addr2
    sta result_addr
    lda addr1+1
    adc addr2+1
    sta result_addr+1
    cld
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to add one 16 bit value in memory to an immediate value
// and store the result in another 16 bit value in memory.  
// result_addr = addr1 + num
// full name: nv_bcd_adc16u_mem16u_immed16u
// params:
//   addr1 is the address of the LSB of 16 bit value in memory that
//         must be a valid BCD number.
//   num: is the immeidate 16bit number to add.  It must be a valid BCD 
//        number which is hex values with no letters in it.
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the BCD result.
// Note: clears decimal mode after the addition is done 
// Processor Status flags: 
//   Carry flag will be set if carry from MSB addition (decimal addition)
//           causee carry.  ie if MSB addition was $99 + $01, carry is set
//   Carry flag will be clear if carry from MSB addition (decimal addition)
//           did not cause carry.
//   No other flags are reliably set.
// Accum: changes
// X Reg: No change
// Y Reg: No Change
// old name: nv_bcd_adc16_immed
.macro nv_bcd_adc16_mem_immed(addr1, num, result_addr)
{
    sed
    lda addr1
    clc
    adc #(num & $00FF)
    sta result_addr
    lda addr1+1
    adc #((num >> 8) & $00FF)
    sta result_addr+1
    cld
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline mcaro to subtract 16 bit BCD values.  All ops and result are BCD
// result_addr = addr1 = addr2
// full name: nv_bcd_sbc16u_mem16u_mem16u
// params:
//   addr1: Operand for subtraction.  Must be valid BCD
//   addr2: Operand for subtraction.  Must be valid BCD
//   result_addr: address of word to recieve the result of subtraction.
// Processor Status flags: 
//   Carry flag will be set if no borrow was required from MSB subtraction
//           ie if MSB subtraction was $04 - $01, carry is set
//   Carry flag will be clear if borrow was required from MSB subtraction
//           (decimal subtraction.)  ie $01 - $04 carry is clear
//   No other flags are reliably set.
// Accum: changes
// X Reg: No change
// Y Reg: No Change
.macro nv_bcd_sbc16(addr1, addr2, result_addr)
{
    sed                     // set decimal (BCD) mode
    sec
    lda addr1
    sbc addr2
    sta result_addr
    lda addr1+1
    sbc addr2+1
    sta result_addr+1
    cld                     // clear decimal (BCD) mode 
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline mcaro to subtract 16 bit immediate value from 16 bit 
// value in memory and store result into 16 bit result addr
// result_addr = addr1 - num
// full name: nv_bcd_sbc16u_mem16u_immed16u
// All operands and result are BCD
// Accum: changes
// X Reg: No change
// Y Reg: No Change
.macro nv_bcd_sbc16_mem_immed(addr1, num, result_addr)
{
    sed                         // set decimal (BCD) mode
    sec                         // set carry for subtraction
    lda addr1
    sbc #(num & $00FF)          // subtract LSBs
    sta result_addr             // store LSB of result
    lda addr1+1
    sbc #((num >> 8) & $00FF)   // subtract MSBs
    sta result_addr+1           // store MSB of result
    cld                         // clear decimal (BCD) mode 
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// macro routine to test if one rectangle overlaps another
// This routine will work on rectangles of any size.
// If its known that one rectangle can completely fit inside the other one
// than another then the macro nv_util_check_small_rect_in_big_rect
// rect1_addr: address of a rectangle.  A rectangle is defined by 
//             8 bytes, which are interpreted as two 16 bit xy pairs 
//             as such:
//               x_left: .word 
//               y_top: .word
//               x_right: .word
//               y_bottom: .word
// rect2_addr: address of another rectangle
// load accum to 1 if they overlap or 0 if they do not overlap
.macro nv_check_rect_overlap16(rect1_addr, rect2_addr)
{
    .label r1_left = rect1_addr
    .label r1_top = rect1_addr + 2
    .label r1_right = rect1_addr + 4
    .label r1_bottom = rect1_addr + 6

    .label r2_left = rect2_addr
    .label r2_top = rect2_addr + 2
    .label r2_right = rect2_addr + 4
    .label r2_bottom = rect2_addr + 6

    // this is the algorithm to determine if rects overlap
    // if ((r2.left is between r1.left and r1.right)  or 
    //     (r2.right is between r1.left and r1.right)) and
    //    ((r2.bottom is below r1.top) and (r2.top is above r1.bottom)))
    // then 
    // {
    //    rects overlap
    // }
    // else
    // {
    //    do same comparison with reverse (use r1 for r2 and r2 for r1 in above if)
    // }

    nv_check_range16(r2_left, r1_left, r1_right, false)
    bne OneVertSideBetween
    nv_check_range16(r2_right, r1_left, r1_right, false)
    bne OneVertSideBetween
    jmp TryReverse
OneVertSideBetween:
    nv_blt16(r2_bottom, r1_top, TryReverse)
    nv_bgt16(r2_top, r1_bottom, TryReverse)
    jmp RectOverlap

TryReverse:
    nv_check_range16(r1_left, r2_left, r2_right, false)
    bne OneVertSideBetween2
    nv_check_range16(r1_right, r2_left, r2_right, false)
    bne OneVertSideBetween2
    jmp NoRectOverlap

OneVertSideBetween2:
    nv_blt16(r1_bottom, r2_top, NoRectOverlap)
    nv_bgt16(r1_top, r2_bottom, NoRectOverlap)
    // fall through to RectOverlap

RectOverlap:
    lda #1
    jmp AccumLoaded
NoRectOverlap:
    lda #0

AccumLoaded:

}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// macro to test if one 16 bit number is within a range
// the number to test and the range bounds are 16 bit numbers at 
// specified memory locations.
// macro params:
//   test_num_addr: is the address of LSB of the 16 bit number to test
//   num_high_addr: is the address of the LSB of the 16 bit number that is
//                  the high bound to check 
//   num_low_addr: is the address of the LSB of the 16 bit number that is
//                 the low bound to check
//   inclusive: should be set to true if the bound numbers are considered
//              in range, or false if the bound numbers are outsid the range. 
// accum: will be set to 1 if test num is between num low and num high.
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_check_range16(test_num_addr, num_low_addr, num_high_addr, inclusive)
{
.if (inclusive)
{
    nv_blt16(test_num_addr, num_low_addr, ResultFalse)
    nv_bgt16(test_num_addr, num_high_addr, ResultFalse)
}
else
{
    nv_ble16(test_num_addr, num_low_addr, ResultFalse)
    nv_bge16(test_num_addr, num_high_addr, ResultFalse)
}

ResultTrue:
    lda #1
    jmp AccumLoaded

ResultFalse:
    lda #0

AccumLoaded:
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to check if a point is within a rectangle.
// macro params:
//   p1_x: is the address of the LSB of the 16 bit number that is the X
//         coord of the point to check
//   p1_y: is the address of the LSB of the 16 bit number that is the Y
//         coord of the point to check
//   rect_addr: is the LSB of the block of memory that represents a rect
//              the memory must be layed out like this:
//                  .word with 16 bit value for rect left coord
//                  .word with 16 bit value for rect top coord
//                  .word with 16 bit value for rect right coord
//                  .word with 16 bit value for rect bottom coord
//   Accum: will be set to 1 if point is in rect or to 0 if its not in rect
//   X Reg: unchanged.
//   Y Reg: unchanged.
// Note: a point on the bounds of the rectangle is not in the rectangle
//       for this macro.
.macro nv_check_in_rect16(p1_x, p1_y, rect_addr)
{
    .label r1_left = rect_addr
    .label r1_top = rect_addr + 2
    .label r1_right = rect_addr + 4
    .label r1_bottom = rect_addr + 6

    nv_blt16(p1_x, r1_left, PointNotInRect)
    nv_bgt16(p1_x, r1_right, PointNotInRect)
    nv_blt16(p1_y, r1_top, PointNotInRect)
    nv_bgt16(p1_y, r1_bottom, PointNotInRect)

PointInRect:
    lda #1
    jmp AccumLoaded

PointNotInRect:
    lda #0

AccumLoaded:
}
//
//////////////////////////////////////////////////////////////////////////////