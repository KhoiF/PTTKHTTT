package model;

import java.io.Serializable;

/** Yêu cầu thiết bị của dịch vụ (3 module không dùng). */
public class YeuCauThietBi implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private int soLuongCan;
    private LoaiThietBi loaiThietBi;
    private DichVu dichVu;

    public YeuCauThietBi() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSoLuongCan() {
        return soLuongCan;
    }

    public void setSoLuongCan(int soLuongCan) {
        this.soLuongCan = soLuongCan;
    }

    public LoaiThietBi getLoaiThietBi() {
        return loaiThietBi;
    }

    public void setLoaiThietBi(LoaiThietBi loaiThietBi) {
        this.loaiThietBi = loaiThietBi;
    }

    public DichVu getDichVu() {
        return dichVu;
    }

    public void setDichVu(DichVu dichVu) {
        this.dichVu = dichVu;
    }
}
