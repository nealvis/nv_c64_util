//////////////////////////////////////////////////////////////////////////////
// nv_math8_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Contains inline macros for 8 bit math related functions.
// importing this file will not allocate any memory for data or code.
// unless the nv_c64_util_data has not already been imported, then it will
// bring that in.
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math8_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_branch8_macs.asm"
#import "nv_math16_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// inline macro to create a bit mask for a bit number between 0 and 7.
// if bit_num_addr contains 0 then the accum will be set to $01
// if bit_num_addr contains 1 then the accum will be set to $02
//   macro parameters:
//     bit_num_addr: is the address of a byte that contains the bit
//                   number for which a bit mask will be created. 
//     negate: is boolean that specifies if the bit mask should be
//             negated.  Normally the mask for bit number 3 would be
//             $08 but if negate is true then the mask will be $F7 
// The bitmask created will be left in accumulator
.macro nv_mask_from_bit_num_mem(bit_num_addr, negate)
{
    lda #$01
    ldx bit_num_addr
    beq MaskDone
    clc 
Loop:
    rol 
    dex
    bne Loop

MaskDone:
    .if (negate == true)
    {
        eor #$FF
    }
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to create a bit mask for a bit number between 0 and 7.
// Macro params
//   negate: is boolean that specifies if the bit mask should be
//           negated.  Normally the mask for bit number 3 would be
//           $08 but if negate is true then the mask will be $F7 
//   accum: must have the bit number for which the mask will be created 
//          upon start and will contain the bitmask upon finish
// The bitmask created will overwrite the bit number in accumulator
.macro nv_mask_from_bit_num_a(negate)
{
    tax
    lda #$01
    cpx #$00 
    beq MaskDone
    clc 
Loop:
    rol 
    dex
    bne Loop

MaskDone:
    .if (negate == true)
    {
        eor #$FF
    }

}

//////////////////////////////////////////////////////////////////////////////
// inline macro to store an immediate 8 bit value in a byte in memory
// macro parameters.
// full name is nv_store8x_mem8x_immed8x
//   addr: the address in which to store the immediate value
//   immed_value: is the value to store ($00 - $FF)
.macro nv_store8x_mem8x_immed8x(addr, immed_value)
{
    .if (immed_value > $00FF)
    {
        .error("Error - nv_store8x_immed: immed_value, was larger than 8 bits")
    }
    lda #immed_value
    sta addr
}
// short name
.macro nv_store8x_immed(addr, immed_value)
{
    nv_store8x_mem8x_immed8x(addr, immed_value)
}


//////////////////////////////////////////////////////////////////////////////
// multiply byte at a memory address with byte in at another mem addr
// and place result in a third (16 bit) memory address
// full name is mul8u_mem8u_mem8u
// params:
//   addr1: addr of first 8bit operand for multiplication
//   addr2: addr of second 8bit operand for multiplication
//   result: address of a 16bit word in memory for the result
//   proc_flags  set the bits in this 8 bit value to be 
//               one or more (ORed together) of the NV_PROCSTAT_XXX consts
// Accum: changes
// X Reg: changes
// Y Reg: changes
.macro mul8u_mem8u_mem8u(addr1, addr2, result, proc_flags)
{
    lda addr2
    nv_mul8_mem_a(addr1, result, proc_flags)
}
// short name
.macro nv_mul8_mem_mem(addr1, addr2, result, proc_flags)
{
    mul8u_mem8u_mem8u(addr1, addr2, result, proc_flags) 
}

//////////////////////////////////////////////////////////////////////////////
// multiply byte at a memory address with an immediate value
// and place result in a third (16 bit) memory address
// full name is nv_mul8u_mem8u_immed8u
// params:
//   addr1: addr of first 8bit operand for multiplication
//   num: the immediate 8 bit value
//   result: address of a 16bit word in memory for the result
//   proc_flags  set the bits in this 8 bit value to be 
//               one or more (ORed together) of the NV_PROCSTAT_XXX consts
// Accum: changes
// X Reg: changes
// Y Reg: changes
.macro nv_mul8u_mem8u_immed8u(addr1, num, result, proc_flags)
{
    .if (num > $00FF)
    {
        .error("Error - nv_mul8_mem_immed: num, was larger than 8 bits")
    }

    lda #num
    nv_mul8_mem_a(addr1, result, proc_flags)
}
// short name
.macro nv_mul8_mem_immed(addr1, num, result, proc_flags)
{
    nv_mul8u_mem8u_immed8u(addr1, num, result, proc_flags)
}

//////////////////////////////////////////////////////////////////////////////
// multiply accum with the 8 bit value at memory address
// and place result in a word at a memory address
// full name is nv_mul8u_mem8u_a8u
// params:
//   addr1: addr of an 8bit unsigned operand for multiplication
//   accum: the other 8bit unsigned operand for multiplication
//   result16: address of a 16bit word in memory for the result
//   proc_flags  set the bits in this 8 bit value to be 
//               one or more (ORed together) of the NV_PROCSTAT_XXX consts
//               The following bits can be set, and if they 
//               are then the corresponding flag will be set if appropriate
//                  NV_PROCSTAT_ZERO:     pass value with this bit set if you 
//                                        want the zero flag set in the case 
//                                        were multiplication result is zero.
//               note that carry can't occur since max 8 bit operands produce
//                    a product that fits in 16 bits so the carry flag will
//                    not be reliably set.  
// Accum: changes
// X Reg: unchanged
// Y Reg: changes
.macro nv_mul8u_mem8u_a8u(addr1, result16, proc_flags)
{
    ldy #0 
    sty result16
    sty result16+1
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag then clear out the scratch_byte
        // which at the end of the macro will have bits set for 
        // anyflags that need to be set.   
        // note that we are assuming y reg is zero because it was set above
        sty scratch_byte
    }


    cmp #$00
    bne AccumNotZero
    // accum is zero if here
    jmp ZeroResult
    
AccumNotZero:
    ldy #$00
    cpy addr1
    bne Addr1NotZero
    // addr2 holds a zero if here
    jmp ZeroResult

Addr1NotZero:
    // start with addr1 
    ldy addr1
    sty result16

    // figure out which power of two fits into the value in accum
    // the accum needs to still have the initial value from before the 
    // macro at this point, if not then we messed up and overwrote it above.
Try128:
    nv_bgt8_immed_a(128, Try64)
    // 256 > accum >= 128 
    sec
    // lda accum  accum already loaded from accum 
    sbc #128  // 128 is only bit 7 set
    ldy #7    // bit 7
    jmp HaveRotateNum 

Try64:
    nv_bgt8_immed_a(64, Try32)
    // 128 > accum >= 64
    sec
    // lda accum  accum already loaded from accum 
    sbc #64   // 64 is only bit 6 set
    ldy #6    // bit 6
    jmp HaveRotateNum 

Try32:
    nv_bgt8_immed_a(32, Try16)
    // 64 > accum >= 32
    sec
    // lda accum accum already loaded from accum 
    sbc #32   // 32 is only bit 5 set
    ldy #5    // bit 5  
    jmp HaveRotateNum 

Try16:
    nv_bgt8_immed_a(16, Try8)
    // 32 > accum >= 16
    sec
    // lda accum  accum already loaded from accum 
    sbc #16   // 16 is only bit 4 set
    ldy #4    // bit 4
    jmp HaveRotateNum 

Try8:
    nv_bgt8_immed_a(8, Try4)
    // 16 > accum >= 8
    sec
    // lda accum  accum already loaded from accum 
    sbc #8    // 8 is only bit 3 set
    ldy #3    // bit 3
    jmp HaveRotateNum 

Try4:
    nv_bgt8_immed_a(4, Try2)
    // 8 > accum >= 4
    sec
    // lda accum  accum already loaded from accum 
    sbc #4    // 4 is only bit 2 set
    ldy #2    // bit 2
    jmp HaveRotateNum 

Try2:
    nv_bgt8_immed_a(2, Try1)
    // 4 > accum >= 2
    sec
    // lda accum  accum already loaded from accum 
    sbc #2    // 2 is only bit 1 set
    ldy #1    // bit 1
    jmp HaveRotateNum 

Try1:
    // 2 > accum and tested for 0 already so,  must be 1
    // so result is ready, MSB already set to 0 and LSB set to addr1
    jmp ResultReady

HaveRotateNum: 
    // when get here y reg should have the number of bits to 
    // rotate left and the accum should have the remaining 
    // number of times multiples of addr1 needs to be added to 
    // the result after its shifted

    // shift left to multiply by the largest power of two
    // that we can which is in the y reg. 
    nv_asl16u_mem16u_y8u(result16)

    // move number of additions to the x reg
    tay

LoopTop:
    beq ResultReady
    nv_adc16x_mem16x_mem8u(result16, addr1, result16)
    dey
jmp LoopTop

ZeroResult:
    .if ((proc_flags & NV_PROCSTAT_ZERO) != 0)
    {   // had zero result and want to set this flag in status reg
        // set it in the scratch byte
        lda scratch_byte 
        ora #NV_PROCSTAT_ZERO
        sta scratch_byte
    }

ResultReady:
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag update flags to set any flag set above
        // which is stored in scratch_byte. 
        .if ((proc_flags & NV_PROCSTAT_ZERO) != 0)
        {
            lda #1 // clear zero flag
        }
        php                 // push processor status register to stack
        pla                 // pull processor status from stack to accum
        ora scratch_byte    // set any flags saved above
        pha                 // push updated flags to the stack
        plp                 // pull updated flags from stack to status reg
    }
}
// short name
.macro nv_mul8_mem_a(addr1, result16, proc_flags)
{
    nv_mul8u_mem8u_a8u(addr1, result16, proc_flags)
}

