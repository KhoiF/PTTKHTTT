-- =====================================================================
-- 03_stored_procedure.sql – Các stored procedure ĐỌC dữ liệu (mọi thao tác ghi dùng transaction trong DAO).
-- Chạy sau 01, 02. Chạy lại được (DROP IF EXISTS rồi tạo lại), không đổi dữ liệu.
-- Tên: sp + tên phương thức DAO (trùng tên phương thức giữa 2 DAO thì thêm hậu tố).
-- =====================================================================
SET NAMES utf8mb4;
USE spa_db;

DELIMITER $$

-- ---------- Đăng nhập (NhanVienQuanLiDAO.kiemTraDangNhap / NhanVienLeTanDAO.kiemTraDangNhap) ----------
-- Tên đăng nhập không phân biệt hoa thường; mật khẩu so khớp chính xác (utf8mb4_bin).
DROP PROCEDURE IF EXISTS spKiemTraDangNhapQuanLi $$
CREATE PROCEDURE spKiemTraDangNhapQuanLi(IN pTenDangNhap VARCHAR(255), IN pMatKhau VARCHAR(255))
BEGIN
    SELECT nv.id, nv.maNhanVien, nv.hoTen, nv.ngaySinh, nv.email, nv.soDienThoai,
           ql.tenDangNhap, ql.chucVu
    FROM tblNhanVienQuanLi ql
    JOIN tblNhanVien nv ON nv.id = ql.tblNhanVienid
    WHERE ql.tenDangNhap = pTenDangNhap
      AND ql.matKhau COLLATE utf8mb4_bin = pMatKhau COLLATE utf8mb4_bin;
END $$

DROP PROCEDURE IF EXISTS spKiemTraDangNhapLeTan $$
CREATE PROCEDURE spKiemTraDangNhapLeTan(IN pTenDangNhap VARCHAR(255), IN pMatKhau VARCHAR(255))
BEGIN
    SELECT nv.id, nv.maNhanVien, nv.hoTen, nv.ngaySinh, nv.email, nv.soDienThoai,
           lt.tenDangNhap, lt.chucVu
    FROM tblNhanVienLeTan lt
    JOIN tblNhanVien nv ON nv.id = lt.tblNhanVienid
    WHERE lt.tenDangNhap = pTenDangNhap
      AND lt.matKhau COLLATE utf8mb4_bin = pMatKhau COLLATE utf8mb4_bin;
END $$

-- ---------- Module 1: Quản lí thông tin dịch vụ (DichVuDAO) ----------
-- Trạng thái "Đã xoá" truyền từ Java (DichVu.TT_DA_XOA) để chỉ định nghĩa một chỗ.

-- timDichVu(tuKhoa): dịch vụ có tên chứa từ khoá (từ khoá rỗng -> tất cả), bỏ dịch vụ "Đã xoá"
DROP PROCEDURE IF EXISTS spTimDichVu $$
CREATE PROCEDURE spTimDichVu(IN pTuKhoa VARCHAR(255), IN pTrangThaiDaXoa VARCHAR(255))
BEGIN
    SELECT id, maDichVu, tenDichVu, loaiDichVu, thoiGianThucHien, donGia, moTa, trangThai
    FROM tblDichVu
    WHERE tenDichVu LIKE CONCAT('%', pTuKhoa, '%')
      AND trangThai <> pTrangThaiDaXoa
    ORDER BY id;
END $$

-- kiemTraTrungTen(tenDichVu[, idBoQua]): số dịch vụ (không tính "Đã xoá", không tính idBoQua) có cùng tên
DROP PROCEDURE IF EXISTS spKiemTraTrungTen $$
CREATE PROCEDURE spKiemTraTrungTen(IN pTenDichVu VARCHAR(255), IN pIdBoQua INT, IN pTrangThaiDaXoa VARCHAR(255))
BEGIN
    SELECT COUNT(*) AS soLuong
    FROM tblDichVu
    WHERE tenDichVu = pTenDichVu
      AND id <> pIdBoQua
      AND trangThai <> pTrangThaiDaXoa;
END $$

-- getDSDichVuDangCungCap(): các dịch vụ có trạng thái "Đang cung cấp" (module 2, trang Lập phiếu)
DROP PROCEDURE IF EXISTS spGetDSDichVuDangCungCap $$
CREATE PROCEDURE spGetDSDichVuDangCungCap(IN pTrangThaiDangCungCap VARCHAR(255))
BEGIN
    SELECT id, maDichVu, tenDichVu, loaiDichVu, thoiGianThucHien, donGia, moTa, trangThai
    FROM tblDichVu
    WHERE trangThai = pTrangThaiDangCungCap
    ORDER BY id;
