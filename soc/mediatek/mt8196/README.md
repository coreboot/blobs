# Firmware list
- mcupm.bin
- sspm.bin
- dpm.dm
- dpm.pm
- dram.elf
- spm_firmware.bin
- gpueb_fw.img
- pi_img.img
- mtk_fsp_romstage.elf

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
# `dram.elf` introduction
`dram.elf` is an ELF format file, which performs DRAM full calibration, DRAM
fast calibration and returns the trained calibration parameters to the caller.
The caller may store the parameters on NOR/NAND or eMMC for faster subsequent
bootups.

## Who uses it
Coreboot loads `dram.elf` during the first bootup if no valid DRAM parameters
are found on NOR/NAND or eMMC.

## How to load `dram.elf`
Coreboot locates `dram.elf` file, locates the entry point `_start`,
passes a `dramc_param` struct argument `dparam` to it, and calls
`_start(&dparam)` to execute `dram.elf`.

## Parameters
```
struct dramc_param {
	struct dramc_param_header header;
	void (*do_putc)(unsigned char c);
	struct dramc_data dramc_datas;
};
```

Below shows the internal structure of `dramc_param`:
```
struct dramc_param_header {
	u16 version;	/* DRAMC_PARAM_HEADER_VERSION, set in coreboot */
	u16 size;	/* size of whole dramc_param, set in coreboot */
	u16 status;	/* DRAMC_PARAM_STATUS_CODES, set in dram blob */
	u16 flags;	/* DRAMC_PARAM_FLAG, set in dram blob */
	u16 config;	/* DRAMC_PARAM_CONFIG, set in coreboot */
};

struct sdram_params {
	/* rank, cbt */
	u32 rank_num;
	u32 dram_cbt_mode;

	u16 delay_cell_timex100;
	u8 u18ph_dly;

	/* duty */
	s8 duty_clk_delay[CHANNEL_MAX][RANK_MAX];
	s8 duty_dqs_delay[CHANNEL_MAX][DQS_NUMBER_LP5];
	s8 duty_wck_delay[CHANNEL_MAX][DQS_NUMBER_LP5];
	.......
	.......
};

struct ddr_mrr_info {
	u16 mr5_vendor_id;
	u16 mr6_revision_id;
	u16 mr7_revision_id;
	u64 mr8_density[RANK_MAX];
	u32 rank_nums;
	u8 die_num[RANK_MAX];
};

struct emi_mdl {
	u32 cona_val;
	u32 conh_val;
	u32 conf_val;
	u32 chn_cona_val;
};

struct sdram_info {
	u32 ddr_type;		/* SDRAM_DDR_TYPE */
	u32 ddr_geometry;	/* SDRAM_DDR_GEOMETRY_TYPE */
};

struct ddr_base_info {
	u32 config_dvfs;		/* SDRAM_DVFS_FLAG */
	struct sdram_info sdram;
	u32 voltage_type;		/* SDRAM_VOLTAGE_TYPE */
	u32 support_ranks;
	u64 rank_size[RANK_MAX];
	struct emi_mdl emi_config;
	DRAM_CBT_MODE_T cbt_mode[RANK_MAX];
	struct ddr_mrr_info mrr_info;
	u32 data_rate;
};

struct dramc_data {
	struct ddr_base_info ddr_info;
	struct sdram_params freq_params[DRAM_DFS_SHU_MAX];
};
```

## The output of `dram.elf`
`dram.elf` configures suitable dramc settings and returns the DRAM parameters.
Then, Coreboot saves the parameters on the specified firmware flash section:
`"RW_MRC_CACHE"`.

## Return values
0 on success; < 0 on failure.

## Version
`$ strings dram.elf | grep "firmware version"`

--------------------------------------------------------------------------------
# SPM introduction
SPM is "System Power Manager" that provides power control for low power task.
SPM provides power related features, e.g. Suspend, Vcore dvfs

SPM firmware is loaded into SPM SRAM at system initialization.

## Who uses it
Coreboot will load spm_firmware.bin to SPM SRAM at ramstage.

## How to load `spm_firmware.bin
Use CBFS to load `spm_firmware.bin`.
No need to pass other parameters to SPM.

## Return value
No return value.

## Version
`$ strings spm_firmware.bin | grep "spm firmware"`

--------------------------------------------------------------------------------
# GPUEB introduction
GPUEB is a micro-processor used for GPU power management.
In addition, it is responsible for controlling GPU DVFS and GPU thermal throttling.

## Who uses it
Coreboot will load GPUEB firmware at ramstage, parse it, and copy the resulting image to the
SRAM of GPUEB.

## How to load `gpueb_fw.img`
Use CBFS to load `gpueb_fw.img`.
After loading is complete, apply the normal boot settings and release the software
reset to trigger GPUEB.

## Return values
No return value.

## Version
`$ strings gpueb_fw.img | grep "gpueb firmware"`

--------------------------------------------------------------------------------
# PI_IMG introduction
The main purpose of the pi_img is to pass various frequency and voltage scaling parameters and
settings to MCUPM.

## Who uses it
Coreboot will load pi_img firmware at ramstage and parse it using mtk_fsp_ramstage.

## How to load `pi_img`
Load `pi_img.img` from CBFS.
No need to pass other parameters to pi_img.

## Return values
No return value.

## Version
`$ strings pi_img.img | grep "pi_img firmware"`

--------------------------------------------------------------------------------
# mtk_fsp_romstage.elf introduction
It is a new blob named MediaTek firmware support package (mtk-fsp) in romstage that includes:

- power switch: It is a hardware design used to switch between two power inputs to determine
  the output voltage. This design is typically applied to systems that require
  dynamic voltage adjustment, such as the Constant Voltage, Constant Current of SRAM.

## Who uses it
Coreboot loads `mtk_fsp_romstage.elf` during the first bootup.

## How to load `mtk_fsp_romstage.elf`
Coreboot locates `mtk_fsp_romstage.elf` file, locates the entry point `_start()` to execute
`mtk_fsp_romstage.elf`.

## Return values
0 on success; non-zero on failure.

## Version
`$ strings mtk_fsp_romstage.elf | grep "interface version"`

--------------------------------------------------------------------------------