//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// multiply accum with the 8 bit value at memory address
// and place result in a word at a memory address.
// result = num * accum
// full name is nv_mul8u_immed8u_a8u
// params:
//   accum: addr of first 8bit operand for multiplication
//   num: immediate 8 bit value which is second operand for mult
//   result: address of a 16bit word in memory for the result
//   proc_flags  set the bits in this 8 bit value to be 
//               one or more (ORed together) of the NV_PROCSTAT_XXX consts
//               The following bits can be set, and if they 
//               are then the corresponding flag will be set if appropriate
//                  NV_PROCSTAT_ZERO:     pass value with this bit set if you 
//                                        want the zero flag set in the case 
//                                        were multiplication result is zero.
//               note that carry can't occur since max 8 bit operands produce
//                    a product that fits in 16 bits so the carry flag will
//                    not be reliably set.  
// Accum: changes
// X Reg: unchanged
// Y Reg: changes
.macro nv_mul8u_immed8u_a8u(num, result, proc_flags)
{
    ldy #0 
    sty result
    sty result+1
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag then clear out the scratch_byte
        // which at the end of the macro will have bits set for 
        // anyflags that need to be set.   
        // note that we are assuming y reg is zero because it was set above
        sty scratch_byte
    }

    cmp #$00
    bne AccumNotZero
    // accum is zero if here
    jmp ZeroResult
    
