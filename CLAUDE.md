# CLAUDE.md – Hệ thống quản lí cửa hàng spa (BTL PTTK HTTT, nhóm N06, module M2)

Nguồn yêu cầu duy nhất: `BaoCao.pdf`. Tên trang/lớp/phương thức/bảng lấy theo **mục 9** (thiết kế), CSDL theo **mục 8**.

## 1. Tổng quan
3 module: (1) Quản lí thông tin dịch vụ – NV quản lí; (2) Nhận khách và phân công NV phục vụ tại quầy – lễ tân; (3) Cho khách thanh toán tại quầy – lễ tân.

Công nghệ: Java 11, JSP thuần (không framework, không Servlet tự viết, không JSTL), Tomcat 9, MySQL 8 (`spa_db`, root/123456), Maven đóng gói war. Driver `mysql-connector-j 8.4.0` đặt ở `src/main/webapp/WEB-INF/lib/` (không khai trong pom để war không chứa 2 bản).
```
pom.xml
database/01_tao_bang.sql       # DROP+CREATE spa_db và toàn bộ bảng mục 8
database/02_du_lieu_mau.sql    # TRUNCATE + nạp dữ liệu mẫu (chạy lại để reset dữ liệu, giữ SP)
database/03_stored_procedure.sql  # các SP đọc dữ liệu (bổ sung dần theo chức năng), chạy lại được
src/main/java/model/           # thực thể theo mục 7.4 (NhanVien, NhanVienQuanLi, NhanVienLeTan, KyThuatVien,
                               #  KhachHang, DichVu, PhieuDichVu, ChiTietPhieuDichVu, PhanCongKTV, MatHang,
                               #  ChiTietMatHang, KhuyenMai, + NguyenLieu, DinhMucNguyenLieu, LoaiThietBi, ...)
src/main/java/dao/             # DAO (cha) + các XxxDAO
src/main/webapp/               # header.jsp, gdDangNhap.jsp, doDangNhap.jsp, doDangXuat.jsp, WEB-INF/web.xml
src/main/webapp/ql/            # trang của NV quản lí
src/main/webapp/lt/            # trang của lễ tân
```

## 2. Bản đồ chức năng
**Chung:** `gdDangNhap.jsp` → `doDangNhap.jsp` (NhanVienQuanLiDAO.kiemTraDangNhap / NhanVienLeTanDAO.kiemTraDangNhap; đúng → session `nvql`/`nvlt`) → `ql/gdChinhNVQL.jsp` hoặc `lt/gdChinhNVLT.jsp`. Bảng: tblNhanVien, tblNhanVienQuanLi, tblNhanVienLeTan.

**M1 – Quản lí thông tin dịch vụ (ql/)** – bảng tblDichVu (kiểm tra xoá: tblChiTietPhieuDichVu, tblPhieuDichVu)
| Trang | DAO |
|---|---|
| gdQuanLiDichVu.jsp (txtTuKhoa, btnTimKiem tự gửi về, bảng + link Sửa/Xoá, btnThemMoi, btnQuayLai) | DichVuDAO.timDichVu(tuKhoa) |
| gdThemDichVu.jsp → doThemDichVu.jsp | DichVuDAO.kiemTraTrungTen(ten), themDichVu(dv) |
| *gdSuaDichVu.jsp → doSuaDichVu.jsp* | *DichVuDAO.getDichVuTheoId(id), kiemTraTrungTen(ten, idBoQua), suaDichVu(dv)* |
| *doXoaDichVu.jsp* | *DichVuDAO.xoaDichVu(dv)* |

