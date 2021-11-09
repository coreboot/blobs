# Firmware list
- spm_firmware.bin

--------------------------------------------------------------------------------
# SPM introduction
SPM is able to turn off more power such as DRAM self-refresh mode and 26M clock off
when system is in suspend. Also, SPM helps support Vcore DVFS feature.

## Who uses it
Linux kernel system suspend and Vcore DVFS.

## How to load `spm_fimware.bin`
Use CBFS to load `spm_fimware.bin` to DRAM and SPM DMA loads it from dram to SPM SRAM.

## Return values
No return value.

## Version
`$ strings spm_firmware.bin | grep pcm_suspend`

--------------------------------------------------------------------------------
# SSPM introduction
SSPM is "Secure System Power Manager" that provides power control in secure domain.
SSPM provides power related features, e.g. CPU DVFS, thermal control, to offload
application processor for security reason.

SSPM firmware is loaded into SSPM SRAM at system initialization.

## Who uses it
Coreboot will load sspm.bin to SSPM SRAM at ramstage.

## How to load `sspm.bin`
Use CBFS to load `sspm.bin`.
No need to pass other parameters to SSPM.

## Return value
No return value.

## Version
`$ strings sspm.bin | grep "SSPM firmware"`

--------------------------------------------------------------------------------