AccumNotZero:
    ldy #$00
    cpy #num
    bne Addr1NotZero
    // num was zero if here
    jmp ZeroResult

Addr1NotZero:
    // start with num 
    ldy #num
    sty result

    // figure out which power of two fits into the value in accum
    // the accum needs to still have the initial value from before the 
    // macro at this point, if not then we messed up and overwrote it above.
Try128:
    nv_bgt8_immed_a(128, Try64)
    // 256 > accum >= 128 
    sec
    // lda accum  accum already loaded from accum 
    sbc #128  // 128 is only bit 7 set
    ldy #7    // bit 7
    jmp HaveRotateNum 

Try64:
    nv_bgt8_immed_a(64, Try32)
    // 128 > accum >= 64
    sec
    // lda accum  accum already loaded from accum 
    sbc #64   // 64 is only bit 6 set
    ldy #6    // bit 6
    jmp HaveRotateNum 

Try32:
    nv_bgt8_immed_a(32, Try16)
    // 64 > accum >= 32
    sec
    // lda accum accum already loaded from accum 
    sbc #32   // 32 is only bit 5 set
    ldy #5    // bit 5  
    jmp HaveRotateNum 

Try16:
    nv_bgt8_immed_a(16, Try8)
    // 32 > accum >= 16
    sec
    // lda accum  accum already loaded from accum 
    sbc #16   // 16 is only bit 4 set
    ldy #4    // bit 4
    jmp HaveRotateNum 

Try8:
    nv_bgt8_immed_a(8, Try4)
    // 16 > accum >= 8
    sec
    // lda accum  accum already loaded from accum 
    sbc #8    // 8 is only bit 3 set
    ldy #3    // bit 3
    jmp HaveRotateNum 

Try4:
    nv_bgt8_immed_a(4, Try2)
    // 8 > accum >= 4
    sec
    // lda accum  accum already loaded from accum 
    sbc #4    // 4 is only bit 2 set
    ldy #2    // bit 2
    jmp HaveRotateNum 

Try2:
    nv_bgt8_immed_a(2, Try1)
    // 4 > accum >= 2
    sec
    // lda accum  accum already loaded from accum 
    sbc #2    // 2 is only bit 1 set
    ldy #1    // bit 1
    jmp HaveRotateNum 

Try1:
    // 2 > accum and tested for 0 already so,  must be 1
    // so result is ready, MSB already set to 0 and LSB set to num
    jmp ResultReady

HaveRotateNum: 
    // when get here y reg should have the number of bits to 
    // rotate left and the accum should have the remaining 
    // number of times multiples of num needs to be added to 
    // the result after its shifted

    // shift left to multiply by the largest power of two
    // that we can which is in the y reg. 
    nv_asl16u_mem16u_y8u(result)

    // move number of additions to the x reg
    tay

LoopTop:
    beq ResultReady
    nv_adc16x_mem_immed(result, num, result)
    dey
jmp LoopTop
ZeroResult:
    .if ((proc_flags & NV_PROCSTAT_ZERO) != 0)
    {   // had zero result and want to set this flag in status reg
        // set it in the scratch byte
        lda scratch_byte 
        ora #NV_PROCSTAT_ZERO
        sta scratch_byte
    }


