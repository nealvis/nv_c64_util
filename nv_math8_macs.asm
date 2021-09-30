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
// if bit_num_addr contains 0 then the accum will be $01
// if bit_num_addr contains 1 then the accum will be $02
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
// macro parameters
//   addr: the address in which to store the immediate value
//   immed_value: is the value to store ($00 - $FF)
.macro nv_store8_immed(addr, immed_value)
{
    .if (immed_value > $00FF)
    {
        .error("Error - nv_store8_immed: immed_value, was larger than 8 bits")
    }
    lda #immed_value
    sta addr
}


//////////////////////////////////////////////////////////////////////////////
// multiply byte at a memory address with byte in at another mem addr
// and place result in a third (16 bit) memory address
// params:
//   addr1: addr of first 8bit operand for multiplication
//   addr2: addr of second 8bit operand for multiplication
//   result: address of a 16bit word in memory for the result
// Accum: changes
// X Reg: changes
// Y Reg: changes
.macro nv_mul8_mem_mem(addr1, addr2, result)
{
    lda #0 
    sta result
    sta result+1
    nv_beq8_immed_far(addr1, $00, ResultReady)
    nv_beq8_immed_far(addr2, $00, ResultReady)

    // start with addr1 
    lda addr1
    sta result

    // figure out which power of two fits into addr2
    lda addr2
Try128:
    nv_bgt8_immed_a(128, Try64)
    // 256 > addr2 >= 128 
    sec
    // lda addr2  accum already loaded from addr2 
    sbc #128  // 128 is only bit 7 set
    ldy #7    // bit 7
    jmp HaveRotateNum 

Try64:
    nv_bgt8_immed_a(64, Try32)
    // 128 > addr2 >= 64
    sec
    // lda addr2  accum already loaded from addr2 
    sbc #64   // 64 is only bit 6 set
    ldy #6    // bit 6
    jmp HaveRotateNum 

Try32:
    nv_bgt8_immed_a(32, Try16)
    // 64 > addr2 >= 32
    sec
    // lda addr2 accum already loaded from addr2 
    sbc #32   // 32 is only bit 5 set
    ldy #5    // bit 5  
    jmp HaveRotateNum 

Try16:
    nv_bgt8_immed_a(16, Try8)
    // 32 > addr2 >= 16
    sec
    // lda addr2  accum already loaded from addr2 
    sbc #16   // 16 is only bit 4 set
    ldy #4    // bit 4
    jmp HaveRotateNum 

Try8:
    nv_bgt8_immed_a(8, Try4)
    // 16 > addr2 >= 8
    sec
    // lda addr2  accum already loaded from addr2 
    sbc #8    // 8 is only bit 3 set
    ldy #3    // bit 3
    jmp HaveRotateNum 

Try4:
    nv_bgt8_immed_a(4, Try2)
    // 8 > addr2 >= 4
    sec
    // lda addr2  accum already loaded from addr2 
    sbc #4    // 4 is only bit 2 set
    ldy #2    // bit 2
    jmp HaveRotateNum 

Try2:
    nv_bgt8_immed_a(2, Try1)
    // 4 > addr2 >= 2
    sec
    // lda addr2  accum already loaded from addr2 
    sbc #2    // 2 is only bit 1 set
    ldy #1    // bit 1
    jmp HaveRotateNum 

Try1:
    // 2 > addr2 and tested for 0 already so,  must be 1
    // so result is ready, MSB already set to 0 and LSB set to addr1
    jmp ResultReady

HaveRotateNum: 
    // when get here y reg should have the number of bits to 
    // rotate left and the accum should have the remaining 
    // number of times multiples of addr1 needs to be added to 
    // the result after its shifted

    // shift left to multiply by the largest power of two
    // that we can which is in the y reg. 
    nv_asl16_y(result)

    // move number of additions to the x reg
    tax

LoopTop:
    beq ResultReady
    nv_adc16_8unsigned(result, addr1, result)
    dex
jmp LoopTop

ResultReady:
}

