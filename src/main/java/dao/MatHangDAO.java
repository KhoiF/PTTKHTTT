package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import model.MatHang;

public class MatHangDAO extends DAO {

    public MatHangDAO() {
        super();
    }

    /** Các mặt hàng có tên chứa chuỗi tìm kiếm (rỗng -> tất cả). */
    public ArrayList<MatHang> timMatHang(String tenMatHang) {
        ArrayList<MatHang> ds = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call spTimMatHang(?)}")) {
            cs.setString(1, tenMatHang == null ? "" : tenMatHang.trim());
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    MatHang mh = new MatHang();
                    mh.setId(rs.getInt("id"));
                    mh.setMaMatHang(rs.getString("maMatHang"));
                    mh.setTenMatHang(rs.getString("tenMatHang"));
                    mh.setDonGia(rs.getFloat("donGia"));
                    mh.setDonViTinh(rs.getString("donViTinh"));
                    mh.setSoLuongTon(rs.getInt("soLuongTon"));
                    ds.add(mh);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm mặt hàng: " + e.getMessage(), e);
        }
        return ds;
    }
}
