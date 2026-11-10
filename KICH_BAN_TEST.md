# Kịch bản test thủ công

Các ca test cho chức năng đăng nhập và 3 module, bám theo kịch bản mục 2 của `BaoCao.pdf` (cột "Căn cứ"), cùng các trường hợp lỗi mà code có xử lí.

## Chuẩn bị

1. CSDL: chạy `database/01_tao_bang.sql` → `02_du_lieu_mau.sql` → `03_stored_procedure.sql` (lần sau chỉ cần chạy lại **02** để đưa dữ liệu về ban đầu).
2. IntelliJ: redeploy Tomcat 9, mở http://localhost:8080/spa/.
3. Tài khoản: quản lí `quanli` / `a@123`; lễ tân `letan` / `a@123`.
4. **Chạy lại `02_du_lieu_mau.sql` trước mỗi phần (A, B, C, D, E)**: các ca trong một phần chạy theo thứ tự, ca sau dùng dữ liệu ca trước để lại.

Dữ liệu mẫu cần nhớ:

| Loại | Dữ liệu |
|---|---|
| Dịch vụ | DV01 Massage body thư giãn (Massage body, 60', 400.000) · DV02 Gội đầu dưỡng sinh thảo dược (45', 150.000) · DV03 Sơn gel móng tay (Chăm sóc móng, 45', 120.000) · DV04 Tắm trắng toàn thân (90', 600.000) |
| KTV | KTV001 Trần Văn Khánh, KTV002 Trần Trọng Hùng (Massage body, Rảnh) · KTV003 Phan Văn Khôi (Gội đầu dưỡng sinh, **Đang phục vụ**) · KTV004 Phạm Thị Lan (Chăm sóc da mặt) · KTV005 Đỗ Thị Mai (Chăm sóc móng) · KTV006 Vũ Thị Ngọc (Tắm trắng) |
| Khách | Nguyễn Văn B 0999 · Nguyễn Văn C 0987 · Nguyễn Văn E 0911 (chưa có số 0888) |
| Phiếu | P01 – B – DV01 – Hùng – 19:00→20:00 21/09/2026 – **Hoàn thành** · P02 – C – DV04 – **Đã thanh toán** · P03 – E – DV02 – Khôi – **Đang phục vụ** (bắt đầu lúc chạy file 02) |
| Mặt hàng | MH01 Tinh dầu thư giãn (Chai, 150.000) · MH02 Muối tắm thảo dược (Hũ, 90.000) · MH03 Mặt nạ dưỡng da (Miếng, 30.000) |
| Khuyến mãi | KM01 Giảm 10% (còn hạn) · KM02 Giảm 50.000 (còn hạn) · KM03 Khuyến mãi hè 2025 (hết hạn) |

"alert" = hộp thông báo của trình duyệt, bấm OK để đóng.

---

## A. Đăng nhập, đăng xuất, phân quyền

| Mã | Căn cứ | Bước và dữ liệu | Kết quả mong đợi | Đạt |
|---|---|---|---|---|
| DN-01 | 2.1 ngoại lệ 2 | Nhập tên `a`, mật khẩu `a123` → Đăng nhập | alert "Tên đăng nhập hoặc mật khẩu không đúng"; bấm OK → vẫn ở trang đăng nhập, ô tên còn `a`, ô mật khẩu còn `a123` | ☐ |
| DN-02 | 2.1 bước 1–2 | Nhập `quanli` / `a@123` → Đăng nhập | Trang "Trang chủ nhân viên quản lí": Họ tên **Nguyễn Văn A**, Chức vụ **Nhân viên quản lí**, 1 thẻ "Quản lí thông tin dịch vụ"; thanh trên ghi "Nguyễn Văn A – Nhân viên quản lí" + nút Đăng xuất | ☐ |
| DN-03 | 2.2 bước 1–2 | Đăng xuất → nhập `letan` / `a@123` | "Trang chủ nhân viên lễ tân", Chức vụ **Nhân viên lễ tân**, 2 thẻ: "Nhận khách và phân công nhân viên phục vụ tại quầy", "Cho khách thanh toán tại quầy" | ☐ |
| DN-04 | — | Đăng xuất → `LETAN` / `a@123` | Đăng nhập được (tên không phân biệt hoa thường) | ☐ |
| DN-05 | — | Đăng xuất → `letan` / `A@123` | alert "Tên đăng nhập hoặc mật khẩu không đúng" (mật khẩu phân biệt hoa thường) | ☐ |
| DN-06 | — | Đăng nhập `letan`, gõ địa chỉ `/spa/ql/gdQuanLiDichVu.jsp` | Bị chuyển về trang đăng nhập | ☐ |
| DN-07 | — | Bấm Đăng xuất → bấm nút Back của trình duyệt → F5 | Về trang đăng nhập; sau F5 vẫn ở trang đăng nhập (không vào lại được trang chủ) | ☐ |
| DN-08 | — | Chưa đăng nhập, gõ `/spa/lt/gdLapHoaDon.jsp` | Chuyển về trang đăng nhập | ☐ |

