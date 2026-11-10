package dao;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import model.ChiTietMatHang;
import model.ChiTietPhieuDichVu;
import model.DichVu;
import model.KhachHang;
import model.KyThuatVien;
import model.NhanVienLeTan;
import model.PhanCongKTV;
import model.PhieuDichVu;

public class PhieuDichVuDAO extends DAO {

    public PhieuDichVuDAO() {
        super();
    }

    /** Các phiếu chưa thanh toán, kèm khách hàng, chi tiết dịch vụ và KTV (mục 9.2). */
    public ArrayList<PhieuDichVu> getDSPhieuHienTai() {
        try (CallableStatement cs = con.prepareCall("{call spGetDSPhieuHienTai(?)}")) {
            cs.setString(1, PhieuDichVu.TT_DA_THANH_TOAN);
            try (ResultSet rs = cs.executeQuery()) {
                return docDSPhieu(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách phiếu hiện tại: " + e.getMessage(), e);
        }
    }

    /** Các phiếu "Hoàn thành" của khách có tên chứa chuỗi tìm kiếm, kèm khách hàng và chi tiết dịch vụ (mục 9.3). */
    public ArrayList<PhieuDichVu> getPhieuCanThanhToan(String tenKhachHang) {
        try (CallableStatement cs = con.prepareCall("{call spGetPhieuCanThanhToan(?, ?)}")) {
            cs.setString(1, tenKhachHang == null ? "" : tenKhachHang.trim());
            cs.setString(2, PhieuDichVu.TT_HOAN_THANH);
            try (ResultSet rs = cs.executeQuery()) {
                return docDSPhieu(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm phiếu cần thanh toán: " + e.getMessage(), e);
        }
    }

    /**
     * Trong một giao dịch (mục 9.3): cập nhật thông tin thanh toán của phiếu trong tblPhieuDichVu
     * (tongGiamGia, phuongThucThanhToan, ngayGioThanhToan, tblKhuyenMaiid, trạng thái "Đã thanh toán")
     * và thêm các dòng tblChiTietMatHang. pdv phải đã gọi tinhTongTien() để có tongGiamGia.
     * Phiếu không còn ở trạng thái "Hoàn thành" (đã thanh toán ở nơi khác) -> huỷ, trả false.
     */
    public boolean luuThanhToan(PhieuDichVu pdv) {
        String sqlPhieu = "UPDATE tblPhieuDichVu SET trangThai = ?, tongGiamGia = ?, phuongThucThanhToan = ?, "
                + "ngayGioThanhToan = ?, tblKhuyenMaiid = ? WHERE id = ? AND trangThai = ?";
        String sqlMatHang = "INSERT INTO tblChiTietMatHang (soLuong, donGiaTaiThoiDiemBan, tblMatHangid, tblPhieuDichVuid) "
                + "VALUES (?, ?, ?, ?)";
        try {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sqlPhieu)) {
                ps.setString(1, PhieuDichVu.TT_DA_THANH_TOAN);
                ps.setFloat(2, pdv.getTongGiamGia());
                ps.setString(3, pdv.getPhuongThucThanhToan());
                ps.setTimestamp(4, new Timestamp(pdv.getNgayGioThanhToan().getTime()));
                if (pdv.getKhuyenMai() == null) {
                    ps.setNull(5, java.sql.Types.INTEGER);
                } else {
                    ps.setInt(5, pdv.getKhuyenMai().getId());
                }
                ps.setInt(6, pdv.getId());
                ps.setString(7, PhieuDichVu.TT_HOAN_THANH);
                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Phiếu id=" + pdv.getId() + " không còn ở trạng thái hoàn thành");
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sqlMatHang, Statement.RETURN_GENERATED_KEYS)) {
                for (ChiTietMatHang ct : pdv.getDsChiTietMatHang()) {
                    ps.setInt(1, ct.getSoLuong());
                    ps.setFloat(2, ct.getDonGiaTaiThoiDiemBan());
                    ps.setInt(3, ct.getMatHang().getId());
                    ps.setInt(4, pdv.getId());
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            ct.setId(rs.getInt(1));
                        }
                    }
                }
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            rollback(e);
            return false;
        } finally {
            autoCommit();
        }
    }

