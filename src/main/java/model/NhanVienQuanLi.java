package model;

/** Nhân viên quản lí. */
public class NhanVienQuanLi extends NhanVien {
    private static final long serialVersionUID = 1L;
    private String tenDangNhap;
    private String matKhau;
    private String chucVu;

    public NhanVienQuanLi() {
    }

    public String getTenDangNhap() {
        return tenDangNhap;
    }

    public void setTenDangNhap(String tenDangNhap) {
        this.tenDangNhap = tenDangNhap;
    }

    public String getMatKhau() {
        return matKhau;
    }

    public void setMatKhau(String matKhau) {
        this.matKhau = matKhau;
    }

    public String getChucVu() {
        return chucVu;
    }

    public void setChucVu(String chucVu) {
        this.chucVu = chucVu;
    }
}