## B. Module 1 – Quản lí thông tin dịch vụ (đăng nhập `quanli`)

| Mã | Căn cứ | Bước và dữ liệu | Kết quả mong đợi | Đạt |
|---|---|---|---|---|
| QL-01 | 2.1 bước 3–4 | Trang chủ → thẻ "Quản lí thông tin dịch vụ" | Trang "Quản lí thông tin dịch vụ": ô tìm (gợi ý "Nhập tên hoặc từ khoá để tìm kiếm"), nút Tìm kiếm, nút "Thêm dịch vụ mới", **bảng trống**, nút Quay lại | ☐ |
| QL-02 | — | Để trống ô tìm → Tìm kiếm | Bảng có 4 dòng DV01–DV04 đúng tên, loại, thời gian, đơn giá (400.000 …), mô tả, trạng thái "Đang cung cấp", link Sửa, Xoá (10 cột: …, Đơn giá, **Mô tả**, Trạng thái, Sửa, Xoá) | ☐ |
| QL-03 | — | Tìm `MASSAGE` | Chỉ DV01 (không phân biệt hoa thường) | ☐ |
| QL-04 | — | Tìm `mat` | Dòng "Không có dịch vụ nào phù hợp" (phân biệt dấu: "mat" ≠ "mặt") | ☐ |
| QL-05 | 2.1 bước 5–8 | Thêm dịch vụ mới → Tên `Chăm sóc da mặt cơ bản`, Loại `Chăm sóc da mặt`, Thời gian `60`, Đơn giá `400.000`, Mô tả `Làm sạch và dưỡng da cơ bản` → Lưu | alert "Thêm dịch vụ thành công" → về trang quản lí. Tìm ô trống: có **DV05** Chăm sóc da mặt cơ bản, 60, 400.000, Đang cung cấp | ☐ |
| QL-06 | 2.1 ngoại lệ 8–8.2 | Thêm dịch vụ mới với **đúng dữ liệu QL-05** → Lưu | alert "Dịch vụ đã tồn tại, vui lòng kiểm tra lại"; OK → form "Thêm dịch vụ mới" vẫn giữ đủ 5 ô đã nhập | ☐ |
| QL-07 | 2.1 ngoại lệ 8.3–8.4 | Ở form QL-06 đổi Tên thành `Tẩy tế bào chết` → Lưu | alert "Thêm dịch vụ thành công"; danh sách có **DV06** Tẩy tế bào chết | ☐ |
| QL-08 | — | Thêm với Tên `CHĂM SÓC DA MẶT CƠ BẢN` (các ô khác hợp lệ) | Báo trùng như QL-06 (trùng tên không phân biệt hoa thường) | ☐ |
| QL-09 | — | Thêm: Tên `Thử`, Loại `Tắm trắng`, Thời gian `30`, Đơn giá `abc` → Lưu; lặp lại với Đơn giá `-5` | alert "Vui lòng nhập đầy đủ và đúng thông tin dịch vụ (thời gian, đơn giá là số dương)", form giữ dữ liệu | ☐ |
| QL-10 | — | Thêm: để trống Tên hoặc Thời gian = `0` → Lưu | Trình duyệt chặn, báo ngay tại ô (ô bắt buộc / giá trị phải ≥ 1); không gửi đi | ☐ |
| QL-11 | — | Thêm dịch vụ mới → Quay lại | Về trang quản lí, không thêm gì | ☐ |
| QL-12 | — | Gõ `da mặt` → Tìm → bấm Sửa ở DV05 | Trang "Sửa thông tin dịch vụ": mã DV05 (chỉ xem), các ô điền sẵn, Đơn giá `400.000`, Trạng thái "Đang cung cấp" | ☐ |
| QL-13 | — | Ở QL-12 đổi Đơn giá `450.000`, Trạng thái `Ngừng cung cấp` → Lưu | alert "Sửa dịch vụ thành công"; về trang quản lí, ô tìm vẫn là `da mặt`; DV05 hiện 450.000 – Ngừng cung cấp | ☐ |
| QL-14 | — | Sửa DV05, đổi Tên thành `Massage body thư giãn` → Lưu | alert "Dịch vụ đã tồn tại, vui lòng kiểm tra lại", form giữ tên vừa gõ | ☐ |
| QL-15 | — | Sửa DV01, không đổi gì → Lưu | alert "Sửa dịch vụ thành công" (không báo trùng với chính nó) | ☐ |
| QL-16 | 3.1 (luật xoá) | Tìm ô trống → Xoá ở **DV01** → hộp hỏi "Bạn có chắc muốn xoá dịch vụ "Massage body thư giãn"?" → OK | alert "Không thể xoá dịch vụ đang có trong phiếu chưa thanh toán"; DV01 vẫn còn | ☐ |
| QL-17 | — | Xoá **DV03** → OK | alert "Xoá dịch vụ thành công"; DV03 biến mất; trong `tblDichVu` không còn dòng DV03 | ☐ |
| QL-18 | — | Xoá **DV04** → OK | alert "Xoá dịch vụ thành công"; DV04 biến mất khỏi danh sách; trong `tblDichVu` DV04 vẫn còn với trạng thái **"Đã xoá"** | ☐ |
| QL-19 | — | Thêm dịch vụ `Tắm trắng toàn thân`, loại Tắm trắng, 90, 650.000 | alert "Thêm dịch vụ thành công" (DV04 "Đã xoá" không tính trùng); mã mới **DV07** | ☐ |
| QL-20 | — | Xoá DV02 → bấm **Huỷ** ở hộp hỏi | Không có gì thay đổi | ☐ |
| QL-21 | — | Gõ địa chỉ `/spa/ql/gdSuaDichVu.jsp?id=4` (DV04 đã xoá) | alert "Không tìm thấy dịch vụ", về trang quản lí | ☐ |
| QL-22 | — | Đăng nhập `letan` → Nhận khách… → Tiếp nhận khách mới | Bảng "Chọn dịch vụ" **không có** DV03 (đã xoá), DV04 (Đã xoá), DV05 (Ngừng cung cấp); có DV01, DV02, DV06, DV07 | ☐ |

