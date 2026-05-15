#================================================
# © Copyright 2026 by Viet Hung Nguyen K67 (EDABK)
#================================================

#!/bin/bash
# run.sh — Shortcut to run Vivado synthesis + implementation
# Usage: ./run.sh

VIVADO=/tools/Xilinx/Vivado/2024.1/bin/vivado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Tạo thư mục logs/ nếu chưa có
mkdir -p "${LOG_DIR}"

# Xoá các file backup/log thừa do Vivado tự tạo ở thư mục gốc
rm -f "${SCRIPT_DIR}"/run_flow_*.backup.* 2>/dev/null || true
rm -f "${SCRIPT_DIR}/vivado.log" "${SCRIPT_DIR}/vivado.jou" 2>/dev/null || true

${VIVADO} -mode batch -notrace \
          -source  "${SCRIPT_DIR}/run_flow.tcl" \
          -log     "${LOG_DIR}/run_flow_${TIMESTAMP}.log" \
          -journal "${LOG_DIR}/run_flow_${TIMESTAMP}.jou"
