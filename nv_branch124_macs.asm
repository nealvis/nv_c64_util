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
#import "nv_math124_macs.asm"

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
// compare the contents of two 12.4 signed fixed pt values and 
// set flags accordingly.
// full name is nv_cmp124u_mem124u_mem124u
// params are:
//   addr1: 16 bit address of op1 which is a 12.4 unsigned fixed pt value
//   addr2: 16 bit address of op2 which is a 12.4 unsigned fixed pt value
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is not set reliably
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_cmp124s(addr1, addr2)
{
    // compare high bytes of each
    lda addr1+1
    eor addr2+1
    bmi DiffSigns
SameSigns:
    // same signs so just do unsigned 16 bit compare
    lda addr1+1
    bpl BothPositive
BothNegative:
    // reverse the operands to comp when both negative
    nv_cmp16(addr2, addr1)
    jmp Done

BothPositive:
    nv_cmp16(addr1, addr2)
    jmp Done

DiffSigns:
    // first check if we are comparing pos zero and neg zero
    // which is a special case.
    lda addr1+1  
    and #$7F
    bne NotPosAndNegZero
    lda addr2+1  
    and #$7F
    bne NotPosAndNegZero
    lda addr1
    and #$FF
    bne NotPosAndNegZero
    lda addr2
    and #$FF
    bne NotPosAndNegZero

WasPosAndNegZero:
    // had pos and neg zeros, Accum has zero in it now
    cmp #$00    // do a cmp with zero to set flags right
    jmp Done    // we are done

NotPosAndNegZero:
    // if we get here then addr1 and addr2 had different signs 
    // and they weren't -0 and +0 so the negative number is less
    // than the positive number

    lda addr1+1
    bmi NegativeAddr1

PositiveAddr1:
    // addr1 is >= addr2 so set carry
    sec
    bcs ClearZeroAndDone  // unconditional branch (because carry set above)

NegativeAddr1:
    // addr1 is NOT >= addr2 so clear carry
    clc

ClearZeroAndDone:
    // clear zero flag, they aren't equal
    lda #$01  // just load a nonzero number to clear zero flag

Done:
}


