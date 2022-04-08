
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
// string that is pointed to by addr.  
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
    ldy #0
TopLoop:
    nv_load_a_from_mem_ptr_plus_y(str_ptr, save_block)
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
    nv_store_a_to_mem_ptr_plus_y(str_ptr, save_block)

    // now inc Y and add a new null terminator to the string.
    iny
    lda #$00
    nv_store_a_to_mem_ptr_plus_y(str_ptr, save_block)

Done:
    pla             // pull the original accum value from stack to accum
    rts
}
//
//////////////////////////////////////////////////////////////////////////////


