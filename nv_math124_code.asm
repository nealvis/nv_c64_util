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

//////////////////////////////////////////////////////////////////////////////
// Inline macro to setup and call subroutine to add two fp124s numbers
// and then copy the result.
// This should be faster than using the nv_call_NvAdc124s macro but
// the subroutine parameters NvAdc124sOp1, NvAdc124sOp2 will
// not be preserved.  The macro parameters op1_fp124s, and op2_fp124s
// will still be preserved though.
// macro parameters:
//   op1_fp124s: address of LSB of fp124s value for operand 1 to be copied
//               to the subroutine parameter NvAdc124sOp1.  
//   op2_fp124s: address of LSB of fp124s value for operand 2 to be copied
//               to the subroutine parameter NvAdc124sOp2.  
//   result_fp124s: address of the LSB of an fp124s word into which the
//                  result (NvAdc124sResult) will be copied. 
//   copy_result: boolean flag indicating if the result (NvAdc124sResult) 
//                should be copyied to result_fp124s.  If false then
//                the result will be left in NvAdc123sResult but not
//                copied to result_fp124s 
.macro nv_call_NvAdc124sRuinOps(op1_fp124s, op2_fp124s, result_fp124s, copy_result)
{
    // copy parameters to subroutine fixed parameters 
    nv_xfer124_mem_mem(op1_fp124s, NvAdc124sOp1)
    nv_xfer124_mem_mem(op2_fp124s, NvAdc124sOp2)

    // call subroutine
    jsr NvAdc124sRuinOps

    // copy subroutine result if macro param for result wasn't zero
    .if (copy_result)
    {
        nv_xfer124_mem_mem(NvAdc124sResult, result_fp124s)
    }
}
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Inline macro to setup and call subroutine to add two fp124s numbers
// and then copy the result.
// macro parameters: 
//   op1_fp124s: address of LSB of fp124s value for operand 1 to be copied
//               to the subroutine parameter NvAdc124sOp1.  
//   op2_fp124s: address of LSB of fp124s value for operand 2 to be copied
//               to the subroutine parameter NvAdc124sOp2.  
//   result_fp124s: address of the LSB of an fp124s word into which the
//                  result (NvAdc124sResult) will be copied.  
//   copy_result: boolean flag indicating if the result (NvAdc124sResult) 
//                should be copyied to result_fp124s.  If false then
//                the result will be left in NvAdc123sResult but not
//                copied to result_fp124s 
.macro nv_call_NvAdc124s(op1_fp124s, op2_fp124s, result_fp124s, copy_result)
{
    // copy parameters to subroutine fixed parameters 
    nv_xfer124_mem_mem(op1_fp124s, NvAdc124sOp1)
    nv_xfer124_mem_mem(op2_fp124s, NvAdc124sOp2)

    // call subroutine
    jsr NvAdc124s

    // copy subroutine result if macro param for result wasn't zero
    .if (copy_result)
    {
        nv_xfer124_mem_mem(NvAdc124sResult, result_fp124s)
    }
}

//////////////////////////////////////////////////////////////////////////////