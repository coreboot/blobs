# Firmware list
- `spm_firmware.bin`
- `sspm.bin`
- `dram.elf`

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
coreboot will load sspm.bin to SSPM SRAM at ramstage.

## How to load `sspm.bin`
Use CBFS to load `sspm.bin`.
No need to pass other parameters to SSPM.

## Return value
No return value.

## Version
`$ strings sspm.bin | grep "SSPM firmware"`

--------------------------------------------------------------------------------
# `dram.elf` introduction
`dram.elf` is an ELF format file, which performs DRAM full calibration, DRAM
fast calibration and returns the trained calibration parameters to the caller.
The caller may store the parameters on NOR/NAND or eMMC for faster subsequent
bootups.

## Who uses it
coreboot loads `dram.elf` during the first bootup if no valid DRAM parameters
are found on NOR/NAND or eMMC.

## How to load `dram.elf`
coreboot locates `dram.elf` file, locates the entry point `_start`,
passes a `dramc_param` struct argument `dparam` to it, and calls
`_start(&dparam)` to execute `dram.elf`.

## Parameters
```
struct dramc_param {
    struct dramc_param_header header; // see below
    void (*do_putc)(unsigned char c);
    struct dramc_data dramc_datas;    // see below
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

struct sdram_info {
	u32 ddr_type;			/* SDRAM_DDR_TYPE */
	u32 ddr_geometry;		/* SDRAM_DDR_GEOMETRY_TYPE */
};

struct sdram_params {
    u32 rank_num;
    u16 num_dlycell_perT;
    u16 delay_cell_timex100;

    /* duty */
    s8 duty_clk_delay[CHANNEL_MAX][RANK_MAX];
    s8 duty_dqs_delay[CHANNEL_MAX][DQS_NUMBER_LP4];
    s8 duty_wck_delay[CHANNEL_MAX][DQS_NUMBER_LP4];
    .......
    .......
};

struct emi_mdl {
	u32 cona_val;
	u32 conh_val;
	u32 conf_val;
	u32 chn_cona_val;
};

struct ddr_mrr_info {
	u16 mr5_vendor_id;
	u16 mr6_revision_id;
	u16 mr7_revision_id;
	u64 mr8_density[RANK_MAX];
	u32 rank_nums;
	u8 die_num[RANK_MAX];
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
Then, coreboot saves the parameters on the specified firmware flash section:
`"RW_MRC_CACHE"`.

## Return values
0 on success; < 0 on failure.

## Version
`$ strings dram.elf | grep "firmware version"`

--------------------------------------------------------------------------------