## C. Module 2 – Nhận khách và phân công nhân viên phục vụ tại quầy (đăng nhập `letan`, đã chạy lại 02)

| Mã | Căn cứ | Bước và dữ liệu | Kết quả mong đợi | Đạt |
|---|---|---|---|---|
| TN-01 | 2.2 bước 3–4 | Trang chủ → "Nhận khách và phân công nhân viên phục vụ tại quầy" | Trang "Tiếp nhận khách hàng": dòng **P01** Nguyễn Văn B, 0999, Massage body thư giãn, Trần Trọng Hùng, 19:00 21/09/2026, Hoàn thành (không có nút); dòng **P03** Nguyễn Văn E, 0911, Gội đầu dưỡng sinh thảo dược, Phan Văn Khôi, Đang phục vụ, có nút **Hoàn thành**. Không có P02 (đã thanh toán) | ☐ |
| LP-01 | 2.2 bước 5–6 | Bấm "Tiếp nhận khách mới" | Trang "Lập phiếu phục vụ": khung Thông tin khách hàng (SĐT, nút Tìm khách hàng, Họ tên), bảng 4 dịch vụ DV01–DV04 có ô Chọn, khung Phân công ghi "Chưa chọn dịch vụ", nút "Xác nhận lập phiếu", "Quay lại" | ☐ |
| LP-02 | 2.2 bước 7–10 | Nhập SĐT `0987` → Tìm khách hàng | Ô Họ tên tự điền **Nguyễn Văn C**, nền xám (chỉ đọc) | ☐ |
| LP-03 | 2.2 bước 12–14 | Tick DV01 "Massage body thư giãn" | Trang tự tải lại, SĐT và họ tên còn nguyên; khung phân công có dòng: Massage body thư giãn · 60 phút · Massage body · hộp chọn có "KTV001 – Trần Văn Khánh – Massage body – Rảnh" và "KTV002 – Trần Trọng Hùng – Massage body – Rảnh" · **Chưa phân công** | ☐ |
| LP-04 | 2.2 bước 15 | Chọn Trần Văn Khánh | Trang tải lại, Khánh vẫn được chọn, cột Trạng thái **Đã phân công** | ☐ |
| LP-05 | 2.2 bước 17–18 | Xác nhận lập phiếu | alert "Lập phiếu phục vụ thành công" → trang Tiếp nhận có dòng **P04** Nguyễn Văn C, 0987, Massage body thư giãn, Trần Văn Khánh, giờ hiện tại, Đang phục vụ | ☐ |
| LP-06 | — | Tiếp nhận khách mới → `0987` → Tìm → tick DV01 | Hộp chọn chỉ còn **Trần Trọng Hùng** (Khánh đang phục vụ P04) | ☐ |
| LP-07 | 2.2 ngoại lệ 10 | Quay lại → Tiếp nhận khách mới → SĐT `0888` → Tìm khách hàng | Dòng đỏ "Khách hàng mới. Vui lòng nhập họ tên khách hàng"; ô Họ tên trống, nhập được | ☐ |
| LP-08 | 2.2 ngoại lệ 10.1–10.3 | Gõ Họ tên `Nguyễn Văn D` → tick DV03 "Sơn gel móng tay" | Trang tải lại: Họ tên **vẫn là Nguyễn Văn D**, dòng đỏ vẫn hiện; khung phân công có Sơn gel móng tay với KTV005 Đỗ Thị Mai | ☐ |
| LP-09 | — | Chọn Đỗ Thị Mai → tick thêm DV01 → chọn Trần Trọng Hùng cho DV01 | Mỗi lần tải lại, lựa chọn KTV của dòng trước **vẫn giữ**; cả 2 dòng "Đã phân công" | ☐ |
| LP-10 | — | Xác nhận lập phiếu | alert "Lập phiếu phục vụ thành công"; Tiếp nhận có **P05** Nguyễn Văn D, 0888, 2 dịch vụ (Massage body thư giãn / Sơn gel móng tay), KTV Trần Trọng Hùng / Đỗ Thị Mai; `tblKhachHang` có **KH004** Nguyễn Văn D 0888 | ☐ |
| LP-11 | 2.2 ngoại lệ 15 | Tiếp nhận khách mới → `0987` → Tìm → tick DV02 "Gội đầu dưỡng sinh thảo dược" | Cột KTV ghi đỏ **"Không có kĩ thuật viên rảnh"**, Trạng thái "Chưa phân công" | ☐ |
| LP-12 | 4.2 (chưa chọn KTV) | Ở LP-11 bấm Xác nhận lập phiếu | alert "Vui lòng chọn kĩ thuật viên cho tất cả dịch vụ"; trang giữ nguyên SĐT, họ tên, dịch vụ đã tick | ☐ |
| LP-13 | — | Bỏ tick DV02, tick DV04 → chọn Vũ Thị Ngọc → Xác nhận | Lập phiếu thành công (**P06**) | ☐ |
| LP-14 | — | Tiếp nhận khách mới → để trống SĐT → Xác nhận lập phiếu | alert "Vui lòng nhập số điện thoại và họ tên khách hàng" | ☐ |
| LP-15 | — | SĐT `0987` → Tìm → không tick dịch vụ nào → Xác nhận | alert "Vui lòng chọn ít nhất một dịch vụ" | ☐ |
| LP-16 | — | Để trống SĐT → bấm Tìm khách hàng | Dòng đỏ "Vui lòng nhập số điện thoại để tìm khách hàng" | ☐ |
| LP-17 | — | Chạy lại 02. Tiếp nhận khách mới → `0987` → Tìm → tick DV01 → giữ **Ctrl** (Mac: **Cmd**) chọn cả Khánh và Hùng → Xác nhận | Thành công; dòng P04 cột Nhân viên phục vụ ghi "Trần Văn Khánh, Trần Trọng Hùng" | ☐ |
| LP-18 | — | Chạy lại 02. Mở **2 tab**: cả 2 tab lập phiếu cho `0987`, tick DV01, chọn Hùng. Tab 1 bấm Xác nhận (thành công). Sang tab 2 bấm Xác nhận | Tab 2: alert "Kĩ thuật viên đã chọn cho dịch vụ "Massage body thư giãn" không còn rảnh, vui lòng chọn lại"; danh sách KTV tab 2 không còn Hùng; không sinh phiếu thứ hai | ☐ |
| HT-01 | 1.2 (Hoàn thành phục vụ) | Trang Tiếp nhận → nút Hoàn thành ở **P03** → hộp hỏi "Xác nhận hoàn thành phục vụ phiếu P03?" → OK | alert "Hoàn thành phục vụ thành công"; P03 chuyển "Hoàn thành", mất nút; trong CSDL Phan Văn Khôi chuyển **Rảnh**, phân công P03 có giờ kết thúc = lúc bấm | ☐ |
| HT-02 | — | Tiếp nhận khách mới → `0911` → Tìm → tick DV02 | Hộp chọn có **KTV003 – Phan Văn Khôi – Gội đầu dưỡng sinh – Rảnh** | ☐ |
| HT-03 | — | Bấm Hoàn thành ở một phiếu khác → bấm **Huỷ** | Không có gì thay đổi | ☐ |
| HT-04 | — | Quay lại → Quay lại | Về trang Tiếp nhận rồi về trang chủ lễ tân | ☐ |

