#================================================
# © Copyright 2026 by Viet Hung Nguyen K67 (EDABK)
#================================================

# ============================================================
#  repack_ip.tcl
#  Mục đích: Repackage Custom IP (attn_core) sau khi sửa source.
#            Mở đúng IP Packager project để ipx:: hoạt động.
#
#  Workflow:
#    1. Sửa source code trong ip_repo/attn_core_1_0/src/
#    2. ./repack_ip.sh      → script này cập nhật component.xml
#    3. Mở GUI (./Zip_implement.xpr) → kết nối port mới vào BD, thêm ILA
#    4. Lưu và đóng GUI
#    5. ./run.sh            → Synth + Impl
# ============================================================

set SCRIPT_DIR  [file dirname [file normalize [info script]]]
set IP_PRJ_PATH [file normalize "${SCRIPT_DIR}/../SIM_VIVADO/ip_repo/edit_attn_core_v1_0.xpr"]
set IP_REPO_DIR [file normalize "${SCRIPT_DIR}/../SIM_VIVADO/ip_repo/attn_core_1_0"]

if {![file exists ${IP_PRJ_PATH}]} {
    puts "ERROR: IP packager project not found:"
    puts "       ${IP_PRJ_PATH}"
    puts "       Please check the path in repack_ip.tcl"
    exit 1
}

puts ">>> Opening IP packager project ..."
puts ">>>   ${IP_PRJ_PATH}"
open_project ${IP_PRJ_PATH}

puts ">>> Adding all source files from repo directory to project ..."
# Đảm bảo mọi file trong src/ và hdl/ đều được đưa vào project
add_files -norecurse [glob -nocomplain "${IP_REPO_DIR}/src/*.{v,sv,vhd}" "${IP_REPO_DIR}/hdl/*.{v,sv,vhd}"]
update_compile_order -fileset sources_1

puts ">>> Merging changes into IP definition ..."
# Chủ động nạp component.xml để tránh lỗi "No core loaded" trong batch mode
set component_xml [file normalize "${IP_REPO_DIR}/component.xml"]
set current_core [ipx::open_core ${component_xml}]

# Đồng bộ hóa file, ports và parameters từ HDL project vào IP Packager
ipx::merge_project_changes files ${current_core}
ipx::merge_project_changes ports ${current_core}
ipx::merge_project_changes hdl_parameters ${current_core}

# Tăng revision để Vivado chính nhận ra có thay đổi và cho phép Upgrade IP
set rev [get_property core_revision ${current_core}]
set new_rev [expr {$rev + 1}]
set_property core_revision ${new_rev} ${current_core}
puts ">>> IP Revision bumped to: ${new_rev}"

ipx::create_xgui_files ${current_core}
ipx::update_checksums ${current_core}
ipx::save_core ${current_core}
close_project

puts ">>> ============================================="
puts ">>> IP Repackaged successfully!"
puts ">>> component.xml updated at:"
puts ">>>   ${IP_REPO_DIR}/component.xml"
puts ">>>"
puts ">>> NEXT STEPS:"
puts ">>>   1. Open GUI: vivado ${SCRIPT_DIR}/Zip_implement.xpr"
puts ">>>      - Connect new ports to Block Design"
puts ">>>      - Add debug probes to ILA if needed"
puts ">>>      - Save and close GUI"
puts ">>>   2. Run: ./run.sh"
puts ">>> ============================================="