    /**
     * Trong một giao dịch: thêm bản ghi vào tblPhieuDichVu (sinh mã P + (MAX(id)+1) đệm 0 đủ 2 chữ số),
     * tblChiTietPhieuDichVu, tblPhanCongKTV và cập nhật trạng thái các KTV được phân công thành "Đang phục vụ".
     * pdv cần có: khachHang (đã có id), nhanVienLeTan, ngayLap, trangThai, dsChiTietPhieuDichVu
     * (mỗi chi tiết có dichVu, donGiaTaiThoiDiemPhucVu, trangThai và ít nhất một PhanCongKTV).
     * Thành công thì gán id mới cho pdv và trả về true; KTV không còn "Rảnh" -> huỷ cả giao dịch, trả false.
     */
    public boolean luuPhieuDichVu(PhieuDichVu pdv) {
        String sqlPhieu = "INSERT INTO tblPhieuDichVu (maPhieu, ngayLap, trangThai, tblKhachHangid, tblNhanVienLeTanid) "
                + "SELECT CONCAT('P', LPAD(n, GREATEST(2, LENGTH(n)), '0')), ?, ?, ?, ? "
                + "FROM (SELECT IFNULL(MAX(id), 0) + 1 AS n FROM tblPhieuDichVu) t";
        String sqlChiTiet = "INSERT INTO tblChiTietPhieuDichVu (donGiaTaiThoiDiemPhucVu, trangThai, tblPhieuDichVuid, tblDichVuid) "
                + "VALUES (?, ?, ?, ?)";
        String sqlPhanCong = "INSERT INTO tblPhanCongKTV (thoiGianBatDau, thoiGianKetThuc, tblKyThuatVienid, tblChiTietPhieuDichVuid) "
                + "VALUES (?, ?, ?, ?)";
        String sqlKTV = "UPDATE tblKyThuatVien SET trangThai = ? WHERE tblNhanVienid = ? AND trangThai = ?";
        try {
            con.setAutoCommit(false);
            if (pdv.getDsChiTietPhieuDichVu().isEmpty()) {
                throw new SQLException("Phiếu phải có ít nhất một dịch vụ");
            }
            try (PreparedStatement ps = con.prepareStatement(sqlPhieu, Statement.RETURN_GENERATED_KEYS)) {
                ps.setDate(1, new java.sql.Date(pdv.getNgayLap().getTime()));
                ps.setString(2, pdv.getTrangThai());
                ps.setInt(3, pdv.getKhachHang().getId());
                ps.setInt(4, pdv.getNhanVienLeTan().getId());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    rs.next();
                    pdv.setId(rs.getInt(1));
                }
            }

            Set<Integer> dsKTV = new LinkedHashSet<>();
            try (PreparedStatement psCT = con.prepareStatement(sqlChiTiet, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psPC = con.prepareStatement(sqlPhanCong)) {
                for (ChiTietPhieuDichVu ct : pdv.getDsChiTietPhieuDichVu()) {
                    if (ct.getDsPhanCong().isEmpty()) {
                        throw new SQLException("Mỗi dịch vụ phải có ít nhất một kỹ thuật viên");
                    }
                    psCT.setFloat(1, ct.getDonGiaTaiThoiDiemPhucVu());
                    psCT.setString(2, ct.getTrangThai());
                    psCT.setInt(3, pdv.getId());
                    psCT.setInt(4, ct.getDichVu().getId());
                    psCT.executeUpdate();
                    try (ResultSet rs = psCT.getGeneratedKeys()) {
                        rs.next();
                        ct.setId(rs.getInt(1));
                    }
                    for (PhanCongKTV pc : ct.getDsPhanCong()) {
                        psPC.setTimestamp(1, new Timestamp(pc.getThoiGianBatDau().getTime()));
                        psPC.setTimestamp(2, new Timestamp(pc.getThoiGianKetThuc().getTime()));
                        psPC.setInt(3, pc.getKyThuatVien().getId());
                        psPC.setInt(4, ct.getId());
                        psPC.executeUpdate();
                        dsKTV.add(pc.getKyThuatVien().getId());
                    }
                }
            }

            // Một KTV có thể làm nhiều dịch vụ của phiếu -> cập nhật mỗi KTV một lần
            try (PreparedStatement ps = con.prepareStatement(sqlKTV)) {
                for (Integer idKTV : dsKTV) {
                    ps.setString(1, KyThuatVien.TT_DANG_PHUC_VU);
                    ps.setInt(2, idKTV);
                    ps.setString(3, KyThuatVien.TT_RANH);
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException("Kỹ thuật viên id=" + idKTV + " không còn rảnh");
                    }
                }
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            rollback(e);
            return false;
        } finally {
            autoCommit();
        }
    }