**M2 – Nhận khách, phân công (lt/)** – bảng tblKhachHang, tblDichVu, tblKyThuatVien, tblPhieuDichVu, tblChiTietPhieuDichVu, tblPhanCongKTV
| Trang | DAO |
|---|---|
| gdTiepNhanKhachHang.jsp (bảng tblPhieuDV, btnTiepNhanKhachMoi, *nút Hoàn thành*) | PhieuDichVuDAO.getDSPhieuHienTai() |
| *doHoanThanhPhucVu.jsp* | *PhieuDichVuDAO.hoanThanhPhucVu(pdv)* |
| gdLapPhieuDichVu.jsp (3 khung: khách / dịch vụ tick / phân công KTV; tự gửi về chính nó) | KhachHangDAO.timKhachHangTheoSDT(sdt), DichVuDAO.getDSDichVuDangCungCap(), KyThuatVienDAO.getDSKTVPhuHop(dv, thoiGianBatDau) |
| doLuuPhieuDichVu.jsp | KhachHangDAO.themKhachHang(kh), PhieuDichVuDAO.luuPhieuDichVu(pdv) |

**M3 – Thanh toán (lt/)** – bảng tblPhieuDichVu, tblChiTietPhieuDichVu, tblKhachHang, tblMatHang, tblChiTietMatHang, tblKhuyenMai
| Trang | DAO |
|---|---|
| gdTimPhieuCanThanhToan.jsp (txtTenKhachHang, btnTimKiem tự gửi về, radChonPhieu, btnLapHoaDon) | PhieuDichVuDAO.getPhieuCanThanhToan(tenKH) |
| gdLapHoaDon.jsp (hộp chọn PTTT, btnSuaThongTin, btnTiepTuc) | – (tính tiền bằng PhieuDichVu.tinhTongTien()) |
| gdChinhSuaThongTin.jsp (tìm/thêm/xoá mặt hàng, số lượng, khuyến mãi, sửa họ tên–SĐT; tự gửi về) → doChinhSuaThongTin.jsp | MatHangDAO.timMatHang(ten), KhuyenMaiDAO.getDSKhuyenMaiHieuLuc(ngay), KhachHangDAO.capNhatKhachHang(kh) |
| gdXacNhan.jsp (btnXacNhan, *nút In hoá đơn*) → doLuuHoaDon.jsp | PhieuDichVuDAO.luuThanhToan(pdv) |

*In nghiêng* = báo cáo không thiết kế, tên do ta tự đặt.

