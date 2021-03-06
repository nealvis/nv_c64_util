//////////////////////////////////////////////////////////////////////////////
// nv_screen_code.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Contains screen related subroutines (and some supporting macros) and data
//
#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif
// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_screen_macs.asm"
#import "nv_math16_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to poke chars for a string to screen memory
// parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of string.
//           this string must be zero terminated.
.macro nv_screen_poke_str_sr()
{
    // two zero page bytes to use as a pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC
    
    // save the zero page bytes that we use
    lda ZERO_PAGE_LO 
    sta save_zero_lo
    lda ZERO_PAGE_HI
    sta save_zero_hi

    //.var screen_poke_start = SCREEN_START + (40*row) + col 
    nv_store16_immed(screen_poke_start, SCREEN_START)
    lda nv_a8
    sta row_counter  // counter starts with row number
    beq DoneAddingRows
RowLoop:
    nv_adc16x_mem_immed(screen_poke_start, 40, screen_poke_start)
    dec row_counter
    bne RowLoop
DoneAddingRows:

    // now add the column
    nv_adc16x_mem16x_mem8u(screen_poke_start, nv_b8, screen_poke_start)

    // now screen_poke_start contains addr of the first screen
    // char to poke

    ldy #0                  // use x reg as loop index start at 0
DirectLoop:
    // load pointer to string base
    lda nv_a16 
    sta ZERO_PAGE_LO
    lda nv_a16+1
    sta ZERO_PAGE_HI

    // load byte from string
    //lda nv_a16,x            // put a byte from string into accum
    lda (ZERO_PAGE_LO),y

    beq Done                // if the byte was 0 then we're done

    // load zero page pointer to point to first char to write
    ldx screen_poke_start 
    stx ZERO_PAGE_LO
    ldx screen_poke_start+1
    stx ZERO_PAGE_HI

    // store byte to screen memory
    //sta screen_poke_start,x // Store the byte to screen
    sta (ZERO_PAGE_LO),y

    iny                     // inc to next byte and next screen location 
    jmp DirectLoop          // Go back for next byte
Done:
    // restore the zero page bytes that we used 
    lda save_zero_hi
    sta ZERO_PAGE_HI
    lda save_zero_lo
    sta ZERO_PAGE_LO
    rts

screen_poke_start:    
    .word 0
row_counter: 
    .word 0
save_zero_lo:
    .byte 0
save_zero_hi:
    .byte 0
}


//////////////////////////////////////////////////////////////////////////////
// Subroutine macro to print the hex value of a byte in memory to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c8: the byte to print should be loaded here
//   nv_d8: set to 1 to include dollar sign
.macro nv_screen_poke_hex_byte_sr()
{
    ldx #0
    lda nv_d8
    beq NoDollar 
YesDollar:
    lda #$24                // dollar sign
    sta temp_hex_str, x
    inx
NoDollar:
    stx nv_g8

    lda nv_c8
    tay
    ror 
    ror 
    ror 
    ror  
    and #$0f
    tax
    lda hex_digit_lookup_poke, x  // load Accum with char to print
    ldx nv_g8
    sta temp_hex_str, x           // copy char to temp str
    inc nv_g8
    tya
    and #$0f
    tax
    lda hex_digit_lookup_poke, x
    ldx nv_g8
    sta temp_hex_str, x
    lda #0
    inx
    sta temp_hex_str, x

    //   nv_a8: row position, already loaded
    //   nv_b8: col position, already loaded
    //   nv_a16: copy addr of temp_hex_str to nv_a16.
    lda #<temp_hex_str
    sta nv_a16 
    lda #>temp_hex_str
    sta nv_a16+1

    jsr NvScreenPokeStr

    rts
}

