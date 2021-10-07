# Nealvis' C64 Utilities
This directory holds nv_c64_util which is just a collection of C64 utility routines and macros 

## Overview
All the assembler code in this directory is written for Kick Assembler and in general the setup outlined in the [environment and tools setup](./env_setup.md)

## Conventions
- Files that do not generate any code by themself when assembled have a filename ending in \_macs (for macros)
- Files that do generate code or data when assembled have a filename ending in \_code or \_data
- In general all identifiers to be used outside of the file will start with NV_ or nv_
- Labels in the code are: PascalCase
- Macro names are: lower_case_with_underscores
- Macro parameters are: lower_case_with_underscores
- Constants are: UPPER_CASE_WITH_UNDERSCORES
- Macros that are intended to be instantiated in conjunction with a label to be called via jsr have "\_sr" at the end (for **S**ub**R**outine).  For example to use nv_sprite_wait_scan_sr you should instantiate the macro along with a label similar to this.
```  
  WaitScanSubroutine:
    nv_sprite_wait_last_scanline_sr()
```
Then when you want to call call the subroutine you should use jsr like this.
```
jsr WaitScanSubroutine
```
- Macros that are just intended to be used for inline code generation do not have \_sr or anything else at the end.  For example if you just want your code to include the assembly code to wait for scan you can just place the nv_sprite_wait_scan macro directly in your code like this:
```
nv_sprite_wait_last_scanline()
```

### Branch and Math Macro Naming
There are a number of macros for conditional branching and math operations that are named so that by looking at the name the following things are clear:
  - The operation
  - The bit width (8 bit or 16 bit) of the operands 
  - The sign of operand (signed or unsigned, or either)
  - For conditional branching (if branch is near(within 127/-128 bytes) or far (any address)
 
To this end these macros are named based on the following:
- FullName := nv_OperationSpecifier_OperandSpecifier_OperandSpecifier_FarSpecifier
- OperationSpecifier := Operation[OperationWidth][Sign]
- OperandSpecifier := Operand[OperandWidth][Sign]
- FarSpecifier := [near|far]
- Operation := [mul|adc|etc]
- OperationWidth := [8|16] no default
- OperandWidth := [8|16] if missing then assume same as OperationWidth
- Sign := [u|s|x] s=signed, u=unsigned, x=either signed or unsigned.   Note that signed implies twos compliment for negative values.  Default is u
- Operand:= mem|immed|a|x|y

The FullName above should be fully descriptive for these type of operations but these full names can be clunky so the following short cut rules were created

Rules:
if operation width omitted then must have operand widths
if operation sign is ommited, then assume unsigned operation
if operand is omitted then assume the operand is mem which is a memory address
if operand width is omitted then assume operation width which is required 
if operand specifier is omitted then assume mem
if operand sign is ommited, then assume operand sign is the same as operation sign
If FarSpecifier is left off assume near

Here are some examples of FullNames and equivilant short names along with some explaination 
#### **beq8u_mem8u_mem8u** -> **nv_beq8**   
This is an example for a macro that does a near branch to a label if one 8bit value in memory is equal to another 8bit value in memory.  The short hand name **nv_beq8**  specifies everything that the full name specifies because it follows the following rules
- Operation is beq as seen in shorthand name
- OperationWidth is 8 bit as seen in the short name
- Operation sign is unsigned based on the rule that ommitted operation signs are assumed to be unsigned
- Operation is for a near branch since "far" isn't specified in the macro name.
- First operand is a memory address based on the rule that omitted operands in the name are assumed to be mem
- First operand width is 8 bit based on the rule that omitted operand width are assumed to match the operation width
- First operand sign is unsigned base don the rule that omitted operand sign is assumed to match operation sign
- Second operand is a memory address based on the rule that omitted operands in the name are assumed to be mem
- Second operand width is 8 bit based on the rule that omitted operand width are assumed to match the operation width
- Second operand sign is unsigned based on the rule that omitted operand sign is assumed to match operation sign

#### **nv_beq8u_immed8u_x8u_far** -> **nv_blt8_immed_x_far**   
This is an example for a macro that does a far branch to a label if an immediate 8bit value is less than to the 8bit value the x register.  The short hand name **nv_blt8_immed_x_far**  specifies everything that the full name specifies because it follows the following rules
- Operation is blt (brach if less than) as seen in short name
- OperationWidth is 8 bit as seen in the shorthand name
- Operation sign is unsigned based on the rule that ommitted operation signs are assumed to be unsigned
- Operation is for a far branch as seen in the short name.
- First operand is a an immediate number as specified by "immed" in the short name
- First operand width is 8 bit based on the rule that omitted operand width are assumed to match the operation width
- First operand sign is unsigned base don the rule that omitted operand sign is assumed to match operation sign
- Second operand is the x register as specified by "x" in the short name
- Second operand width is 8 bit based on the rule that omitted operand width are assumed to match the operation width
- Second operand sign is unsigned based on the rule that omitted operand sign is assumed to match operation sign

#### **nv_adc16u_mem16u_mem16u** -> **nv_adc16**   
This is an example for a macro that does an add with carry on two 16bit words in memory.  The short hand name **nv_adc16**  specifies everything that the full name specifies because it follows the following rules
- Operation is adc (add with carry) as seen in short name
- OperationWidth is 16 bit as seen in the shorthand name
- Operation sign is unsigned based on the rule that ommitted operation signs are assumed to be unsigned
- First operand is a an address to the LSB of a 16bit word in memory because omitted operands are assumed to be mem
- First operand width is 16 bit based on the rule that omitted operand width are assumed to match the operation width
- First operand sign is unsigned base don the rule that omitted operand sign is assumed to match operation sign
- Second operand is a an address to the LSB of a 16bit word in memory because omitted operands are assumed to be mem
- Second operand width is 16 bit based on the rule that omitted operand width are assumed to match the operation width
- Second operand sign is unsigned based on the rule that omitted operand sign is assumed to match operation sign


## Usage
There are macros and data parts of the library.  The macros depend on some data variables and lookup tables etc.  All the data can be assembled into
any file by
```
#import "<path to nv_c64_util here>/nv_c64_util_data.asm"
```
After the data has been assembled then the the macros can be assembled with this:
```
#import "<path to nv_c64_util here>/nv_c64_util_macs.asm"
```
When using the above method the data will go into whatever segement and memory block its being imported into.  Which allows the user some flexibility as to where the data goes.  But if you don't prefer you could import both with the following, and the data will go to a default location (towards the end of BASIC memory.)

```
#import "<path to nv_c64_util here>/nv_c64_util_macs_and_data.asm"
```
