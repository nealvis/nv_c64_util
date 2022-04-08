//////////////////////////////////////////////////////////////////////////////
// nv_string_code.asm
// Copyright(c) 2022 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Contains string related subroutines (and some supporting macros) and data
//
#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif
// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_string_macs.asm"
#import "nv_math16_macs.asm"
#import "nv_math124_macs.asm"

// pointer to use for all string subroutines
nv_str1_ptr: .word $00
nv_str_save_block: .word $00


//////////////////////////////////////////////////////////////////////////////
// inline macro to fill a string with the decimal representation of the
// specified fp124s value.
//   fp124s_low_byte_addr: is the address of the low byte of the word
//                         that will be interpreted as a signed 12.4 fixed 
//                         point num and printed
//   str_ptr: is the pointer to the address of the first char of string
//             to build up.  It must point to area in memory big enough 
//             to hold all the
//             digits on both sides of decimal, plus a sign, plus a decimal 
//             plus a null. (11 bytes for fp124s)
.macro nv_str_fp124s_to_str_sr(fp124s_low_byte_addr, str_ptr)
{
    // start with empty string
    lda #$00
    nv_store_a_to_mem_ptr(str_ptr, nv_str_save_block)

    // will call NvStrCatChar_a subroutine below so must
    // set the nv_str1_ptr to the same address as passed pointer
    nv_xfer16_mem_mem(str_ptr, nv_str1_ptr) 

    lda fp124s_low_byte_addr+1
    bpl IsPositive
IsNegative:
    lda #$2D                // the - sign
    jsr NvStrCatChar_a      // call sr to concatenate char in Accum to str

IsPositive:
    // setup scratch word with the value left of point
    lda fp124s_low_byte_addr + 1
    and #$7F                        // mask off the sign bit
    sta scratch_word+1
    lda fp124s_low_byte_addr
    sta scratch_word
    nv_lsr16u_mem16u_immed8u(scratch_word, 4)

    ldy #0
ThousandsTop:
    nv_blt16_immed(scratch_word, 1000, DoneThousands)
    // count 1000s in y reg
    iny
    nv_sbc16_mem_immed(scratch_word, 1000, scratch_word)
    jmp ThousandsTop

DoneThousands:
    // Y reg has number of thousands in it
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    ldy #0
HundredsTop:
    nv_blt16_immed(scratch_word, 100, DoneHundreds)
    // count 100s in y reg
    iny
    nv_sbc16_mem_immed(scratch_word, 100, scratch_word)
    jmp HundredsTop
DoneHundreds:

    // y reg has number of hundreds in it
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    ldy #0
TensTop:
    nv_blt16_immed(scratch_word, 10, DoneTens)
    // count 10s in y reg
    iny
    nv_sbc16_mem_immed(scratch_word, 10, scratch_word)
    jmp TensTop
DoneTens:

    // y reg has number of tens in it
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    ldy #0
OnesTop:
    nv_blt16_immed(scratch_word, 1, DoneOnes)
    // count 1s in y reg
    iny
    nv_sbc16_mem_immed(scratch_word, 1, scratch_word)
    jmp OnesTop
DoneOnes:

    // y reg has number of ones in it
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    // add decimal point to string
    lda #$2E                // decimal point char to accum
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    // zero out the scratch word.  we will use this as a bcd
    // value that is the number on the right of decimal point
    nv_store16_immed(scratch_word, 0)

    // setup Y register with the low 4 bits of the fp124
    lda fp124s_low_byte_addr
    and #$0F
    tay
TopRight:
    cpy #0
    beq DoneRight
    // add the smallest decimal value to our scratch bcd 16 bit value
    nv_bcd_adc16_mem_immed(scratch_word, $0625, scratch_word)
    dey
    jmp TopRight
DoneRight:    
    // now scratch_word has the BCD for the right of decimal
    // concatenate each digit 

    // first digit right of decimal
    lda scratch_word+1
    lsr 
    lsr 
    lsr
    lsr
    tay
    // y reg has first digit to right of decimal its in range 0-9
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    // second digit to right of decimal
    lda scratch_word+1
    and #$0F
    tay
    // y reg has second digit to right of decimal its in range 0-9
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

    // third digit to right of decimal
    lda scratch_word
    lsr 
    lsr 
    lsr
    lsr
    tay
    // y reg has third digit to right of decimal its in range 0-9
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str


    // Forth digit to right of decimal
    lda scratch_word
    and #$0F
    tay
    // y reg has second digit to right of decimal its in range 0-9
    lda hex_digit_lookup, y
    jsr NvStrCatChar_a      // call sr to concatenate char in A to str

Done:
    rts
}
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
//  Subroutines to call below here
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// Subroutine to call to concatenate the char in accumulator to the
// null terminated string at the address pointed to by the specified 
// pointer.
// Before calling:
//   Accum: load with the character to concat to string
//   nv_str1_ptr: setup to point to the string.  If the string is
//                at a label str_addr then the setup code could be:
//                  lda #<str_addr
//                  sta nv_str1_ptr
//                  lda #>str_addr
//                  sta nv_str1_ptr+1
// After calling: 
//   The char will be concatenated to the string pointed to by
//   nv_str1_ptr.
NvStrCatChar_a:
  nv_str_cat_char_a_sr(nv_str1_ptr, nv_str_save_block)
//
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// Subroutine to call to fill a string with the decimal string 
// representation of a fp124s value
// Before calling:
//   nv_fp124s_for_to_str: Set to the fp124s value to convert
//   nv_str1_ptr: setup to point to the string.  If the string is
//                at a label str_addr then the setup code could be:
//                  lda #<str_addr
//                  sta nv_str1_ptr
//                  lda #>str_addr
//                  sta nv_str1_ptr+1
// After calling: 
//   The null terminated string will be in the string at the address 
//   pointed to by nv_str1_ptr.
NvStrFP124sToStr:
  nv_str_fp124s_to_str_sr(nv_fp124s_for_to_str, nv_str1_ptr)
  // rts is within macro above

nv_fp124s_for_to_str: .word $0000


//
////////////////////////////////////////////////////////////////////////

