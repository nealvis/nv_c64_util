//////////////////////////////////////////////////////////////////////////////
// nv_sprite_extra_macs.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// macros to access the sprite extra data block
// including read/write to/from the extra data block
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_sprite_extra_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_sprite_raw_macs.asm"
#import "nv_screen_rect_macs.asm"
#import "nv_math124_macs.asm"
#import "nv_branch124_macs.asm"

// zero page pointer to use whenever a zero page pointer is needed
// usually used to store and load to and from the sprite extra pointer
.const ZERO_PAGE_LO = $FB
.const ZERO_PAGE_HI = $FC

// Constants for screen edges for bouncing.  

// These are the default max position values when bouncing
.const NV_SPRITE_LEFT_BOUNCE_FP124S_DEFAULT = NvBuildClosest124s(23)
.const NV_SPRITE_RIGHT_BOUNCE_FP124S_DEFAULT = NvBuildClosest124s(320)
.const NV_SPRITE_TOP_BOUNCE_FP124S_DEFAULT = NvBuildClosest124s(50)
.const NV_SPRITE_BOTTOM_BOUNCE_FP124S_DEFAULT = NvBuildClosest124s(234)

// These are the default max position values when wrapping
.const NV_SPRITE_LEFT_WRAP_FP124S_DEFAULT = NvBuildClosest124s(2)
.const NV_SPRITE_RIGHT_WRAP_FP124S_DEFAULT = NvBuildClosest124s(339) 
.const NV_SPRITE_TOP_WRAP_FP124S_DEFAULT = NvBuildClosest124s(32)
.const NV_SPRITE_BOTTOM_WRAP_FP124S_DEFAULT = NvBuildClosest124s(249)

// These are the possible actions when sprite would exceed max position
.const NV_SPRITE_ACTION_WRAP = 0
.const NV_SPRITE_ACTION_BOUNCE = 1

// struct that provides info for a sprite.  this is a construct of the assembler
// it just provides an easy way to reference all these different compile time values.
// No actual memory is created when an instance of the struct is created.
.struct nv_sprite_info_struct{
    name, 
    num, 
    init_x_fp124s, 
    init_y_fp124s, 
    init_x_vel_fp124s, 
    init_y_vel_fp124s, 
    data_ptr, 
    base_addr, 
    action_top, 
    bounce_left, 
    bounce_bottom, 
    bounce_right,
    top_min_fp124s, 
    left_min_fp124s, 
    bottom_max_fp124s, 
    right_max_fp124s, 
    enabled,
    hitbox_left,    // left coord within sprite
    hitbox_top,     // top coord within sprite 
    hitbox_right,   // right coord within sprite
    hitbox_bottom}  // bottom coord within sprite