## D. Module 3 – Cho khách thanh toán tại quầy (đăng nhập `letan`, đã chạy lại 02)

| Mã | Căn cứ | Bước và dữ liệu | Kết quả mong đợi | Đạt |
|---|---|---|---|---|
| TT-01 | 2.3 bước 4–5 | Trang chủ → "Cho khách thanh toán tại quầy" | Trang "Tìm phiếu cần thanh toán": ô Tên khách hàng, nút Tìm kiếm, **bảng trống**, nút "Lập hoá đơn thanh toán", "Quay lại" | ☐ |
| TT-02 | 2.3 bước 6–7 | Gõ `Nguyễn Văn B` → Tìm kiếm | 1 dòng: ( ) P01 · Nguyễn Văn B · 0999 · 19:00 21/09/2026 · 20:00 21/09/2026 · Massage body thư giãn · 400.000 · Hoàn thành | ☐ |
| TT-03 | — | Gõ `Văn C` → Tìm kiếm | "Không có phiếu nào cần thanh toán" (P02 đã thanh toán không hiện) | ☐ |
| TT-04 | — | Tìm `Nguyễn Văn B`, **không chọn** phiếu → Lập hoá đơn thanh toán | alert "Vui lòng chọn một phiếu cần thanh toán", ở lại trang Tìm | ☐ |
| TT-05 | 2.3 bước 8–9 | Chọn P01 → Lập hoá đơn thanh toán | Trang "Lập hoá đơn thanh toán": Khách hàng Nguyễn Văn B, SĐT 0999; Danh sách phiếu: P01, 19:00 21/09/2026, 20:00 21/09/2026, Hoàn thành, 400.000; Chi tiết dịch vụ – Phiếu P01: Massage body thư giãn, 1, 400.000, 400.000; Mặt hàng đã chọn: "Chưa có mặt hàng nào"; Tổng tiền dịch vụ 400.000 VNĐ, Tổng tiền hàng 0 VNĐ, Giảm giá 0 VNĐ, **Tổng tiền hoá đơn 400.000 VNĐ**; Phương thức thanh toán = Tiền mặt | ☐ |
| TT-06 | 2.3 bước 12–15 | Chọn `Tiền mặt` → Tiếp tục | Trang "Xác nhận hoá đơn": Khách hàng Nguyễn Văn B – 0999; Nhân viên lập phiếu Nguyễn Văn A; dòng P01 · Massage body thư giãn · 1 · 400.000 · 400.000; Tổng tiền 400.000, Giảm giá 0, **Tổng thanh toán 400.000**, Phương thức Tiền mặt; nút Xác nhận, In hoá đơn, Quay lại | ☐ |
| TT-07 | 1.3 (In hoá đơn) | Bấm **In hoá đơn** | Bản xem trước khi in: tiêu đề "HOÁ ĐƠN THANH TOÁN", dòng "Cửa hàng spa – In lúc …"; **không** có thanh xanh trên cùng, **không** có nút nào | ☐ |
| TT-08 | 2.3 bước 18–19 | Đóng bản in → bấm **Xác nhận** | alert "Thanh toán thành công" → về trang Tìm phiếu (bảng trống). Tìm `Nguyễn Văn B` → "Không có phiếu nào cần thanh toán". CSDL: P01 "Đã thanh toán", tongGiamGia 0, Tiền mặt, ngayGioThanhToan = lúc bấm | ☐ |
| TT-09 | — | Bấm Back của trình duyệt về trang Xác nhận → bấm Xác nhận lần nữa | alert "Vui lòng chọn một phiếu cần thanh toán", về trang Tìm; CSDL không đổi | ☐ |
| TT-10 | 2.3 ngoại lệ 13–13.2 | **Chạy lại 02.** Tìm `Nguyễn Văn B` → chọn P01 → Lập hoá đơn → chọn `Chuyển khoản` → **Sửa thông tin** | Trang "Chỉnh sửa thông tin": ô Tên mặt hàng + nút Tìm; "Mặt hàng đã chọn": chưa có; hộp Khuyến mãi; tổng tiền; Thông tin khách hàng (Họ tên Nguyễn Văn B, SĐT 0999 – sửa được); nút Xác nhận, Quay lại | ☐ |
| TT-11 | 2.3 ngoại lệ 13.3 | Gõ `Tinh dầu thư giãn` → Tìm | Bảng: MH01 · Tinh dầu thư giãn · Chai · 150.000 · ô số lượng `1` · nút Thêm | ☐ |
| TT-12 | 2.3 ngoại lệ 13.3–13.4 | Để số lượng 1 → Thêm | "Mặt hàng đã chọn": MH01 · Tinh dầu thư giãn · 1 · 150.000 · 150.000; Tổng tiền hàng 150.000; Tổng tiền hoá đơn **550.000** | ☐ |
| TT-13 | — | Ở dòng MH01 của kết quả tìm, nhập số lượng `2` → Thêm | Không thêm dòng mới; MH01 thành **3**, thành tiền 450.000 (cộng dồn) | ☐ |
| TT-14 | — | Ở "Mặt hàng đã chọn" sửa số lượng MH01 thành `1` → bấm ra ngoài ô | Trang tự tải lại, MH01 = 1, tổng hoá đơn 550.000 | ☐ |
| TT-15 | — | Sửa số lượng MH01 thành `0` → bấm ra ngoài ô | alert "Số lượng phải là số nguyên dương"; số lượng giữ 1 | ☐ |
| TT-16 | — | Tìm ô trống → ở MH02 nhập số lượng `0` → Thêm | Trình duyệt chặn, báo giá trị phải ≥ 1 (không gửi đi) | ☐ |
| TT-17 | — | Thêm MH02 số lượng 2 → bấm Xoá ở dòng MH02 | MH02 biến mất, tổng quay về 550.000 | ☐ |
| TT-18 | 1.3 (Áp dụng KM) | Mở hộp Khuyến mãi | Chỉ có "-- Không áp dụng --", "KM01 – Giảm 10% (giảm 10%; Áp dụng cho mọi hoá đơn)", "KM02 – Giảm 50.000 (giảm 50.000 VNĐ; Áp dụng cho mọi hoá đơn)"; **không có KM03** (hết hạn) | ☐ |
| TT-19 | — | Chọn KM01 | Giảm giá **55.000**, Tổng tiền hoá đơn **495.000** | ☐ |
| TT-20 | — | Chọn KM02 | Giảm giá **50.000**, Tổng **500.000** | ☐ |
| TT-21 | — | Đổi Họ tên thành rỗng → Xác nhận | alert "Vui lòng nhập họ tên và số điện thoại khách hàng", ở lại trang, dữ liệu giữ | ☐ |
| TT-22 | — | Họ tên `Nguyễn Văn B`, SĐT `0987` (của khách C) → Xác nhận | alert "Cập nhật thông tin khách hàng không thành công", ở lại trang, ô SĐT vẫn 0987 | ☐ |
| TT-23 | — | Chọn KM01; sửa số lượng MH01 thành `2` rồi bấm ra ngoài ô (trang tải lại); Họ tên `Nguyễn Văn Bình`, SĐT `0999` → Xác nhận | alert "Cập nhật thông tin khách hàng thành công" → trang Lập hoá đơn: Khách hàng **Nguyễn Văn Bình**; MH01 số lượng **2**; Tổng tiền hàng 300.000; "Giảm giá (KM01 – Giảm 10%): 70.000 VNĐ"; Tổng tiền hoá đơn **630.000**; Phương thức vẫn **Chuyển khoản** | ☐ |
| TT-24 | — | Tiếp tục → Xác nhận hoá đơn | Khách hàng Nguyễn Văn Bình – 0999; 2 dòng: P01 Massage body thư giãn 1 · 400.000 và P01 Tinh dầu thư giãn 2 · 150.000 · 300.000; Tổng tiền 700.000; Giảm giá (KM01 – Giảm 10%) 70.000; **Tổng thanh toán 630.000**; Chuyển khoản | ☐ |
| TT-25 | — | Bấm Xác nhận | alert "Thanh toán thành công". CSDL: P01 "Đã thanh toán", tongGiamGia **70000**, "Chuyển khoản", tblKhuyenMaiid = 1; `tblChiTietMatHang` có 1 dòng (soLuong 2, đơn giá 150000, MH01); `tblMatHang` MH01 vẫn tồn **50** (không trừ kho); `tblKhachHang` id 1 tên Nguyễn Văn Bình | ☐ |
| TT-26 | — | **Chạy lại 02.** Chọn P01 → Lập hoá đơn → Sửa thông tin → thêm MH01 → chọn KM01 → Quay lại → Quay lại | Lập hoá đơn vẫn có MH01 và KM01; Quay lại về trang Tìm với ô tên `Nguyễn Văn B` và P01 đang được chọn | ☐ |
| TT-27 | — | Ở TT-26 bấm Lập hoá đơn thanh toán lại với P01 | Hoá đơn làm lại từ đầu: không mặt hàng, không khuyến mãi, Tiền mặt, tổng 400.000 | ☐ |
| TT-28 | — | Đăng xuất, đăng nhập lại `letan`, gõ `/spa/lt/gdXacNhan.jsp` | alert "Vui lòng chọn một phiếu cần thanh toán", về trang Tìm | ☐ |