//////////////////////////////////////////////////////////////////////////////
// compare the contents of one 12.4 signed fixed point value in memory 
// with another fP124s immediate value. Set flags accordingly.
// full name is nv_cmp124u_mem124s_immed124s
// params are:
//   addr1: 16 bit address of op1 which is a 12.4 unsigned fixed pt value
//   addr2: 16 bit address of op2 which is a 12.4 unsigned fixed pt value
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is not set reliably
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_cmp124s_immed(addr1, num)
{
    .if ((num & $8000) != 0)
    {   // num is negative
        lda addr1+1
        bpl PosNeg
        
        NegNeg:      // addr1 Neg, num Neg
        // first compare the MSBs
        lda #((num >> 8) & $00FF)  
        cmp addr1+1
        bne Done

        // MSBs are equal so need to compare LSBs
        lda #(num & $00FF)  
        cmp addr1
        jmp Done

        PosNeg:      // addr1 Pos, num Neg
        .if (num == $8000)
        {   // negative zero in num, so its really pos zero and positive addr1
            nv_cmp16_immed(addr1, $0000)
            jmp Done
        }
        else
        {
            // addr1 is >= num so set carry
            sec
            // Fall through to ClearZeroAndDone
            //bcs ClearZeroAndDone  // unconditional branch (because carry set above)
        }
    }
    else
    {   // num is positive
        lda addr1+1
        bmi NegPos 

        PosPos:     // addr1 Pos  num Pos
        nv_cmp16_immed(addr1, num)
        jmp Done
        
        NegPos:     // addr1 Neg, num Pos
        lda addr1+1
        and $7F
        bne Addr1NotNegZero
        lda addr1
        and $FF
        bne Addr1NotNegZero
        Addr1IsNegZero:
        .if (num == $0000)
        {   // Addr1 is -0 and num is pos zero so 
            // compare the 0 in accum with 0 to set the flags
            // and we're done
            cmp #$00
            jmp Done
        }
        // if we get here then addr1 is -0 but num is not +0
        // so fall through 

        Addr1NotNegZero:
        // addr1 is NOT >= num so clear carry
        clc
        // fall through to ClearZeroAndDone 
    }

ClearZeroAndDone:
    // clear zero flag, they aren't equal
    lda #$01  // just load a nonzero number to clear zero flag

Done:
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
// branch if two signed fixed pt 12.4 values in memory have the same 
// contents
// branch if addr1 == addr2  
//   note that $8000 == $0000
// full name is nv_beq124s_mem124s_mem124s
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124s(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    beq label
}


//////////////////////////////////////////////////////////////////////////////
// branch if two unsigned fixed pt 12.4 values in memory have the same value
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
// branch if two signed fixed pt 12.4 values in memory have the same value
// branch if addr1 == addr2
// full name is nv_beq124s_mem124s_mem124s_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124s_far(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    bne Done
    jmp label
Done:
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
// inline macro to branch if one fp124s value in memory has the same content  
// as an immediate fp124s bit value.
// branch if addr1 == num
// full name is nv_beq124s_mem124s_immed124s
//   addr1: is the address of LSB of one fp124s value (addr1+1 is MSB)
//   num: is the immediate fp124s value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_beq124s_immed(addr1, num, label)
{
    nv_cmp124s_immed(addr1, num)
    beq label
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
.macro nv_beq124u_immed_far(addr1, num, label)
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
// branch if two fp124 signed values in memory have the different contents
// branch if addr1 != addr2
// full name is nv_bne124s_mem124s_mem124s
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124s(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    bne label
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
// branch if two fp124s values in memory have the different contents.
// branch if addr1 != addr2
// full name is nv_bne124s_mem124s_mem124s_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124s_far(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    beq Done
    jmp label
Done:

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
// inline macro to branch if one fp124s value in memory has different 
// content than an immediate fp124s bit value.
// branch if addr1 != num
// full name is nv_bne124s_mem124s_immed124s
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   num: is the immediate fp124s value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bne124s_immed(addr1, num, label)
{
    nv_cmp124s_immed(addr1, num)
    bne label
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
//   label: the label to branch to 
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124u(addr1, addr2, label)
{
    nv_blt16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of an fp124s value at one memory
// location is less than the contents of another fp124s value in another
// location.
// branch if addr1 < addr2
// full name is nv_blt124s_mem124s_mem124s
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: the label to branch to if condition is true
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124s(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    bcc label
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
// inline macro to jump to a label if the contents of an fp124s value in  
// one memory location is less than the value of another fp124s value in
// another memory location.
// branch if addr1 < addr2
// full name is nv_blt124s_mem124s_mem124s_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: the label to branch to if comparison is true
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124s_far(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    bcs Done
    jmp label
Done:
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
// inline macro to branch if one fp124s value in memory is less than 
// an immediate fp124s value.
// branch if addr1 < num
// full name is nv_blt124s_mem124s_immed124s
//   addr1: is the address of LSB of one fp124s value (addr1+1 is MSB)
//   num: is the immediate fp124s value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_blt124s_immed(addr1, num, label)
{
    nv_cmp124s_immed(addr1, num)
    bcc label
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
//   label: the label to branch to if condition is true
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124u(addr1, addr2, label)
{
    nv_ble16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of an fp124s value at one memory
// location is less than or equal to another fp124s value at another 
// memory location.
// branch if addr1 <= addr2
// full name is nv_ble124s_mem124s_mem124s
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: the label to branch to if condition is true
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124s(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    bcc label
    beq label
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
// inline macro to branch if the contents of an fp124s value at one memory 
// location is less than or equal to another fp124s value in another memory 
// location.
// branch if addr1 <= addr2
// full name is nv_ble124s_mem124s_mem124s_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: is the address of LSB of one fp124s word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other fp124s word (addr2+1 is MSB)
//   label: the label to branch to if word1 < word2
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124s_far(addr1, addr2, label)
{
    nv_bgt124s(addr1, addr2, Done)
    jmp label
Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one fp124u value in memory is less than or 
// equal to an immediate fp124u value.
// branch if addr1 <= num
// full name is nv_ble124u_mem124u_immed124u
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
// inline macro to branch if one fp124s value in memory is less than or 
// equal to an immediate fp124s value.
// branch if addr1 <= num
// full name is nv_ble124s_mem124s_immed124s
//   addr1: is the address of LSB of one fp124s value (addr1+1 is MSB)
//   num: is the immediate fp124s value to compare with the contents of addr1
//   label: is the label to branch to
// Accum: changes
// X Reg: remains unchanged
// Y Reg: remains unchanged
.macro nv_ble124s_immed(addr1, num, label)
{
    nv_cmp124s_immed(addr1, num)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    bcc label
    beq label
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
// inline macro to branch if the fp124u value at one memory location  
// are greater than the fp124u value in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt124u_mem124u_mem124u
//   addr1: the address of the LSB of one fp124u value
//   addr2: the address of the LSB of the other fp124u value 
//   label: the label to branch to if condition is true
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt124u(addr1, addr2, label)
{
    nv_bgt16(addr1, addr2, label)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the fp124s value at one memory location  
// are greater than the fp124s value in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt124s_mem124s_mem124s
//   addr1: the address of the LSB of one fp124s value
//   addr2: the address of the LSB of the other fp124s value 
//   label: the label to branch to if condition true
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt124s(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    beq Done    // equal so not greater than, we're done
    bcs label   // >= but we already tested for == so must be greater than
Done:

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
// inline macro to branch if the contents of an fp124s value at one memory 
// location are greater than the fp124s value in another memory location.
// branch if addr1 > addr2
// full name is nv_bgt124s_mem124s_mem124s_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of one fp124s value
//   addr2: the address of the LSB of the other fp124s value 
//   label: the label to branch to if addr1 > addr2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bgt124s_far(addr1, addr2, label)
{
    nv_ble124s(addr1, addr2, Done)
    jmp label
Done:
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
// inline macro to branch if one fp124s value in memory is greater than
// an immediate fp124s value.
// branch if addr1 > num
// full name is nv_bgt124s_mem124s_immed124s
//   addr1: is the address of LSB of one fp124s value (addr1+1 is MSB)
//   num: is the immediate fp124s value to compare with the contents of addr1
//   label: is the label to branch to
//   Accum: changes
//   X Reg: no change
//   Y Reg: no change
.macro nv_bgt124s_immed(addr1, num, label)
{
    nv_cmp124s_immed(addr1, num)
    // Carry Flag	Set if addr1 >= addr2
    // Zero Flag	Set if addr1 == addr2

    beq Done    // equal so not greater than, we're done
    bcs label   // >= but we already tested for == so must be greater than
Done:
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
// inline macro to branch if the contents of one fp124u value in memory 
// is greater than or equal to the contents of another fp124u value
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
// inline macro to branch if the contents of one fp124s value in memory 
// is greater than or equal to the contents of another fp124u value
// in another memory location.
// branch if addr1 >= addr2
// full name is nv_bge124s_mem124s_mem124s
//   addr1: the address of the LSB of one fp124s value 
//   addr2: the address of the LSB of the other fp124s value 
//   label: the label to branch to if condition is true
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge124s(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2

    bcs label

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
// inline macro to branch if the contents of one fp124s value at one memory 
// location are greater than or equal to the contents of and fp124s value
// in another memory location.
// branch if addr1 >= addr2
// full name is nv_bge124s_mem124s_mem124s_far
// The branch label's address can be farther than +127/-128 bytes away
//   addr1: the address of the LSB of one fp124s value 
//   addr2: the address of the LSB of the other fp124s value 
//   label: the label to branch to if addr1 >= addr2
// Accum: changes
// X Reg: unchanged
// Y Reg: unchanged
.macro nv_bge124s_far(addr1, addr2, label)
{
    nv_cmp124s(addr1, addr2)
    // Carry Flag	Set if addr1 >= addr2
    bcc Done
    jmp label
Done:
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
// inline macro to branch if one fp124s value in memory is greater or equal 
// to an immediate fp124s value.
// branch if addr1 >= num
// full name is nv_bge124s_mem124s_immed124s
//   addr1: is the address of the LSB of an fp124s value (addr1+1 is MSB)
//   num: is the immediate fp124s bit value to compare with the contents of addr1
//   label: is the label to branch to
.macro nv_bge124s_immed(addr1, num, label)
{
    nv_cmp124s_immed(addr1, num)
    // Carry Flag	Set if addr1 >= num

    bcs label
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

