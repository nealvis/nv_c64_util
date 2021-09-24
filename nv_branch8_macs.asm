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
    nv_beq8_a(addr2, label)
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


//////////////////////////////////////////////////////////////////////////////
// macros with accum as an opperand
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as accumulator
// branch if addr1 = accum
// macro params:
//   accum: has a value to compare with that at addr1
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_a(addr1, label)
{
    cmp addr1
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as accumulator
// branch if addr1 = accum
// macro params:
//   accum: has a value to compare with that at addr1
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_a_far(addr1, label)
{
    cmp addr1
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has different contents than accum
// branch if addr1 != accum
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_a(addr1, label)
{
    cmp addr1
    bne label
}

//////////////////////////////////////////////////////////////////////////////
// branch if one bytes in memory has different contents than accum.
// branch if addr1 = accum
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_a_far(addr1, label)
{
    cmp addr1
    beq Done    // is equal, don't branch/jump to label
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents of the accum.
// branch if addr1 > accum
//   addr1: the address of byte1
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_a(addr1, label)
{
    cmp addr1   // carry will be set if addr1 <= accum
    bcc label   // addr1 > accum
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents of the accum.
// branch if addr1 > accum
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_a_far(addr1, label)
{
    cmp addr1   // carry will be set if addr1 <= accum
    bcs Done    // carry set so no branch
    jmp label   // addr1 > accum
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents of accum
// branch if addr1 >= accum
//   addr1: the address of byte1
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_a(addr1, label)
{
    cmp addr1   // carry will be set if addr1 <= accum
    beq label   // addr1 = accum, so branch
    bcc label   // addr1 > accum, so branch
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents of accum
// branch if addr1 >= accum
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_a_far(addr1, label)
{
    cmp addr1     // carry will be set if addr1 <= accum
    bne NotEqual  // not equal so check less/greater
    jmp label     // addr1 = accum, so branch
NotEqual:
    bcs Done      // addr < accum because checked for equal above, no branch
    jmp label     // addr1 > accum, so branch
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents of accum.
// branch if addr1 <= accum
//   addr1: the address of the byte in memory
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_a(addr1, label)
{
    // want to branch if addr1 < accum
    cmp addr1  // carry will be set if addr1 <= accum
    beq Done   // if equal then its not less than
    bcs label  // addr <= accum, but already check for = so its <
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents of accum.
// branch if addr1 < accum
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the byte in memory
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_a_far(addr1, label)
{
    // want to branch if addr1 < accum
    cmp addr1  // carry will be set if addr1 <= accum
    bcc Done   // addr1 > accum, no branch
    beq Done   // addr == accum, no branch
    jmp label
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents the accumulator 
// branch if addr1 <= accum
//   addr1: the address of the first byte
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_a(addr1, label)
{
    cmp addr1  // carry will be set if addr1 <= accum
    bcs label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents the accumulator 
// branch if addr1 <= accum
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the first byte
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_a_far(addr1, label)
{
    cmp addr1  // carry will be set if addr1 <= accum
    bcc Done
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// macros with X Reg as an opperand
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as X reg
// branch if addr1 = X Reg
// macro params:
//   x reg: has a value to compare with that at addr1
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_x(addr1, label)
{
    cpx addr1
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as X Reg
// branch if addr1 = X Reg
// The branch label's address can be farther than +127/-128 bytes away
// macro params:
//   x reg: has a value to compare with that at addr1
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_x_far(addr1, label)
{
    cpx addr1
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// branch if a byte in memory has different contents than x reg
// branch if addr1 != X Reg
//   addr1: is the address of one byte in memory
//   X Reg: value to compare with addr1 contents
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_x(addr1, label)
{
    cpx addr1
    bne label
}

//////////////////////////////////////////////////////////////////////////////
// branch if one bytes in memory has different contents than x reg.
// branch if addr1 != x reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of one byte in memory
//   X reg: holds value to compare with whats at addr1
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_x_far(addr1, label)
{
    cpx addr1
    beq Done    // is equal, don't branch/jump to label
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents of the x reg.
// branch if addr1 > x reg
//   addr1: the address of byte1
//   x reg: value to compare with contents at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_x(addr1, label)
{
    cpx addr1   // carry will be set if addr1 <= x reg
    bcc label   // addr1 > x reg
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents of the x reg.
// branch if addr1 > x reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   x reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_x_far(addr1, label)
{
    cpx addr1   // carry will be set if addr1 <= x reg
    bcs Done    // carry set so no branch
    jmp label   // addr1 > x reg
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents of x reg
// branch if addr1 >= x reg
//   addr1: the address of byte1
//   x reg: holds value to compare with contents of addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_x(addr1, label)
{
    cpx addr1   // carry will be set if addr1 <= x reg
    beq label   // addr1 = x reg, so branch
    bcc label   // addr1 > x reg, so branch
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents of x reg
// branch if addr1 >= x reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   x reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_x_far(addr1, label)
{
    cpx addr1     // carry will be set if addr1 <= x reg
    bne NotEqual  // not equal so check less/greater
    jmp label     // addr1 = x reg, so branch
NotEqual:
    bcs Done      // addr < x reg because checked for equal above, no branch
    jmp label     // addr1 > x reg, so branch
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents of x reg.
// branch if addr1 <= x reg
//   addr1: the address of the byte in memory
//   x reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_x(addr1, label)
{
    // want to branch if addr1 < x reg
    cpx addr1  // carry will be set if addr1 <= x reg
    beq Done   // if equal then its not less than
    bcs label  // addr <= x reg, but already check for = so its <
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents of x reg.
// branch if addr1 < x reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the byte in memory
//   x reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_x_far(addr1, label)
{
    // want to branch if addr1 < x reg
    cpx addr1  // carry will be set if addr1 <= x reg
    bcc Done   // addr1 > x reg, no branch
    beq Done   // addr == x reg, no branch
    jmp label
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents the x reg 
// branch if addr1 <= x reg
//   addr1: the address of the first byte
//   x reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_x(addr1, label)
{
    cpx addr1  // carry will be set if addr1 <= x reg
    bcs label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents the x reg 
// branch if addr1 <= x reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the first byte
//   x reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_x_far(addr1, label)
{
    cpx addr1  // carry will be set if addr1 <= x reg
    bcc Done
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// macros with Y Reg as an opperand
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as Y reg
// branch if addr1 = Y Reg
// macro params:
//   y reg: has a value to compare with that at addr1
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_y(addr1, label)
{
    cpy addr1
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as Y Reg
// branch if addr1 = Y Reg
// The branch label's address can be farther than +127/-128 bytes away
// macro params:
//   y reg: has a value to compare with that at addr1
//   addr1: is the address of one byte in memory
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_y_far(addr1, label)
{
    cpy addr1
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// branch if a byte in memory has different contents than y reg
// branch if addr1 != Y Reg
//   addr1: is the address of one byte in memory
//   Y Reg: value to compare with addr1 contents
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_y(addr1, label)
{
    cpy addr1
    bne label
}

//////////////////////////////////////////////////////////////////////////////
// branch if one bytes in memory has different contents than y reg.
// branch if addr1 != y reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of one byte in memory
//   Y reg: holds value to compare with whats at addr1
//   label: is the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_y_far(addr1, label)
{
    cpy addr1
    beq Done    // is equal, don't branch/jump to label
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents of the y reg.
// branch if addr1 > y reg
//   addr1: the address of byte1
//   y reg: value to compare with contents at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_y(addr1, label)
{
    cpy addr1   // carry will be set if addr1 <= y reg
    bcc label   // addr1 > y reg
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than the contents of the y reg.
// branch if addr1 > y reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   y reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_y_far(addr1, label)
{
    cpy addr1   // carry will be set if addr1 <= y reg
    bcs Done    // carry set so no branch
    jmp label   // addr1 > y reg
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents of y reg
// branch if addr1 >= y reg
//   addr1: the address of byte1
//   y reg: holds value to compare with contents of addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_y(addr1, label)
{
    cpy addr1   // carry will be set if addr1 <= y reg
    beq label   // addr1 = y reg, so branch
    bcc label   // addr1 > y reg, so branch
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are greater than or equal to the contents of y reg
// branch if addr1 >= y reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of byte1
//   y reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_y_far(addr1, label)
{
    cpy addr1     // carry will be set if addr1 <= y reg
    bne NotEqual  // not equal so check less/greater
    jmp label     // addr1 = y reg, so branch
NotEqual:
    bcs Done      // addr < y reg because checked for equal above, no branch
    jmp label     // addr1 > y reg, so branch
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents of y reg.
// branch if addr1 <= y reg
//   addr1: the address of the byte in memory
//   y reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_y(addr1, label)
{
    // want to branch if addr1 < y reg
    cpy addr1  // carry will be set if addr1 <= y reg
    beq Done   // if equal then its not less than
    bcs label  // addr <= y reg, but already check for = so its <
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than the contents of y reg.
// branch if addr1 < y reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the byte in memory
//   y reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_y_far(addr1, label)
{
    // want to branch if addr1 < y reg
    cpy addr1  // carry will be set if addr1 <= y reg
    bcc Done   // addr1 > y reg, no branch
    beq Done   // addr == y reg, no branch
    jmp label
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents the y reg 
// branch if addr1 <= y reg
//   addr1: the address of the first byte
//   y reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_y(addr1, label)
{
    cpy addr1  // carry will be set if addr1 <= y reg
    bcs label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a byte at one memory location  
// are less than or equal to the contents the y reg 
// branch if addr1 <= y reg
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the first byte
//   y reg: holds value to compare with byte at addr1
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_y_far(addr1, label)
{
    cpy addr1  // carry will be set if addr1 <= y reg
    bcc Done
    jmp label
Done:
}



//////////////////////////////////////////////////////////////////////////////
// macros with immediate number and accum as an opperand
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as accumulator
// macro params:
// branch if num = accum
//   accum: has a value to compare
//   num: is the immediate 8 bit value to compare
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_immed_a(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }
    cmp #num
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// branch if a bytes in memory has same contents as accumulator
// branch if num = accum
// The branch label's address can be farther than +127/-128 bytes away
// macro params:
//   accum: has a value to compare 
//   num: is the immediate 8 bit value to compare
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq8_immed_a_far(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }
    cmp #num
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// branch if a an 8 bit immediate value is  different than contents of accum
// branch if num != accum
//   num: is the immediate 8 bit value
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_immed_a(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }
    cmp #num
    bne label
}

//////////////////////////////////////////////////////////////////////////////
// branch if immiediate 8 bit value is different than accum.
// branch if num != accum
// The branch label's address can be farther than +127/-128 bytes away
//   num: is the immediate 8 bit number to compare
//   label: is the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne8_immed_a_far(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }
    cmp #num
    beq Done    // is equal, don't branch/jump to label
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value is greater than accum  
// branch if num > accum
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_immed_a(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }
    cmp #num   // carry will be set if num <= accum
    bcc label   // num > accum
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8bit immed value   
// is greater than the contents of the accum.
// branch if num > accum
// The branch label's address can be farther than +127/-128 bytes away
//   num: the 8 bit immdediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt8_immed_a_far(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

    cmp #num   // carry will be set if num <= accum
    bcs Done    // carry set so no branch
    jmp label   // num > accum
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value   
// is greater than or equal to the contents of accum
// branch if num >= accum
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_immed_a(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

    cmp #num   // carry will be set if num <= accum
    beq label   // num = accum, so branch
    bcc label   // num > accum, so branch
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value 
// is greater than or equal to the contents of accum
// branch if num >= accum
// The branch label's address can be farther than +127/-128 bytes away
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge8_immed_a_far(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

    cmp #num     // carry will be set if num <= accum
    bne NotEqual  // not equal so check less/greater
    jmp label     // num = accum, so branch
NotEqual:
    bcs Done      // num < accum because checked for equal above, no branch
    jmp label     // num > accum, so branch
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value  
// is less than the contents of accum.
// branch if num <= accum
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_immed_a(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

    // want to branch if num < accum
    cmp #num  // carry will be set if num <= accum
    beq Done   // if equal then its not less than
    bcs label  // num <= accum, but already check for = so its <
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value  
// is less than the contents of accum.
// branch if num < accum
// The branch label's address can be farther than +127/-128 bytes away
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt8_immed_a_far(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

   // want to branch if num < accum
    cmp #num  // carry will be set if num <= accum
    bcc Done   // num > accum, no branch
    beq Done   // addr == accum, no branch
    jmp label
Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value  
// is less than or equal to the contents the accumulator 
// branch if num <= accum
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_immed_a(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

    cmp #num  // carry will be set if num <= accum
    bcs label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if an 8 bit immediate value  
// is less than or equal to the contents the accumulator 
// branch if num <= accum
// The branch label's address can be farther than +127/-128 bytes away
//   num: the 8 bit immediate value to compare
//   label: the label to branch to if condition is met
// Accum: unchanged
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_ble8_immed_a_far(num, label)
{
    .if (num > $00FF)
    {
        .error "Error - immediate value too big"
    }

    cmp #num  // carry will be set if num <= accum
    bcc Done
    jmp label
Done:
}


