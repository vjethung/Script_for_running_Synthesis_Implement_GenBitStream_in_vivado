#================================================
# © Copyright 2026 by Viet Hung Nguyen K67 (EDABK)
#================================================

# ============================================================
#  run_flow.tcl
#  Rút gọn từ:
#    - Zip_implement.runs/synth_1/design_1_wrapper.tcl
#    - Zip_implement.runs/impl_1/design_1_wrapper.tcl
#
#  Mục đích: chạy toàn bộ Synthesis + Implementation
#            bằng Vivado batch mode (terminal), không cần GUI.
#
#  Workflow:
#    1. (Nếu sửa IP) ./repack_ip.sh    → Repackage IP
#    2. (Nếu cần)   Mở GUI, kết nối port mới vào BD, thêm ILA
#    3.             ./run.sh            → Synth + Impl + Timing
#
#  Cách chạy:
#    vivado -mode batch -source run_flow.tcl
#    (xem hướng dẫn đầy đủ ở run_flow_guide.md)
# ============================================================

set PRJ_ROOT [file dirname [file normalize [info script]]]
set PRJ_NAME "Zip_implement"

# --- CẤU HÌNH IP REPO ---
# Chỉ dùng để upgrade_ip nếu IP có phiên bản mới hơn trong catalog
set IP_REPO_PATH "${PRJ_ROOT}/../SIM_VIVADO/ip_repo/attn_core_1_0"
# ---------------------------------------------------------

# ----------------------------------------------------------
# BƯỚC 1: MỞ PROJECT
# ----------------------------------------------------------
puts ">>> \[1/6\] Opening project ${PRJ_NAME}.xpr ..."
open_project ${PRJ_ROOT}/${PRJ_NAME}.xpr

# ----------------------------------------------------------
# BƯỚC 1.5: UPGRADE IP NẾU CÓ PHIÊN BẢN MỚI
#   Chạy sau khi đã repack IP bằng ./repack_ip.sh
#   Sau đó generate_target để BD nhận port mới.
# ----------------------------------------------------------
puts ">>> \[1.5/6\] Checking for IP upgrades ..."
update_ip_catalog -quiet

set dirty_ips [get_ips -filter {IS_LOCKED == 1 || UPGRADE_VERSIONS != ""}]
if {[llength $dirty_ips] > 0} {
    puts ">>> Upgrading IPs: ${dirty_ips}"
    upgrade_ip $dirty_ips
    export_ip_user_files -of_objects [get_ips $dirty_ips] -no_script -sync -force -quiet

    # Regenerate Block Design targets để cập nhật port/interface mới vào wrapper
    # Chỉ lấy các file BD chính (không lấy các nested BD bên trong IP như DDR4)
    set bd_files [get_files -filter {IS_GENERATED == 0 && EXTENSION == "bd"}]
    if {[llength $bd_files] > 0} {
        puts ">>> Regenerating Block Design output products for: ${bd_files}"
        generate_target all $bd_files
        export_ip_user_files -of_objects $bd_files -no_script -sync -force -quiet
    }
} else {
    puts ">>> All IPs are up-to-date."
}

# ----------------------------------------------------------
# BƯỚC 2: TỰ ĐỘNG RESET NẾU RUN ĐÃ COMPLETE
#   Vivado yêu cầu reset_run trước khi launch_runs nếu run
#   đã ở trạng thái Complete. Script tự xử lý điều này.
# ----------------------------------------------------------
set synth_state [get_property STATUS [get_runs synth_1]]
if {$synth_state ne "Not started"} {
    puts ">>> synth_1 status: '${synth_state}' — auto-resetting ..."
    reset_run synth_1
}

set impl_state [get_property STATUS [get_runs impl_1]]
if {$impl_state ne "Not started"} {
    puts ">>> impl_1 status: '${impl_state}' — auto-resetting ..."
    reset_run impl_1
}

# ----------------------------------------------------------
# BƯỚC 3: SYNTHESIS
# ----------------------------------------------------------
puts ">>> \[2/6\] Launching Synthesis (synth_1) ..."
launch_runs synth_1 -jobs 8

puts ">>> \[3/6\] Waiting for Synthesis to complete ..."
wait_on_run synth_1

# Kiểm tra kết quả synthesis
set synth_status [get_property STATUS [get_runs synth_1]]
puts ">>> Synthesis STATUS: ${synth_status}"
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis FAILED. Check log:"
    puts "       ${PRJ_ROOT}/${PRJ_NAME}.runs/synth_1/runme.log"
    exit 1
}
puts ">>> Synthesis PASSED."

# ----------------------------------------------------------
# BƯỚC 4: IMPLEMENTATION
# ----------------------------------------------------------
puts ">>> \[4/6\] Launching Implementation (impl_1) ..."
launch_runs impl_1 -jobs 8

puts ">>> \[5/6\] Waiting for Implementation to complete ..."
wait_on_run impl_1

# Kiểm tra kết quả implementation
set impl_status [get_property STATUS [get_runs impl_1]]
puts ">>> Implementation STATUS: ${impl_status}"
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Implementation FAILED. Check log:"
    puts "       ${PRJ_ROOT}/${PRJ_NAME}.runs/impl_1/runme.log"
    exit 1
}
puts ">>> Implementation PASSED."

# ----------------------------------------------------------
# BƯỚC 5: BÁO CÁO TIMING (266.5 MHz check)
# ----------------------------------------------------------
puts ">>> \[6/6\] Opening results and generating timing report ..."
open_run impl_1 -name impl_1

report_timing_summary \
    -max_paths 10 \
    -report_unconstrained \
    -warn_on_violation \
    -file ${PRJ_ROOT}/${PRJ_NAME}.runs/impl_1/timing_summary_final.rpt

# In nhanh WNS ra terminal
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
puts ">>> ======================================="
puts ">>> WNS (Worst Negative Slack): ${wns} ns"
if {$wns >= 0} {
    puts ">>> TIMING CLOSURE: PASSED (no violations)"
} else {
    puts ">>> TIMING CLOSURE: FAILED (timing violations exist)"
}
puts ">>> ======================================="
puts ">>> Full report: ${PRJ_ROOT}/${PRJ_NAME}.runs/impl_1/timing_summary_final.rpt"

# ----------------------------------------------------------
# BƯỚC 6 (TUỲ CHỌN): GENERATE BITSTREAM
#   Bỏ comment 3 dòng dưới nếu muốn tạo bitfile luôn
# ----------------------------------------------------------
# puts ">>> Generating bitstream ..."
# launch_runs impl_1 -to_step write_bitstream -jobs 8
# wait_on_run impl_1

puts ">>> run_flow.tcl DONE."