END $$

-- getDichVuTheoId(id): một dịch vụ (dùng cho trang Sửa)
DROP PROCEDURE IF EXISTS spGetDichVuTheoId $$
CREATE PROCEDURE spGetDichVuTheoId(IN pId INT)
BEGIN
    SELECT id, maDichVu, tenDichVu, loaiDichVu, thoiGianThucHien, donGia, moTa, trangThai
    FROM tblDichVu
    WHERE id = pId;
END $$

-- ---------- Module 2: Nhận khách và phân công nhân viên phục vụ tại quầy ----------

-- KhachHangDAO.timKhachHangTheoSDT(soDienThoai): khách có đúng số điện thoại
DROP PROCEDURE IF EXISTS spTimKhachHangTheoSDT $$
CREATE PROCEDURE spTimKhachHangTheoSDT(IN pSoDienThoai VARCHAR(255))
BEGIN
    SELECT id, maKhachHang, hoTen, soDienThoai, email
    FROM tblKhachHang
    WHERE soDienThoai = pSoDienThoai;
END $$

-- KyThuatVienDAO.getDSKTVPhuHop(dv, thoiGianBatDau): KTV có chuyên môn = loại dịch vụ, trạng thái "Rảnh"
-- và không có phân công nào trùng khoảng [pBatDau, pBatDau + pSoPhut phút)
DROP PROCEDURE IF EXISTS spGetDSKTVPhuHop $$
CREATE PROCEDURE spGetDSKTVPhuHop(IN pLoaiDichVu VARCHAR(255), IN pBatDau TIMESTAMP, IN pSoPhut INT,
                                  IN pTrangThaiRanh VARCHAR(255))
BEGIN
    SELECT nv.id, nv.maNhanVien, nv.hoTen, nv.ngaySinh, nv.email, nv.soDienThoai, k.chuyenMon, k.trangThai
    FROM tblKyThuatVien k
    JOIN tblNhanVien nv ON nv.id = k.tblNhanVienid
    WHERE k.chuyenMon = pLoaiDichVu
      AND k.trangThai = pTrangThaiRanh
      AND NOT EXISTS (SELECT 1 FROM tblPhanCongKTV pc
                      WHERE pc.tblKyThuatVienid = k.tblNhanVienid
                        AND pc.thoiGianBatDau < pBatDau + INTERVAL pSoPhut MINUTE
                        AND pc.thoiGianKetThuc > pBatDau)
    ORDER BY nv.maNhanVien;
END $$

-- PhieuDichVuDAO.getDSPhieuHienTai(): các phiếu chưa thanh toán kèm khách hàng, lễ tân lập, chi tiết dịch vụ, KTV.
-- Mỗi dòng = một phân công KTV (phiếu × chi tiết × phân công); DAO gom lại thành đối tượng.
DROP PROCEDURE IF EXISTS spGetDSPhieuHienTai $$
CREATE PROCEDURE spGetDSPhieuHienTai(IN pTrangThaiDaThanhToan VARCHAR(255))
BEGIN
    SELECT p.id AS pId, p.maPhieu, p.ngayLap, p.trangThai AS pTrangThai,
           p.tongGiamGia, p.phuongThucThanhToan, p.ngayGioThanhToan,
           kh.id AS khId, kh.maKhachHang, kh.hoTen AS khHoTen, kh.soDienThoai AS khSoDienThoai, kh.email AS khEmail,
           lt.id AS ltId, lt.maNhanVien AS ltMa, lt.hoTen AS ltHoTen,
           ct.id AS ctId, ct.donGiaTaiThoiDiemPhucVu, ct.trangThai AS ctTrangThai,
           dv.id AS dvId, dv.maDichVu, dv.tenDichVu, dv.loaiDichVu, dv.thoiGianThucHien, dv.donGia AS dvDonGia,
           dv.trangThai AS dvTrangThai,
           pc.id AS pcId, pc.thoiGianBatDau, pc.thoiGianKetThuc,
           ktv.id AS ktvId, ktv.maNhanVien AS ktvMa, ktv.hoTen AS ktvHoTen, k.chuyenMon, k.trangThai AS ktvTrangThai
    FROM tblPhieuDichVu p
    JOIN tblKhachHang kh ON kh.id = p.tblKhachHangid
    JOIN tblNhanVien lt ON lt.id = p.tblNhanVienLeTanid
    JOIN tblChiTietPhieuDichVu ct ON ct.tblPhieuDichVuid = p.id
    JOIN tblDichVu dv ON dv.id = ct.tblDichVuid
    JOIN tblPhanCongKTV pc ON pc.tblChiTietPhieuDichVuid = ct.id
    JOIN tblKyThuatVien k ON k.tblNhanVienid = pc.tblKyThuatVienid
    JOIN tblNhanVien ktv ON ktv.id = k.tblNhanVienid
    WHERE p.trangThai <> pTrangThaiDaThanhToan
    ORDER BY p.id, ct.id, pc.id;
