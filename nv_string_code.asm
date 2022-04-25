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
nv_str1_ptr: .word $0000
nv_str2_ptr: .word $0000
nv_str_save_block: .word $0000


//////////////////////////////////////////////////////////////////////////////
// inline macro to fill a string with the decimal representation of the
// specified fp124 value.  Carry flag determines if its interpreted as
// signed or unsigned.
//   carry flag: set   -> signed fp124
//               clear -> unsigned fp124
//   fp124_addr: is the address of the LSB of the fp124 value
//               that will be interpreted as a signed or usigned and
//               converted to string.
//   str_ptr: is the pointer to the address of the first char of string
//             to build up.  It must point to area in memory big enough 
//             to hold all the
//             digits on both sides of decimal, plus a sign, plus a decimal 
//             plus a null. (11 bytes for fp124s)
.macro nv_str_fp124x_to_str_sr(fp124_addr, str_ptr)
{
    // start with empty string
    lda #$00
    nv_store_a_to_mem_ptr(str_ptr, nv_str_save_block)

    // will call NvStrCatChar_a subroutine below so must
    // set the nv_str1_ptr to the same address as passed pointer
    nv_xfer16_mem_mem(str_ptr, nv_str1_ptr) 

    lda fp124_addr+1

    // if carry is clear then its an unsigned fp124
    bcc DoneWithSign            // unsigned number so skip sign stuff
    bpl DoneWithSign            // signed but positive number sign is 0

    // if get here its a signed number and its negative
IsNegative:
    // start the string by concatenating a minus sign
    lda #$2D                // the - sign
    jsr NvStrCatChar_a      // call sr to concatenate char in Accum to str
 
    // setup scratch word with the value left of decimal point
    lda fp124_addr + 1
    and #$7F                // its neg signed so mask off the sign bit
DoneWithSign:               
    // accum now has MSB of the fp124x with sign masked off if needed
    sta scratch_word+1
    lda fp124_addr
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
    lda fp124_addr
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
// representation of a fp124 value.  The fp124 value can be signed or
// unsigned the carry flag will determine how its intepreted
// Before calling:
//   carry flag: set   -> signed fp124
//               clear -> unsigned fp124
//   nv_fp124_for_to_str: Set to the fp124 value to convert
//   nv_str1_ptr: setup to point to the string.  If the string is
//                at a label str_addr then the setup code could be:
//                  lda #<str_addr
//                  sta nv_str1_ptr
//                  lda #>str_addr
//                  sta nv_str1_ptr+1
// After calling: 
//   The null terminated string will be in the string at the address 
//   pointed to by nv_str1_ptr.
NvStrFP124xToStr:
  nv_str_fp124x_to_str_sr(nv_fp124_for_to_str, nv_str1_ptr)
  // rts is within macro above

nv_fp124_for_to_str: .word $0000


//
////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//
NvStrTrimEnd:
{
    nv_str_trim_end_char_a_sr(nv_str1_ptr, trim_end_save_block)
    // rts is in macro above

trim_end_save_block:
    .word $0000

}
//
//////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
// Subroutine to call to concatenate the char in accumulator to the
// null terminated string at the address pointed to by the specified 
// pointer.
// Before calling:
//   nv_str1_ptr: setup to point to the str1.  If the string is
//                at a label str_addr then the setup code could be:
//                  lda #<str_addr
//                  sta nv_str1_ptr
//                  lda #>str_addr
//                  sta nv_str1_ptr+1
//   nv_str2_ptr: setup to point to the str2.  If the string is
//                at a label str2_addr then the setup code could be:
//                  lda #<str2_addr
//                  sta nv_str2_ptr
//                  lda #>str2_addr
//                  sta nv_str2_ptr+1
// After calling: The flags will be set as if cmp done
//                Z flag set if strings are equal
//                Carry flag set when str2 is less than or equal to str1
//                Carry flag is clear when str2 is greater than str1
NvStrCmp:
{
  nv_str_cmp_sr(nv_str1_ptr, nv_str2_ptr, nv_str_save_block)
  // rts is in macro above.

  nv_str_cmp_save_block: .word $0000
}

//
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// Subroutine to call to copy one string to another. 
// The source string must be null terminated and the destination
// string will be null terminated upon return.
// The destination string pointer must be large enough to accomodate
// the source string including the terminating null
// Before calling:
//   nv_str1_ptr: setup to point to the source string.  If the src str is
//                at a label str_addr then the setup code could be:
//                  lda #<str_addr
//                  sta nv_str1_ptr
//                  lda #>str_addr
//                  sta nv_str1_ptr+1
//   nv_str2_ptr: setup to point to the destination string.  If the dest str
//                is at a label str2_addr then the setup code could be:
//                  lda #<str2_addr
//                  sta nv_str2_ptr
//                  lda #>str2_addr
//                  sta nv_str2_ptr+1
NvStrCpy:
{
    nv_str_cpy_sr(nv_str1_ptr, nv_str2_ptr, nv_str_cpy_save_block)
    // note that rts is in above macro

    nv_str_cpy_save_block: .word $0000
}