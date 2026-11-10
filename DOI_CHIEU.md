# Đối chiếu code với báo cáo

Đối chiếu mã nguồn hiện tại (`src/`, `database/`) với `BaoCao.pdf` (đọc cả phần chữ và hình: biểu đồ UC, trạng thái, lớp, giao tiếp, hoạt động, tuần tự, CSDL, giao diện). Chưa sửa code theo tài liệu này.

Quy ước: **[Mục x.y]** = mục trong báo cáo; *in nghiêng* = tên do nhóm tự đặt (báo cáo không có).

## 1. Tóm tắt

| Loại | Số mục | Ghi chú |
|---|---|---|
| Chức năng còn thiếu | 6 (T1 đã sửa) | Không thiếu luồng nghiệp vụ chính nào; chủ yếu là chi tiết hiển thị/lưu trữ bị bỏ có chủ đích |
| Chức năng thừa | 9 | Phần lớn là phần báo cáo có UC nhưng không thiết kế, hoặc kiểm tra dữ liệu/bảo vệ |
| Làm khác thiết kế | 28 | CSDL, DAO, từng module |
| Báo cáo mâu thuẫn | 38 | Kèm cách code đang xử lí |

Cả 3 module chạy đủ kịch bản chính và các kịch bản ngoại lệ của mục 2 (xem `KICH_BAN_TEST.md`).

## 2. Chức năng còn thiếu (báo cáo có, code chưa có)

| # | Nội dung trong báo cáo | Hiện trạng code | Lí do |
|---|---|---|---|
| T1 | **[2.1 bước 4]** Danh sách dịch vụ có cột "Mô tả" | **Đã sửa:** bảng `gdQuanLiDichVu.jsp` có cột Mô tả, đặt giữa "Đơn giá" và "Trạng thái" đúng thứ tự cột ở 2.1 bước 4; dòng "Không có dịch vụ nào phù hợp" colspan 10 | Trước đây làm theo hình 9.1 (không có cột này) |
| T2 | **[2.2 ngoại lệ 10.3–10.4]** Khách mới: nút "Ok" và thông báo "Thêm mới khách hàng thành công" ngay trên trang Lập phiếu | Không có nút Ok; khách mới được lưu khi bấm "Xác nhận lập phiếu", không có thông báo riêng | Quyết định đã chốt (theo 9.2, 10.2) |
| T3 | **[7.3]** Phiếu lưu 2 vai trò lễ tân: người lập phiếu và *nhân viên thu tiền* (`nhanVienThanhToan`) | Chỉ lưu người lập phiếu; trang Xác nhận hoá đơn ghi "Nhân viên lập phiếu" | CSDL mục 8 không có cột này |
| T4 | **[6.3.1 bước 40]** Lưu tổng tiền dịch vụ, tổng tiền hàng, tổng thanh toán vào phiếu | Chỉ lưu `tongGiamGia`; các tổng khác tính lại bằng `tinhTongTien()` | Theo 8.5 (đã loại bỏ thuộc tính dẫn xuất) |
| T5 | **[1.3]** "Chọn chương trình khuyến mãi *phù hợp*"; **[3.3, 8]** `dieuKienApDung` | Chỉ lọc theo ngày hiệu lực + trạng thái; `dieuKienApDung` chỉ hiển thị, không kiểm tra | Báo cáo không nói điều kiện được kiểm tra thế nào |
| T6 | **[4.1–4.3, 2.x]** Thông báo sai đăng nhập "Tên đăng nhập hoặc mật khẩu sai" (mục 4) | Dùng câu của mục 2: "…không đúng" | Hai mục ghi khác nhau, chọn mục 2 |

Các phương thức của pha phân tích (mục 5) như `layThongTinNVQL()`, `layThongTinNVLT()`, `layThongTinKhachHang()`, `layDSChiTietPhieuDichVu()`, `capNhatTrangThaiKyThuatVien()` không có phương thức riêng trong code. Đây không phải thiếu, vì pha thiết kế (mục 9) đã gộp chúng vào `kiemTraDangNhap()`, `getPhieuCanThanhToan()`, `luuPhieuDichVu()`.

