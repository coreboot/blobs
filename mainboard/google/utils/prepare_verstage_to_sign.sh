#!/bin/bash
# Copyright 2023 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Abort on error.
set -eu -o pipefail

# Extract program name for usage instructions.
PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: ${PROG} <input_firmware> <token> <output_firmware>

For detail, reference the AMD documentation titled "OEM PSP VERSTAGE BL FW Signing
Key Pair Generation and Certificate Request Process" -
http://dr/corp/drive/folders/1ySJyDgbH73W1lqrhxMvM9UYl5TtJt_mw. This document
is Google internal only and is under NDA. This document is loosely based on the
"AMD BIOS Signing Key Pair Generation and Certificate Request Process Document
(id: 56535)" from AMD devhub.

EOF

  if [[ $# -ne 0 ]]; then
    echo "$*" >&2
    exit 1
  else
    exit 0
  fi
}

die() {
  echo "$*" >&2
  exit 1
}

# Check the arguments to make sure we have the correct number.
if [[ $# -ne 3 ]]; then
  usage "Error: Incorrect number of arguments"
fi

write_byte() {
  local position="$1"
  local value="$2"
  local file="$3"

  echo -n -e "\x${value}" |
    dd of="${file}" bs=1 count=1 seek="${position}" conv=notrunc status=none
}

write_dword_le() {
  local -i position="$1"
  local value
  value="$(printf "%08x" "$2")"
  local file="$3"

  write_byte $((position)) "${value:6:2}" "${file}"
  write_byte $((position + 1)) "${value:4:2}" "${file}"
  write_byte $((position + 2)) "${value:2:2}" "${file}"
  write_byte $((position + 3)) "${value:0:2}" "${file}"
}

copy_key_id() {
  local input_file="$1"
  local -i input_offset="$2"
  local output_file="$3"
  local -i output_offset="$4"
  local -i id_size=16

  dd if="${input_file}" skip="${input_offset}" \
    of="${output_file}" seek="${output_offset}" \
    bs=1 count="${id_size}" conv=notrunc status=none
}

main() {
  local input_firmware="$1"
  local amd_key="$2"
  local output_firmware="$3"

  if [[ "${input_firmware}" == "${output_firmware}" ]]; then
    usage "Error: input and output files must not be the same"
  fi

  if [[ ! -e "${input_firmware}" || ! -e "${amd_key}" ]]; then
    usage "Error: either input or amd_key does not exist"
  fi

  local -i sig_size=256 # RSA2048 signature size
  local -i fw_size
  local -i image_size
  local -i header_size=256 # AMDFW header size
  local -i signed_fw_size
  local -i unsigned_fw_size
  local -i signed_fw_minus_header_size

  fw_size="$(stat -c %s "${input_firmware}")"
  image_size="$((fw_size + sig_size))"
  # Search for PSP_FOOTER_DATA in psp_verstage binary. On boards with CBFS_VERIFICATION
  # enabled, metadata hash anchor follows PSP_FOOTER_DATA and is excluded from signing.
  local -a psp_footer_matches
  readarray -t psp_footer_matches < <(
    od -v --address-radix=d -t x4 --width=64 "${input_firmware}" | \
      awk '/[[:digit:]]+( 9{8}){16}$/ {print ($1 + 64)}'
  )
  if [[ "${#psp_footer_matches[@]}" -ne 1 ]]; then
    die "Multiple PSP Footer matches"
  fi
  signed_fw_size="${psp_footer_matches[0]}"
  if [[ "${signed_fw_size}" -le "${header_size}" ]]; then
    die "PSP Footer Data unexpectedly inside header!!!"
  fi
  signed_fw_minus_header_size="$((signed_fw_size - header_size))"
  unsigned_fw_size="$((fw_size - signed_fw_size))"

  dd if="${input_firmware}" of="${output_firmware}" bs=1 count="${signed_fw_size}" status=none

  # Since the header is also part of the signed binary, update the required fields before
  # signing. Refer to Appendix D in the AMD BIOS Signing Key Pair and Certification Process
  # document for what needs to be changed in the psp_verstage header.
  write_dword_le "0x14" "${signed_fw_minus_header_size}" "${output_firmware}"
  # Set the signed flag in the header
  write_dword_le "0x30" "1" "${output_firmware}"
  write_dword_le "0x6c" "${image_size}" "${output_firmware}"
  write_dword_le "0x70" "${unsigned_fw_size}" "${output_firmware}"
  copy_key_id "${amd_key}" "0x04" "${output_firmware}" "0x38"

  echo "Finished preparing PSP Verstage for signing"
}

main "$@"
