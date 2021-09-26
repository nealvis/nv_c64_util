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
// multiply byte at a memory address with byte in accum
// result is in accum
.macro nv_mul8(addr)
{
    .error ("ERROR - nv_mul8: not implemented")
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// multiply the contents of the accum with the immediate
// number and put result in accum
.macro nv_mul8_immed(num)
{
    .error ("ERROR - nv_mul8_immediate: not implemented")
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to do twos compliment on accum
.macro nv_twos_comp8_accum()
{
    eor #$FF
    clc
    adc #$01
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to do twos compliment on accum
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
// inline macro to do twos compliment on accum
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_sbc8(addr1, addr2, result_addr)
{
    sec
    lda addr1
    sbc addr2
    sta result_addr
}
//
//////////////////////////////////////////////////////////////////////////////