## 3. Chức năng thừa (code có, báo cáo không thiết kế)

| # | Chức năng | Vị trí | Căn cứ |
|---|---|---|---|
| X1 | Đăng xuất | `doDangXuat.jsp`, link trên thanh trên | Không có trong UC; quyết định đã chốt |
| X2 | *Sửa dịch vụ* (trang + DAO), cho đổi trạng thái "Đang cung cấp"/"Ngừng cung cấp" | `ql/gdSuaDichVu.jsp`, `ql/doSuaDichVu.jsp`, `DichVuDAO.getDichVuTheoId/suaDichVu`, `kiemTraTrungTen(ten, idBoQua)` | UC 1.1 và lớp phân tích 5.1 (`subSua`) có, nhưng mục 4, 9, 10, 11 không thiết kế |
| X3 | *Xoá dịch vụ* (xoá hẳn / đánh dấu "Đã xoá" / từ chối) | `ql/doXoaDichVu.jsp`, `DichVuDAO.xoaDichVu` | UC 1.1, 5.1 (`subXoa`), luật xoá ở 3.1; không có thiết kế |
| X4 | *Hoàn thành phục vụ* | `lt/doHoanThanhPhucVu.jsp`, `PhieuDichVuDAO.hoanThanhPhucVu`, nút trên `gdTiepNhanKhachHang.jsp` | Có ở UC 1.2 (bước 2, 4) và 3.1; biểu đồ UC, mục 4, 5, 9–11 không có |
| X5 | Kiểm tra quyền theo vai trò ở đầu mỗi trang `ql/`, `lt/` | mọi trang `ql/*`, `lt/*` | Báo cáo không nói |
| X6 | Kiểm tra dữ liệu nhập và câu báo lỗi (thời gian/đơn giá dương, SĐT/họ tên bắt buộc, ≥1 dịch vụ, số lượng mặt hàng nguyên dương…) | `doThemDichVu`, `doSuaDichVu`, `doLuuPhieuDichVu`, `gd/doChinhSuaThongTin` | Báo cáo chỉ có trùng tên dịch vụ và "chưa chọn KTV" (4.2) |
| X7 | Bảo vệ dữ liệu khi nhiều người cùng thao tác: KTV đã bận lúc lưu phiếu → huỷ; phiếu đã thanh toán ở nơi khác → không thanh toán lại | `luuPhieuDichVu`, `luuThanhToan`, `doLuuPhieuDichVu` | Báo cáo không nói |
| X8 | Hộp xác nhận trước khi Xoá dịch vụ / Hoàn thành phục vụ | `gdQuanLiDichVu.jsp`, `gdTiepNhanKhachHang.jsp` | Báo cáo không nói |
| X9 | Tiêu đề chỉ hiện khi in ("HOÁ ĐƠN THANH TOÁN – In lúc …"), thanh trên hiện tên + chức vụ người đăng nhập | `gdXacNhan.jsp`, `header.jsp` | Chỉ để hiển thị |

## 4. Chỗ làm khác thiết kế

### 4.1. CSDL (mục 8, hình trang 43)

| # | Thiết kế | Code | Lí do |
|---|---|---|---|
| K1 | Hình: `tblNhanVienQuanLy`, `tbLoaiThietBi` | `tblNhanVienQuanLi`, `tblLoaiThietBi` | Theo chữ mục 8.1 |
| K2 | Hình: khoá ngoại `tblNhanVienLeTantblNhanVienid`, `tblKyThuatVientblNhanVienid` | `tblNhanVienLeTanid`, `tblKyThuatVienid` | Theo chữ mục 8.4 |
| K3 | Hình: `tblChiTietMatHang.tblHoaDonid` | Bỏ cột | Không có bảng HoaDon (3.3) |
| K4 | `tblKhachHang.maKhachHang integer(10)` | `VARCHAR`, dạng KH001 | Lớp KhachHang khai `String` (7.4) |
| K5 | `tblKhachHang.email` NOT NULL (không đánh dấu N) | Cho NULL | Lập phiếu không hỏi email |
| K6 | `tblDichVu.tenDichVu` UNIQUE | Không UNIQUE, kiểm tra trùng bằng code (bỏ qua dịch vụ "Đã xoá") | Dịch vụ "Đã xoá" giữ tên cũ |
| K7 | Kiểu `integer(10)`, `float(10)`, `timestamp` | `INT`, `FLOAT`, `TIMESTAMP`; collation `utf8mb4_0900_as_ci` | Phân biệt dấu, không phân biệt hoa thường |
| K8 | Đọc dữ liệu: báo cáo không nói | Mọi thao tác đọc qua stored procedure (`03_stored_procedure.sql`), ghi bằng transaction | Yêu cầu của nhóm |

