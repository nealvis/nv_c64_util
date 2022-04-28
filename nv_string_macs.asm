
//////////////////////////////////////////////////////////////////////////////
// nv_string_macs.asm
// Copyright(c) 2022 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This assembler file defines macros relating to string.

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_string_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_pointer_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// Adds the character in Accum into the null terminated string
// that is pointed to by addr.  
// Note that this macro will blindly add the char to the string 
//      and has no way of knowing if the bytes are available.
// Note that the string can be 254 chars max or 255 when including null.
// macro params:
//   addr: the address of the first char of the string.  The string
//         must be null terminated because that is how the position
//         for the new char is determined.  
// Accum: unchanged
// X Reg: unchanged
// Y Reg: Changes
.macro nv_str_cat_char_a(addr)
{
    pha
    ldy #0
TopLoop:    
    lda addr, y
    beq BreakLoop
    iny
    beq Done        // if Y Reg is zero then there are no nulls
    jmp TopLoop

BreakLoop:
    cpy #$FF
    beq Done        // if Y Reg is 255 then no room for another char, done

    // now Y reg is the index of the null, overwrite that with the 
    // value that was on the accum
    pla             // move the original accum value from stack to accum
    pha             // push it back on because below we pull it off
    sta addr, y
    // now inc Y and add a new null terminator to the string.
    iny
    lda #$00
    sta addr, y

Done:
    pla             // pull the original accum value from stack to accum
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// macros subroutine that adds the char in Accum to end of null terminated 
// string that is pointed to by str_ptr.  
// Note that this macro will blindly add the char to the string 
//      and has no way of knowing if the bytes are available.
// Note that the string can be 254 chars max or 255 when including null.
// macro params:
//   str_ptr: the address of a pointer to the first char of the string.  
//            The string must be null terminated because that is how the 
//            position for the new char is determined.  
//   save_block: the address of a two byte block of memory that can be
//               used to save zero page contents
// Accum: unchanged
// X Reg: changes
// Y Reg: Changes
.macro nv_str_cat_char_a_sr(str_ptr, save_block)
{
    pha
    nv_save_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    ldy #0
TopLoop:
    nv_load_a_from_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)
    //lda addr, y
    cmp #$00
    beq BreakLoop
    iny
    beq Done        // if Y Reg is zero then there are no nulls
    jmp TopLoop

BreakLoop:
    cpy #$FF
    beq Done        // if Y Reg is 255 then no room for another char, done

    // now Y reg is the index of the null, overwrite that with the 
    // value that was on the accum
    pla             // move the original accum value from stack to accum
    pha             // push it back on because below we pull it off
    nv_store_a_to_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)

    // now inc Y and add a new null terminator to the string.
    iny
    lda #$00
    nv_store_a_to_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)

Done:
    nv_restore_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    pla             // pull the original accum value from stack to accum
    rts
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// macros subroutine that trims end of a null terminated string by 
// removing any chars that match a specified char 
// Note that this macro will blindly find the null at the end of the 
//      string and remove the chars that match by setting them to null 
//      it has and has no way of knowing if the bytes are actually allocated
//      to the string.
// Note that the string can be 254 chars max (or 255 bytes including null.)
// macro params:
//   str_ptr: the address of a pointer to the first char of the string.  
//            The string must be null terminated because that is how the 
//            end of string will be found  
//   accum: the char to trim
//   x reg: max number of chars to trim.  set to 0 for no max (other than 254)
//   save_block: the address of a two byte block of memory that can be
//               used to save zero page contents
// Accum: changes
// X Reg: changes
// Y Reg: changes
.macro nv_str_trim_end_char_a_sr(str_ptr, save_block)
{
    sta TrimCharAddr    // save the char to trim
    stx TrimCounter     // save the max number of chars to trim
    nv_save_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)

    ldy #0              // start looking for end of string
TopLoop:
    // get first char of string into Accum
    nv_load_a_from_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)
    cmp #$00        // see if this byte is null
    beq BreakTopLoop   // if it is null then break out of the loop 
    iny             // not null so try next char in string
    beq Done        // if Y Reg is zero we've looked at 255 chars already
                    // and none were null so break out
    jmp TopLoop     // try next char.

BreakTopLoop:

Loop2:
    // at this point str_ptr+y points to the null in the string
    cpy #$00        // check if the very first char is null
    beq Done        // first char in string is null so nothing to trim

    dey
    nv_load_a_from_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)
    cmp TrimCharAddr        // compare char at end with specified char
    bne Done                // if its not equal then done trimming

    // if get here then need to trim this char and try the next
    lda #$00
    nv_store_a_to_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)

    dec TrimCounter
    beq Done

    jmp Loop2

Done:
    nv_restore_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    rts
TrimCharAddr: .byte 0
TrimCounter: .byte 0
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// macros subroutine that trims start of a null terminated string by 
// removing any chars that match a specified char 
// Note this macro relies on the string being null terminated.
// Note that the string can be 254 chars max (or 255 bytes including null.)
// macro params:
//   str_ptr: the address of a pointer to the first char of the string.  
//            The string must be null terminated.
//   accum: the char to trim
//   x reg: the max number of chars to trim.  set to zero for no limit
//          other than the 254 max chars in the string.
//   save_block: the address of a two byte block of memory that can be
//               used to save zero page contents
// Accum: changes
// X Reg: changes
// Y Reg: changes
.macro nv_str_trim_start_char_a_sr(str_ptr, save_block)
{
    stx MaxTrimCounter
    sta TrimCharAddr    // save the char to trim
    lda #$00
    sta TrimCounter     // start trim counter at 0

    // save the values in the zero page addresses that will be used
    // as a pointer to the string
    nv_save_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)

    ldy #0              // start looking for matching chars
