package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.NhanVienLeTan;

public class NhanVienLeTanDAO extends DAO {

    public NhanVienLeTanDAO() {
        super();
    }

    /**
     * Như NhanVienQuanLiDAO.kiemTraDangNhap nhưng tìm trong tblNhanVienLeTan:
     * khớp thì điền thông tin nhân viên vào nvlt và trả về true.
     */
    public boolean kiemTraDangNhap(NhanVienLeTan nvlt) {
        try (CallableStatement cs = con.prepareCall("{call spKiemTraDangNhapLeTan(?, ?)}")) {
            cs.setString(1, nvlt.getTenDangNhap());
            cs.setString(2, nvlt.getMatKhau());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    nvlt.setId(rs.getInt("id"));
                    nvlt.setMaNhanVien(rs.getString("maNhanVien"));
                    nvlt.setHoTen(rs.getString("hoTen"));
                    nvlt.setNgaySinh(rs.getDate("ngaySinh"));
                    nvlt.setEmail(rs.getString("email"));
                    nvlt.setSoDienThoai(rs.getString("soDienThoai"));
                    nvlt.setTenDangNhap(rs.getString("tenDangNhap"));
                    nvlt.setChucVu(rs.getString("chucVu"));
                    return true;
                }
                return false;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra đăng nhập: " + e.getMessage(), e);
        }
    }
}