### 4.2. Lớp thực thể, DAO (mục 7, 9)

| # | Thiết kế | Code | Lí do |
|---|---|---|---|
| K9 | Thuộc tính `X[]`, DAO trả `DichVu[]`, `PhieuDichVu[]`… | `ArrayList<X>` | Dễ thêm/xoá mặt hàng trong session |
| K10 | 7.4: `KhuyenMai` không có ngày | Có `ngayBatDau`, `ngayKetThuc` | Theo hình 9.x và CSDL |
| K11 | 5.3: `tinhTongTien()` trả `double` | Trả `float` (các thuộc tính tiền là `float` theo 7.4); giảm % làm tròn đến đồng | Thống nhất kiểu |
| K12 | Không có | Thêm `PhieuDichVu.themMatHang/suaSoLuongMatHang/xoaMatHang/getThoiGianBatDau/getThoiGianKetThuc`, `ChiTietMatHang.getThanhTien()` | Dùng chung cho trang gd và do |
| K13 | 9.1: `DAO()` mở kết nối | Dùng một `static Connection`, mở lại khi đóng/mất kết nối | Yêu cầu của nhóm |
| K14 | 9.3: `luuThanhToan` "cập nhật thông tin thanh toán" | Chỉ cập nhật khi phiếu còn "Hoàn thành" | Tránh thanh toán 2 lần |

### 4.3. Đăng nhập (9.1, 9.2)

| # | Thiết kế | Code |
|---|---|---|
| K15 | 9.1 `doDangNhap.jsp` gọi `NhanVienQuanLiDAO`, 9.2 cùng trang đó gọi `NhanVienLeTanDAO` | Một trang: thử tài khoản quản lí trước rồi lễ tân |
| K16 | Kịch bản: `a` / `a@123` cho cả 2 vai trò | Tài khoản `quanli` / `a@123`, `letan` / `a@123`; tên đăng nhập không phân biệt hoa thường, mật khẩu phân biệt |

### 4.4. Module 1 – Quản lí thông tin dịch vụ

| # | Thiết kế | Code |
|---|---|---|
| K17 | 9.1/10.1: chưa có từ khoá → bảng trống, có từ khoá → tìm | Như thiết kế; thêm: bấm Tìm với ô trống → hiện tất cả (trừ "Đã xoá"); kết quả rỗng → "Không có dịch vụ nào phù hợp" |
| K18 | 9.1: sau thêm → về `gdQuanLiDichVu.jsp` | Như thiết kế, giữ lại từ khoá đang tìm khi quay về |
| K19 | 9.1: "sinh mã dịch vụ" | DV + (MAX(id)+1) đệm 0 đủ 2 chữ số |

### 4.5. Module 2 – Nhận khách và phân công

