//////////////////////////////////////////////////////////////////////////////
// nv_pointer_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// inline macros for pointer releated functions
// importing this file will not generate any code or data directly

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_pointer_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_branch16_macs.asm"

// zero page pointer to use whenever a zero page pointer is needed
// but one is not specified
.const NV_PTR_DEFAULT_ZERO_LO = $FB
.const NV_PTR_DEFAULT_ZERO_HI = NV_PTR_DEFAULT_ZERO_LO + 1


//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in accumulator to the address
// pointed to by a specified pointer
// macro params:
//   ptr_addr: is the addres that contains the pointer to destination
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: unchanged, holds the byte that will be stored 
//   X Reg: unchanged
//   Y Reg: will change
.macro nv_store_a_to_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1

    // load zero page ptr with our pointer
    ldy ptr_addr
    sty ZERO_PAGE_LO
    ldy ptr_addr+1
    sty ZERO_PAGE_HI

    // story accum to the address in our pointer
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to load accum with the byte pointed to by a specified pointer
// macro params:
//   ptr_addr: is the address that contains the pointer to data
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: changes, will holds the byte loaded from mem ptr 
//   X Reg: unchanged
//   Y Reg: changes
.macro nv_load_a_from_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1

    // load zero page ptr with our pointer
    ldy ptr_addr
    sty ZERO_PAGE_LO
    ldy ptr_addr+1
    sty ZERO_PAGE_HI

    // store accum to the address in our pointer
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    lda (ZERO_PAGE_LO),y  // indirect indexed load accum to pointed to addr

    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to load accum with the byte pointed to by a specified pointer
