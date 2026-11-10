package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.NhanVienQuanLi;

public class NhanVienQuanLiDAO extends DAO {

    public NhanVienQuanLiDAO() {
        super();
    }

    /**
     * Tìm trong tblNhanVien kết hợp tblNhanVienQuanLi bản ghi khớp tenDangNhap và matKhau của nvql;
     * nếu có thì điền id, họ tên, chức vụ (và các thông tin nhân viên khác) vào nvql, trả về true.
     */
    public boolean kiemTraDangNhap(NhanVienQuanLi nvql) {
        try (CallableStatement cs = con.prepareCall("{call spKiemTraDangNhapQuanLi(?, ?)}")) {
            cs.setString(1, nvql.getTenDangNhap());
            cs.setString(2, nvql.getMatKhau());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    nvql.setId(rs.getInt("id"));
                    nvql.setMaNhanVien(rs.getString("maNhanVien"));
                    nvql.setHoTen(rs.getString("hoTen"));
                    nvql.setNgaySinh(rs.getDate("ngaySinh"));
                    nvql.setEmail(rs.getString("email"));
                    nvql.setSoDienThoai(rs.getString("soDienThoai"));
                    nvql.setTenDangNhap(rs.getString("tenDangNhap"));
                    nvql.setChucVu(rs.getString("chucVu"));
                    return true;
                }
                return false;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra đăng nhập: " + e.getMessage(), e);
        }
    }
}
