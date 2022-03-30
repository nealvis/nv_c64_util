//////////////////////////////////////////////////////////////////////////////
// nv_branch124_macs.asm
// Copyright(c) 2022 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This file contains macros to branch based on FixedPoint 12.4 values 

#importonce
#if !NV_C64_UTIL_DATA
.error "Error - nv_branch124_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_branch16_macs.asm"


//////////////////////////////////////////////////////////////////////////////
// compare the contents of two 12.4 unsigned fixed pt values and 
// set flags accordingly.
// full name is nv_cmp124u_mem16u_mem16u
// params are:
//   addr1: 16 bit address of op1 which is a 12.4 unsigned fixed pt value
//   addr2: 16 bit address of op2 which is a 12.4 unsigned fixed pt value
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is not set reliably
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_cmp124u(addr1, addr2)
{
    nv_cmp16(addr1, addr2)
}

//////////////////////////////////////////////////////////////////////////////
// compare the contents of two unsigned fixed point 12.4 values and set 
// flags accordingly.
// full name is nv_cmp124u_mem124u_immed124u
// params are:
//   addr1: 16 bit address of op1 which is a 12.4 unsigned fixed pt value
//   addr2: 16 bit address of op2 which is a 12.4 unsigned fixed pt value
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is undefined
// Accum: changes
// X Reg: no change
// Y Reg: no change
.macro nv_cmp124u_immed(addr1, num)
{
    nv_cmp16_immed(addr1, num)
}


//////////////////////////////////////////////////////////////////////////////
// branch if two unsigned fixed pt 12.4 values in memory have the same 
// contents
// branch if addr1 == addr2
// full name is nv_beq124u_mem124u_mem124u
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124u(addr1, addr2, label)
{
    nv_beq16(addr1, addr2, label)
}