## 3. Quy ước code
- **Bám sát báo cáo**: không thêm/bớt chức năng, không đặt luật nghiệp vụ mà báo cáo không có. Chi tiết nhỏ báo cáo không nói (câu thông báo, mã tự sinh, giá trị mặc định...) → chọn cách đơn giản nhất, **ghi vào mục 7** rồi làm tiếp, không dừng lại hỏi.
- `gdXxx.jsp` hiển thị, `doXxx.jsp` xử lí (không in HTML). Mọi trang: xử lí xong hết (kể cả `sendRedirect`/`forward`) rồi mới `<%@ include file="/header.jsp" %>` và in HTML.
- Scriptlet chỉ dùng cú pháp **Java 8** (không `var`, không switch biểu thức, không text block). Không dùng EL/JSTL.
- `dao.DAO`: `protected static Connection con`; hàm khởi tạo mở kết nối nếu `con == null || con.isClosed()`. Mọi DAO kế thừa DAO, dùng chung Connection này.
- **Đọc** = `CallableStatement` gọi stored procedure (tên `sp` + tên phương thức, vd `spTimDichVu`). **Ghi** = transaction: `setAutoCommit(false)` → các câu lệnh → `commit()`; lỗi → `rollback()`, trả `false`; cuối cùng `setAutoCommit(true)`.
- CSS và JS dùng chung chỉ đặt trong `header.jsp`. header.jsp cũng hiện thông báo: đọc `session` thuộc tính `thongBao` → `alert()` rồi xoá.
- Mẫu trang gd: `<%@ page contentType=... %>` + import → scriptlet xử lí (khai `String tieuDe = "...";`) → `<%@ include file="/header.jsp" %>` → HTML → kết thúc `</div></body></html>`. Hàm có sẵn từ header: `h()` (escape HTML), `js()`, `u()` (mã hoá tham số URL), `chuoi()`, `tien()`, `thoiGian()`, `ngay()`, `chon()`/`tick()` (selected/checked), `soNguyen()`; JS: `guiForm(this)`, `xacNhan('...')`, `inTrang()`; CSS (màu chủ đạo xanh dương, biến `--xanh`, `--xanh-dam`, `--xanh-nhat`, `--xanh-vien` trong `:root`): `.khung`, `.hop-nho`/`.hop-vua` (khung hẹp: form, trang chủ, hoá đơn), `.thanh-cong-cu` (trái tìm – phải nút), `.thanh-tim` (nhãn + ô + nút tìm trên một dòng), `.o-dai`, `.o-so`, `.giua`, `table.bang` (`td.so`, `td.giua`; dòng `td[colspan]` = dòng thông báo rỗng), `table.form`, `table.tong-tien` (`tr.dam` = dòng tổng), `.hang-nut`, `.nut` (link dạng nút chính), `.nut nut-phu` (nút phụ – mọi nút "Quay lại"), `.thong-tin-nv` + `.luoi-the` + `.the-menu` (trang chủ dạng thẻ), `.the-dang-nhap` (trang đăng nhập đặt `request.setAttribute("lopTrang", "trang-dang-nhap")` → header thêm lớp cho `<body>`, thẻ căn giữa màn hình), `.loi`, `.ghi-chu`, `.no-print`, `.chi-in` (chỉ hiện khi in). Khi in: tự ẩn thanh trên, `.hang-nut`, mọi nút. Thanh trên hiện "Họ tên – Chức vụ" + Đăng xuất. Không viết `style="..."` trong trang. DAO ghi: `catch (SQLException e) { rollback(e); return false; } finally { autoCommit(); }` (hàm có sẵn trong DAO). Trang do không include header (tự parse tham số).
- UTF-8 mọi nơi: `<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>`, web.xml `<request-character-encoding>UTF-8</request-character-encoding>`, CSDL `utf8mb4`, URL JDBC `useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh`.
- Trang tự gửi về chính nó phải **giữ lại dữ liệu đã nhập/chọn** (từ khoá, tên khách, SĐT, họ tên, dịch vụ đã tick, KTV đã chọn, phiếu đã chọn).

## 4. Quyết định đã chốt (chỗ báo cáo mâu thuẫn)
- Một trang đăng nhập chung cho cả 2 vai trò, có đăng xuất (`doDangXuat.jsp`, link trong header). Tài khoản test: `quanli` / `a@123`, `letan` / `a@123`.
- Khách mới **không có nút Ok**: hiện "Khách hàng mới. Vui lòng nhập họ tên khách hàng", khách được lưu khi bấm "Xác nhận lập phiếu" (theo 9.2).
- Có chức năng **Hoàn thành phục vụ** ở trang Tiếp nhận khách hàng.
- Mỗi dịch vụ chọn một hoặc nhiều KTV; một KTV được làm nhiều dịch vụ của cùng phiếu.
- Xoá dịch vụ đã có trong hoá đơn cũ → chỉ đánh dấu trạng thái "Đã xoá" (ẩn ở mọi màn hình, không tính khi kiểm tra trùng tên).
- Hoá đơn chính là phiếu đã thanh toán (không có bảng HoaDon). Tối đa 1 khuyến mãi, giảm theo phần trăm hoặc số tiền.
- 5 loại dịch vụ: Massage body, Chăm sóc da mặt, Gội đầu dưỡng sinh, Chăm sóc móng, Tắm trắng.
- In hoá đơn = nút in (`window.print()`) trên trang xác nhận. Không trừ tồn kho mặt hàng.

