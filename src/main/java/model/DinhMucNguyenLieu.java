package model;

import java.io.Serializable;

/** Định mức nguyên liệu của dịch vụ (3 module không dùng). */
public class DinhMucNguyenLieu implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private float soLuongDinhMuc;
    private NguyenLieu nguyenLieu;
    private DichVu dichVu;

    public DinhMucNguyenLieu() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public float getSoLuongDinhMuc() {
        return soLuongDinhMuc;
    }

    public void setSoLuongDinhMuc(float soLuongDinhMuc) {
        this.soLuongDinhMuc = soLuongDinhMuc;
    }

    public NguyenLieu getNguyenLieu() {
        return nguyenLieu;
    }

    public void setNguyenLieu(NguyenLieu nguyenLieu) {
        this.nguyenLieu = nguyenLieu;
    }

    public DichVu getDichVu() {
        return dichVu;
    }

    public void setDichVu(DichVu dichVu) {
        this.dichVu = dichVu;
    }
}