END $$

-- ---------- Module 3: Cho khách thanh toán tại quầy ----------

-- PhieuDichVuDAO.getPhieuCanThanhToan(tenKhachHang): các phiếu "Hoàn thành" của khách có tên chứa chuỗi tìm kiếm,
-- kèm khách hàng và chi tiết dịch vụ. Cùng bộ cột với spGetDSPhieuHienTai (DAO dùng chung hàm docDSPhieu).
DROP PROCEDURE IF EXISTS spGetPhieuCanThanhToan $$
CREATE PROCEDURE spGetPhieuCanThanhToan(IN pTenKhachHang VARCHAR(255), IN pTrangThaiHoanThanh VARCHAR(255))
BEGIN
    SELECT p.id AS pId, p.maPhieu, p.ngayLap, p.trangThai AS pTrangThai,
           p.tongGiamGia, p.phuongThucThanhToan, p.ngayGioThanhToan,
           kh.id AS khId, kh.maKhachHang, kh.hoTen AS khHoTen, kh.soDienThoai AS khSoDienThoai, kh.email AS khEmail,
           lt.id AS ltId, lt.maNhanVien AS ltMa, lt.hoTen AS ltHoTen,
           ct.id AS ctId, ct.donGiaTaiThoiDiemPhucVu, ct.trangThai AS ctTrangThai,
           dv.id AS dvId, dv.maDichVu, dv.tenDichVu, dv.loaiDichVu, dv.thoiGianThucHien, dv.donGia AS dvDonGia,
           dv.trangThai AS dvTrangThai,
           pc.id AS pcId, pc.thoiGianBatDau, pc.thoiGianKetThuc,
           ktv.id AS ktvId, ktv.maNhanVien AS ktvMa, ktv.hoTen AS ktvHoTen, k.chuyenMon, k.trangThai AS ktvTrangThai
    FROM tblPhieuDichVu p
    JOIN tblKhachHang kh ON kh.id = p.tblKhachHangid
    JOIN tblNhanVien lt ON lt.id = p.tblNhanVienLeTanid
    JOIN tblChiTietPhieuDichVu ct ON ct.tblPhieuDichVuid = p.id
    JOIN tblDichVu dv ON dv.id = ct.tblDichVuid
    JOIN tblPhanCongKTV pc ON pc.tblChiTietPhieuDichVuid = ct.id
    JOIN tblKyThuatVien k ON k.tblNhanVienid = pc.tblKyThuatVienid
    JOIN tblNhanVien ktv ON ktv.id = k.tblNhanVienid
    WHERE p.trangThai = pTrangThaiHoanThanh
      AND kh.hoTen LIKE CONCAT('%', pTenKhachHang, '%')
    ORDER BY p.id, ct.id, pc.id;
END $$

-- MatHangDAO.timMatHang(tenMatHang): mặt hàng có tên chứa chuỗi tìm kiếm
DROP PROCEDURE IF EXISTS spTimMatHang $$
CREATE PROCEDURE spTimMatHang(IN pTenMatHang VARCHAR(255))
BEGIN
    SELECT id, maMatHang, tenMatHang, donGia, donViTinh, soLuongTon
    FROM tblMatHang
    WHERE tenMatHang LIKE CONCAT('%', pTenMatHang, '%')
    ORDER BY id;
END $$

-- KhuyenMaiDAO.getDSKhuyenMaiHieuLuc(ngay): ngayBatDau <= ngay <= ngayKetThuc và trạng thái "Đang áp dụng"
-- (ngày bắt đầu/kết thúc để trống thì coi như không giới hạn)
DROP PROCEDURE IF EXISTS spGetDSKhuyenMaiHieuLuc $$
CREATE PROCEDURE spGetDSKhuyenMaiHieuLuc(IN pNgay DATE, IN pTrangThaiDangApDung VARCHAR(255))
BEGIN
    SELECT id, maKhuyenMai, tenChuongTrinh, loaiGiamGia, giaTriGiam, dieuKienApDung, trangThai, ngayBatDau, ngayKetThuc
    FROM tblKhuyenMai
    WHERE trangThai = pTrangThaiDangApDung
      AND (ngayBatDau IS NULL OR ngayBatDau <= pNgay)
      AND (ngayKetThuc IS NULL OR ngayKetThuc >= pNgay)
    ORDER BY id;
END $$

DELIMITER ;
