# Firmware list
- mcupm.bin

--------------------------------------------------------------------------------
# MCUPM introduction
MCUPM is a hardware module which is used for MCUSYS Power Management.
MCUPM firmware (`mcupm.bin`) is loaded into MCUPM SRAM at system initialization.

## Who uses it
Coreboot will load MCUPM at ramstage. It will copy mcupm.bin to MCUPM SRAM.

## How to load `mcupm.bin`
Use CBFS to load `mcupm.bin`, then set normal boot flag and release software reset pin of MCUPM.

## Return values
No return value.

## Version
`$ strings mcupm.bin | grep "MCUPM firmware"`

--------------------------------------------------------------------------------
