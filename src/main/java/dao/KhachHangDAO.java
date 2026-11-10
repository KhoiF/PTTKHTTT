package dao;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import model.KhachHang;

public class KhachHangDAO extends DAO {

    public KhachHangDAO() {
        super();
    }

    /** Khách hàng có đúng số điện thoại, không có thì trả null. */
    public KhachHang timKhachHangTheoSDT(String soDienThoai) {
        try (CallableStatement cs = con.prepareCall("{call spTimKhachHangTheoSDT(?)}")) {
            cs.setString(1, soDienThoai == null ? "" : soDienThoai.trim());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    KhachHang kh = new KhachHang();
                    kh.setId(rs.getInt("id"));
                    kh.setMaKhachHang(rs.getString("maKhachHang"));
                    kh.setHoTen(rs.getString("hoTen"));
                    kh.setSoDienThoai(rs.getString("soDienThoai"));
                    kh.setEmail(rs.getString("email"));
                    return kh;
                }
                return null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm khách hàng: " + e.getMessage(), e);
        }
    }

    /**
     * Thêm khách hàng mới, sinh mã KH + (MAX(id)+1) đệm 0 đủ 3 chữ số.
     * Thành công thì gán id mới cho kh và trả về true (trùng số điện thoại -> false).
     */
    public boolean themKhachHang(KhachHang kh) {
        String sql = "INSERT INTO tblKhachHang (maKhachHang, hoTen, soDienThoai, email) "
                + "SELECT CONCAT('KH', LPAD(n, GREATEST(3, LENGTH(n)), '0')), ?, ?, ? "
                + "FROM (SELECT IFNULL(MAX(id), 0) + 1 AS n FROM tblKhachHang) t";
        try {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, kh.getHoTen());
                ps.setString(2, kh.getSoDienThoai());
                ps.setString(3, kh.getEmail());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        kh.setId(rs.getInt(1));
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

    /** Cập nhật họ tên, số điện thoại, email của khách (module 3, trang Chỉnh sửa thông tin); trùng SĐT -> false. */
    public boolean capNhatKhachHang(KhachHang kh) {
        String sql = "UPDATE tblKhachHang SET hoTen = ?, soDienThoai = ?, email = ? WHERE id = ?";
        try {
            con.setAutoCommit(false);
            int soDong;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, kh.getHoTen());
                ps.setString(2, kh.getSoDienThoai());
                ps.setString(3, kh.getEmail());
                ps.setInt(4, kh.getId());
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
}
