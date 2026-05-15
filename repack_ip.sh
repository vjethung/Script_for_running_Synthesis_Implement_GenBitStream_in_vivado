#!/bin/bash
# repack_ip.sh — Repackage Custom IP sau khi sửa source code
# Usage: ./repack_ip.sh

VIVADO=/tools/Xilinx/Vivado/2024.1/bin/vivado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p "${LOG_DIR}"

# Dọn rác
rm -f "${SCRIPT_DIR}"/run_flow_*.backup.* 2>/dev/null || true
rm -f "${SCRIPT_DIR}/vivado.log" "${SCRIPT_DIR}/vivado.jou" 2>/dev/null || true

echo ">>> Repackaging IP attn_core ..."
echo ">>> Log: ${LOG_DIR}/repack_ip_${TIMESTAMP}.log"

${VIVADO} -mode batch -notrace \
          -source  "${SCRIPT_DIR}/repack_ip.tcl" \
          -log     "${LOG_DIR}/repack_ip_${TIMESTAMP}.log" \
          -journal "${LOG_DIR}/repack_ip_${TIMESTAMP}.jou"
