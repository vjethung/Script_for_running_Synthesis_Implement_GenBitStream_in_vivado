**© Copyright 2026 by Viet Hung Nguyen K67 (EDABK)**

# 🛠️ Hướng Dẫn: Chạy Vivado Synthesis + Implementation Bằng Terminal

> **Áp dụng cho:** Mọi Vivado project (không phụ thuộc vào dự án cụ thể)
> **Yêu cầu:** Có các file `run_flow.tcl`, `run.sh`, `gen_bit.tcl`, `bitstream.sh` trong thư mục project

> [!IMPORTANT]
> **Quy trình khuyến nghị:**
>
> 1. Sử dụng **Vivado GUI** để xây dựng Block Design (BD), chỉnh sửa RTL và chạy Simulation.
> 2. Khi đến bước **Synthesis** và **Implementation**, hãy sử dụng **Terminal** (thông qua bộ script này) để tối ưu hiệu năng, tránh treo máy và dễ quản lý log.

---

## 📁 Cấu trúc cần có

├── logs/               ← Chứa lịch sử log (timestamped)

├── run.sh              ← Chạy Synthesis + Implementation

├── bitstream.sh        ← CHỈ chạy Generate Bitstream (nhanh)

├── run_flow.tcl        ← Script chính (Synth + Impl)

├── gen_bit.tcl         ← Script phụ (chỉ Bitstream)

├──`<project>`.xpr       ← File project Vivado

└── Other folders   ← Các folder được tạo ra sau khi tạo project Vivado bằng gui

---

## 🖥️ BƯỚC 0: Mở Terminal

### Trên Ubuntu / Linux:

**Cách 1 — Từ File Manager:**

> Mở thư mục project → Click chuột phải vào vùng trống → **"Open Terminal Here"**

**Cách 2 — Phím tắt:**

```
Ctrl + Alt + T
```

Sau đó điều hướng vào thư mục project:

```bash
cd /đường/dẫn/đến/thư/mục/project
```

**Cách 3 — Từ VS Code:**

> Menu **Terminal → New Terminal** (hoặc ``Ctrl + ` ``)
> Terminal sẽ tự mở đúng thư mục đang làm việc.

---

## ⚙️ BƯỚC 1: Tuỳ chỉnh trước lần chạy đầu tiên

Chỉ cần làm **1 lần** khi setup project mới.

### 1a. Sửa file Shell (`run.sh` & `bitstream.sh`) — trỏ đúng Vivado

Mở cả 2 file `.sh`, sửa dòng `VIVADO=` trỏ đến bản cài đặt trên máy bạn:

```sh
# Nếu sử dung trên server thì không cần thay đổi
# Sửa trong cả run.sh và bitstream.sh
VIVADO=/home/<user>/tools/Xilinx/Vivado/<version>/bin/vivado
```

### 1b. Sửa file TCL (`run_flow.tcl` & `gen_bit.tcl`) — Đặt tên Project

Mở cả 2 file `.tcl`, tìm và sửa biến `PRJ_NAME` khớp với tên dự án của bạn (không kèm đuôi `.xpr`):

```tcl
# Sửa trong cả run_flow.tcl và gen_bit.tcl
set PRJ_NAME "Tên_Dự_Án_Của_Bạn"
```

> **Lưu ý:** Biến này sẽ tự động cập nhật mọi đường dẫn file và thư mục kết quả.

### 1c. Cấp quyền chạy cho file Shell (chỉ làm 1 lần)

```bash
chmod +x run.sh bitstream.sh
```

---

## 🚀 BƯỚC 2: Chạy Flow

```bash
./run.sh
```

Đó là tất cả. Vivado sẽ tự chạy synthesis → implementation → timing report.

---

## 📊 BƯỚC 3: Đọc kết quả

### Kết quả in trực tiếp ra terminal:

```
>>> [1/6] Opening project ...
>>> [2/6] Launching Synthesis (synth_1) ...
>>> [3/6] Waiting for Synthesis to complete ...
>>> Synthesis STATUS: synth_design Complete!
>>> Synthesis PASSED.
>>> [4/6] Launching Implementation (impl_1) ...
>>> [5/6] Waiting for Implementation to complete ...
>>> Implementation PASSED.
>>> [6/6] Opening results and generating timing report ...
>>> =======================================
>>> WNS (Worst Negative Slack): 0.123 ns
>>> TIMING CLOSURE: PASSED (no violations)
>>> =======================================
>>> Full report: .../impl_1/timing_summary_final.rpt
>>> run_flow.tcl DONE.
```

### Các file kết quả tạo ra:

| File                                               | Nội dung                                              |
| -------------------------------------------------- | ------------------------------------------------------ |
| `<project>.runs/impl_1/timing_summary_final.rpt` | Báo cáo timing đầy đủ                            |
| `logs/run_flow_YYYYMMDD_HHMMSS.log`              | Log toàn bộ quá trình chạy (lưu theo thời gian) |
| `<project>.runs/synth_1/runme.log`               | Log chi tiết synthesis                                |
| `<project>.runs/impl_1/runme.log`                | Log chi tiết implementation                           |

---

## 🔄 Reset Run — Tự Động

Script **tự động detect** trạng thái run trước khi launch:

```
>>> synth_1 status: 'synth_design Complete!' — auto-resetting ...
>>> impl_1 status: 'route_design Complete!' — auto-resetting ...
```

> Không cần làm gì thêm — script xử lý tự động mỗi lần chạy.

---

## ⚡ BƯỚC 4: Chỉ tạo Bitstream (Nếu đã Impl xong)

Nếu bạn đã chạy `./run.sh` thành công và chỉ muốn tạo file `.bit` mà không muốn chạy lại từ đầu:

```bash
chmod +x bitstream.sh
./bitstream.sh
```

> **Lưu ý:** Script này sẽ kiểm tra xem Implementation đã xong chưa trước khi chạy. Nếu chưa xong, nó sẽ báo lỗi.

---

## 🐛 Xử Lý Lỗi Thường Gặp

### ❌ `bash: ./run.sh: Permission denied`

```bash
chmod +x run.sh
./run.sh
```

### ❌ `vivado: command not found`

```bash
# Thêm Vivado vào PATH tạm thời
export PATH=/home/<user>/tools/Xilinx/Vivado/<version>/bin:$PATH
./run.sh
```

### ❌ `ERROR: Synthesis FAILED`

```bash
# Xem dòng lỗi trong log
grep -i "error\|critical" <project>.runs/synth_1/runme.log
```

# Xem các đường vi phạm timing (thay `<project>` bằng tên dự án của bạn)

grep -A 20 "Slack (VIOLATED)" `<project>`.runs/impl_1/timing_summary_final.rpt | head -80

### ❌ Synthesis không chạy lại sau khi sửa RTL

→ Bỏ comment `reset_run synth_1` và `reset_run impl_1` trong `run_flow.tcl`

---

## 📋 Checklist Port Sang Project Mới

- [ ] Copy `run_flow.tcl` và `run.sh` vào thư mục project mới
- [ ] Sửa `VIVADO=` trong `run.sh` và `bitstream.sh` (nếu khác version)
- [ ] Sửa `PRJ_NAME` trong `run_flow.tcl` và `gen_bit.tcl` thành tên project mới
- [ ] Kiểm tra tên run (`synth_1`, `impl_1`) khớp với project
- [ ] Chạy `chmod +x run.sh bitstream.sh`
- [ ] Mở terminal tại thư mục project → `./run.sh`

---