//////////////////////////////////////////////////////////////////////////////
// macro that creates a block of memory to hold all the extra data for a 
// sprite such as its velocity and an in memory x and y location.
// macro parameter:
//   spt_info: is an instance of the nv_sprite_info_struct.  This contains
//             all the compile time info needed/known about the strite.
.macro nv_sprite_extra_data(spt_info)
{
    *=spt_info.base_addr                                 // tell assembler where to put this stuff
    sprite_base_addr:                                    // the address of the first byte
    sprite_num_addr: .byte spt_info.num                  // the sprite number (0-7 only)
    sprite_x_fp124s_addr: .word spt_info.init_x_fp124s   // the sprite's x loc
    sprite_y_fp124s_addr: .word spt_info.init_y_fp124s   // the sprite's y loc
    sprite_vel_x_fp124s_addr: .word spt_info.init_x_vel_fp124s // the sprite's x velocity in pixels
    sprite_vel_y_fp124s_addr: .word spt_info.init_y_vel_fp124s // the sprite's y velocity in pixels
    sprite_data_ptr_addr: .word spt_info.data_ptr        // 16 bit addr of sprite data
    sprite_action_top: .byte spt_info.action_top         // set to 1 to bounce bottom or 0 not to
    sprite_bounce_left: .byte spt_info.bounce_left       // set to 1 to bounce bottom or 0 not to
    sprite_bounce_bottom: .byte spt_info.bounce_bottom   // set to 1 to bounce bottom or 0 not to
    sprite_bounce_right: .byte spt_info.bounce_right     // set to 1 to bounce bottom or 0 not to

    // top boundry for the sprite
    sprite_top_min_fp124s_addr: .word spt_info.top_min_fp124s == 0 ? (spt_info.action_top == NV_SPRITE_ACTION_BOUNCE ? NV_SPRITE_TOP_BOUNCE_FP124S_DEFAULT : NV_SPRITE_TOP_WRAP_FP124S_DEFAULT) : spt_info.top_min_fp124s
    
    // left boundry for the sprite
    sprite_left_min_fp124s_addr: .word spt_info.left_min_fp124s == 0 ? (spt_info.bounce_left == 1 ? NV_SPRITE_LEFT_BOUNCE_FP124S_DEFAULT : NV_SPRITE_LEFT_WRAP_FP124S_DEFAULT) :spt_info.left_min_fp124s 

   // bottom boundry for the sprite
    sprite_bottom_max_fp124s_addr: .word spt_info.bottom_max_fp124s == 0 ? (spt_info.bounce_bottom == 1 ? NV_SPRITE_BOTTOM_BOUNCE_FP124S_DEFAULT : NV_SPRITE_BOTTOM_WRAP_FP124S_DEFAULT) :spt_info.bottom_max_fp124s

    // right boundry for the sprite
    sprite_right_max_fp124s_addr: .word spt_info.right_max_fp124s == 0 ? (spt_info.bounce_right == 1 ? NV_SPRITE_RIGHT_BOUNCE_FP124S_DEFAULT : NV_SPRITE_RIGHT_WRAP_FP124S_DEFAULT) : spt_info.right_max_fp124s

    // sprite enabled flag.  nonzero is enabled, zero is disabled
    sprite_enabled: .byte 0

    // the hitbox coords are within the sprite's rectangle where the upper left
    // corner of the sprite (ie the sprites official location) is (0, 0)
    // So the min value will be 0 and max will be sprite height/width.
    // To get the screen coords of the hitbox just add the sprite location to 
    // the hitbox coords within the sprite.
    sprite_hitbox_left_addr: .byte spt_info.hitbox_left
    sprite_hitbox_top_addr: .byte spt_info.hitbox_top
    sprite_hitbox_right_addr: .byte spt_info.hitbox_right
    sprite_hitbox_bottom_addr: .byte spt_info.hitbox_bottom

    // some scratch memory for each sprite     
    sprite_scratch1: .word 0
    sprite_scratch2: .word 0

    sprite_scratch_rect:
    sprite_scratch_rect_left: .word 0
    sprite_scratch_rect_top: .word 0
    sprite_scratch_rect_right: .word 0
    sprite_scratch_rect_bottom: .word 0    
}

//////////////////////////////////////////////////////////////////////////////
// offsets to use to get to the different fields within the nv_sprite block
.const NV_SPRITE_NUM_OFFSET = 0
.const NV_SPRITE_X_FP124S_OFFSET = NV_SPRITE_NUM_OFFSET + 1
.const NV_SPRITE_Y_FP124S_OFFSET = NV_SPRITE_X_FP124S_OFFSET + 2
.const NV_SPRITE_VEL_X_FP124S_OFFSET = NV_SPRITE_Y_FP124S_OFFSET + 2
.const NV_SPRITE_VEL_Y_FP124S_OFFSET = NV_SPRITE_VEL_X_FP124S_OFFSET + 2
.const NV_SPRITE_DATA_PTR_OFFSET = NV_SPRITE_VEL_Y_FP124S_OFFSET + 2
.const NV_SPRITE_ACTION_TOP_OFFSET = NV_SPRITE_DATA_PTR_OFFSET + 2
.const NV_SPRITE_ACTION_LEFT_OFFSET = NV_SPRITE_ACTION_TOP_OFFSET + 1
.const NV_SPRITE_ACTION_BOTTOM_OFFSET = NV_SPRITE_ACTION_LEFT_OFFSET + 1
.const NV_SPRITE_ACTION_RIGHT_OFFSET = NV_SPRITE_ACTION_BOTTOM_OFFSET + 1

