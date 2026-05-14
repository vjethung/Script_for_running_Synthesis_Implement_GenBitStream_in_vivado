#================================================
# © Copyright 2026 by Viet Hung Nguyen K67 (EDABK)
#================================================

#!/bin/bash
# bitstream.sh — Shortcut to generate bitstream only
# Usage: ./bitstream.sh

VIVADO=/tools/Xilinx/Vivado/2024.1/bin/vivado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p "${LOG_DIR}"

# Dọn rác
rm -f "${SCRIPT_DIR}"/run_flow_*.backup.* 2>/dev/null || true
rm -f "${SCRIPT_DIR}/vivado.log" "${SCRIPT_DIR}/vivado.jou" 2>/dev/null || true

${VIVADO} -mode batch \
          -source  "${SCRIPT_DIR}/gen_bit.tcl" \
          -log     "${LOG_DIR}/bitstream_${TIMESTAMP}.log" \
          -journal "${LOG_DIR}/bitstream_${TIMESTAMP}.jou"
