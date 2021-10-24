//////////////////////////////////////////////////////////////////////////////
// nv_keyboard_code.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Contains keyboard subroutines

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_keyboard_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif
// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_keyboard_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// subroutine to wait for the user to press any key.  Works both after  
// nv_key_init has been called and by using kernal routines if it hasn't
// been called.
NvKeyWaitAnyKey:
    nv_key_wait_any_key()
    rts
// NvKeyWaitAnyKey - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to wait for no keys to be pressed
NvKeyWaitNoKey:
    nv_key_wait_no_key()
    rts
// NvKeyWaitNoKey - end
//////////////////////////////////////////////////////////////////////////////
