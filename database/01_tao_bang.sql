-- =====================================================================
-- 01_tao_bang.sql – Tạo CSDL spa_db và toàn bộ bảng theo mục 8 báo cáo
-- (sơ đồ CSDL trang 43). Chạy lại được: XOÁ spa_db cũ rồi tạo mới.
-- Thứ tự chạy: 01_tao_bang.sql -> 02_du_lieu_mau.sql -> (sau này) 03_stored_procedure.sql
--
-- Khác với hình sơ đồ (đã ghi trong CLAUDE.md mục 7):
--  * tên bảng theo mục 8.1: tblNhanVienQuanLi (hình: tblNhanVienQuanLy), tblLoaiThietBi (hình: tbLoaiThietBi)
--  * tên khoá ngoại theo mục 8.4: tblNhanVienLeTanid, tblKyThuatVienid
--    (hình: tblNhanVienLeTantblNhanVienid, tblKyThuatVientblNhanVienid)
--  * tblChiTietMatHang bỏ cột tblHoaDonid (không có bảng HoaDon)
--  * tblKhachHang.maKhachHang là VARCHAR (KH001) thay vì integer; email cho phép NULL
--  * tblDichVu.tenDichVu KHÔNG đặt UNIQUE: dịch vụ "Đã xoá" vẫn giữ tên nhưng không tính trùng
-- =====================================================================
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS spa_db;
-- as_ci: phân biệt dấu (mặt ≠ mat), không phân biệt hoa thường
CREATE DATABASE spa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci;
USE spa_db;

-- ---------- Nhân viên (kế thừa 1-1, bảng con dùng tblNhanVienid làm khoá chính) ----------
CREATE TABLE tblNhanVien (
    id           INT          NOT NULL AUTO_INCREMENT,
    maNhanVien   VARCHAR(255) NOT NULL,
    hoTen        VARCHAR(255) NOT NULL,
    ngaySinh     DATE         NOT NULL,
    email        VARCHAR(255) NOT NULL,
    soDienThoai  VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_NhanVien_ma (maNhanVien)
) ENGINE = InnoDB;

CREATE TABLE tblNhanVienQuanLi (
    tblNhanVienid INT          NOT NULL,
    tenDangNhap   VARCHAR(255) NOT NULL,
    matKhau       VARCHAR(255) NOT NULL,
    chucVu        VARCHAR(255) NOT NULL,
    PRIMARY KEY (tblNhanVienid),
    UNIQUE KEY uq_NhanVienQuanLi_tenDangNhap (tenDangNhap),
    CONSTRAINT fk_NhanVienQuanLi_NhanVien FOREIGN KEY (tblNhanVienid) REFERENCES tblNhanVien (id)
) ENGINE = InnoDB;

CREATE TABLE tblNhanVienLeTan (
    tblNhanVienid INT          NOT NULL,
    tenDangNhap   VARCHAR(255) NOT NULL,
    matKhau       VARCHAR(255) NOT NULL,
    chucVu        VARCHAR(255) NOT NULL,
    PRIMARY KEY (tblNhanVienid),
    UNIQUE KEY uq_NhanVienLeTan_tenDangNhap (tenDangNhap),
    CONSTRAINT fk_NhanVienLeTan_NhanVien FOREIGN KEY (tblNhanVienid) REFERENCES tblNhanVien (id)
) ENGINE = InnoDB;

CREATE TABLE tblKyThuatVien (
    tblNhanVienid INT          NOT NULL,
    chuyenMon     VARCHAR(255) NOT NULL,   -- đúng bằng một trong 5 loại dịch vụ
    trangThai     VARCHAR(255) NOT NULL,   -- Rảnh / Đang phục vụ
    PRIMARY KEY (tblNhanVienid),
    CONSTRAINT fk_KyThuatVien_NhanVien FOREIGN KEY (tblNhanVienid) REFERENCES tblNhanVien (id)
) ENGINE = InnoDB;

-- ---------- Khách hàng, dịch vụ, mặt hàng, khuyến mãi ----------
CREATE TABLE tblKhachHang (
    id           INT          NOT NULL AUTO_INCREMENT,
    maKhachHang  VARCHAR(255) NOT NULL,
    hoTen        VARCHAR(255) NOT NULL,
    soDienThoai  VARCHAR(255) NOT NULL,
    email        VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_KhachHang_ma (maKhachHang),
    UNIQUE KEY uq_KhachHang_sdt (soDienThoai)
) ENGINE = InnoDB;

