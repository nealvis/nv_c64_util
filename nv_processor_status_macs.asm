//////////////////////////////////////////////////////////////////////////////
// nv_processor_status_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This assembler file contains macros and constants regarding the 
// processor status register and maybe used throughout the 
// nv_c64_utils project

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_processor_status_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


// the 6502 processor status flag bits 
.const NV_PROCSTAT_NONE = $00
.const NV_PROCSTAT_CARRY = $01
.const NV_PROCSTAT_ZERO = $02
.const NV_PROCSTAT_INTERUPT = $04
.const NV_PROCSTAT_DECIMAL = $08
.const NV_PROCSTAT_BREAK = $10
.const NV_PROCSTAT_UNKNOWN = $20
.const NV_PROCSTAT_OVERFLOW = $40
.const NV_PROCSTAT_NEGATIVE = $80
