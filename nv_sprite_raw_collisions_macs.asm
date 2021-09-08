//////////////////////////////////////////////////////////////////////////////
// nv_sprite_raw_collisions_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// For macros, constants and other non code or data generating constructs
// regarding sprite collisions based on the raw hw.

#if !NV_C64_UTIL_DATA
.error "Error - nv_sprite_raw_collisions_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"
