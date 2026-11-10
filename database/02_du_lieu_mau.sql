-- =====================================================================
-- 02_du_lieu_mau.sql – Dữ liệu mẫu (CLAUDE.md mục 5), tên lấy theo kịch bản báo cáo.
-- Chạy sau 01_tao_bang.sql. Chạy lại bất cứ lúc nào để đưa dữ liệu về ban đầu
-- (xoá sạch dữ liệu các bảng, giữ nguyên cấu trúc và stored procedure).
--
-- Kịch bản dùng được:
--  2.1  thêm "Chăm sóc da mặt cơ bản" (chưa có) -> thêm lại lần 2 báo trùng -> "Tẩy tế bào chết"
--       xoá DV03 (chưa có trong phiếu nào) -> xoá thật; DV04 (chỉ trong phiếu đã thanh toán) -> "Đã xoá";
--       DV01, DV02 (trong phiếu chưa thanh toán) -> không cho xoá
--  2.2  khách cũ Nguyễn Văn C 0987; khách mới Nguyễn Văn D (SĐT chưa có, vd 0888);
--       Massage body: Trần Văn Khánh, Trần Trọng Hùng rảnh;
--       Gội đầu dưỡng sinh: KTV duy nhất Phan Văn Khôi đang bận -> ngoại lệ 15
--  2.3  Nguyễn Văn B có P01 "Hoàn thành" 400.000; mặt hàng "Tinh dầu thư giãn";
--       KM01, KM02 còn hạn; KM03 hết hạn (không được hiện)
-- =====================================================================
SET NAMES utf8mb4;
USE spa_db;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE tblSuDungThietBi;
TRUNCATE TABLE tblThietBiPhucVu;
TRUNCATE TABLE tblYeuCauThietBi;
TRUNCATE TABLE tblLoaiThietBi;
TRUNCATE TABLE tblDinhMucNguyenLieu;
TRUNCATE TABLE tblNguyenLieu;
TRUNCATE TABLE tblChiTietMatHang;
TRUNCATE TABLE tblPhanCongKTV;
TRUNCATE TABLE tblChiTietPhieuDichVu;
TRUNCATE TABLE tblPhieuDichVu;
TRUNCATE TABLE tblKhuyenMai;
TRUNCATE TABLE tblMatHang;
TRUNCATE TABLE tblDichVu;
TRUNCATE TABLE tblKhachHang;
TRUNCATE TABLE tblKyThuatVien;
TRUNCATE TABLE tblNhanVienLeTan;
TRUNCATE TABLE tblNhanVienQuanLi;
TRUNCATE TABLE tblNhanVien;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------- Nhân viên ----------
INSERT INTO tblNhanVien (id, maNhanVien, hoTen, ngaySinh, email, soDienThoai) VALUES
(1, 'NV001',  'Nguyễn Văn A',   '1990-05-12', 'quanli@spa.local', '0901000001'),
(2, 'NV002',  'Nguyễn Văn A',   '1995-08-20', 'letan@spa.local',  '0901000002'),
(3, 'KTV001', 'Trần Văn Khánh', '1998-03-15', 'khanh@spa.local',  '0902000001'),
(4, 'KTV002', 'Trần Trọng Hùng','1997-11-02', 'hung@spa.local',   '0902000002'),
(5, 'KTV003', 'Phan Văn Khôi',  '1999-07-25', 'khoi@spa.local',   '0902000003'),
(6, 'KTV004', 'Phạm Thị Lan',   '1996-01-30', 'lan@spa.local',    '0902000004'),
(7, 'KTV005', 'Đỗ Thị Mai',     '2000-09-09', 'mai@spa.local',    '0902000005'),
(8, 'KTV006', 'Vũ Thị Ngọc',    '1998-12-18', 'ngoc@spa.local',   '0902000006');

INSERT INTO tblNhanVienQuanLi (tblNhanVienid, tenDangNhap, matKhau, chucVu) VALUES
(1, 'quanli', 'a@123', 'Nhân viên quản lí');

INSERT INTO tblNhanVienLeTan (tblNhanVienid, tenDangNhap, matKhau, chucVu) VALUES
(2, 'letan', 'a@123', 'Nhân viên lễ tân');

INSERT INTO tblKyThuatVien (tblNhanVienid, chuyenMon, trangThai) VALUES
(3, 'Massage body',       'Rảnh'),
(4, 'Massage body',       'Rảnh'),
(5, 'Gội đầu dưỡng sinh', 'Đang phục vụ'),   -- đang làm P03
(6, 'Chăm sóc da mặt',    'Rảnh'),
(7, 'Chăm sóc móng',      'Rảnh'),
(8, 'Tắm trắng',          'Rảnh');

