# Firmware list
- sspm.bin
- dpm.dm
- dpm.pm

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
# DPM introduction
DPM is a hardware module for DRAM Power Management, which is used for DRAM low power.
For example: self refresh, disable PLL/DLL when not in use.

DPM includes two parts of images: data part (`dpm.dm`) and program part (`dpm.pm`).

## Who uses it
Coreboot loads dpm at ramstage, and copies `dpm.dm` & `dpm.pm` to DPM SRAM.

## How to load DPM
Use CBFS to load `dpm.dm` and `dpm.pm`.
No need to pass other parameters to DPM.

## Return values
No return value.

## Add version
```
$ echo -n 'DPMD Firmware version: x.x' >> dpm.dm
$ echo -n 'DPMP Firmware version: x.x' >> dpm.pm
```

## Version
```
$ strings dpm.dm | grep version
$ strings dpm.pm | grep version
```

--------------------------------------------------------------------------------