## 5. Dữ liệu mẫu (database/02_du_lieu_mau.sql)
- NV: NV001 Nguyễn Văn A – Nhân viên quản lí (`quanli`); NV002 Nguyễn Văn A – Nhân viên lễ tân (`letan`).
- KTV (chuyên môn – trạng thái): KTV001 Trần Văn Khánh (Massage body – Rảnh), KTV002 Trần Trọng Hùng (Massage body – Rảnh), KTV003 Phan Văn Khôi (Gội đầu dưỡng sinh – Đang phục vụ, KTV duy nhất của loại này → kịch bản ngoại lệ 15), KTV004 Phạm Thị Lan (Chăm sóc da mặt – Rảnh), KTV005 Đỗ Thị Mai (Chăm sóc móng – Rảnh), KTV006 Vũ Thị Ngọc (Tắm trắng – Rảnh).
- Dịch vụ: DV01 Massage body thư giãn (Massage body, 60', 400.000); DV02 Gội đầu dưỡng sinh thảo dược (45', 150.000); DV03 Sơn gel móng tay (Chăm sóc móng, 45', 120.000 – chưa có trong phiếu nào → xoá thật); DV04 Tắm trắng toàn thân (90', 600.000 – chỉ có trong phiếu đã thanh toán → xoá thành "Đã xoá"). **Không** tạo "Chăm sóc da mặt cơ bản", "Tẩy tế bào chết".
- Khách: Nguyễn Văn B 0999, Nguyễn Văn C 0987, Nguyễn Văn E 0911. **Không** tạo Nguyễn Văn D (khách mới).
- Phiếu: P01 – B, DV01, Trần Trọng Hùng, 19:00–20:00 21/09/2026, "Hoàn thành" (chờ thanh toán); P02 – C, DV04, Vũ Thị Ngọc, 15/09/2026, "Đã thanh toán" (Tiền mặt); P03 – E, DV02, Phan Văn Khôi, bắt đầu NOW(), "Đang phục vụ".
- Mặt hàng: MH01 Tinh dầu thư giãn (Chai, 150.000), MH02 Muối tắm thảo dược (Hũ, 90.000), MH03 Mặt nạ dưỡng da (Miếng, 30.000).
- Khuyến mãi: KM01 Giảm 10% (Phần trăm, 01/01/2026–31/12/2027, Đang áp dụng); KM02 Giảm 50.000 (Số tiền, 01/01/2026–31/12/2027, Đang áp dụng); KM03 Khuyến mãi hè 2025 (Phần trăm 20, 01/06/2025–31/08/2025 – hết hạn).

## 6. Cách làm việc
- Làm **từng bước theo yêu cầu** của người dùng; không làm trước bước sau.
- Xong mỗi bước: tự kiểm tra (biên dịch được thì `javac` model/dao với jar driver, chạy SQL nếu có `mysql`), ghi chi tiết tự chọn vào mục 7, đưa người dùng **cách kiểm tra** cụ thể (trang nào, nhập gì, kết quả mong đợi).
- Người dùng chạy bằng **IntelliJ + Tomcat 9** (máy không có lệnh `mvn`): mở pom.xml, cấu hình Tomcat Local, deploy artifact `war exploded`, context `/spa` → http://localhost:8080/spa/. CSDL: chạy lần lượt `database/01_…`, `02_…`, `03_…` trong MySQL Workbench / IntelliJ Database. `spa_db` trên máy đã là CSDL của dự án (người dùng đã chạy 01, 02) → được chạy lại 03 trực tiếp; chỉ chạy 01/02 (xoá dữ liệu) khi cần reset. Tự chạy thử chức năng có ghi dữ liệu trên bản sao `spa_db_test` (01–03 đổi tên CSDL) để không làm đổi dữ liệu `spa_db`.