//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// multiply byte at a memory address with an immediate value
// and place result in a third (16 bit) memory address
// params:
//   addr1: addr of first 8bit operand for multiplication
//   num: immediate value which is the second  8bit operand for mult
//   result: address of a 16bit word in memory for the result
// Accum: changes
// X Reg: changes
// Y Reg: changes
.macro nv_mul8_mem_immed(addr1, num, result)
{
    .if (num > $00FF)
    {
        .error("Error - nv_mul8_mem_immed: num, was larger than 8 bits")
    }

    lda #0 
    sta result
    sta result+1
    nv_beq8_immed_far(addr1, $00, ResultReady)
    nv_beq8_immed_a_far(num, ResultReady)

    // start with addr1 
    lda addr1
    sta result

    // figure out which power of two fits into #num
    lda #num
Try128:
    nv_bgt8_immed_a(128, Try64)
    // 256 > num >= 128 
    sec
    // lda #num  accum already loaded from #num 
    sbc #128  // 128 is only bit 7 set
    ldy #7    // bit 7
    jmp HaveRotateNum 

Try64:
    nv_bgt8_immed_a(64, Try32)
    // 128 > num >= 64
    sec
    // lda #num  accum already loaded from #num 
    sbc #64   // 64 is only bit 6 set
    ldy #6    // bit 6
    jmp HaveRotateNum 

Try32:
    nv_bgt8_immed_a(32, Try16)
    // 64 > addr2 >= 32
    sec
    // lda #num accum already loaded from #num 
    sbc #32   // 32 is only bit 5 set
    ldy #5    // bit 5  
    jmp HaveRotateNum 

Try16:
    nv_bgt8_immed_a(16, Try8)
    // 32 > num >= 16
    sec
    // lda #num  accum already loaded from #num 
    sbc #16   // 16 is only bit 4 set
    ldy #4    // bit 4
    jmp HaveRotateNum 

Try8:
    nv_bgt8_immed_a(8, Try4)
    // 16 > #num >= 8
    sec
    // lda #num  accum already loaded from #num 
    sbc #8    // 8 is only bit 3 set
    ldy #3    // bit 3
    jmp HaveRotateNum 

Try4:
    nv_bgt8_immed_a(4, Try2)
    // 8 > num >= 4
    sec
    // lda #num  accum already loaded from #num 
    sbc #4    // 4 is only bit 2 set
    ldy #2    // bit 2
    jmp HaveRotateNum 

Try2:
    nv_bgt8_immed_a(2, Try1)
    // 4 > num >= 2
    sec
    // lda #num  accum already loaded from #num 
    sbc #2    // 2 is only bit 1 set
    ldy #1    // bit 1
    jmp HaveRotateNum 

Try1:
    // 2 > addr2 and tested for 0 already so,  must be 1
    // so result is ready, MSB already set to 0 and LSB set to addr1
    jmp ResultReady

HaveRotateNum: 
    // when get here y reg should have the number of bits to 
    // rotate left and the accum should have the remaining 
    // number of times multiples of addr1 needs to be added to 
    // the result after its shifted

    // shift left to multiply by the largest power of two
    // that we can which is in the y reg. 
    nv_asl16_y(result)

    // move number of additions to the x reg
    tax

LoopTop:
    beq ResultReady
    nv_adc16_8unsigned(result, addr1, result)
    dex
jmp LoopTop

ResultReady:
}

//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to perform twos compliment on accum
// note: that twos compliment on $80 (-128, the min neg value)
//       is $80 (itself, since +128 is unrepresentable in 8bits).  
//       The consumer of this macro should check for that case
// accum: changed to hold the twos compliment of what it held when called
// x reg: unchanged
// y reg: unchanged
.macro nv_twos_comp8_a()
{
    eor #$FF
    clc
    adc #$01
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to do an in place twos compliment on the 8 bit value 
// at a memory addr
// macro params: 
//   addr: the memory address to a byte that holds the value to perform
//         the twos compliment on.  After the macro executes this
//         byte will be the twos compliment of the value it was prior
// Note: that twos compliment of -128 will be -128 since +128 can't be
//       represented in 8 signed bits of twos compliment encoded numbers.
// Accum: changes
// x reg: unchanged
// y reg: unchanged
.macro nv_twos_comp8_mem(addr)
{
    lda addr
    eor #$FF
    sta addr
    inc addr
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to do subtraction between two 8bit values, both 
// in memory.
// result_addr = addr1 - addr2
// Params: 
//   addr1: address of op1 for subtraction
//   addr2: address of op2 for subtraction
//   restult_addr: address to place result of subtration 
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_sbc8(addr1, addr2, result_addr)
{
    sec
    lda addr1
    sbc addr2
    sta result_addr  // sta doesn't modify status register
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to do subtraction between two 8bit values, one in memory 
// and the other is an immediate number
// result_addr = addr1 - num
// Params: 
//   addr1: address of op1 for subtraction
//   num: the immediate number to use as op2 for subtraction
//   restult_addr: address to place result of subtration 
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_sbc8_mem_immed(addr1, num, result_addr)
{
    sec
    lda addr1
    sbc #num
    sta result_addr  // sta doesn't modify status register
}
//
//////////////////////////////////////////////////////////////////////////////

