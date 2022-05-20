//////////////////////////////////////////////////////////////////////////////
// nv_math124_code.asm 
// Copyright(c) 2022 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// contains code/subroutines for fixed point 12.4 math

//////////////////////////////////////////////////////////////////////////////
// Import other modules as needed here
#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math124_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_math124_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// subroutines to add two signed fp124s numbers
// NvAdc124s will preserve the NvAdc124sOp1, and NvAdc124sOp2 values
// NvAdc124sRuinOps will ruin the values of NvAdc124sOp1 and NvAdc124sOp2
// Subroutine params:
//   NvAdc124sOp1: fp124s that will be used as first operand
//   NvAdc124sOp2: fp124s that will be used as second operand
//   NvAdc124sResult: fp124s that will be set to the result upon return
// Example of setup for call:
//     nv_xfer124_mem_mem(op1, NvAdc124sOp1)
//     nv_xfer124_mem_mem(op2, NvAdc124sOp2)
//     jsr NvAdc124s
//     // now NvAdc124sResult has the result 
// Accum changes
// X Reg unchanged
// Y Reg unchanged
NvAdc124s:
{
    nv_adc124s_sr(NvAdc124sOp1, NvAdc124sOp2, NvAdc124sResult)
}

NvAdc124sRuinOps:
{
    nv_adc124s_ruin_ops_sr(NvAdc124sOp1, NvAdc124sOp2, NvAdc124sResult)
}

// Op1 for both subroutines
NvAdc124sOp1: .word $0000

// Op2 for both subroutines
NvAdc124sOp2: .word $0000

// result for both subroutines
NvAdc124sResult: .word $0000

//
//////////////////////////////////////////////////////////////////////////////