CREATE TABLE tblDichVu (
    id                INT          NOT NULL AUTO_INCREMENT,
    maDichVu          VARCHAR(255) NOT NULL,
    tenDichVu         VARCHAR(255) NOT NULL,
    loaiDichVu        VARCHAR(255) NOT NULL,   -- 5 loại dịch vụ
    thoiGianThucHien  INT          NOT NULL,   -- phút
    donGia            FLOAT        NOT NULL,
    moTa              VARCHAR(255) NULL,
    trangThai         VARCHAR(255) NOT NULL,   -- Đang cung cấp / Ngừng cung cấp / Đã xoá
    PRIMARY KEY (id),
    UNIQUE KEY uq_DichVu_ma (maDichVu)
) ENGINE = InnoDB;

CREATE TABLE tblMatHang (
    id          INT          NOT NULL AUTO_INCREMENT,
    maMatHang   VARCHAR(255) NOT NULL,
    tenMatHang  VARCHAR(255) NOT NULL,
    donGia      FLOAT        NOT NULL,
    donViTinh   VARCHAR(255) NOT NULL,
    soLuongTon  INT          NOT NULL,   -- không trừ khi bán (CLAUDE.md mục 4)
    PRIMARY KEY (id),
    UNIQUE KEY uq_MatHang_ma (maMatHang)
) ENGINE = InnoDB;

CREATE TABLE tblKhuyenMai (
    id               INT          NOT NULL AUTO_INCREMENT,
    maKhuyenMai      VARCHAR(255) NOT NULL,
    tenChuongTrinh   VARCHAR(255) NOT NULL,
    loaiGiamGia      VARCHAR(255) NOT NULL,   -- Phần trăm / Số tiền
    giaTriGiam       FLOAT        NOT NULL,
    dieuKienApDung   VARCHAR(255) NOT NULL,
    trangThai        VARCHAR(255) NOT NULL,   -- Đang áp dụng
    ngayBatDau       DATE         NULL,
    ngayKetThuc      DATE         NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_KhuyenMai_ma (maKhuyenMai)
) ENGINE = InnoDB;

-- ---------- Phiếu dịch vụ (= hoá đơn khi đã thanh toán) ----------
CREATE TABLE tblPhieuDichVu (
    id                   INT          NOT NULL AUTO_INCREMENT,
    maPhieu              VARCHAR(255) NOT NULL,
    ngayLap              DATE         NOT NULL,
    trangThai            VARCHAR(255) NOT NULL,   -- Đang phục vụ / Hoàn thành / Đã thanh toán
    tblKhachHangid       INT          NOT NULL,
    tblNhanVienLeTanid   INT          NOT NULL,   -- lễ tân lập phiếu
    tongGiamGia          FLOAT        NULL,       -- các cột thanh toán chỉ có giá trị khi đã thanh toán
    phuongThucThanhToan  VARCHAR(255) NULL,
    ngayGioThanhToan     TIMESTAMP    NULL,
    tblKhuyenMaiid       INT          NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_PhieuDichVu_ma (maPhieu),
    CONSTRAINT fk_PhieuDichVu_KhachHang FOREIGN KEY (tblKhachHangid) REFERENCES tblKhachHang (id),
    CONSTRAINT fk_PhieuDichVu_NhanVienLeTan FOREIGN KEY (tblNhanVienLeTanid) REFERENCES tblNhanVienLeTan (tblNhanVienid),
    CONSTRAINT fk_PhieuDichVu_KhuyenMai FOREIGN KEY (tblKhuyenMaiid) REFERENCES tblKhuyenMai (id)
) ENGINE = InnoDB;

CREATE TABLE tblChiTietPhieuDichVu (
    id                        INT          NOT NULL AUTO_INCREMENT,
    donGiaTaiThoiDiemPhucVu   FLOAT        NOT NULL,
    trangThai                 VARCHAR(255) NOT NULL,   -- Đang phục vụ / Hoàn thành
    tblPhieuDichVuid          INT          NOT NULL,
    tblDichVuid               INT          NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ChiTietPhieuDichVu_PhieuDichVu FOREIGN KEY (tblPhieuDichVuid) REFERENCES tblPhieuDichVu (id),
    CONSTRAINT fk_ChiTietPhieuDichVu_DichVu FOREIGN KEY (tblDichVuid) REFERENCES tblDichVu (id)
) ENGINE = InnoDB;