| # | Thiết kế | Code |
|---|---|---|
| K20 | Hình 9.2: bảng phân công 4 cột | Thêm cột "Trạng thái" (Đã/Chưa phân công) theo kịch bản 2.2 bước 14; không có KTV rảnh → "Không có kĩ thuật viên rảnh" |
| K21 | 9.2: "hộp chọn cho phép chọn một hoặc nhiều KTV" | `select multiple` (giữ Ctrl/Cmd); tick dịch vụ / chọn KTV tự gửi trang về chính nó |
| K22 | 9.2: tìm thấy khách → tự điền họ tên | Như thiết kế, ô họ tên chuyển chỉ đọc; SĐT đã có lúc lưu → dùng khách cũ |
| K23 | 9.2: `getDSKTVPhuHop` theo chuyên môn + không trùng giờ | Thêm điều kiện trạng thái "Rảnh" (UC 1.2) |
| K24 | Kịch bản: phân công 19h–20h | Mọi phân công bắt đầu lúc lưu phiếu, kết thúc dự kiến = bắt đầu + thời gian dịch vụ; khi Hoàn thành ghi giờ kết thúc thật |

### 4.6. Module 3 – Cho khách thanh toán

| # | Thiết kế | Code |
|---|---|---|
| K25 | Hình 9.3: trang Lập hoá đơn không có dòng giảm giá | Có dòng "Giảm giá (mã – tên KM)" (chữ 9.3, 10.3 có nói giảm giá) |
| K26 | 9.3: Chỉnh sửa thông tin có hộp chọn khuyến mãi; hình 9.3 không có | Có hộp chọn khuyến mãi (theo chữ 9.3) |
| K27 | 9.3: `doChinhSuaThongTin` chỉ xử lí thông tin khách | Ghi thêm số lượng + khuyến mãi đang chọn trên form (phòng khi chưa kịp tự gửi về) |
| K28 | 9.3/11.3: `doLuuHoaDon` lưu → thông báo → về trang Tìm | Như thiết kế; xoá phiếu khỏi session; nếu lưu lỗi → "Thanh toán không thành công", ở lại trang Xác nhận |

## 5. Chỗ báo cáo mâu thuẫn hoặc thiếu thông tin

Cột "Code" ghi cách đang xử lí (chi tiết ở `CLAUDE.md` mục 4, 7).

### 5.1. Use case và kịch bản (mục 1, 2)

