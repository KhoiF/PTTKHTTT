package model;

import java.io.Serializable;

/** Thiết bị phục vụ (3 module không dùng). */
public class ThietBiPhucVu implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private String maThietBi;
    private String tenThietBi;
    private String viTri;
    private String tinhTrang;
    private LoaiThietBi loaiThietBi;

    public ThietBiPhucVu() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaThietBi() {
        return maThietBi;
    }

    public void setMaThietBi(String maThietBi) {
        this.maThietBi = maThietBi;
    }

    public String getTenThietBi() {
        return tenThietBi;
    }

    public void setTenThietBi(String tenThietBi) {
        this.tenThietBi = tenThietBi;
    }

    public String getViTri() {
        return viTri;
    }

    public void setViTri(String viTri) {
        this.viTri = viTri;
    }

    public String getTinhTrang() {
        return tinhTrang;
    }

    public void setTinhTrang(String tinhTrang) {
        this.tinhTrang = tinhTrang;
    }

    public LoaiThietBi getLoaiThietBi() {
        return loaiThietBi;
    }

    public void setLoaiThietBi(LoaiThietBi loaiThietBi) {
        this.loaiThietBi = loaiThietBi;
    }
}