//////////////////////////////////////////////////////////////////////////////
// branch if two unsigned fixed pt 12.4 values in memory have the same 
// branch if addr1 == addr2
// full name is nv_beq124u_mem124u_mem124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124u_far(addr1, addr2, label)
{
    nv_beq16_far(addr1, addr2, label)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory has the same content  
// as an immediate fp124u bit value.
// branch if addr1 == num
// full name is nv_beq124u_mem124u_immed124u
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124u_immed(addr1, num, label)
{
    nv_beq16_immed(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory has the same content  
// as an immediate fp124u bit value.
// branch if addr1 == num
// full name is nv_beq124u_mem124u_immed124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u bit value to compare with the contents 
//        of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124_immed_far(addr1, num, label)
{
    nv_beq16_immed_far(addr1, num, label)
}

//////////////////////////////////////////////////////////////////////////////
// branch if two fp124 unsigned values in memory have the different contents
// branch if addr1 != addr2
// full name is nv_bne124u_mem124u_mem124u
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124u(addr1, addr2, label)
{
    nv_bne16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// branch if two fp124u values in memory have the different contents.
// branch if addr1 != addr2
// full name is nv_bne124u_mem124u_mem124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124u_far(addr1, addr2, label)
{
    nv_bne16_far(addr1, addr2, label)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory has different 
// content than an immediate fp124u bit value.
// branch if addr1 != num
// full name is nv_bne124u_mem124u_immed124u
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   num: is the immediate fp124u value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124u_immed(addr1, num, label)
{
    nv_bne16_immed(addr1, num, label)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory has different 
// contents than an immediate 16 bit value.
// branch if addr1 != num
// full name is nv_bne124u_mem124u_immed124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   num: is the immediate fp124u word to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124u_immed_far(addr1, num, label)
{
    nv_bne16_immed_far(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of an fp124u value at one memory
// location is less than the contents of another fp124u value in another
// location.
// branch if addr1 < addr2
// full name is nv_blt124u_mem124u_mem124u
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124u(addr1, addr2, label)
{
    nv_blt16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to jump to a label if the contents of an fp124u value in  
// one memory location is less than the value of another fp124u value in
// another memory location.
// branch if addr1 < addr2
// full name is nv_blt124u_mem124u_mem124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: the label to branch to if comparison is true
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124u_far(addr1, addr2, label)
{
    nv_blt16_far(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is less than 
// an immediate fp124u value.
// branch if addr1 < num
// full name is nv_blt124u_mem124u_immed124u
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124u_immed(addr1, num, label)
{
    nv_blt16_immed(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is less than 
// an immediate fp124u value
// branch if addr1 < num
// full name is nv_blt124u_mem124u_immed124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124u_immed_far(addr1, num, label)
{
    nv_blt16_immed_far(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of an fp124u value at one memory
// location is less than or equal to another fp124u value at another 
// memory location.
// branch if addr1 <= addr2
// full name is nv_ble124u_mem124u_mem124u
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124u(addr1, addr2, label)
{
    nv_ble16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of an fp124u value at one memory 
// location is less than or equal to another fp124u value in another memory 
// location.
// branch if addr1 <= addr2
// full name is nv_ble124u_mem124u_mem124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124u word (addr2+1 is MSB)
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124u_far(addr1, addr2, label)
{
    nv_ble16_far(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is less than or 
// equal to an immediate fp124u value.
// branch if addr1 <= num
// full name is nv_ble16u_mem16u_immed16u
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124u_immed(addr1, num, label)
{
    nv_ble16_immed(addr1, num, label)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is less than or 
// equal to an immediate fp124u value.
// branch if addr1 <= num
// full name is nv_ble124u_mem124u_immed124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u bit value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124u_immed_far(addr1, num, label)
{
    nv_ble16_immed_far(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are greater than the contents in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt124u_mem124u_mem124u
//   addr1: the address of the LSB of one fp124u value
//   addr2: the address of the LSB of the other fp124u value 
//   label: the label to branch to if addr1 > addr2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt124u(addr1, addr2, label)
{
    nv_bgt16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of an fp124u value at one memory 
// location are greater than the fp124u value in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt124u_mem124u_mem124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of one fp124u value
//   addr2: the address of the LSB of the other fp124u value 
//   label: the label to branch to if word1 > word2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt124u_far(addr1, addr2, label)
{
    nv_bgt16_far(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is greater than
// an immediate fp124u value.
// branch if addr1 > num
// full name is nv_bgt124u_mem124u_immed124u
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u value to compare with the contents of addr1
//   label: is the label to branch to
//   Accum: changes
//   X Reg: no change
//   Y Reg: no change
.macro nv_bgt124u_immed(addr1, num, label)
{
    nv_bgt16_immed(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is greater than
// an immediate fp124u bit value.
// branch if addr1 > num
// full name is nv_bgt124u_mem124u_immed124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u value to compare with the contents of addr1
//   label: is the label to branch to
//   Accum: changes
//   X Reg: no change
//   Y Reg: no change
.macro nv_bgt124u_immed_far(addr1, num, label)
{
    nv_bgt16_immed_far(addr1, num, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of one fp124u value one memory 
// location are greater than or equal to the contents of another fp124u value
// in another memory location.
// branch if addr1 >= addr2
// full name is nv_bge124u_mem124u_mem124u
//   addr1: the address of the LSB of one fp124u value 
//   addr2: the address of the LSB of the other fp124u value 
//   label: the label to branch to if addr1 >= addr2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge124u(addr1, addr2, label)
{
    nv_bge16(addr1, addr2, label)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of one fp124u value at one memory 
// location are greater than or equal to the contents of and fp124u value
// in another memory location.
// branch if addr1 >= addr2
// full name is nv_bge124u_mem124u_mem124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of one fp124u value 
//   addr2: the address of the LSB of the other fp124u value 
//   label: the label to branch to if addr1 >= addr2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge124u_far(addr1, addr2, label)
{
    nv_bge16_far(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is greater or equal 
// to an immediate fp124u value.
// branch if addr1 >= num
// full name is nv_bge124u_mem124u_immed124u
//   addr1: is the address of the LSB of an fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124u bit value to compare with the contents of addr1
//   label: is the label to branch to
.macro nv_bge124u_immed(addr1, num, label)
{
    nv_bge16_immed(addr1, num, label)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is greater or equal
// to an immediate fp124u value.
// branch if addr1 >= num
// full name is nv_bge124u_mem124u_immed124u_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124u value (addr1+1 is MSB)
//   num: is the immediate fp124 bit value to compare with the addr1
//   label: is the label to branch to
.macro nv_bge124u_immed_far(addr1, num, label)
{
    nv_bge16_immed_far(addr1, num, label)
}

