#================================================
# © Copyright 2026 by Viet Hung Nguyen K67 (EDABK)
#================================================

# ============================================================
#  gen_bit.tcl
#  Mục đích: Chỉ chạy bước Generate Bitstream sau khi Impl đã xong
# ============================================================

set PRJ_ROOT [file dirname [file normalize [info script]]]
set PRJ_NAME "Zip_implement"

# Mở Project
puts ">>> Opening project ${PRJ_NAME}.xpr ..."
open_project ${PRJ_ROOT}/${PRJ_NAME}.xpr

# Kiểm tra trạng thái Implementation
set impl_status [get_property STATUS [get_runs impl_1]]
if {$impl_status ne "route_design Complete!"} {
    puts "WARNING: Implementation is NOT complete (Status: ${impl_status})."
    puts "         Bitstream generation might fail or use old results."
}

# Generate Bitstream
puts ">>> Launching write_bitstream (impl_1) ..."
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# Kiểm tra kết quả
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Bitstream generation FAILED."
    exit 1
}

puts ">>> Bitstream generated successfully."
puts ">>> Location: ${PRJ_ROOT}/${PRJ_NAME}.runs/impl_1/design_1_wrapper.bit"
puts ">>> gen_bit.tcl DONE."