-- ---------- Khách hàng (không tạo Nguyễn Văn D – khách mới của kịch bản 2.2) ----------
INSERT INTO tblKhachHang (id, maKhachHang, hoTen, soDienThoai, email) VALUES
(1, 'KH001', 'Nguyễn Văn B', '0999', NULL),
(2, 'KH002', 'Nguyễn Văn C', '0987', NULL),
(3, 'KH003', 'Nguyễn Văn E', '0911', NULL);

-- ---------- Dịch vụ (không tạo "Chăm sóc da mặt cơ bản", "Tẩy tế bào chết" – kịch bản 2.1 thêm mới) ----------
INSERT INTO tblDichVu (id, maDichVu, tenDichVu, loaiDichVu, thoiGianThucHien, donGia, moTa, trangThai) VALUES
(1, 'DV01', 'Massage body thư giãn',        'Massage body',       60, 400000, 'Massage toàn thân thư giãn với tinh dầu', 'Đang cung cấp'),
(2, 'DV02', 'Gội đầu dưỡng sinh thảo dược', 'Gội đầu dưỡng sinh', 45, 150000, 'Gội đầu bằng thảo dược kết hợp massage cổ vai gáy', 'Đang cung cấp'),
(3, 'DV03', 'Sơn gel móng tay',             'Chăm sóc móng',      45, 120000, 'Cắt da, dũa và sơn gel móng tay', 'Đang cung cấp'),
(4, 'DV04', 'Tắm trắng toàn thân',          'Tắm trắng',          90, 600000, 'Tắm trắng toàn thân bằng thảo dược', 'Đang cung cấp');

-- ---------- Mặt hàng ----------
INSERT INTO tblMatHang (id, maMatHang, tenMatHang, donGia, donViTinh, soLuongTon) VALUES
(1, 'MH01', 'Tinh dầu thư giãn',  150000, 'Chai',  50),
(2, 'MH02', 'Muối tắm thảo dược',  90000, 'Hũ',    30),
(3, 'MH03', 'Mặt nạ dưỡng da',     30000, 'Miếng', 100);

-- ---------- Khuyến mãi ----------
-- KM03 để trạng thái "Đang áp dụng" nhưng đã hết hạn: kiểm tra điều kiện theo ngày có hoạt động.
INSERT INTO tblKhuyenMai (id, maKhuyenMai, tenChuongTrinh, loaiGiamGia, giaTriGiam, dieuKienApDung, trangThai, ngayBatDau, ngayKetThuc) VALUES
(1, 'KM01', 'Giảm 10%',            'Phần trăm', 10,    'Áp dụng cho mọi hoá đơn', 'Đang áp dụng', '2026-01-01', '2027-12-31'),
(2, 'KM02', 'Giảm 50.000',         'Số tiền',   50000, 'Áp dụng cho mọi hoá đơn', 'Đang áp dụng', '2026-01-01', '2027-12-31'),
(3, 'KM03', 'Khuyến mãi hè 2025',  'Phần trăm', 20,    'Áp dụng cho mọi hoá đơn', 'Đang áp dụng', '2025-06-01', '2025-08-31');

-- ---------- Phiếu dịch vụ ----------
-- P01: chờ thanh toán (kịch bản 2.3); P02: đã thanh toán (hoá đơn cũ); P03: đang phục vụ
INSERT INTO tblPhieuDichVu (id, maPhieu, ngayLap, trangThai, tblKhachHangid, tblNhanVienLeTanid,
                            tongGiamGia, phuongThucThanhToan, ngayGioThanhToan, tblKhuyenMaiid) VALUES
(1, 'P01', '2026-09-21', 'Hoàn thành',    1, 2, NULL, NULL,       NULL,                  NULL),
(2, 'P02', '2026-09-15', 'Đã thanh toán', 2, 2, 0,    'Tiền mặt', '2026-09-15 15:45:00', NULL),
(3, 'P03', CURDATE(),    'Đang phục vụ',  3, 2, NULL, NULL,       NULL,                  NULL);

INSERT INTO tblChiTietPhieuDichVu (id, donGiaTaiThoiDiemPhucVu, trangThai, tblPhieuDichVuid, tblDichVuid) VALUES
(1, 400000, 'Hoàn thành',   1, 1),   -- P01: Massage body thư giãn
(2, 600000, 'Hoàn thành',   2, 4),   -- P02: Tắm trắng toàn thân
(3, 150000, 'Đang phục vụ', 3, 2);   -- P03: Gội đầu dưỡng sinh thảo dược

INSERT INTO tblPhanCongKTV (id, thoiGianBatDau, thoiGianKetThuc, tblKyThuatVienid, tblChiTietPhieuDichVuid) VALUES
(1, '2026-09-21 19:00:00', '2026-09-21 20:00:00', 4, 1),   -- Trần Trọng Hùng
(2, '2026-09-15 14:00:00', '2026-09-15 15:30:00', 8, 2),   -- Vũ Thị Ngọc
(3, NOW(), NOW() + INTERVAL 45 MINUTE,            5, 3);   -- Phan Văn Khôi (kết thúc dự kiến)