## 7. Chi tiết tự chọn (cập nhật dần)
- Trạng thái phiếu: "Đang phục vụ" → "Hoàn thành" → "Đã thanh toán". KTV: "Rảnh" / "Đang phục vụ". Dịch vụ: "Đang cung cấp" / "Ngừng cung cấp" / "Đã xoá". KM: "Đang áp dụng". `loaiGiamGia`: "Phần trăm" / "Số tiền". PTTT: Tiền mặt / Chuyển khoản / Thẻ (mặc định Tiền mặt).
- Mã tự sinh trong câu INSERT: tiền tố + (MAX(id)+1) đệm 0: DV01, P01, KH001 (maKhachHang kiểu VARCHAR).
- CSDL so với hình trang 43: tên bảng theo mục 8.1 (`tblNhanVienQuanLi`, `tblLoaiThietBi`); tên khoá ngoại theo 8.4 (`tblNhanVienLeTanid`, `tblKyThuatVienid`); tblChiTietMatHang bỏ `tblHoaDonid`; `tblKhachHang.email` cho NULL; `tenDichVu` không UNIQUE (vì "Đã xoá"); cột không đánh dấu N là NOT NULL; integer→INT, float→FLOAT, timestamp→TIMESTAMP. Collation `utf8mb4_0900_as_ci` (phân biệt dấu, không phân biệt hoa thường) cho cả tìm kiếm và kiểm tra trùng tên. Tạo đủ bảng nguyên liệu/thiết bị nhưng không dùng.
- Model theo 7.4 (+ `ngayBatDau`, `ngayKetThuc` của KhuyenMai lấy từ biểu đồ mục 9/CSDL); `NhanVien` abstract; mọi lớp Serializable với `serialVersionUID = 1L` (để Tomcat nạp lại session sau khi sửa model và redeploy); thuộc tính `X[]` trong biểu đồ → `ArrayList<X>` khởi tạo rỗng (DAO cũng trả `ArrayList`). Không có `nhanVienThanhToan`. Hằng trạng thái đặt trong lớp: `PhieuDichVu.TT_*`, `DS_PHUONG_THUC_THANH_TOAN`; `ChiTietPhieuDichVu.TT_*`; `KyThuatVien.TT_RANH/TT_DANG_PHUC_VU`; `DichVu.TT_*`, `DS_TRANG_THAI`, `DS_LOAI_DICH_VU`; `KhuyenMai.TT_DANG_AP_DUNG`, `LOAI_PHAN_TRAM/LOAI_SO_TIEN` — code luôn dùng hằng, không gõ chuỗi. `PhieuDichVu.tinhTongTien()` gán 4 tổng và trả `tongThanhToan` (float); giảm % làm tròn đến đồng; phiếu đã thanh toán giữ `tongGiamGia` đã lưu. `ChiTietMatHang.getThanhTien()`.
- Trạng thái chi tiết phiếu chỉ có "Đang phục vụ"/"Hoàn thành" (thanh toán không đổi chi tiết). P02 không áp khuyến mãi (tongGiamGia 0). KM03 để "Đang áp dụng" nhưng hết hạn để thử lọc theo ngày. Mật khẩu lưu dạng chữ thường (như báo cáo).
- Đăng nhập: doDangNhap thử NhanVienQuanLiDAO trước rồi NhanVienLeTanDAO (SP `spKiemTraDangNhapQuanLi`, `spKiemTraDangNhapLeTan`); tên đăng nhập không phân biệt hoa thường, mật khẩu phân biệt (`COLLATE utf8mb4_bin`). Đúng → huỷ phiên cũ, tạo phiên mới, lưu `nvql`/`nvlt` (đã xoá mật khẩu), redirect trang chủ. Sai: "Tên đăng nhập hoặc mật khẩu không đúng", forward về form giữ tên đăng nhập và mật khẩu. Đăng xuất: huỷ phiên → gdDangNhap.jsp. Mỗi trang ql/, lt/ tự kiểm tra session đúng vai trò ở đầu trang, sai → redirect `/gdDangNhap.jsp`. DAO đọc lỗi SQL → `RuntimeException`.
- do-page: thành công → `sendRedirect`; lỗi cần giữ dữ liệu → `forward` về trang gd (giữ nguyên tham số). Thông báo luôn qua `session.thongBao`.
- M1: chưa bấm Tìm (không có `txtTuKhoa`) → bảng trống; bấm Tìm với ô trống → hiện tất cả (trừ "Đã xoá"); tìm được rỗng → dòng "Không có dịch vụ nào phù hợp". Tìm theo tên chứa từ khoá (SP `spTimDichVu`). Cột bảng theo hình giao diện 9.1 + cột Mô tả giữa Đơn giá và Trạng thái (theo 2.1 bước 4; rỗng → ô trống). Từ khoá được mang theo (`tuKhoa`) sang Thêm/Sửa/Xoá và giữ khi quay về. Kiểm tra nhập (Thêm, Sửa): tên ≠ rỗng, loại thuộc 5 loại, thời gian nguyên > 0, đơn giá > 0 (gõ được `400.000` hoặc `400000`), mô tả ≤ 255, rỗng → NULL; sai → "Vui lòng nhập đầy đủ và đúng thông tin dịch vụ (thời gian, đơn giá là số dương)". Sửa: hiện mã (không sửa), sửa mọi trường + trạng thái (Đang/Ngừng cung cấp), trùng tên trừ chính nó; mở dịch vụ không có/"Đã xoá" → "Không tìm thấy dịch vụ". Xoá: link + `confirm`; `xoaDichVu` trả false khi còn phiếu chưa thanh toán → "Không thể xoá dịch vụ đang có trong phiếu chưa thanh toán"; chỉ trong phiếu đã thanh toán → "Đã xoá"; chưa có phiếu → xoá thật. Câu: "Thêm/Sửa/Xoá dịch vụ thành công", "Thêm/Sửa dịch vụ không thành công" (lỗi CSDL), "Dịch vụ đã tồn tại, vui lòng kiểm tra lại". Mã DV đệm 0 đủ 2 chữ số, quá 99 thì giữ nguyên số (DV100).
- M2 (đã làm DAO + Tiếp nhận): SP `spGetDSPhieuHienTai` trả dạng phẳng (phiếu × chi tiết × phân công, cột có alias pId, ctId, pcId…); `PhieuDichVuDAO.docDSPhieu(rs)` gom thành đối tượng — M3 dùng lại (SP mới phải trả cùng bộ cột). `PhieuDichVu.getThoiGianBatDau()/getThoiGianKetThuc()` = min/max phân công. Trang Tiếp nhận: cột theo hình 9.2 + cột "Hoàn thành" (nút chỉ ở phiếu "Đang phục vụ", có `confirm`); mỗi dịch vụ một dòng trong ô, KTV cách nhau dấu phẩy; danh sách rỗng → "Không có phiếu phục vụ nào". `luuPhieuDichVu`: KTV không còn "Rảnh" lúc lưu, hoặc chi tiết không có KTV → huỷ cả giao dịch, trả false. `hoanThanhPhucVu` chỉ với phiếu "Đang phục vụ", KTV về "Rảnh" trừ khi còn phiếu khác đang phục vụ; câu lỗi "Hoàn thành phục vụ không thành công". Mã khách KH + đệm 0 đủ 3 chữ số; mã phiếu P + đủ 2 chữ số.
- M2 Lập phiếu: một form duy nhất tự gửi về gdLapPhieuDichVu.jsp (nút Tìm khách hàng; tick dịch vụ và chọn KTV tự submit bằng `onchange="guiForm(this)"`); nút "Xác nhận lập phiếu" dùng `formaction="doLuuPhieuDichVu.jsp"` nên mọi lần gửi mang đủ dữ liệu. Tham số: `txtSoDienThoai`, `txtHoTen`, `daTimKhach` (ẩn, =1 sau khi đã bấm Tìm → mỗi lần gửi tra lại SĐT), `chkDichVu` (nhiều id), `slKTV_<idDichVu>` (select multiple, nhiều id KTV). Khách cũ: tự điền họ tên, ô họ tên chỉ đọc; khách mới: dòng đỏ "Khách hàng mới. Vui lòng nhập họ tên khách hàng", giữ họ tên đã gõ; Tìm với SĐT trống → "Vui lòng nhập số điện thoại để tìm khách hàng". Bảng phân công: Dịch vụ, Thời gian, Chuyên môn yêu cầu, KTV (option "KTV001 – Trần Văn Khánh – Massage body – Rảnh"), Trạng thái "Đã/Chưa phân công" (cột này theo kịch bản 2.2 bước 14); không có KTV → "Không có kĩ thuật viên rảnh" (ngoại lệ 15). getDSKTVPhuHop: thời gian bắt đầu = thời điểm mở/gửi trang. doLuu kiểm tra lại ở máy chủ, lỗi → forward giữ dữ liệu: thiếu SĐT/họ tên → "Vui lòng nhập số điện thoại và họ tên khách hàng"; không dịch vụ → "Vui lòng chọn ít nhất một dịch vụ"; dịch vụ thiếu KTV → "Vui lòng chọn kĩ thuật viên cho tất cả dịch vụ"; KTV gửi lên không còn trong danh sách phù hợp → "Kĩ thuật viên đã chọn cho dịch vụ "…" không còn rảnh, vui lòng chọn lại"; themKhachHang lỗi → "Thêm khách hàng mới không thành công"; luuPhieuDichVu lỗi → "Lập phiếu phục vụ không thành công, vui lòng kiểm tra lại kĩ thuật viên". SĐT đã có → dùng khách cũ (bỏ qua họ tên gõ). Mọi phân công bắt đầu = thời điểm lưu, kết thúc dự kiến = bắt đầu + thời gian dịch vụ; donGiaTaiThoiDiemPhucVu = đơn giá hiện hành. Thành công → "Lập phiếu phục vụ thành công", về gdTiepNhanKhachHang.jsp. Không ràng buộc định dạng SĐT (kịch bản dùng "0987").
- M2 Hoàn thành: phiếu + chi tiết "Hoàn thành", thoiGianKetThuc = NOW(), KTV về "Rảnh"; câu "Hoàn thành phục vụ thành công".
- M3 (đã làm DAO + Tìm phiếu + Lập hoá đơn): SP `spGetPhieuCanThanhToan` (cùng bộ cột spGetDSPhieuHienTai, dùng `docDSPhieu`), `spTimMatHang`, `spGetDSKhuyenMaiHieuLuc` (ngày bắt đầu/kết thúc NULL = không giới hạn). Trang Tìm: chưa tìm → bảng trống, tìm ô trống → mọi phiếu "Hoàn thành", rỗng → "Không có phiếu nào cần thanh toán"; cột theo hình 9.3, chọn bằng radio `radChonPhieu`; "Tổng tiền" = tổng tiền dịch vụ. Một form: Tìm kiếm (GET về chính nó), "Lập hoá đơn thanh toán" `formaction="gdLapHoaDon.jsp"`. Session: `dsPhieuCanThanhToan` (kết quả tìm), `tenKhachHangTim`, `pdv` (phiếu đang lập hoá đơn). gdLapHoaDon: có `btnLapHoaDon` → lấy phiếu theo `radChonPhieu` trong `dsPhieuCanThanhToan`, xoá mặt hàng/khuyến mãi cũ, PTTT mặc định "Tiền mặt", lưu `pdv`; không có → dùng `pdv` trong session (quay về từ Chỉnh sửa/Xác nhận); không có phiếu hợp lệ → "Vui lòng chọn một phiếu cần thanh toán" về trang Tìm. Hiện thêm dòng "Giảm giá" (mục 9.3; hình không có), kèm mã + tên KM nếu có. Form gdLapHoaDon: `slPhuongThucThanhToan`, nút "Sửa thông tin" `formaction="gdChinhSuaThongTin.jsp"`, "Tiếp tục" → gdXacNhan.jsp (POST) — hai trang này phải ghi PTTT nhận được vào `pdv`. Quay lại → trang Tìm với `tenKhachHangTim` và `radChonPhieu`. `luuThanhToan` chỉ cập nhật phiếu đang "Hoàn thành" (đã thanh toán → false), cần `tinhTongTien()` trước. `capNhatKhachHang` cập nhật họ tên, SĐT, email.
- M3 Chỉnh sửa thông tin: một form tự gửi về (ẩn `tuGuiVe=1`; `daTimMatHang=1` sau khi đã Tìm → mỗi lần gửi tìm lại để giữ kết quả). Mỗi lần gửi về: ghi số lượng `txtSoLuongDaChon_<idMH>` (onchange tự gửi), khuyến mãi `slKhuyenMai` (onchange tự gửi; "" = không áp dụng; chỉ nhận KM trong getDSKhuyenMaiHieuLuc(hôm nay)), xoá (`btnXoaMatHang`=id), thêm (`btnThemMatHang`=id, số lượng `txtSoLuong_<idMH>` mặc định 1) vào `pdv` qua `PhieuDichVu.themMatHang/suaSoLuongMatHang/xoaMatHang` (thêm trùng → cộng số lượng; đơn giá bán = đơn giá hiện hành); số lượng không nguyên dương → "Số lượng phải là số nguyên dương"; tìm rỗng → "Không tìm thấy mặt hàng nào". Từ gdLapHoaDon mang `slPhuongThucThanhToan` → ghi vào pdv. Nhãn KM: "KM01 – Giảm 10% (giảm 10%; điều kiện)". Họ tên, SĐT chỉ lưu khi bấm Xác nhận. doChinhSuaThongTin: ghi nốt số lượng + KM trên form (trường hợp chưa kịp tự gửi), họ tên/SĐT trống → "Vui lòng nhập họ tên và số điện thoại khách hàng"; có đổi → capNhatKhachHang (lỗi, vd trùng SĐT → "Cập nhật thông tin khách hàng không thành công", forward giữ dữ liệu; được → "Cập nhật thông tin khách hàng thành công") → redirect gdLapHoaDon. Quay lại (link) → gdLapHoaDon, bỏ phần họ tên/SĐT chưa xác nhận.
- M3 Xác nhận: ghi PTTT nhận từ gdLapHoaDon; bảng "Mã phiếu | Dịch vụ / Mặt hàng | Số lượng | Đơn giá | Thành tiền" (dịch vụ rồi mặt hàng, cột mã phiếu ghi mã phiếu cho mọi dòng); Tổng tiền (= dịch vụ + hàng), Giảm giá (kèm KM), Tổng thanh toán, PTTT; nhãn "Nhân viên lập phiếu:" = lễ tân lập phiếu. Nút Xác nhận, In hoá đơn (`inTrang()`, khối nút `.no-print`), Quay lại → gdLapHoaDon. doLuuHoaDon: `tinhTongTien()` rồi set ngày giờ thanh toán = hiện tại, "Đã thanh toán" → luuThanhToan; thành công → xoá `pdv`, `dsPhieuCanThanhToan` khỏi session, "Thanh toán thành công", về gdTimPhieuCanThanhToan.jsp (bảng trống); lỗi (vd phiếu đã thanh toán ở nơi khác) → trả trạng thái "Hoàn thành", "Thanh toán không thành công", về gdXacNhan. Trang Chỉnh sửa/Xác nhận/lưu không có `pdv` hợp lệ → "Vui lòng chọn một phiếu cần thanh toán" về trang Tìm. Không kiểm tra/trừ tồn kho.
- Định dạng: tiền `400.000`, thời gian `HH:mm dd/MM/yyyy`.
- DAO: kết nối mở lại cả khi `!con.isValid(2)` (MySQL tự cắt kết nối để lâu); không kết nối được → `RuntimeException` (hiện lỗi 500, không nuốt lỗi). pom: groupId `n06`, finalName `spa`.
