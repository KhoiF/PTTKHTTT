package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;

import model.DichVu;
import model.KyThuatVien;

public class KyThuatVienDAO extends DAO {

    public KyThuatVienDAO() {
        super();
    }

    /**
     * KTV có chuyên môn khớp loại dịch vụ của dv, đang "Rảnh" và không có phân công nào trùng khoảng
     * thời gian từ thoiGianBatDau đến thoiGianBatDau + thời gian thực hiện của dv (mục 9.2).
     */
    public ArrayList<KyThuatVien> getDSKTVPhuHop(DichVu dv, Date thoiGianBatDau) {
        ArrayList<KyThuatVien> ds = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call spGetDSKTVPhuHop(?, ?, ?, ?)}")) {
            cs.setString(1, dv.getLoaiDichVu());
            cs.setTimestamp(2, new Timestamp(thoiGianBatDau.getTime()));
            cs.setInt(3, dv.getThoiGianThucHien());
            cs.setString(4, KyThuatVien.TT_RANH);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    KyThuatVien ktv = new KyThuatVien();
                    ktv.setId(rs.getInt("id"));
                    ktv.setMaNhanVien(rs.getString("maNhanVien"));
                    ktv.setHoTen(rs.getString("hoTen"));
                    ktv.setNgaySinh(rs.getDate("ngaySinh"));
                    ktv.setEmail(rs.getString("email"));
                    ktv.setSoDienThoai(rs.getString("soDienThoai"));
                    ktv.setChuyenMon(rs.getString("chuyenMon"));
                    ktv.setTrangThai(rs.getString("trangThai"));
                    ds.add(ktv);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lấy danh sách kỹ thuật viên phù hợp: " + e.getMessage(), e);
        }
        return ds;
    }
}