| # | Mâu thuẫn | Code |
|---|---|---|
| M1 | **1.1**: mô tả có "UC Xem thông tin dịch vụ", biểu đồ UC chỉ có Thêm/Sửa/Xoá (extend) | Xem = tìm kiếm + danh sách |
| M2 | **1.2**: Bước 2 và Bước 4 có "Hoàn thành phục vụ" nhưng biểu đồ UC không có; mục 4, 5, 6, 9, 10, 11 cũng không thiết kế | Làm thêm nút Hoàn thành (X4) |
| M3 | **1.3**: biểu đồ UC có "Thêm mặt hàng vào hoá đơn" nhưng Bước 4 không mô tả; ngược lại "sửa thông tin khách hàng" có ở 5.3, 9.3 nhưng không có UC | Làm cả hai theo 9.3 |
| M4 | **1.3** "lập hoá đơn cho *một* phiếu", 3.3 "mỗi lần thanh toán ứng với đúng một phiếu" ↔ 5.3 "các phiếu được chọn", hình 9.3 "Danh sách phiếu dịch vụ", 8.5 "các phiếu của hóa đơn" | Một hoá đơn = một phiếu |
| M5 | **2.1, 2.2, 2.3**: cùng tài khoản `a` / `a@123`, cùng tên Nguyễn Văn A cho quản lí và lễ tân | Tài khoản `quanli`, `letan` |
| M6 | **2.1 bước 6** form không có ô mô tả, **bước 7** lại nhập mô tả | Form có ô mô tả (theo hình 9.1) |
| M7 | **2.1**: đơn giá 400.000 VNĐ ↔ **6.1, 11.1**: đơn giá = 400 | Lưu theo đồng (400.000) |
| M8 | **2.1 bước 4**: bảng có cột Mô tả (giữa Đơn giá và Trạng thái) ↔ hình 9.1 không có | Theo 2.1: có cột Mô tả giữa Đơn giá và Trạng thái (T1) |
| M9 | **2.1**: "Dịch vụ đã tồn tại, vui lòng kiểm tra lại" ↔ **4.1**: "thông báo lỗi" chung | Dùng câu của 2.1 |
| M10 | **2.x**: "Tên đăng nhập hoặc mật khẩu không đúng" ↔ **4.x**: "…sai" | Dùng câu của 2.x |
| M11 | **2.2**: phiếu P01 của Nguyễn Văn B, SĐT 0123, "Đang thực hiện" ↔ **2.3**: P01 của Nguyễn Văn B, SĐT 0999, "Hoàn thành", cùng giờ 19h 21/09/2026 | Dữ liệu mẫu: P01 – B – 0999 – Hoàn thành |
| M12 | Trạng thái phiếu "Đang thực hiện" (2.2) ↔ "Đang phục vụ" (9.2, 11.2); KTV "đang bận" (2.2) ↔ "Đang phục vụ" (5.2, 9.2) | "Đang phục vụ" cho cả hai |
| M13 | **2.1**: "Chăm sóc da mặt cơ bản" là dịch vụ *mới*, 60 phút, 400.000 ↔ **2.2, 6.2, 11.2**: đã có sẵn là DV02, 30 phút, 200 | Không tạo sẵn; mã DV02 trong kịch bản 2.2 không khớp |
| M14 | **2.2 bước 14**: KTV001 Trần Văn Khánh chuyên môn "Chăm sóc da" rồi sửa thành "Massage body" ngay trong câu | Massage body |
| M15 | **2.2 ngoại lệ 10**: có nút "Ok" + "Thêm mới khách hàng thành công" ↔ **9.2, 10.2**: khách mới lưu khi xác nhận lập phiếu | Theo 9.2 (T2) |
| M16 | **2.2, 6.2**: thời gian bắt đầu phân công 19h 21/09/2026 ↔ **9.2**: thời điểm lập phiếu | Thời điểm lập phiếu |
| M17 | Lọc KTV: **1.2** "đang rảnh" (theo trạng thái) ↔ **5.2, 9.2** "không trùng khoảng thời gian" | Áp cả hai điều kiện (K23) |
| M18 | **2.3 ngoại lệ 13.3**: trang Chỉnh sửa có nút "Tiếp tục" ↔ **9.3**: nút `btnXacNhan` | Nút "Xác nhận" |
| M19 | **2.3 13.2** và hình 9.3: trang Chỉnh sửa không có khuyến mãi ↔ chữ **5.3, 9.3, 10.3**: có chọn khuyến mãi | Có (K26) |
| M20 | Hình 9.3: chọn phiếu bằng ô checkbox ↔ **9.3**: `radChonPhieu` (radio) | Radio |
| M21 | **6.3.1 bước 35** "nhân viên lập Nguyễn Văn A": không rõ là người lập phiếu hay người thu tiền | Người lập phiếu; nhãn trên trang Xác nhận hoá đơn đổi thành "Nhân viên lập phiếu:" cho khỏi nhầm (T3) |
| M22 | 5 loại dịch vụ (9.1 "hộp chọn 5 loại") không được liệt kê ở đâu | Massage body, Chăm sóc da mặt, Gội đầu dưỡng sinh, Chăm sóc móng, Tắm trắng |

### 5.2. Trạng thái, hoạt động (mục 4, 10)

| # | Mâu thuẫn | Code |
|---|---|---|
| M23 | **4.1, 6.1, 9.1, 10.1, 11.1** chỉ thiết kế Thêm; UC 1.1 và lớp phân tích 5.1 có Sửa/Xoá | Làm Sửa/Xoá (X2, X3) |
| M24 | **4.2**: lưu phiếu "chưa phân công KTV → thông báo, quay lại lập phiếu" ↔ biểu đồ hoạt động **10.2** không có nhánh này | Có kiểm tra |
| M25 | **4.3 Bước 1** liệt kê 4 trạng thái ↔ hình 4.3 có thêm "chỉnh sửa thông tin", "xác nhận" | Theo hình + 9.3 |
| M26 | **4.3 Bước 2**: ở Lập hoá đơn "chọn phương thức và nhấn Xác nhận → thành công" (bỏ qua trang xác nhận) ↔ hình 4.3, 9.3: Tiếp tục → trang Xác nhận → Xác nhận | Có trang Xác nhận |
| M27 | Hình **4.3**: không có mũi tên từ "Chỉnh sửa thông tin" quay về "Lập hoá đơn" | Xác nhận/Quay lại → Lập hoá đơn (theo 9.3, 10.3) |
| M28 | Mục **10.3** không có hình biểu đồ hoạt động; **10.2/10.3** ghi "tương tự 4.1", "như 4.2" (đúng ra là 10.1, 10.2); **9.2** ghi "như module 3.1" | — |

