//////////////////////////////////////////////////////////////////////////////
// nv_rand_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
/////////////////////////////////////////////////////////////////////////////
// contains inline macros for random numbers
// importing this file will not allocate any memory for data or code
// unless nv_c64_util_data.asm not yet imported in which case it will
// be imported.
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_rand_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

.const VOICE_3_FREQ_REG_ADDR = $D40E
.const VOICE_3_CONTROL_REG_ADDR = $D412
.const VOICE_3_WAVE_OUTPUT = $D41B

//////////////////////////////////////////////////////////////////////////////
// inline macro to initialize random number macros and routines.
// macro params:
//   pre_calc: if true then will precalculate random numbers in a list
//             that will be used later when random numbers needed.
//             since the random number generator depends on the
//             noise generator of the SID, generating random numbers
//             will affect the sound if playing sounds while you 
//             need random numbers.  So pass true and precalculate
//             the numbers before you start the music to preven this.
.macro nv_rand_init(pre_calc)
{
    lda #$FF                        // load accum with max freq value
    sta VOICE_3_FREQ_REG_ADDR       // low byte
    sta VOICE_3_FREQ_REG_ADDR+1     // high byte
    lda #$80                        // value for noise waveform and gate off
    sta VOICE_3_CONTROL_REG_ADDR    // store vals to voice 3 control reg
    lda #$00
    sta nv_rand_index
    .if (pre_calc)
    {
        ldy #1
    OuterLoop:
        ldx #0
    Loop:
        lda VOICE_3_WAVE_OUTPUT
        sta nv_rand_bytes, x
        inx
        bne Loop
        dey
        beq OuterLoop
    }
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to load accum with random byte.
// macro params:
//   precalc: pass true use a precalculated random number
//            if passing true then nv_rand_init() should have also 
//            been executed with pre_calc as true.
.macro nv_rand_byte_a(pre_calc)
{
    .if (pre_calc)
    {
        inc nv_rand_index
        ldx nv_rand_index
        lda nv_rand_bytes, x
    }
    else
    {
        lda VOICE_3_WAVE_OUTPUT
    }
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to create a random color.   A random number from 0 to 15
// will be loaded into the Accum.
//   precalc: pass true use a precalculated random number
//            if passing true then nv_rand_init() should have also 
//            been executed with pre_calc as true.
.macro nv_rand_color_a(pre_calc)
{
    nv_rand_byte_a(pre_calc)
    and #$0F
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to expand after done using all the other macros in this file
.macro nv_rand_done()
{

}
//
//////////////////////////////////////////////////////////////////////////////