CREATE TABLE tblPhanCongKTV (
    id                       INT       NOT NULL AUTO_INCREMENT,
    thoiGianBatDau           TIMESTAMP NOT NULL,
    thoiGianKetThuc          TIMESTAMP NOT NULL,   -- lúc lập: dự kiến; lúc hoàn thành: thực tế
    tblKyThuatVienid         INT       NOT NULL,
    tblChiTietPhieuDichVuid  INT       NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_PhanCongKTV_KyThuatVien FOREIGN KEY (tblKyThuatVienid) REFERENCES tblKyThuatVien (tblNhanVienid),
    CONSTRAINT fk_PhanCongKTV_ChiTietPhieuDichVu FOREIGN KEY (tblChiTietPhieuDichVuid) REFERENCES tblChiTietPhieuDichVu (id)
) ENGINE = InnoDB;

CREATE TABLE tblChiTietMatHang (
    id                     INT   NOT NULL AUTO_INCREMENT,
    soLuong                INT   NOT NULL,
    donGiaTaiThoiDiemBan   FLOAT NOT NULL,
    tblMatHangid           INT   NOT NULL,
    tblPhieuDichVuid       INT   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ChiTietMatHang_MatHang FOREIGN KEY (tblMatHangid) REFERENCES tblMatHang (id),
    CONSTRAINT fk_ChiTietMatHang_PhieuDichVu FOREIGN KEY (tblPhieuDichVuid) REFERENCES tblPhieuDichVu (id)
) ENGINE = InnoDB;

-- ---------- Nguyên liệu, thiết bị: có trong CSDL toàn hệ thống, 3 module này không dùng ----------
CREATE TABLE tblNguyenLieu (
    id            INT          NOT NULL AUTO_INCREMENT,
    maNguyenLieu  VARCHAR(255) NOT NULL,
    tenNguyenLieu VARCHAR(255) NOT NULL,
    donViTinh     VARCHAR(255) NOT NULL,
    soLuongTon    FLOAT        NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE tblDinhMucNguyenLieu (
    id              INT   NOT NULL AUTO_INCREMENT,
    soLuongDinhMuc  FLOAT NOT NULL,
    tblNguyenLieuid INT   NOT NULL,
    tblDichVuid     INT   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_DinhMucNguyenLieu_NguyenLieu FOREIGN KEY (tblNguyenLieuid) REFERENCES tblNguyenLieu (id),
    CONSTRAINT fk_DinhMucNguyenLieu_DichVu FOREIGN KEY (tblDichVuid) REFERENCES tblDichVu (id)
) ENGINE = InnoDB;

CREATE TABLE tblLoaiThietBi (
    id      INT          NOT NULL AUTO_INCREMENT,
    maLoai  VARCHAR(255) NOT NULL,
    tenLoai VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE tblYeuCauThietBi (
    id               INT NOT NULL AUTO_INCREMENT,
    soLuongCan       INT NOT NULL,
    tblDichVuid      INT NOT NULL,
    tblLoaiThietBiid INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_YeuCauThietBi_DichVu FOREIGN KEY (tblDichVuid) REFERENCES tblDichVu (id),
    CONSTRAINT fk_YeuCauThietBi_LoaiThietBi FOREIGN KEY (tblLoaiThietBiid) REFERENCES tblLoaiThietBi (id)
) ENGINE = InnoDB;

CREATE TABLE tblThietBiPhucVu (
    id               INT          NOT NULL AUTO_INCREMENT,
    maThietBi        VARCHAR(255) NOT NULL,
    tenThietBi       VARCHAR(255) NOT NULL,
    viTri            VARCHAR(255) NOT NULL,
    tinhTrang        VARCHAR(255) NOT NULL,
    tblLoaiThietBiid INT          NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ThietBiPhucVu_LoaiThietBi FOREIGN KEY (tblLoaiThietBiid) REFERENCES tblLoaiThietBi (id)
) ENGINE = InnoDB;

CREATE TABLE tblSuDungThietBi (
    id                      INT       NOT NULL AUTO_INCREMENT,
    thoiGianBatDau          TIMESTAMP NOT NULL,
    thoiGianKetThuc         TIMESTAMP NOT NULL,
    tblChiTietPhieuDichVuid INT       NOT NULL,
    tblThietBiPhucVuid      INT       NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_SuDungThietBi_ChiTietPhieuDichVu FOREIGN KEY (tblChiTietPhieuDichVuid) REFERENCES tblChiTietPhieuDichVu (id),
    CONSTRAINT fk_SuDungThietBi_ThietBiPhucVu FOREIGN KEY (tblThietBiPhucVuid) REFERENCES tblThietBiPhucVu (id)
) ENGINE = InnoDB;