    /**
     * Hoàn thành phục vụ (báo cáo không thiết kế): trong một giao dịch, phiếu và các chi tiết -> "Hoàn thành",
     * ghi thời gian kết thúc thực tế (NOW()) cho các phân công, chuyển các KTV về "Rảnh"
     * (trừ KTV còn phân công ở phiếu khác đang phục vụ). Phiếu không "Đang phục vụ" -> false.
     */
    public boolean hoanThanhPhucVu(PhieuDichVu pdv) {
        String sqlPhieu = "UPDATE tblPhieuDichVu SET trangThai = ? WHERE id = ? AND trangThai = ?";
        String sqlChiTiet = "UPDATE tblChiTietPhieuDichVu SET trangThai = ? WHERE tblPhieuDichVuid = ?";
        String sqlPhanCong = "UPDATE tblPhanCongKTV pc JOIN tblChiTietPhieuDichVu ct ON ct.id = pc.tblChiTietPhieuDichVuid "
                + "SET pc.thoiGianKetThuc = NOW() WHERE ct.tblPhieuDichVuid = ?";
        String sqlKTV = "UPDATE tblKyThuatVien k SET k.trangThai = ? "
                + "WHERE k.tblNhanVienid IN (SELECT pc.tblKyThuatVienid FROM tblPhanCongKTV pc "
                + "    JOIN tblChiTietPhieuDichVu ct ON ct.id = pc.tblChiTietPhieuDichVuid WHERE ct.tblPhieuDichVuid = ?) "
                + "AND NOT EXISTS (SELECT 1 FROM tblPhanCongKTV pc2 "
                + "    JOIN tblChiTietPhieuDichVu ct2 ON ct2.id = pc2.tblChiTietPhieuDichVuid "
                + "    JOIN tblPhieuDichVu p2 ON p2.id = ct2.tblPhieuDichVuid "
                + "    WHERE pc2.tblKyThuatVienid = k.tblNhanVienid AND p2.trangThai = ?)";
        try {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sqlPhieu)) {
                ps.setString(1, PhieuDichVu.TT_HOAN_THANH);
                ps.setInt(2, pdv.getId());
                ps.setString(3, PhieuDichVu.TT_DANG_PHUC_VU);
                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Phiếu id=" + pdv.getId() + " không ở trạng thái đang phục vụ");
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sqlChiTiet)) {
                ps.setString(1, ChiTietPhieuDichVu.TT_HOAN_THANH);
                ps.setInt(2, pdv.getId());
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(sqlPhanCong)) {
                ps.setInt(1, pdv.getId());
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(sqlKTV)) {
                ps.setString(1, KyThuatVien.TT_RANH);
                ps.setInt(2, pdv.getId());
                ps.setString(3, PhieuDichVu.TT_DANG_PHUC_VU);
                ps.executeUpdate();
            }
            con.commit();
            pdv.setTrangThai(PhieuDichVu.TT_HOAN_THANH);
            return true;
        } catch (SQLException e) {
            rollback(e);
            return false;
        } finally {
            autoCommit();
        }
    }

    /**
     * Gom kết quả dạng phẳng (mỗi dòng = phiếu × chi tiết × phân công, cột như spGetDSPhieuHienTai)
     * thành danh sách PhieuDichVu kèm khách hàng, lễ tân lập, chi tiết dịch vụ và phân công KTV.
     */
    private ArrayList<PhieuDichVu> docDSPhieu(ResultSet rs) throws SQLException {
        Map<Integer, PhieuDichVu> dsPhieu = new LinkedHashMap<>();
        Map<Integer, ChiTietPhieuDichVu> dsChiTiet = new HashMap<>();
        while (rs.next()) {
            int idPhieu = rs.getInt("pId");
            PhieuDichVu pdv = dsPhieu.get(idPhieu);
            if (pdv == null) {
                pdv = new PhieuDichVu();
                pdv.setId(idPhieu);
                pdv.setMaPhieu(rs.getString("maPhieu"));
                pdv.setNgayLap(rs.getDate("ngayLap"));
                pdv.setTrangThai(rs.getString("pTrangThai"));
                pdv.setTongGiamGia(rs.getFloat("tongGiamGia"));
                pdv.setPhuongThucThanhToan(rs.getString("phuongThucThanhToan"));
                pdv.setNgayGioThanhToan(rs.getTimestamp("ngayGioThanhToan"));

                KhachHang kh = new KhachHang();
                kh.setId(rs.getInt("khId"));
                kh.setMaKhachHang(rs.getString("maKhachHang"));
                kh.setHoTen(rs.getString("khHoTen"));
                kh.setSoDienThoai(rs.getString("khSoDienThoai"));
                kh.setEmail(rs.getString("khEmail"));
                pdv.setKhachHang(kh);

                NhanVienLeTan nvlt = new NhanVienLeTan();
                nvlt.setId(rs.getInt("ltId"));
                nvlt.setMaNhanVien(rs.getString("ltMa"));
                nvlt.setHoTen(rs.getString("ltHoTen"));
                pdv.setNhanVienLeTan(nvlt);

                dsPhieu.put(idPhieu, pdv);
            }

            int idChiTiet = rs.getInt("ctId");
            ChiTietPhieuDichVu ct = dsChiTiet.get(idChiTiet);
            if (ct == null) {
                ct = new ChiTietPhieuDichVu();
                ct.setId(idChiTiet);
                ct.setDonGiaTaiThoiDiemPhucVu(rs.getFloat("donGiaTaiThoiDiemPhucVu"));
                ct.setTrangThai(rs.getString("ctTrangThai"));
                ct.setPhieuDichVu(pdv);

                DichVu dv = new DichVu();
                dv.setId(rs.getInt("dvId"));
                dv.setMaDichVu(rs.getString("maDichVu"));
                dv.setTenDichVu(rs.getString("tenDichVu"));
                dv.setLoaiDichVu(rs.getString("loaiDichVu"));
                dv.setThoiGianThucHien(rs.getInt("thoiGianThucHien"));
                dv.setDonGia(rs.getFloat("dvDonGia"));
                dv.setTrangThai(rs.getString("dvTrangThai"));
                ct.setDichVu(dv);

                pdv.getDsChiTietPhieuDichVu().add(ct);
                dsChiTiet.put(idChiTiet, ct);
            }

            PhanCongKTV pc = new PhanCongKTV();
            pc.setId(rs.getInt("pcId"));
            pc.setThoiGianBatDau(rs.getTimestamp("thoiGianBatDau"));
            pc.setThoiGianKetThuc(rs.getTimestamp("thoiGianKetThuc"));
            KyThuatVien ktv = new KyThuatVien();
            ktv.setId(rs.getInt("ktvId"));
            ktv.setMaNhanVien(rs.getString("ktvMa"));
            ktv.setHoTen(rs.getString("ktvHoTen"));
            ktv.setChuyenMon(rs.getString("chuyenMon"));
            ktv.setTrangThai(rs.getString("ktvTrangThai"));
            pc.setKyThuatVien(ktv);
            ct.getDsPhanCong().add(pc);
        }
        return new ArrayList<>(dsPhieu.values());
    }
}