.const NV_SPRITE_TOP_MIN_FP124S_OFFSET = NV_SPRITE_ACTION_RIGHT_OFFSET + 1
.const NV_SPRITE_LEFT_MIN_FP124S_OFFSET = NV_SPRITE_TOP_MIN_FP124S_OFFSET + 2
.const NV_SPRITE_BOTTOM_MAX_FP124S_OFFSET = NV_SPRITE_LEFT_MIN_FP124S_OFFSET + 2
.const NV_SPRITE_RIGHT_MAX_FP124S_OFFSET = NV_SPRITE_BOTTOM_MAX_FP124S_OFFSET + 2

.const NV_SPRITE_ENABLED_OFFSET = NV_SPRITE_RIGHT_MAX_FP124S_OFFSET + 2

.const NV_SPRITE_HITBOX_LEFT_OFFSET = NV_SPRITE_ENABLED_OFFSET + 1
.const NV_SPRITE_HITBOX_TOP_OFFSET = NV_SPRITE_HITBOX_LEFT_OFFSET + 1
.const NV_SPRITE_HITBOX_RIGHT_OFFSET = NV_SPRITE_HITBOX_TOP_OFFSET + 1
.const NV_SPRITE_HITBOX_BOTTOM_OFFSET = NV_SPRITE_HITBOX_RIGHT_OFFSET + 1

.const NV_SPRITE_SCRATCH1_OFFSET = NV_SPRITE_HITBOX_BOTTOM_OFFSET + 1
.const NV_SPRITE_SCRATCH2_OFFSET = NV_SPRITE_SCRATCH1_OFFSET + 2

// 8 bytes to create four 16 bit coords for a rect (left, top, right, bottom)
.const NV_SPRITE_SCRATCH_RECT_OFFSET = NV_SPRITE_SCRATCH2_OFFSET + 2
.const NV_SPRITE_SCRATCH_RECT_LEFT_OFFSET = NV_SPRITE_SCRATCH_RECT_OFFSET
.const NV_SPRITE_SCRATCH_RECT_TOP_OFFSET = NV_SPRITE_SCRATCH_RECT_LEFT_OFFSET + 2
.const NV_SPRITE_SCRATCH_RECT_RIGHT_OFFSET = NV_SPRITE_SCRATCH_RECT_TOP_OFFSET + 2
.const NV_SPRITE_SCRATCH_RECT_BOTTOM_OFFSET = NV_SPRITE_SCRATCH_RECT_RIGHT_OFFSET + 2