ResultReady:
    .if (proc_flags != NV_PROCSTAT_NONE)
    {   // if we care about any flag update flags to set any flag set above
        // which is stored in scratch_byte. 
        .if ((proc_flags & NV_PROCSTAT_ZERO) != 0)
        {
            lda #1 // clear zero flag
        }
        php                 // push processor status register to stack
        pla                 // pull processor status from stack to accum
        ora scratch_byte    // set any flags saved above
        pha                 // push updated flags to the stack
        plp                 // pull updated flags from stack to status reg
    }
}
// short name
.macro nv_mul8_immed_a(num, result, proc_flags)
{
    nv_mul8u_immed8u_a8u(num, result, proc_flags)
}

//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to perform twos compliment on accum.
// full name is nv_twos_comp8x_a8x
// note: that twos compliment on $80 (-128, the min neg value)
//       is $80 (itself, since +128 is unrepresentable in 8bits).  
//       The consumer of this macro should check for that case
// accum: changed to hold the twos compliment of what it held when called
// x reg: unchanged
// y reg: unchanged
.macro nv_twos_comp8x_a8x()
{
    eor #$FF
    clc
    adc #$01
}
// short name
.macro nv_twos_comp8x_a()
{
    nv_twos_comp8x_a8x()
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to do an in place twos compliment on the 8 bit value 
// at a memory addr.
// full name is nv_twos_comp8x_mem8x
// macro params: 
//   addr: the memory address to a byte that holds the value to perform
//         the twos compliment on.  After the macro executes this
//         byte will be the twos compliment of the value it was prior
// Note: that twos compliment of -128 will be -128 since +128 can't be
//       represented in 8 signed bits of twos compliment encoded numbers.
// Accum: changes
// x reg: unchanged
// y reg: unchanged
.macro nv_twos_comp8x_mem8x(addr)
{
    lda addr
    eor #$FF
    sta addr
    inc addr
}
// short name
.macro nv_twos_comp8x_mem(addr)
{
    nv_twos_comp8x_mem8x(addr)
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to do subtraction between two signed 8bit values, both 
// in memory.
// full name is nv_sbc8x_mem8x_mem8x
// result_addr = addr1 - addr2
// Params: 
//   addr1: address of op1 for subtraction
//   addr2: address of op2 for subtraction
//   restult_addr: address to place result of subtration 
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
// status flags: 
//   Carry will be clear when result, assuming unsigned args, is less than 0
//         Can think of it as: If interpreting all args as unsigned and 
//         addr2 > addr1 then carry will be clear because borrow will be needed
//   Carry will set when result between 0 and 255 (interpreting args unsigned)
//         Can think of it as: if interpreting all args as unsigned then carry
//         will be set when addr1 >= addr2 because no borrow is needed.
//   Overflow clear when result is within -128 and +127
//            ex: $02 - $01 = $01   // 2-1=1, V clear: $03 in range
//   Overflow set when the result is outside twos comp range of -128 and 127 
//            ex: $80 - $01 = $80   // -128-1=-129, V set outside range 
.macro nv_sbc8x_mem8x_mem8x(addr1, addr2, result_addr)
{
    sec
    lda addr1
    sbc addr2
    sta result_addr  // sta doesn't modify status register
}
// short name
.macro nv_sbc8x(addr1, addr2, result_addr)
{
    nv_sbc8x_mem8x_mem8x(addr1, addr2, result_addr)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to do subtraction between two 8bit values, one in memory 
// and the other is an immediate number
// result_addr = addr1 - num
// full name is nv_sbc8x_mem8x_immed8x
// Params: 
//   addr1: address of op1 for subtraction
//   num: the immediate number to use as op2 for subtraction
//   restult_addr: address to place result of subtration 
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
// status flags: 
//   Carry will be clear when result, assuming unsigned args, is less than 0
//         Can think of it as: If interpreting all args as unsigned and 
//         num > num then carry will be clear because borrow will be needed
//   Carry will set when result between 0 and 255 (interpreting args unsigned)
//         Can think of it as: if interpreting all args as unsigned then carry
//         will be set when addr1 >= num because no borrow is needed.
//   Overflow clear when result is within -128 and +127
//            ex: $02 - $01 = $01   // 2-1=1, V clear: $03 in range
//   Overflow set when the result is outside twos comp range of -128 and 127 
//            ex: $80 - $01 = $80   // -128-1=-129, V set outside range 
.macro nv_sbc8x_mem8x_immed8x(addr1, num, result_addr)
{
    sec
    lda addr1
    sbc #num
    sta result_addr  // sta doesn't modify status register
}
// short name
.macro nv_sbc8x_mem_immed(addr1, num, result_addr)
{
    nv_sbc8x_mem8x_immed8x(addr1, num, result_addr)
}
//
//////////////////////////////////////////////////////////////////////////////

