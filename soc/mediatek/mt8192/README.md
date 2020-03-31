# Firmware list
- drame.elf

--------------------------------------------------------------------------------
# `dram.elf` Introduction

`dram.elf` is one ELF format file which is used for calibration.
The dram.elf is loaded at the first time bootup, it will do DRAM
full calibration, and save calibration parameters to NAND (or EMMC)
for faster bootup after the frist bootup.

## Who uses it
   - coreboot loads `dram.elf` at the first time bootup if no DRAM parameters exist.

## How to load `dram.elf`
   - coreboot locates `dram.elf` file, and locates the entry point "_start",
     then it passes DRAM struct "param", and call _start(&param) to execute `dram.elf`
     flow.

## Parameters
```
    struct dramc_param {
        struct dramc_param_header header; // see below
        void (*do_putc)(unsigned char c);
        struct dramc_data dramc_datas;    // see below
    };
```
   Below shows the internal structure of dramc_param:
```
    struct dramc_param_header {
        u32 checksum;   /* checksum of dramc_datas, update in the coreboot */
        u16 version;    /* DRAMC_PARAM_HEADER_VERSION, update in the coreboot */
        u16 size;       /* size of whole dramc_param, update in the coreboot */
        u16 status;     /* DRAMC_PARAM_STATUS_CODES, update in the dram blob */
        u16 flags;      /* DRAMC_PARAM_FLAGS, update in the dram blob */
    };

    struct dramc_data {
        struct ddr_base_info ddr_info;
        struct sdram_params freq_params[DRAM_DFS_SHU_MAX];
    };

    struct ddr_base_info {
        u16 config_dvfs;		/* DRAMC_PARAM_DVFS_FLAG */
        u16 ddr_type;			/* DRAMC_PARAM_DDR_TYPE */
        u16 ddr_geometry;		/* DRAMC_PARAM_GEOMETRY_TYPE */
        u16 voltage_type;		/* DRAM_PARAM_VOLTAGE_TYPE */
        u32 support_ranks;
        u64 rank_size[RANK_MAX];
        struct emi_mdl emi_config;
        dram_cbt_mode cbt_mode[RANK_MAX];
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
```

## The output of `dram.elf`
   - `dram.elf` will set the suitable dramc settings, also save the DRAM parameters
     to NAND (or EMMC) on the specified section: "RW_DDR_TRAINING".

## Return Values
   - 0   : means successful.
   - < 0 : means failed.
