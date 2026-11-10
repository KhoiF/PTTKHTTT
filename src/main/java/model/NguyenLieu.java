package model;

import java.io.Serializable;

/** Nguyên liệu (có trong CSDL toàn hệ thống, 3 module không dùng). */
public class NguyenLieu implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private String maNguyenLieu;
    private String tenNguyenLieu;
    private String donViTinh;
    private float soLuongTon;

    public NguyenLieu() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaNguyenLieu() {
        return maNguyenLieu;
    }

    public void setMaNguyenLieu(String maNguyenLieu) {
        this.maNguyenLieu = maNguyenLieu;
    }

    public String getTenNguyenLieu() {
        return tenNguyenLieu;
    }

    public void setTenNguyenLieu(String tenNguyenLieu) {
        this.tenNguyenLieu = tenNguyenLieu;
    }

    public String getDonViTinh() {
        return donViTinh;
    }

    public void setDonViTinh(String donViTinh) {
        this.donViTinh = donViTinh;
    }

    public float getSoLuongTon() {
        return soLuongTon;
    }

    public void setSoLuongTon(float soLuongTon) {
        this.soLuongTon = soLuongTon;
    }
}