// plus the y register.  so if pointer value is $1000 and Y contains 3
// the byte loaded will be from $1003
// macro params:
//   ptr_addr: is the address that contains the pointer to data
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: changes, will holds the byte loaded from mem ptr 
//   X Reg: changes
//   Y Reg: unchanged
.macro nv_load_a_from_mem_ptr_plus_y(ptr_addr, save_block)
{
    .const ZERO_PAGE_LO = NV_PTR_DEFAULT_ZERO_LO
    .const ZERO_PAGE_HI = NV_PTR_DEFAULT_ZERO_HI

    nv_save_zero_page_ptr(ZERO_PAGE_LO, save_block)

    // save our zero page pointer
    //ldx ZERO_PAGE_LO
    //stx save_block
    //ldx ZERO_PAGE_HI
    //stx save_block+1

    // load zero page ptr with our pointer
    ldx ptr_addr
    stx ZERO_PAGE_LO
    ldx ptr_addr+1
    stx ZERO_PAGE_HI

    // store accum to the address in our pointer
    lda (ZERO_PAGE_LO),y  // indirect indexed load accum to pointed to addr

    // restore our zero page pointer
    nv_restore_zero_page_ptr(ZERO_PAGE_LO, save_block)
    //ldx save_block
    //stx ZERO_PAGE_LO
    //ldx save_block+1
    //stx ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_save_zero_page_ptr(zero_lo, save_block)
{
    .var ZERO_PAGE_LO = zero_lo
    .var ZERO_PAGE_HI = zero_lo+1

    .if (zero_lo == -1)
    {
        .eval ZERO_PAGE_LO = NV_PTR_DEFAULT_ZERO_LO
        .eval ZERO_PAGE_HI = NV_PTR_DEFAULT_ZERO_HI
    }

    // save the zero page pointer to the save block
    ldx ZERO_PAGE_LO
    stx save_block
    ldx ZERO_PAGE_HI
    stx save_block+1
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_restore_zero_page_ptr(zero_lo, save_block)
{
    .var ZERO_PAGE_LO = zero_lo
    .var ZERO_PAGE_HI = zero_lo+1

    .if (zero_lo == -1)
    {
        .eval ZERO_PAGE_LO = NV_PTR_DEFAULT_ZERO_LO
        .eval ZERO_PAGE_HI = NV_PTR_DEFAULT_ZERO_HI
    }

    // restore our zero page pointer
    ldx save_block
    stx ZERO_PAGE_LO
    ldx save_block+1
    stx ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_load_a_from_mem_ptr_plus_y_no_save(ptr_addr, zero_lo)
{
    .var ZERO_PAGE_LO = zero_lo
    .var ZERO_PAGE_HI = zero_lo+1

    .if (zero_lo == -1)
    {
        .eval ZERO_PAGE_LO = NV_PTR_DEFAULT_ZERO_LO
        .eval ZERO_PAGE_HI = NV_PTR_DEFAULT_ZERO_HI
    }

    // load zero page ptr with our pointer
    ldx ptr_addr
    stx ZERO_PAGE_LO
    ldx ptr_addr+1
    stx ZERO_PAGE_HI

    // store accum to the address in our pointer
    lda (ZERO_PAGE_LO),y  // indirect indexed load accum to pointed to addr
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to store accum to the byte pointed to by a specified pointer
// plus the y register.  If pointer value is $1000 and Y contains 3
// the byte will be stored to memory address $1003
// macro params:
//   ptr_addr: is the address that contains the pointer to data
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: unchanged, should be set to the byte to store already 
//   X Reg: changes
//   Y Reg: unchanged
.macro nv_store_a_to_mem_ptr_plus_y(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldx ZERO_PAGE_LO
    stx save_block
    ldx ZERO_PAGE_HI
    stx save_block+1

    // load zero page ptr with our pointer
    ldx ptr_addr
    stx ZERO_PAGE_LO
    ldx ptr_addr+1
    stx ZERO_PAGE_HI

    // store accum to the address in our pointer
    sta (ZERO_PAGE_LO),y  // indirect indexed load accum to pointed to addr

    // restore our zero page pointer
    ldx save_block
    stx ZERO_PAGE_LO
    ldx save_block+1
    stx ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to store accum to the byte pointed to by a specified pointer
// plus the y register.  If pointer value is $1000 and Y contains 3
// the byte will be stored to memory address $1003
// macro params:
//   ptr_addr: is the address that contains the pointer to data
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: unchanged, should be set to the byte to store already 
//   X Reg: changes
//   Y Reg: unchanged
.macro nv_store_a_to_mem_ptr_plus_y_no_save(ptr_addr, zero_lo)
{
    .var ZERO_PAGE_LO = zero_lo
    .var ZERO_PAGE_HI = zero_lo+1

    .if (zero_lo == -1)
    {
        .eval ZERO_PAGE_LO = NV_PTR_DEFAULT_ZERO_LO
        .eval ZERO_PAGE_HI = NV_PTR_DEFAULT_ZERO_HI
    }

    // load zero page ptr with our pointer
    ldx ptr_addr
    stx ZERO_PAGE_LO
    ldx ptr_addr+1
    stx ZERO_PAGE_HI

    // store accum to the address in our pointer
    sta (ZERO_PAGE_LO),y  // indirect indexed load accum to pointed to addr
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in y register to the address
// pointed to by a specified pointer
// macro params:
//   ptr_addr: is the addres that contains the pointer to destination
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: will change
//   X Reg: unchanged
//   Y Reg: will change, holds the byte that will be stored
.macro nv_store_y_to_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    lda ZERO_PAGE_LO
    sta save_block
    lda ZERO_PAGE_HI
    sta save_block+1

    // load zero page ptr with our pointer
    lda ptr_addr
    sta ZERO_PAGE_LO
    lda ptr_addr+1
    sta ZERO_PAGE_HI

    // story accum to the address in our pointer
    tya                   // move y to a to prepare to store
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

    // restore our zero page pointer
    lda save_block
    sta ZERO_PAGE_LO
    lda save_block+1
    sta ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in x register to the address
// pointed to by a specified pointer
// macro params:
//   ptr_addr: is the addres that contains the pointer to destination
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: will change
//   X Reg: unchanged, holds the byte to store
//   Y Reg: will change, 
.macro nv_store_x_to_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    lda ZERO_PAGE_LO
    sta save_block
    lda ZERO_PAGE_HI
    sta save_block+1

    // load zero page ptr with our pointer
    lda ptr_addr
    sta ZERO_PAGE_LO
    lda ptr_addr+1
    sta ZERO_PAGE_HI

    // story accum to the address in our pointer
    txa                   // move y to a to prepare to store
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

    // restore our zero page pointer
    lda save_block
    sta ZERO_PAGE_LO
    lda save_block+1
    sta ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in accumulator to the list of addresses
// pointed to by a specified pointer
// macro params:
//   ptr_list_addr: is the addres that contains the pointer to the list 
//                  of destination addresses.  the list will be terminated
//                  with $FFFF value but can't be more than 256 total
//                  bytes including the $FFFF terminator 
//                  the list must have an even number of total bytes.
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
// Y Reg: changes
// Accum: does not change, holds byte to store
// X Reg: changes 
.macro nv_store_a_to_mem_ptr_list(ptr_list_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1

    ldx #0
LoopTop:

    // load zero page ptr with our pointer
    ldy ptr_list_addr,x
    sty ZERO_PAGE_LO
    ldy ptr_list_addr+1, x
    sty ZERO_PAGE_HI
    
    ldy #$FF
    cpy ZERO_PAGE_LO
    bne NotListTerminator
    cpy ZERO_PAGE_HI
    bne NotListTerminator
    // must be term
    jmp HitListTerminator
NotListTerminator:

    // story accum to the address in our pointer
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr
    inx
    inx
    jmp LoopTop

HitListTerminator:
    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
}
//
//////////////////////////////////////////////////////////////////////////////