TopLoop:
    // get first char of string into Accum
    nv_load_a_from_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)
    cmp TrimCharAddr   // see if this byte is one we are trimming
    bne BreakTopLoop   // if it is not then we are done with this loop

    // if here then we need to trim this char, so inc the number of 
    // chars to trim
    inc TrimCounter

    // dec our max trim counter that is the limit of most chars to trim
    dec MaxTrimCounter
    beq BreakTopLoop // we've hit the limit of chars to trim.

    iny              // inc index to next char in string
    beq DoneError    // never found the null, that can't be!
    jmp TopLoop      // loop up to try next char.

BreakTopLoop:

    // At this point TrimCounter has the number of chars to trim 
    // from the string.  It could be zero chars.

    ldy TrimCounter
    sty SaveY
    beq Done        // were no chars to trim

Loop2:

    // here Y Reg must have the index of the char to copy

    // get a char to move forward in the string to overwrite the 
    // trimmed chars
    nv_load_a_from_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)
    pha     // save the byte to copy on stack

    // now adjust y index to destination copy position
    tya
    sec
    sbc TrimCounter
    tay
    pla
    
    // now save the char in accum to forward position in string
    nv_store_a_to_mem_ptr_plus_y_no_save(str_ptr, NV_PTR_DEFAULT_ZERO_LO)

    cmp #$00        // check if we just copied the null
    beq Done        // we did, so done copying chars

    // didn't copy null yet so increment the copy source index
    inc SaveY
    ldy SaveY

    jmp Loop2

DoneError:
    // TODO. some error indicator here would be nice.

Done:
    nv_restore_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    rts
TrimCharAddr: .byte 0
TrimCounter: .byte 0
MaxTrimCounter: .byte 0
SaveY: .byte 0
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inlne macro for a subroutine that compares two strings
// macro params:
//   str1_ptr: the address of a pointer to the first char of the string.  
//             The string must be null terminated
//   str2_ptr: the address of a pointer to the first char of another string
//             for the comparison
//   save_block: is the address of a word that can be used to save 2 zero 
//               page bytes that will be used during the macro.
// upon return the following status flags will be set:
//   Zero flag: set if the strings are equal exactly, otherwise will be clear
//   Carry flag: Set if the first string is >= the second string
//               Clear if the first string is < the second string
.macro nv_str_cmp_sr(str1_ptr, str2_ptr, save_block)
{
    nv_save_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    ldy #$00
TopLoop:
    // get first char of str1 into Accum
    nv_load_a_from_mem_ptr_plus_y_no_save(str2_ptr, NV_PTR_DEFAULT_ZERO_LO)
    sta temp_char
    nv_load_a_from_mem_ptr_plus_y_no_save(str1_ptr, NV_PTR_DEFAULT_ZERO_LO)
    cmp temp_char   // compare accum with temp_char str1[y] with str2[y]
    bne Done        // chars are not equal, flags are set, just return

CharsEqual:
    cmp #$00
    beq Done        // chars are equal and they are both null
                    // done comparing chars just return

    // if here then chars are equal but not null, try next char
    iny
    beq Done        // if we've gon through 255 chars then just finish

    jmp TopLoop     // back to top of the loop for next char

Done:
    php             // save status flags from comparison above
    nv_restore_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    plp             // restore status flags from comparison above
    rts

temp_char: .byte $00
}
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// macro to copy a source string to a destination string.
// The source string must be null terminated and 254 chars or less (255 if 
// you include the null)
// The destionation string mush have enough bytes to accomodate the copy
// macro params:
//   src_str_ptr: the address of a pointer to the source string for the copy 
//             The string must be null terminated
//   dest_str_ptr: the address of a pointer to the destination string
//             for the copy.  
//   save_block: is the address of a word that can be used to save 2 zero 
//               page bytes that will be used during the macro.
.macro nv_str_cpy(src_str_ptr, dest_str_ptr, save_block)
{
    nv_save_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
    ldy #$00
TopLoop:
    // get a char of src string into Accum
    nv_load_a_from_mem_ptr_plus_y_no_save(src_str_ptr, NV_PTR_DEFAULT_ZERO_LO)

    // store that char into the destination string
    nv_store_a_to_mem_ptr_plus_y_no_save(dest_str_ptr, NV_PTR_DEFAULT_ZERO_LO)

    cmp #$00    // check if we just copied the null
    beq Done    // if we did copy null then we are done.

    // if here then haven't seen the null yet, increment y and
    // copy another char.
    iny

    // if we've copied 255 and y reg has wrapped around then bail.
    cpy #$00
    beq DoneWithError

    jmp TopLoop

DoneWithError:
    // TODO: do something to indicate an error here

Done:
    nv_restore_zero_page_ptr(NV_PTR_DEFAULT_ZERO_LO, save_block)
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// macro for a subroutine to copy a source string to a destination string.
// The source string must be null terminated and 254 chars or less (255 if 
// you include the null)
// The destionation string mush have enough bytes to accomodate the copy
// macro params:
//   src_str_ptr: the address of a pointer to the source string for the copy 
//             The string must be null terminated
//   dest_str_ptr: the address of a pointer to the destination string
//             for the copy.  
//   save_block: is the address of a word that can be used to save 2 zero 
//               page bytes that will be used during the macro.
.macro nv_str_cpy_sr(src_str_ptr, dest_str_ptr, save_block)
{
    nv_str_cpy(src_str_ptr, dest_str_ptr, save_block)
    rts
}
//
//////////////////////////////////////////////////////////////////////////////