### 5.3. Lớp phân tích, thiết kế (mục 3, 5, 6, 7, 9)

| # | Mâu thuẫn | Code |
|---|---|---|
| M29 | **5.1** chữ: `GDQuanLyDichVu`, `DichVu.timDichVu()` ↔ hình 5.1: `GDQuanLiDichVu`, `layThongTinDichVu()` | Theo 9.1: `gdQuanLiDichVu.jsp`, `timDichVu` |
| M30 | **5.2** chữ: chủ thể `layDSPhieuDichVuHienTai()`, `lapPhieuDichVu()` là `PhieuDichVu` ↔ hình 5.2 đặt ở `ChiTietPhieuDichVu`; `capNhatTrangThaiKyThuatVien()` ↔ `capNhatTrangThaiKTV()` (hình, 6.2) | Theo 9.2: `getDSPhieuHienTai`, `luuPhieuDichVu` (gộp cập nhật KTV) |
| M31 | Tên phương thức phân tích ↔ thiết kế: `kTraDangNhap`/`kiemTraDangNhap`, `kTraTrungTenDichVu`/`kiemTraTrungTen`, `timPhieuCanThanhToan`/`getPhieuCanThanhToan`, `thanhToan`/`luuThanhToan`, `capNhatThongTinKhachHang` (trả `KhachHang`) / `capNhatKhachHang` (trả `boolean`) | Theo mục 9 |
| M32 | **6.3.1 bước 27**: "GDLapHoaDon gọi lớp *HoaDon* để tính tổng tiền" nhưng bước 28 là `PhieuDichVu.tinhTongTien()`; 3.3 nói không có lớp HoaDon | `PhieuDichVu.tinhTongTien()` |
| M33 | Lớp `ChuongTrinhKhuyenMai` (3.3) ↔ `KhuyenMai` (5.3 trở đi) | `KhuyenMai` |
| M34 | **3.3** KhachHang có `ghiChu`; ChiTietPhieuDichVu có `soLuong`, `thanhTien` ↔ 7.4/CSDL không có (hình 9.3 vẫn hiện "Số lượng 1", "Thành tiền") | Không lưu; hiển thị số lượng = 1, thành tiền = đơn giá |
| M35 | **7.3** có `nhanVienThanhToan` ↔ 7.4 và CSDL không có | Không lưu (T3) |
| M36 | Hình **5.3**: `ChiTietMatHang` chỉ có `donGiaTaiThoiDiemBan` (thiếu `soLuong`); 7.4 `ChiTietPhieuDichVu.dsPhanCong : PhanCongKTV` (thiếu `[]`) | Có `soLuong`; `dsPhanCong` là danh sách |

### 5.4. CSDL (mục 8)

| # | Mâu thuẫn | Code |
|---|---|---|
| M37 | **8.2** vẫn liệt kê `tongTienDichVu`, `tongTienHang`, `tongThanhToan` trong `tblPhieuDichVu` ↔ **8.5** loại bỏ; 8.5 còn nói về `tblHoaDon.tblKhachHangid` dù không có bảng HoaDon; tên bảng/khoá ngoại trong hình ≠ chữ (K1–K3) | Theo 8.5 và chữ 8.1, 8.4 |
| M38 | Không quy định: các giá trị `loaiGiamGia`, cách dùng `dieuKienApDung`, cách sinh mã (dịch vụ, khách, phiếu), các trạng thái dịch vụ ngoài "Đang cung cấp" | Tự chọn, ghi ở `CLAUDE.md` mục 7 |
