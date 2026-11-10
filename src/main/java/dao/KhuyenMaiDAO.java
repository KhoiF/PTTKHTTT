package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;

import model.KhuyenMai;

public class KhuyenMaiDAO extends DAO {

    public KhuyenMaiDAO() {
        super();
    }

    /** Các chương trình có ngày bắt đầu ≤ ngay ≤ ngày kết thúc và trạng thái "Đang áp dụng" (mục 9.3). */
    public ArrayList<KhuyenMai> getDSKhuyenMaiHieuLuc(Date ngay) {
        ArrayList<KhuyenMai> ds = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call spGetDSKhuyenMaiHieuLuc(?, ?)}")) {
            cs.setDate(1, new java.sql.Date(ngay.getTime()));
            cs.setString(2, KhuyenMai.TT_DANG_AP_DUNG);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    KhuyenMai km = new KhuyenMai();
                    km.setId(rs.getInt("id"));
                    km.setMaKhuyenMai(rs.getString("maKhuyenMai"));
                    km.setTenChuongTrinh(rs.getString("tenChuongTrinh"));
                    km.setLoaiGiamGia(rs.getString("loaiGiamGia"));
                    km.setGiaTriGiam(rs.getFloat("giaTriGiam"));
                    km.setDieuKienApDung(rs.getString("dieuKienApDung"));
                    km.setTrangThai(rs.getString("trangThai"));
                    km.setNgayBatDau(rs.getDate("ngayBatDau"));
                    km.setNgayKetThuc(rs.getDate("ngayKetThuc"));
                    ds.add(km);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách khuyến mãi: " + e.getMessage(), e);
        }
        return ds;
    }
}
