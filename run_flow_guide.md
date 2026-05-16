**© Copyright 2026 by Viet Hung Nguyen K67 (EDABK)**

# 🛠️ Hướng Dẫn: Chạy Vivado Synthesis + Implementation Bằng Terminal

> **Áp dụng cho:** Mọi Vivado project (không phụ thuộc vào dự án cụ thể)
> **Yêu cầu:** Có đầy đủ các file script trong thư mục project

> [!IMPORTANT]
> **Quy trình khuyến nghị kết hợp GUI & Terminal:**
>
> 1. Dùng **Vivado GUI** để tạo Block Design, viết RTL, chạy Simulation.
> 2. Khi sửa Custom IP → chạy **`./repack_ip.sh`** để cập nhật, sau đó mở GUI kết nối port mới & thêm ILA.
> 3. Khi cần Synthesis + Implementation → chạy **`./run.sh`** qua Terminal.

---

## 📁 Cấu trúc cần có

```
<your_project_folder>/
├── logs/               ← Chứa lịch sử log (timestamped)
├── run.sh              ← Chạy Synthesis + Implementation
├── bitstream.sh        ← CHỈ chạy Generate Bitstream (nhanh)
├── repack_ip.sh        ← Repackage Custom IP sau khi sửa source
├── run_flow.tcl        ← Script chính (Synth + Impl)
├── gen_bit.tcl         ← Script phụ (chỉ Bitstream)
├── repack_ip.tcl       ← Script repackage IP
└── <project>.xpr       ← File project Vivado
```

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
> Menu **Terminal → New Terminal** (hoặc `` Ctrl + ` ``)
> Terminal sẽ tự mở đúng thư mục đang làm việc.

---

## ⚙️ BƯỚC 1: Tuỳ chỉnh trước lần chạy đầu tiên

Chỉ cần làm **1 lần** khi setup project mới.

### 1a. Sửa file Shell (`run.sh`, `bitstream.sh`, `repack_ip.sh`) — trỏ đúng Vivado

Mở **tất cả** các file `.sh`, sửa dòng `VIVADO=`:

```sh
# Sửa trong run.sh, bitstream.sh và repack_ip.sh, nếu chạy trên server thì không cần sửa
VIVADO=/home/<user>/tools/Xilinx/Vivado/<version>/bin/vivado
```

### 1b. Sửa file TCL (`run_flow.tcl`, `gen_bit.tcl`, `repack_ip.tcl`) — Cấu hình Dự án & IP

Mở các file `.tcl`, tìm phần cấu hình ở đầu file và sửa:

```tcl
# 1. Đặt tên dự án — sửa trong run_flow.tcl và gen_bit.tcl
set PRJ_NAME "Tên_Dự_Án_Của_Bạn"   # tên file .xpr không kèm đuôi

# 2. Cấu hình IP — sửa trong repack_ip.tcl
set IP_NAME    "tên_thư_mục_ip"    ;# Tên IP trong ip_repo
set TOP_MODULE "tên_module_top"    ;# Tên module chính của IP
set RELATIVE_IP_REPO_PATH "path/đến/repo" ;# Đường dẫn từ script đến IP repo
```

> [!TIP]
> Script `repack_ip.tcl` hiện đã hỗ trợ **tự động dọn dẹp** các file khai báo sai hoặc không tồn tại (stale files). Bạn không cần lo lắng nếu lỡ xóa file trên đĩa cứng mà quên xóa trong project IP.


### 1c. Cấp quyền chạy cho file Shell (chỉ làm 1 lần)

```bash
chmod +x run.sh bitstream.sh repack_ip.sh
```

---

## 🔁 BƯỚC 2 *(Tùy chọn)*: Workflow khi sửa Custom IP

> [!NOTE]
> **Bỏ qua BƯỚC 2 nếu bạn không sửa Custom IP.**
> Nếu chỉ sửa RTL hoặc chỉ muốn build lại → chuyển thẳng sang **BƯỚC 3**.

Thực hiện **tuần tự** khi cần thêm port, sửa giao diện, hoặc thay đổi logic IP:

### Bước 2a — Sửa source code IP
Chỉnh sửa các file source (`.sv`, `.v`, `.vhd`) trong thư mục IP source của bạn bằng editor tùy thích (VS Code, vim, ...).
Đường dẫn thư mục IP source có thể xem trong `IP_REPO_DIR` tại `repack_ip.tcl`.

### Bước 2b — Repackage IP
```bash
./repack_ip.sh
```
Script sẽ mở IP Packager project, phát hiện port/interface mới từ HDL và cập nhật `component.xml`.

### Bước 2c — Mở GUI và cập nhật Block Design
```bash
vivado <project>.xpr &
```
Trong GUI:
- **Kết nối port mới** vào Block Design (BD)
- **Thêm debug probes** vào ILA nếu cần debug
- **Lưu** (`Ctrl+S`) và **đóng** Vivado

---

## 🚀 BƯỚC 3: Chạy Build

Dù có hay không sửa IP, bước cuối cùng luôn là:

```bash
./run.sh
```

Vivado sẽ tự chạy: **Synthesis → Implementation → Timing Report**.


---

## 📊 BƯỚC 4: Đọc kết quả

### Kết quả in trực tiếp ra terminal:

```
>>> [1/6] Opening project ...
>>> [1.5/6] Checking for IP upgrades ...
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

| File | Nội dung |
|------|----------|
| `<project>.runs/impl_1/timing_summary_final.rpt` | Báo cáo timing đầy đủ |
| `logs/run_flow_YYYYMMDD_HHMMSS.log` | Log toàn bộ quá trình chạy |
| `logs/repack_ip_YYYYMMDD_HHMMSS.log` | Log repackage IP |
| `<project>.runs/synth_1/runme.log` | Log chi tiết synthesis |
| `<project>.runs/impl_1/runme.log` | Log chi tiết implementation |

---

## ⚡ BƯỚC 5: Chỉ tạo Bitstream (Nếu đã Impl xong)

Nếu đã chạy `./run.sh` thành công và chỉ muốn tạo file `.bit`:

```bash
./bitstream.sh
```

> **Lưu ý:** Script kiểm tra trạng thái Implementation trước khi chạy. Nếu chưa xong sẽ báo lỗi.

---

## 🔄 Reset Run — Tự Động

Script `run.sh` **tự động detect** và reset run cũ trước khi launch mới:

```
>>> synth_1 status: 'synth_design Complete!' — auto-resetting ...
>>> impl_1 status: 'route_design Complete!' — auto-resetting ...
```

> Không cần làm gì thêm — script xử lý tự động.

---

## 🐛 Xử Lý Lỗi Thường Gặp

### ❌ `bash: ./run.sh: Permission denied`

```bash
chmod +x run.sh bitstream.sh repack_ip.sh
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

### ❌ `TIMING CLOSURE: FAILED`
```bash
grep -A 20 "Slack (VIOLATED)" <project>.runs/impl_1/timing_summary_final.rpt | head -80
```

### ❌ Port mới không thấy trong Block Design sau khi sửa IP
→ Cần chạy đúng thứ tự: `./repack_ip.sh` → mở GUI kết nối port → `./run.sh`

### ❌ Synthesis không chạy lại sau khi sửa RTL
→ Script tự động reset — nếu muốn giữ nguyên synthesis, hãy comment dòng `reset_run synth_1` trong `run_flow.tcl`

---

## 📋 Checklist Port Sang Project Mới

- [ ] Copy tất cả file `.sh` và `.tcl` vào thư mục project mới
- [ ] Sửa `VIVADO=` trong `run.sh`, `bitstream.sh`, `repack_ip.sh`
- [ ] Sửa `PRJ_NAME` trong `run_flow.tcl` và `gen_bit.tcl`
- [ ] Sửa `IP_NAME` và `TOP_MODULE` trong `repack_ip.tcl`
- [ ] Kiểm tra tên run (`synth_1`, `impl_1`) khớp với project
- [ ] Chạy `chmod +x run.sh bitstream.sh repack_ip.sh`
- [ ] Mở terminal tại thư mục project → `./run.sh`

---

**© Copyright 2026 by Viet Hung Nguyen K67 (EDABK)**
*Developed for Zipformer FPGA Acceleration Project.*
