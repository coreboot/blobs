# Firmware list

- drame.elf

# `dram.elf` Introduction

`dram.elf` is one ELF format file which is used for calibration.
The `dram.elf` is loaded at the first bootup. It will do DRAM
full calibration, and save calibration parameters to NAND/NOR (or EMMC)
for faster bootup after the first bootup.

## Who uses it

coreboot loads `dram.elf` at the first time bootup if no DRAM parameters have
been cached.


## How to load `dram.elf`

coreboot locates `dram.elf` file, and locates the entry point `_start`,
then it passes DRAM struct `param`, and calls `_start(&param)` to execute
`dram.elf` flow.

## Parameters

```
struct dramc_param {
    struct dramc_param_header header; // see below
    void (*do_putc)(unsigned char c);
    struct sdram_params freq_params[DRAM_DFS_SHU_MAX];    // see below
};
```

Below shows the internal structure of `dramc_param`:

```
struct dramc_param_header {
    u16 status;     /* DRAMC_PARAM_STATUS_CODES, update in the dram blob */
    u32 magic;      /* DRAMC_PARAM_HEADER_MAGIC */
    u16 version;    /* DRAMC_PARAM_HEADER_VERSION, update in the coreboot */
    u16 size;       /* size of whole dramc_param, update in the coreboot */
I   u16 config;     /* DRAMC_PARAM_CONFIG, used for blob */
    u16 flags;      /* DRAMC_PARAM_FLAGS, update in the dram blob */
    u32 checksum;   /* checksum of dramc_datas, update in the coreboot */
};

struct sdram_params {
    u16 source;
    u16 frequency;       /* DRAM frequency */
    u8 rank_num;         /* DRAM rank number */
    u16 ddr_geometry;    /* DRAMC_PARAM_GEOMETRY_TYPE */
    u8 wr_level[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];

    /* DUTY */
    s8 duty_clk_delay[CHANNEL_MAX];
    s8 duty_dqs_delay[CHANNEL_MAX][DQS_NUMBER_LP4];

    /* CBT */
    u8 cbt_final_vref[CHANNEL_MAX][RANK_MAX];
    u8 cbt_clk_dly[CHANNEL_MAX][RANK_MAX];
    u8 cbt_cmd_dly[CHANNEL_MAX][RANK_MAX];
    u8 cbt_cs_dly[CHANNEL_MAX][RANK_MAX];
    u8 cbt_ca_perbit_delay[CHANNEL_MAX][RANK_MAX][DQS_BIT_NUMBER];

    /* Gating */
    u8 gating2T[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];
    u8 gating05T[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];
    u8 gating_fine_tune[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];
    u8 gating_pass_count[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];

    /* TX perbit */
    u8 tx_vref[CHANNEL_MAX][RANK_MAX];
    u16 tx_center_min[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];
    u16 tx_center_max[CHANNEL_MAX][RANK_MAX][DQS_NUMBER_LP4];
    u16 tx_win_center[CHANNEL_MAX][RANK_MAX][DQ_DATA_WIDTH_LP4];
    u16 tx_first_pass[CHANNEL_MAX][RANK_MAX][DQ_DATA_WIDTH_LP4];
    u16 tx_last_pass[CHANNEL_MAX][RANK_MAX][DQ_DATA_WIDTH_LP4];

    /* datlat */
    u8 rx_datlat[CHANNEL_MAX][RANK_MAX];

    /* RX perbit */
    u8 rx_vref[CHANNEL_MAX];
    s16 rx_firspass[CHANNEL_MAX][RANK_MAX][DQ_DATA_WIDTH_LP4];
    u8 rx_lastpass[CHANNEL_MAX][RANK_MAX][DQ_DATA_WIDTH_LP4];

    u32 emi_cona_val;
    u32 emi_conh_val;
    u32 emi_conf_val;
    u32 chn_emi_cona_val[CHANNEL_MAX];
    u32 cbt_mode_extern;
    u32 delay_cell_unit;
};
```

## Output of `dram.elf`

`dram.elf` will set suitable dramc settings, and save the DRAM parameters
to NAND/NOR (or EMMC) in the specified section: `RW_DDR_TRAINING`.

## Return Values

- 0   : means successful.
- < 0 : means failed.

## Version

```
$ strings dram.elf | grep "firmware version"
MediaTek DRAM firmware version: 1.5.0
```