## E. Liên thông 3 module (đã chạy lại 02)

| Mã | Bước và dữ liệu | Kết quả mong đợi | Đạt |
|---|---|---|---|
| LT-01 | `quanli`: thêm dịch vụ `Chăm sóc da mặt cơ bản`, Chăm sóc da mặt, 60, 400.000 | Thêm thành công, mã DV05 | ☐ |
| LT-02 | `letan`: Tiếp nhận khách mới → `0987` → Tìm → tick "Chăm sóc da mặt cơ bản" | Hộp chọn có **KTV004 – Phạm Thị Lan – Chăm sóc da mặt – Rảnh** | ☐ |
| LT-03 | Chọn Phạm Thị Lan → Xác nhận lập phiếu | P04 của Nguyễn Văn C, Đang phục vụ | ☐ |
| LT-04 | `quanli`: thử Xoá "Chăm sóc da mặt cơ bản" | "Không thể xoá dịch vụ đang có trong phiếu chưa thanh toán" | ☐ |
| LT-05 | `letan`: Hoàn thành P04 → Cho khách thanh toán → tìm `Nguyễn Văn C` | Thấy P04 · Chăm sóc da mặt cơ bản · 400.000 · Hoàn thành | ☐ |
| LT-06 | Lập hoá đơn P04 → Sửa thông tin → KM02 → Xác nhận → chọn `Thẻ` → Tiếp tục → Xác nhận | "Thanh toán thành công"; hoá đơn: Tổng tiền 400.000, Giảm 50.000, Tổng thanh toán **350.000**, Thẻ | ☐ |
| LT-07 | `quanli`: Xoá "Chăm sóc da mặt cơ bản" | "Xoá dịch vụ thành công"; dịch vụ biến mất nhưng trong CSDL còn với trạng thái "Đã xoá" (vì đã có trong hoá đơn P04) | ☐ |