//////////////////////////////////////////////////////////////////////////////
// Subroutine macro to print the hex value of a byte in memory to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c16: the byte to print should be loaded here
//   nv_d8: set to 1 to include dollar sign
.macro nv_screen_poke_hex_word_sr()
{
    // set nv_c8 with high byte first
    lda nv_c16+1
    sta nv_c8
    jsr NvScreenPokeHexByte

    // now load nv_c8 with low byte to print
    lda nv_c16
    sta nv_c8

    // save d8
    lda nv_d8
    sta save_d8
    beq NoDollar 
YesDollar:
    inc nv_b8

NoDollar:
    inc nv_b8
    inc nv_b8

    // set d8 with 0 for no dollar for LSB
    lda #0
    sta nv_d8

    jsr NvScreenPokeHexByte

    // restore d8 with dollar flag
    lda save_d8
    sta nv_d8
    bne StillNoDollar   // now restore the nv_b8 by dec
StillYesDollar:
    dec nv_b8           // decrement 1 extra time if dollar
StillNoDollar:
    dec nv_b8           // dec 2 times regardless of dollar
    dec nv_b8           // now it should be same as when called.
    rts

    // subroutine variables
    save_d8: .byte 0
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the fp124 value at the address given.
// it will be interpreted as signed or unsigned based on carry flag
//   carry flag: set   -> signed fp124
//               clear -> unsigned fp124 
//   fp124x_addr: is the address of the LSB of the fp124
//                to print
//   str_addr: is the address of the string to build up with decimal
//             digits to print. It must be big enough to hold all the
//             digits on both sides of decimal, plus a sign, plus a decimal 
//             plus a null. (11 bytes for fp124s)
.macro nv_screen_print_dec_fp124x_sr(fp124x_addr, str_addr)
{
    // start with empty string
    lda #$00
    sta str_addr

    // setup the string pointer for the string subroutines
    lda #<str_addr
    sta nv_str1_ptr
    lda #>str_addr
    sta nv_str1_ptr+1

    // copy the fp124s value specified to the one that the to string
    // routine uses when converting to string 
    nv_xfer124_mem_mem(fp124x_addr, nv_fp124_for_to_str)

    // the parameters already setup, now call subroutine that converts to str
    // Note: the carry flag must stay as it was at the top of the macro
    //       all the way to here
    jsr NvStrFP124xToStr
 
    // now trim the trailing 0s
    lda #<str_addr
    sta nv_str1_ptr
    lda #>str_addr
    sta nv_str1_ptr+1
    lda #$30                // trim trailing zeros ($30 is '0')
    jsr NvStrTrimEnd
    lda #'.'                // trim trailing decimal points
    jsr NvStrTrimEnd


    // str_addr should contain the string, so print it
    nv_screen_print_str(str_addr)

    rts
}




//////////////////////////////////////////////////////////////////////////////
// Instantiations of macros from above go below here
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of string.
//           this string must be zero terminated.
NvScreenPokeStr:
    nv_screen_poke_str_sr()


//////////////////////////////////////////////////////////////////////////////
// Subroutine to print the hex value of a byte in specific memory location
// to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c8: the byte to print should be loaded here
//   nv_d8: set to 1 to include dollar sign
NvScreenPokeHexByte:
    nv_screen_poke_hex_byte_sr()


//////////////////////////////////////////////////////////////////////////////
// Subroutine to print the hex value of a byte in specific memory location
// to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c16: the word to print should be loaded here
//   nv_d8: set to 1 to include dollar sign
NvScreenPokeHexWord:
    nv_screen_poke_hex_word_sr()

//////////////////////////////////////////////////////////////////////////////
// subroutine to poke a char to a location on the screen
// params:
//   X Reg: screen column
//   Y Reg: screen row
//   Accum: char to poke
NvScreenPokeChar_xya:
    nv_screen_poke_char_xya()
    rts


//////////////////////////////////////////////////////////////////////////////
// subroutine to poke a char to a list of screen coords
// params:
//   X Reg, Y Reg: is the LSB/MSB of the list_addr which is 
//              the address of the list of coords for the macro.  
//              this address should point to pairs of bytes that
//              are (x, y) positions on the screen ie (col, row)
//              the end of list is marked by negative number ($FF)
//              typical list may look like this
//                list_addr: .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
//   accum: the byte to poke to the list of coords
nv_screen_save_zero_page_lo: .word $0000
.const NV_SCREEN_ZERO_PAGE_LO = $FB
.const NV_SCREEN_ZERO_PAGE_HI = $FC
NvScreenPokeCharToCoordList_axy:
    nv_screen_poke_byte_to_coord_list_axy(NV_SCREEN_ZERO_PAGE_LO, 
                                          nv_screen_save_zero_page_lo, 
                                          SCREEN_START)
    rts
    

//////////////////////////////////////////////////////////////////////////////
// subroutine to poke a color to a list of screen coords
// params:
//   X Reg, Y Reg: is the LSB/MSB of the list_addr which is 
//              the address of the list of coords for the macro.  
//              this address should point to pairs of bytes that
//              are (x, y) positions on the screen ie (col, row)
//              the end of list is marked by negative number ($FF)
//              typical list may look like this
//                list_addr: .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
//   accum: the byte to poke (color) to each of the bytes specified in
//          the list of coords
NvScreenPokeColorToCoordList_axy:
    nv_screen_poke_byte_to_coord_list_axy(NV_SCREEN_ZERO_PAGE_LO, 
                                          nv_screen_save_zero_page_lo, 
                                          SCREEN_COLOR_START)
    rts

NvScreenPokeCoordList:
    nv_screen_poke_coord_list(NV_SCREEN_ZERO_PAGE_LO, 
                              nv_screen_poke_coord_list_mem_block)
    rts

// 7 byte block for nv_screen_poke_coord_list to use internally
// per comments for the macro.
nv_screen_poke_coord_list_mem_block: 
    .byte 0, 0, 0, 0, 0, 0, 0   // x, y, color, char, Y index, zero lsb, msb


//////////////////////////////////////////////////////////////////////////////
// subroutines to print a fp124s and fp124u values in decimal format.
// Before calling:
//   nv_fp124_to_print: must contain the fp124 value to be printed. 
//                      this can be either signed or unsigned
//   cursor: should be positioned on the screen
// Note: caller doesn't need to do anything with nv_fp124_str.  that
//       is just a temp variable used internally .
NvScreenPrintDecFP124s:
    sec                 // set carry flag indicating a signed fp124
    bcs DoPrint         // branch to do printing
NvScreenPrintDecFP124u:
    clc                 // clear carry indicating an unsigned fp124
                        // fall through to do printing
DoPrint:    
    //nv_screen_print_dec_fp124x_sr(nv_fp124_to_print, nv_fp124_str)
    //// rts is in macro above
    
    // set up the result string to hold the result
    lda #<nv_fp124_str
    sta nv_str1_ptr
    lda #>nv_fp124_str
    sta nv_str1_ptr+1
 
    nv_xfer124_mem_mem(nv_fp124_to_print, nv_fp124_for_to_str)

    jsr NvStrFP124xToStrWithTrim
    nv_screen_print_str(nv_fp124_str)
    rts

nv_fp124_to_print: .word $0000
nv_fp124_str: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
#import "nv_string_code.asm"



/*

    // set up the result string to hold the result
    lda #<result_str
    sta nv_str1_ptr
    lda #>result_str
    sta nv_str1_ptr+1

    // set the fp124x parameter for the subroutine
    nv_xfer124_mem_mem(op124x, nv_fp124_for_to_str)

    // set the carry flag to indicate signed or unsigned fp124
    .if (is_signed)
    {
        sec
    }
    else
    {
        clc
    }
    
    // call the string conversion subroutine
    //jsr NvStrFP124xToStr
    jsr NvStrFP124xToStrWithTrim
*/