//////////////////////////////////////////////////////////////////////////////
// assembler function to return the address of the sprite number
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_num_addr(info)
{
    .return info.base_addr + NV_SPRITE_NUM_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// assembler function to return the address of the sprite Y velocity
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_vel_y_fp124s_addr(info) 
{
    .return info.base_addr + NV_SPRITE_VEL_Y_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// assembler function to return the address of the sprite X velocity.  
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_vel_x_fp124s_addr(info)
{
    .return info.base_addr + NV_SPRITE_VEL_X_FP124S_OFFSET
}


//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the sprite X position.
// This is a 16 bit value so the address of the LSB will be returned  
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_x_fp124s_addr(info)
{
    .return nv_sprite_x_fp124s_lsb_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the LSB of sprite X position.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_x_fp124s_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_X_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the hitbox left byte
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_hitbox_left_addr(info)
{
    .return info.base_addr + NV_SPRITE_HITBOX_LEFT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the hitbox top byte
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_hitbox_top_addr(info)
{
    .return info.base_addr + NV_SPRITE_HITBOX_TOP_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the hitbox right byte
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_hitbox_right_addr(info)
{
    .return info.base_addr + NV_SPRITE_HITBOX_RIGHT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the hitbox bottom byte
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_hitbox_bottom_addr(info)
{
    .return info.base_addr + NV_SPRITE_HITBOX_BOTTOM_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch rect
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch_rect_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH_RECT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch rect left coord
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch_rect_left_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH_RECT_LEFT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch rect top coord
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch_rect_top_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH_RECT_TOP_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch rect right coord
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch_rect_right_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH_RECT_RIGHT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch rect bottom coord
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch_rect_bottom_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH_RECT_BOTTOM_OFFSET
}


//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the MSB of sprite X position.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_x_fp124s_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_X_FP124S_OFFSET+1
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the sprite Y position.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_y_fp124s_addr(info)
{
    .return info.base_addr + NV_SPRITE_Y_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the sprite's data pointer.
// This is not the address the data pointer is pointing to but the address
// of the pointer itself.
// This is a 16 bit value so the address of the LSB will be returned
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_data_ptr_addr(info)
{
    .return nv_sprite_data_ptr_lsb_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of LSB of the sprite's data 
// pointer.  This is not the addr the data pointer is pointing to but the addr
// of the pointer itself.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_data_ptr_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_DATA_PTR_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of MSB of the sprite's data 
// pointer.  This is not the addr the data pointer is pointing to but the addr
// of the pointer itself.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_data_ptr_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_DATA_PTR_OFFSET + 1
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite top action.
// this address should contain one of the NV_SPRITE_ACTION_XXX values
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_top_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_ACTION_TOP_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite left action.
// this address should contain one of the NV_SPRITE_ACTION_XXX values
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_left_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_ACTION_LEFT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite bottom action.
// this address should contain one of the NV_SPRITE_ACTION_XXX values
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_bottom_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_ACTION_BOTTOM_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite right action.
// this address should contain one of the NV_SPRITE_ACTION_XXX values
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_right_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_ACTION_RIGHT_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite top min
// position on the screen.  Attempting to move to a position less than
// this will result in the top action being taken which could be bounce, 
// wrap, etc.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_top_min_fp124s_addr(info)
{
    .return info.base_addr + NV_SPRITE_TOP_MIN_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite left min
// position on the screen.  Attempting to move to a position less than
// this will result in the left action being taken which could be bounce, 
// wrap, etc.
// This is a 16 bit value so the addr of the LSB will be returned
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_left_min_fp124s_addr(info)
{
    .return info.base_addr + NV_SPRITE_LEFT_MIN_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the LSB of sprite left min
// position on the screen.  Attempting to move to a position less than
// this will result in the left action being taken which could be bounce, 
// wrap, etc.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_left_min_fp124s_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_LEFT_MIN_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the MSB of sprite left min
// position on the screen.  Attempting to move to a position less than
// this will result in the left action being taken which could be bounce, 
// wrap, etc.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_left_min_fp124s_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_LEFT_MIN_FP124S_OFFSET+1
}


//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of sprite bottom max
// position on the screen.  Attempting to move to a position greater than
// this will result in the bottom action being taken which could be bounce, 
// wrap, etc.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_bottom_max_fp124s_addr(info)
{
    .return info.base_addr + NV_SPRITE_BOTTOM_MAX_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the sprite right max
// position on the screen.  Attempting to move to a position greater than
// this will result in the right action being taken which could be bounce, 
// wrap, etc.
// This is a 16 bit value so the addr of the LSB will be returned
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_right_max_fp124s_addr(info)
{
    .return nv_sprite_right_max_fp124s_lsb_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the LSB of sprite right max
// position on the screen.  Attempting to move to a position greater than
// this will result in the right action being taken which could be bounce, 
// wrap, etc.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_right_max_fp124s_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_RIGHT_MAX_FP124S_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the the MSB of sprite right max
// position on the screen.  Attempting to move to a position greater than
// this will result in the right action being taken which could be bounce, 
// wrap, etc.
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_right_max_fp124s_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_RIGHT_MAX_FP124S_OFFSET+1
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch1 word for sprite
// This is 16 bit value so addr of LSB will be returned
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch1_word_addr(info)
{
    .return nv_sprite_scratch1_word_lsb_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the LSB of scratch1 word 
// for sprite
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch1_word_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH1_OFFSET
}

//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the MLB of scratch1 word 
// for sprite
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch1_word_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH1_OFFSET+1
}


//////////////////////////////////////////////////////////////////////////////
// Assembler function to return the address of the scratch2 word for sprite
// This is 16 bit value so addr of LSB will be returned
// function parameters:
//   info: nv_sprite_info_struct that contains the address to return
.function nv_sprite_scratch2_word_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH2_OFFSET
}


//////////////////////////////////////////////////////////////////////////////
// move the sprite's data pointer to the zero page for some indirection
// assume that when this macro is used that the address of the sprite's 
// extra data is in ZERO_PAGE_LO and ZERO_PAGE_HI already.
// after this macro is executed the ZERO_PAGE_LO and ZERO_PAGE_HI 
// will contain the address of the sprite's data (the 64 bytes that
// define the sprite's shape and color)
.macro nv_sprite_data_ptr_to_zero_page()
{
   
    nv_sprite_extra_word_to_mem(NV_SPRITE_DATA_PTR_OFFSET, scratch_word)
    
    // store sprite data pointer in scratch word to zero page.
    // note this over writes the pointer to extra data in zero page
    // which many of the macros in this file rely on as a pre condition.
    lda scratch_word
    sta ZERO_PAGE_LO

    lda scratch_word+1
    sta ZERO_PAGE_HI
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data bloc assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  byte from the extra data will be put in Accumulator
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get. 
// Y will be changed,
// X not changed
// A will contain the bye from the extra data 
.macro nv_sprite_extra_byte_to_a(offset)
{
    // use indirect addressing to get the sprite number
    ldy #offset             // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y    // indirect indexed load sprite num to accum
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data bloc assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  Byte from the extra data will be put in X register
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get.  
.macro nv_sprite_extra_byte_to_x(offset)
{
    nv_sprite_extra_byte_to_a(offset)
    tax
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data bloc assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  Byte from the extra data will be put in Y register
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get.  
.macro nv_sprite_extra_byte_to_y(offset)
{
    nv_sprite_extra_byte_to_a(offset)
    tay
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data block assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  Byte from the extra data will be put in the specified
// memory location.
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get.  
//  mem: is the memory location in which to copy the byte
.macro nv_sprite_extra_byte_to_mem(offset, mem)
{
    nv_sprite_extra_byte_to_a(offset)
    sta mem
}


//////////////////////////////////////////////////////////////////////////////
// copy a byte from memory to an offset within sprite extra block.
// Assumes that the pointer to the extra data block is
// already in ZERO_PAGE_LO and ZERO_PAGE_HI
// macro parameters:
//   mem: the source memory location from which to copy the byte
//   offset: the offset within the extra block (destination) to write 
//           the byte
// Y changes
// A changes
// X unchanged
.macro nv_sprite_mem_byte_to_extra(mem, offset)
{
    lda mem
    nv_sprite_a_to_extra(offset)
}

//////////////////////////////////////////////////////////////////////////////
// copy a 16 bit word from offset within sprite extra memory to somewhere
// else in memory.  Assumes that the pointer to the extra data block is
// already in ZERO_PAGE_LO and ZERO_PAGE_HI
// macro parameters:
//   offset: the offset within the sprite extra block of low byte of word
//   mem_lo: the low byte of detination memory location
// Y changes
// A changes
// X unchanged
.macro nv_sprite_extra_word_to_mem(offset, mem_lo)
{
    nv_sprite_extra_byte_to_a(offset)
    sta mem_lo
    nv_sprite_extra_byte_to_a(offset+1)
    sta mem_lo+1
}


//////////////////////////////////////////////////////////////////////////////
// copy a 16 bit word from memory to an offset within sprite extra block.
// Assumes that the pointer to the extra data block is
// already in ZERO_PAGE_LO and ZERO_PAGE_HI
// macro parameters:
//   mem_lo: the LSB of source memory location to copy to the extra block
//   offset: the offset of LSB to of the destination word to write within 
//           the sprite extra block 
// Y changes
// A changes
// X unchanged
.macro nv_sprite_mem_word_to_extra(mem_lo, offset)
{
    lda mem_lo
    nv_sprite_a_to_extra(offset)
    lda mem_lo+1
    nv_sprite_a_to_extra(offset+1)
}


//////////////////////////////////////////////////////////////////////////////
// store accum contents to the specified offset within the extra data block
// pointed to by ZERO_PAGE_LO and ZERO_PAGE_HI
// Y Reg: will be changed
// Accum: will not be changed, 
//        but must be set to value to be written before using macro
// X Reg: will not be changed
.macro nv_sprite_a_to_extra(offset)
{
    // use indirect addressing to get the sprite number
    ldy #offset       // load Y reg with offset to sprite number
    sta (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
}

//////////////////////////////////////////////////////////////////////////////
// store x reg contents to the specified offset within the extra data block
// pointed to by ZERO_PAGE_LO and ZERO_PAGE_HI
// Y Reg: will be changed
// Accum: will be changed  
// X Reg: set to value to be written before using macro
.macro nv_sprite_x_to_extra(offset)
{
    txa
    nv_sprite_a_to_extra(offset)
}



//////////////////////////////////////////////////////////////////////////////
// subroutine to move a sprite based on information in the sprite extra 
// struct (info) that is passed into the macro.  The sprite x and y location
// in memory will be updated according to the x and y velocity.
// Note if the sprite goes off the edge it will be take the appropriate action
// like move to the opposite side of the screen or bounce based on sprite 
// extra data.
// Note that this only updates the location in memory, it doesn't update the
// sprite location in sprite registers.  To update sprite location in registers
// and on the screen, call nv_sprite_set_location_from_memory_sr after this.
.macro nv_sprite_move_any_direction_sr(info)
{
    nv_bpl124s_far(nv_sprite_vel_y_fp124s_addr(info), PosVelY)

NegVelY:
    nv_sprite_move_negative_y(info)
    jmp DoneY

PosVelY:
    nv_sprite_move_positive_y(info)
    
DoneY:
// Y location done, now on to X
    nv_bmi124s_far(nv_sprite_vel_x_fp124s_addr(info), NegVelX)

PosVelX:
// moving right (positive X velocity)
    nv_sprite_move_positive_x(info)
    jmp FinishedUpdate

NegVelX:
// moving left (negative X velocity)
    nv_sprite_move_negative_x(info)

FinishedUpdate:
    rts                // already popped the return address, jump back now
}

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_positive_y(info)
{
    // put potential new y in the sprite's Y position
    nv_adc124s(nv_sprite_y_fp124s_addr(info), nv_sprite_vel_y_fp124s_addr(info), nv_sprite_y_fp124s_addr(info))

    // if its less than bottom then no action to take, we are done
    nv_blt124s_far(nv_sprite_y_fp124s_addr(info), nv_sprite_bottom_max_fp124s_addr(info), Done)

    // if get here then moving past bottom and need to take appropriate action
    // bounce, wrap, etc
    nv_beq8_immed_far(nv_sprite_bottom_action_addr(info), NV_SPRITE_ACTION_WRAP, DoWrap)

DoBounce:
    // bounce by reversing the sign of the y velocity
    nv_ops124s(nv_sprite_vel_y_fp124s_addr(info))

    // now put the y position back to where it was before we added velocity
    // (undo the y position update above)
    nv_adc124s(nv_sprite_y_fp124s_addr(info), nv_sprite_vel_y_fp124s_addr(info), nv_sprite_y_fp124s_addr(info))
    jmp Done

DoWrap:
    // wrap to top by setting current y position to the top
    nv_xfer124_mem_mem(nv_sprite_top_min_fp124s_addr(info), nv_sprite_y_fp124s_addr(info))
    jmp Done

Done:

}    


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_negative_y(info)
{
    // put potential new y in the sprite's Y position
    nv_adc124s(nv_sprite_y_fp124s_addr(info), nv_sprite_vel_y_fp124s_addr(info), nv_sprite_y_fp124s_addr(info))

    // if its greater than top then no action to take, we are done
    nv_bgt124s_far(nv_sprite_y_fp124s_addr(info), nv_sprite_top_min_fp124s_addr(info), Done)

    // if get here then moving past bottom and need to take appropriate action
    // bounce, wrap, etc
    nv_beq8_immed_far(nv_sprite_top_action_addr(info), NV_SPRITE_ACTION_WRAP, DoWrap)

DoBounce:
    // bounce by reversing the sign of the y velocity
    nv_ops124s(nv_sprite_vel_y_fp124s_addr(info))

    // now put the y position back to where it was before we added velocity
    // (undo the y position update above)
    nv_adc124s(nv_sprite_y_fp124s_addr(info), nv_sprite_vel_y_fp124s_addr(info), nv_sprite_y_fp124s_addr(info))
    jmp Done

DoWrap:
    // wrap to bottom by setting current y position to the bottom
    nv_xfer124_mem_mem(nv_sprite_bottom_max_fp124s_addr(info), nv_sprite_y_fp124s_addr(info))
    jmp Done

Done:
}

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_positive_x(info)
{
    // put potential new x in the sprite's x position
    nv_adc124s(nv_sprite_x_fp124s_addr(info), nv_sprite_vel_x_fp124s_addr(info), nv_sprite_x_fp124s_addr(info))

    // if its less than right then no action to take, we are done
    nv_blt124s_far(nv_sprite_x_fp124s_addr(info), nv_sprite_right_max_fp124s_addr(info), Done)

    // if get here then moving past right and need to take appropriate action
    // bounce, wrap, etc
    nv_beq8_immed_far(nv_sprite_right_action_addr(info), NV_SPRITE_ACTION_WRAP, DoWrap)

DoBounce:
    // bounce by reversing the sign of the x velocity
    nv_ops124s(nv_sprite_vel_x_fp124s_addr(info))

    // now put the x position back to where it was before we added velocity
    // (undo the x position update above)
    nv_adc124s(nv_sprite_x_fp124s_addr(info), nv_sprite_vel_x_fp124s_addr(info), nv_sprite_x_fp124s_addr(info))
    jmp Done

DoWrap:
    // wrap to left by setting current x position to the top
    nv_xfer124_mem_mem(nv_sprite_left_min_fp124s_addr(info), nv_sprite_x_fp124s_addr(info))
    jmp Done

Done:
}    

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_negative_x(info)
{
    // put potential new x in the sprite's X position
    nv_adc124s(nv_sprite_x_fp124s_addr(info), nv_sprite_vel_x_fp124s_addr(info), nv_sprite_x_fp124s_addr(info))

    // if its greater than left min then no action to take, we are done
    nv_bgt124s_far(nv_sprite_x_fp124s_addr(info), nv_sprite_left_min_fp124s_addr(info), Done)

    // if get here then moving past bottom and need to take appropriate action
    // bounce, wrap, etc
    nv_beq8_immed_far(nv_sprite_left_action_addr(info), NV_SPRITE_ACTION_WRAP, DoWrap)

DoBounce:
    // bounce by reversing the sign of the x velocity
    nv_ops124s(nv_sprite_vel_x_fp124s_addr(info))

    // now put the x position back to where it was before we added velocity
    // (undo the x position update above)
    nv_adc124s(nv_sprite_x_fp124s_addr(info), nv_sprite_vel_x_fp124s_addr(info), nv_sprite_x_fp124s_addr(info))
    jmp Done

DoWrap:
    // wrap to right by setting current x position to the bottom
    nv_xfer124_mem_mem(nv_sprite_right_max_fp124s_addr(info), nv_sprite_x_fp124s_addr(info))
    jmp Done

Done:
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to set the action for the scenario when the sprite is 
// attempting to move past its left min position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_left_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_left_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro set the action for the scenario when the sprite is 
// attempting to move past its right max position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_right_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_right_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro set the action for the scenario when the sprite is 
// attempting to move past its top min position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_top_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_top_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the action for the scenario when the sprite is 
// attempting to move past its bottom max position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_bottom_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_bottom_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// in line macro set the action for the scenario when the sprite is 
// attempting to move past any max or min position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_all_actions(info, value)
{
    ldx #value
    stx nv_sprite_left_action_addr(info)
    stx nv_sprite_top_action_addr(info)
    stx nv_sprite_right_action_addr(info)
    stx nv_sprite_bottom_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to set the action for the scenario when the sprite is 
// attempting to move past its min or max position in any direction.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_all_actions_sr(info, value)
{
    nv_sprite_set_all_actions(info, value)
    rts
}

//////////////////////////////////////////////////////////////////////////////
// Inline macro (no rts) to setup everything for a sprite so its ready to 
// be enabled and moved.
.macro nv_sprite_setup(info)
{
    nv_sprite_raw_set_mode(info.num, info.data_ptr)
    nv_sprite_raw_set_data_ptr(info.num, info.data_ptr)
    nv_sprite_raw_set_color_from_data(info.num, info.data_ptr)
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to setup the sprite so that its ready to be enabled 
// and moved.  
.macro nv_sprite_setup_sr(info)
{
    nv_sprite_setup(info)
    rts
}


//////////////////////////////////////////////////////////////////////////////
// Inline macro to test if a sprite overlaps with a character on screen
// 
// Params: 
//   X Reg: character's X loc on screen
//   Y Reg: character's Y loc on screen
// macro params:
//   rect1_addr: is a temp rectangle that will be used to 
//               determine overlap.  it will be filled with 
//               the sprite's rectangle pixel coords
//   char_rect_addr: is a temp retangle that will be used to 
//                   store the char's rectangle with pixel coords
//                   it doesn't need to be set prior to using macro
//                   the macro just needs the space to use
// Return: loads the accum with 0 for no overlap or nonzero if is overlap
// 
.macro nv_sprite_check_overlap_char(info, char_rect_addr)
{
    nv_screen_rect_char_coord_to_screen_pixels(char_rect_addr)
    nv_sprite_check_overlap_rect(info, char_rect_addr)
}


//////////////////////////////////////////////////////////////////////////////
// Inline macro to test if a sprite's hitbox rectangle overlaps 
// with a prefilled rectangle
// 
// macro params:
//   info: the sprite info struct
//   rect_addr: is address of retangle whose contents will be tested for
//              overlap with the sprite's rectangle.. the contents must
//              be prefilled with coords
// Return: loads the accum with 0 for no overlap or nonzero if is overlap
.macro nv_sprite_check_overlap_rect(info, rect_addr)
{
    .label r1_left = nv_sprite_scratch_rect_left_addr(info)
    .label r1_top = nv_sprite_scratch_rect_top_addr(info)
    .label r1_right = nv_sprite_scratch_rect_right_addr(info)
    .label r1_bottom = nv_sprite_scratch_rect_bottom_addr(info)

    .label r2_left = rect_addr
    .label r2_top = rect_addr + 2
    .label r2_right = rect_addr + 4
    .label r2_bottom = rect_addr + 6

    .const SPRITE_WIDTH = 24
    .const SPRITE_HEIGHT = 21
    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
    .const CHAR_PIXEL_WIDTH = $0008
    .const CHAR_PIXEL_HEIGHT = $0008

    /////////// put sprite's rectangle to rect1, use the hitbox not full sprite
    nv_conv124s_mem16s(nv_sprite_x_fp124s_addr(info), r1_left)
    nv_adc16x_mem16x_mem8u(r1_left, nv_sprite_hitbox_right_addr(info), r1_right)
    nv_adc16x_mem16x_mem8u(r1_left, nv_sprite_hitbox_left_addr(info), r1_left)

    nv_conv124s_mem16s(nv_sprite_y_fp124s_addr(info), r1_top)
    nv_adc16x_mem16x_mem8u(r1_top, nv_sprite_hitbox_bottom_addr(info), r1_bottom)
    nv_adc16x_mem16x_mem8u(r1_top, nv_sprite_hitbox_top_addr(info), r1_top)

    // now check for overlap with rect1 and rect2
    nv_check_rect_overlap16(nv_sprite_scratch_rect_addr(info), rect_addr)
}



