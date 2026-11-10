package dao;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import model.DichVu;
import model.PhieuDichVu;

public class DichVuDAO extends DAO {

    public DichVuDAO() {
        super();
    }

    /** Các dịch vụ có tên chứa từ khoá (rỗng -> tất cả), không gồm dịch vụ "Đã xoá". */
    public ArrayList<DichVu> timDichVu(String tuKhoa) {
        ArrayList<DichVu> ds = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call spTimDichVu(?, ?)}")) {
            cs.setString(1, tuKhoa == null ? "" : tuKhoa.trim());
            cs.setString(2, DichVu.TT_DA_XOA);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ds.add(docDichVu(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm dịch vụ: " + e.getMessage(), e);
        }
        return ds;
    }

    /** Các dịch vụ có trạng thái "Đang cung cấp" (module 2, trang Lập phiếu phục vụ). */
    public ArrayList<DichVu> getDSDichVuDangCungCap() {
        ArrayList<DichVu> ds = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call spGetDSDichVuDangCungCap(?)}")) {
            cs.setString(1, DichVu.TT_DANG_CUNG_CAP);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ds.add(docDichVu(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách dịch vụ đang cung cấp: " + e.getMessage(), e);
        }
        return ds;
    }

    /** true nếu đã có dịch vụ cùng tên (không tính dịch vụ "Đã xoá"). */
    public boolean kiemTraTrungTen(String tenDichVu) {
        return kiemTraTrungTen(tenDichVu, 0);
    }

    /** Như trên nhưng bỏ qua dịch vụ có id = idBoQua (dùng khi sửa). */
    public boolean kiemTraTrungTen(String tenDichVu, int idBoQua) {
        try (CallableStatement cs = con.prepareCall("{call spKiemTraTrungTen(?, ?, ?)}")) {
            cs.setString(1, tenDichVu == null ? "" : tenDichVu.trim());
            cs.setInt(2, idBoQua);
            cs.setString(3, DichVu.TT_DA_XOA);
            try (ResultSet rs = cs.executeQuery()) {
                return rs.next() && rs.getInt("soLuong") > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trùng tên dịch vụ: " + e.getMessage(), e);
        }
    }

    /** Một dịch vụ theo id, không có thì trả null. */
    public DichVu getDichVuTheoId(int id) {
        try (CallableStatement cs = con.prepareCall("{call spGetDichVuTheoId(?)}")) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                return rs.next() ? docDichVu(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy dịch vụ: " + e.getMessage(), e);
        }
    }

    /**
     * Sinh mã dịch vụ (DV + (MAX(id)+1) đệm 0 đủ 2 chữ số), thêm bản ghi vào tblDichVu.
     * Thành công thì gán id mới cho dv và trả về true.
     */
    public boolean themDichVu(DichVu dv) {
        String sql = "INSERT INTO tblDichVu (maDichVu, tenDichVu, loaiDichVu, thoiGianThucHien, donGia, moTa, trangThai) "
                + "SELECT CONCAT('DV', LPAD(n, GREATEST(2, LENGTH(n)), '0')), ?, ?, ?, ?, ?, ? "
                + "FROM (SELECT IFNULL(MAX(id), 0) + 1 AS n FROM tblDichVu) t";
        try {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, dv.getTenDichVu());
                ps.setString(2, dv.getLoaiDichVu());
                ps.setInt(3, dv.getThoiGianThucHien());
                ps.setFloat(4, dv.getDonGia());
                ps.setString(5, dv.getMoTa());
                ps.setString(6, dv.getTrangThai());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        dv.setId(rs.getInt(1));
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

    /** Cập nhật tên, loại, thời gian, đơn giá, mô tả, trạng thái của dịch vụ (không sửa dịch vụ "Đã xoá"). */
    public boolean suaDichVu(DichVu dv) {
        String sql = "UPDATE tblDichVu SET tenDichVu = ?, loaiDichVu = ?, thoiGianThucHien = ?, donGia = ?, "
                + "moTa = ?, trangThai = ? WHERE id = ? AND trangThai <> ?";
        try {
            con.setAutoCommit(false);
            int soDong;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, dv.getTenDichVu());
                ps.setString(2, dv.getLoaiDichVu());
                ps.setInt(3, dv.getThoiGianThucHien());
                ps.setFloat(4, dv.getDonGia());
                ps.setString(5, dv.getMoTa());
                ps.setString(6, dv.getTrangThai());
                ps.setInt(7, dv.getId());
                ps.setString(8, DichVu.TT_DA_XOA);
                soDong = ps.executeUpdate();
            }
            con.commit();
            return soDong == 1;
        } catch (SQLException e) {
            rollback(e);
            return false;
        } finally {
            autoCommit();
        }
    }

    /**
     * Xoá dịch vụ:
     * - còn trong phiếu chưa thanh toán -> không xoá, trả false (mục 3.1);
     * - chỉ có trong phiếu đã thanh toán (hoá đơn cũ) -> đánh dấu "Đã xoá";
     * - chưa có trong phiếu nào -> xoá bản ghi.
     */
    public boolean xoaDichVu(DichVu dv) {
        String danhDauXoa = "UPDATE tblDichVu SET trangThai = ? WHERE id = ? AND trangThai <> ? "
                + "AND EXISTS (SELECT 1 FROM tblChiTietPhieuDichVu ct WHERE ct.tblDichVuid = ?) "
                + "AND NOT EXISTS (SELECT 1 FROM tblChiTietPhieuDichVu ct "
                + "  JOIN tblPhieuDichVu p ON p.id = ct.tblPhieuDichVuid "
                + "  WHERE ct.tblDichVuid = ? AND p.trangThai <> ?)";
        String xoaHan = "DELETE FROM tblDichVu WHERE id = ? AND trangThai <> ? "
                + "AND NOT EXISTS (SELECT 1 FROM tblChiTietPhieuDichVu ct WHERE ct.tblDichVuid = ?)";
        try {
            con.setAutoCommit(false);
            int soDong;
            try (PreparedStatement ps = con.prepareStatement(danhDauXoa)) {
                ps.setString(1, DichVu.TT_DA_XOA);
                ps.setInt(2, dv.getId());
                ps.setString(3, DichVu.TT_DA_XOA);
                ps.setInt(4, dv.getId());
                ps.setInt(5, dv.getId());
                ps.setString(6, PhieuDichVu.TT_DA_THANH_TOAN);
                soDong = ps.executeUpdate();
            }
            if (soDong == 0) {
                try (PreparedStatement ps = con.prepareStatement(xoaHan)) {
                    ps.setInt(1, dv.getId());
                    ps.setString(2, DichVu.TT_DA_XOA);
                    ps.setInt(3, dv.getId());
                    soDong = ps.executeUpdate();
                }
            }
            con.commit();
            return soDong == 1;
        } catch (SQLException e) {
            rollback(e);
            return false;
        } finally {
            autoCommit();
        }
    }

    private DichVu docDichVu(ResultSet rs) throws SQLException {
        DichVu dv = new DichVu();
        dv.setId(rs.getInt("id"));
        dv.setMaDichVu(rs.getString("maDichVu"));
        dv.setTenDichVu(rs.getString("tenDichVu"));
        dv.setLoaiDichVu(rs.getString("loaiDichVu"));
        dv.setThoiGianThucHien(rs.getInt("thoiGianThucHien"));
        dv.setDonGia(rs.getFloat("donGia"));
        dv.setMoTa(rs.getString("moTa"));
        dv.setTrangThai(rs.getString("trangThai"));
        return dv;
    }
}
