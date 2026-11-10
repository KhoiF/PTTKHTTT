package model;

/** Kỹ thuật viên. */
public class KyThuatVien extends NhanVien {
    private static final long serialVersionUID = 1L;
    public static final String TT_RANH = "Rảnh";
    public static final String TT_DANG_PHUC_VU = "Đang phục vụ";

    private String chuyenMon;
    private String trangThai;

    public KyThuatVien() {
    }

    public String getChuyenMon() {
        return chuyenMon;
    }

    public void setChuyenMon(String chuyenMon) {
        this.chuyenMon = chuyenMon;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }
}
