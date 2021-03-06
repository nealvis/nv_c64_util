//////////////////////////////////////////////////////////////////////////////
// nv_branch16_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This file contains macros to branch based on 16 bit values 

#importonce
#if !NV_C64_UTIL_DATA
.error "Error - nv_branch16_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


//////////////////////////////////////////////////////////////////////////////
// compare the contents of two 16 bit words and set flags accordingly.
// full name is nv_cmp16u_mem16u_mem16u
// params are:
//   addr1: 16 bit address of op1
//   addr2: 16 bit address of op2
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is undefined
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_cmp16(addr1, addr2)
{
    // first compare the MSBs
    lda addr1+1
    cmp addr2+1
    bne Done

    // MSBs are equal so need to compare LSBs
    lda addr1
    cmp addr2

Done:
}

//////////////////////////////////////////////////////////////////////////////
// compare the contents of two 16 bit words and set flags accordingly.
// full name is nv_cmp16u_mem16u_immed16u
// params are:
//   addr1: 16 bit address of op1
//   addr2: 16 bit address of op2
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is undefined
// Accum: changes
// X Reg: no change
// Y Reg: no change
.macro nv_cmp16_immed(addr1, num)
{
    // first compare the MSBs
    lda addr1+1
    cmp #((num >> 8) & $00FF)
    bne Done

    // MSBs are equal so need to compare LSBs
    lda addr1
    cmp #(num & $00FF)

Done:
}


//////////////////////////////////////////////////////////////////////////////
// branch if two words in memory have the same contents
// branch if addr1 == addr2
// full name is nv_beq16u_mem16u_mem16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq16(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// branch if two words in memory have the same contents.
// branch if addr1 == addr2
// full name is nv_beq16u_mem16u_mem16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq16_far(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has the same content as 
// an immediate 16 bit value.
// branch if addr1 == num
// full name is nv_beq16u_mem16u_immed16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq16_immed(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    beq label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has the same content as 
// an immediate 16 bit value.
// branch if addr1 == num
// full name is nv_beq16u_mem16u_immed16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq16_immed_far(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    bne Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// branch if two words in memory have the different contents
// branch if addr1 != addr2
// full name is nv_bne16u_mem16u_mem16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne16(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    bne label
}


//////////////////////////////////////////////////////////////////////////////
// branch if two words in memory have the different contents.
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne16_far(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    beq Done
    jmp label
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has different content than 
// an immediate 16 bit value.
// branch if addr1 != num
// full name is nv_bne16u_mem16u_num16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne16_immed(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    bne label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has different contents than 
// an immediate 16 bit value.
// branch if addr1 != num
// full name is nv_bne16u_mem16u_num16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne16_immed_far(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    beq Done
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are less than the contents in another memory location .
// branch if addr1 < addr2
// full name is nv_blt16u_mem16u_mem16u
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt16(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    bcc label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to jump to a label if the contents of a word at one 
// memory location are less than the contents in another memory location.
// branch if addr1 < addr2
// full name is nv_blt16u_mem16u_mem16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt16_far(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    bcs Done
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is less than 
// an immediate 16 bit value.
// branch if addr1 < num
// full name is nv_blt16u_mem16u_immed16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt16_immed(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    bcc label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is less than 
// an immediate 16 bit value
// branch if addr1 < num
// full name is nv_blt16u_mem16u_immed16u far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt16_immed_far(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    bcs Done
    jmp label
Done:    
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are less than or equal to the contents in another memory location.
// branch if addr1 <= addr2
// full name is nv_ble16u_mem16u_mem16u
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble16(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    bcc label
    beq label
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are less than or equal to the contents in another memory location.
// branch if addr1 <= addr2
// full name is nv_ble16u_mem16u_mem16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble16_far(addr1, addr2, label)
{
    nv_bgt16(addr1, addr2, Done)
    jmp label
Done:    
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is less than or equal to
// an immediate 16 bit value.
// branch if addr1 <= num
// full name is nv_ble16u_mem16u_immed16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble16_immed(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    bcc label
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is less than or equal to
// an immediate 16 bit value.
// branch if addr1 <= num
// full name is nv_ble16u_mem16u_immed16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble16_immed_far(addr1, num, label)
{
    nv_bgt16_immed(addr1, num, Done)
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are greater than the contents in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt16u_mem16u_mem16u
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 > word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt16(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    beq Done    // equal so not greater than, we're done
    bcs label   // >= but we already tested for == so must be greater than
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are greater than the contents in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt16u_mem16u_mem16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 > word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt16_far(addr1, addr2, label)
{
    nv_ble16(addr1, addr2, Done)
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is greater than
// an immediate 16 bit value.
// branch if addr1 > num
// full name is nv_bgt16u_mem16u_immed16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// todo print macro
//   Accum: changes
//   X Reg: no change
//   Y Reg: no change
.macro nv_bgt16_immed(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    beq Done    // equal so not greater than, we're done
    bcs label   // >= but we already tested for == so must be greater than
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is greater than
// an immediate 16 bit value.
// branch if addr1 > num
// full name is nv_bgt16u_mem16u_immed16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// todo print macro
//   Accum: changes
//   X Reg: no change
//   Y Reg: no change
.macro nv_bgt16_immed_far(addr1, num, label)
{
    nv_ble16_immed(addr1, num, Done)
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are greater than or equal to the contents in another memory location.
// branch if addr1 >= addr2
// full name is nv_bge16u_mem16u_mem16u
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 >= word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge16(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2

    bcs label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are greater than or equal to the contents in another memory location.
// branch if addr1 >= addr2
// full name is nv_bge16u_mem16u_mem16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 >= word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge16_far(addr1, addr2, label)
{
    nv_cmp16(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2
    bcc Done
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is greater or equal tothan
// an immediate 16 bit value.
// branch if addr1 >= num
// full name is nv_bge16u_mem16u_immed16u
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// todo print macro
.macro nv_bge16_immed(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    // Carry Flag	Set if addr1 >= num

    bcs label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory is greater or equal tothan
// an immediate 16 bit value.
// branch if addr1 >= num
// full name is nv_bge16u_mem16u_immed16u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
// todo print macro
.macro nv_bge16_immed_far(addr1, num, label)
{
    nv_cmp16_immed(addr1, num)
    // Carry Flag	Set if addr1 >= num
    bcc Done
    jmp label
Done:
}

