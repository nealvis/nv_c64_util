//////////////////////////////////////////////////////////////////////////////
// nv_branch8_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This file contains macros to branch based on 8 bit values 

#importonce
#if !NV_C64_UTIL_DATA
.error "Error - nv_branch16_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


//////////////////////////////////////////////////////////////////////////////
// branch if two bytes in memory have the same contents
//   addr1: is the address of one byte in memory
//   addr2: is the address of the other byte in memory
//   label: is the label to branch to if bytes are equal
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// branch if two bytes in memory have the same contents.
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address one byte in memory
//   addr2: is the address of the other byte
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_far(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one byte in memory has the same content as 
// an immediate 8 bit value
//   addr1: is the address of the byte in memory
//   num: is the immediate 8 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_immediate(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_beq8_immediate, immediate value too big"
    }
    lda #num
    cmp addr1
    beq label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has the same content as 
// an immediate 16 bit value
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_immediate_far(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_beq8_immediate_far, immediate value too big"
    }
    lda #num
    cmp addr1
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// branch if two bytes in memory have the different contents
//   addr1: is the address of one byte in memory
//   addr2: is the address of the other byte in memory
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    bne label
}

//////////////////////////////////////////////////////////////////////////////
// branch if two bytes in memory have the different contents.
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of one byte in memory
//   addr2: is the address of the other byte in memory
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_far(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    beq Done    // is equal, don't branch/jump to label
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one byte in memory has the same content as 
// an immediate 8 bit value
//   addr1: is the address of the byte in memory
//   num: is the immediate 8 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_immediate(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_beq8_immediate, immediate value too big"
    }
    lda #num
    cmp addr1
    bne label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has the same content as 
// an immediate 16 bit value
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_immediate_far(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_beq8_immediate_far, immediate value too big"
    }
    lda #num
    cmp addr1
    beq Done
    jmp label
Done:
}




//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents in another memory location 
//   addr1: the address of the first byte
//   addr2: the address of the second byte 
//   label: the label to branch to if first byte < second byte
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    bcc label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to jump to a label if the contents of a word at one 
// memory location are less than the contents in another memory location.
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_far(addr1, addr2, label)
{
    lda addr1 
    cmp addr2
    bcs Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents an immediate 8 bit value 
//   addr1: the address of the first byte
//   num: the immediate byte
//   label: the label to branch to if first byte < immediate value
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_immediate(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_blt8_immediate, immediate value too big"
    }

    lda addr1
    cmp #num
    bcc label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents an immediate 8 bit value.
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the first byte
//   num: the immediate byte
//   label: the label to branch to if first byte < immediate value
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_immediate_far(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_blt8_immediate_far, immediate value too big"
    }

    lda addr1
    cmp #num
    bcs Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents in another memory location 
//   addr1: the address of the first byte
//   addr2: the address of the second byte 
//   label: the label to branch to if first byte <= second byte
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    bcc label
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents in another memory location 
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the first byte
//   addr2: the address of the second byte 
//   label: the label to branch to if first byte <= second byte
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_far(addr1, addr2, label)
{
    // after cmp: 
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    lda addr1
    cmp addr2
    bcs GTE
LT:
    jmp label       // not greater than or equal to, is less than so branch

GTE:
    bne Done        // greater than but not equal so no branch

EQ:                 // must be equal so jump
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to an immediate 8 bit value 
//   addr1: the address of the first byte
//   num: the immediate 8 bit value 
//   label: the label to branch to if first byte <= second byte
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_immediate(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_ble8_immediate, immediate value too big"
    }

    lda addr1
    cmp #num
    bcc label
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents of an immediate 8 bit value 
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the first byte
//   num: the immediate 8 bit value of the second byte 
//   label: the label to branch to if first byte <= second byte
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_immediate_far(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_ble8_immediate_far, immediate value too big"
    }

    // after cmp: 
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    lda addr1
    cmp #num
    bcs GTE
LT:
    jmp label       // not greater than or equal to, is less than so branch

GTE:
    bne Done        // greater than but not equal so no branch

EQ:                 // must be equal so jump
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents in another memory location 
//   addr1: the address of byte1
//   addr2: the address of byte2 
//   label: the label to branch to if byte1 > byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8(addr1, addr2, label)
{
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2
    lda addr1
    cmp addr2
    beq Done    // equal so not greater than, we're done
    bcs label   // >= but we already tested for == so must be greater than
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents in another memory location 
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   addr2: the address of byte2 
//   label: the label to branch to if byte1 > byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_far(addr1, addr2, label)
{
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2
    lda addr1
    cmp addr2
    beq Done    // equal so not greater than, we're done
    bcc Done    // addr1 < addr2 so not greater than
    jmp label   // didn't branch because equal or less than so jmp
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents in another memory location 
//   addr1: the address of byte1
//   num: the immediate 8 bit number 
//   label: the label to branch to if byte1 > num
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_immediate(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_bgt8_immediate, immediate value too big"
    }

    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2
    lda addr1
    cmp #num
    beq Done    // equal so not greater than, we're done
    bcs label   // >= but we already tested for == so must be greater than
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the an immediate 8 bit number 
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   num: the immediate 8 bit number 
//   label: the label to branch to if byte1 > byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_immediate_far(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_bgt8_immediate_far, immediate value too big"
    }

    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2
    lda addr1
    cmp #num
    beq Done    // equal so not greater than, we're done
    bcc Done    // addr1 < addr2 so not greater than
    jmp label   // didn't branch because equal or less than so jmp
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents in another byte in memory 
//   addr1: the address of byte1
//   addr2: the address of byte2 
//   label: the label to branch to if byte1 >= byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    // Carry Flag	Set if addr1 >= addr2

    bcs label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents in another byte in memory
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   addr2: the address of byte2 
//   label: the label to branch to if byte1 >= byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_far(addr1, addr2, label)
{
    lda addr1
    cmp addr2
    // Carry Flag Set if addr1 >= addr2

    bcc Done
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to an immediate 8 bit value 
//   addr1: the address of byte1
//   num: the immediate 8 bit value
//   label: the label to branch to if byte1 >= byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_immediate(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_bge8_immediate, immediate value too big"
    }

    lda addr1
    cmp #num
    // Carry Flag	Set if addr1 >= addr2

    bcs label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to an immediate 8 bit value 
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   num: the immediate 8 bit value
//   label: the label to branch to if byte1 >= byte2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_immediate_far(addr1, num, label)
{
    .if (num > $00FF)
    {
        .error "Error - nv_bge8_immediate_far, immediate value too big"
    }

    lda addr1
    cmp #num
    // Carry Flag	Set if addr1 >= addr2

    bcc Done   // carry is clear so addr1 < addr2, no branch
    jmp label
Done:
}


