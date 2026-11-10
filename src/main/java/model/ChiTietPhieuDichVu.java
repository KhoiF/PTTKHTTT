package model;

import java.io.Serializable;
import java.util.ArrayList;

/** Một dịch vụ trên một phiếu (số lượng luôn 1, thành tiền = donGiaTaiThoiDiemPhucVu). */
public class ChiTietPhieuDichVu implements Serializable {
    private static final long serialVersionUID = 1L;
    /** Trạng thái chi tiết chỉ có 2 giá trị (thanh toán không đổi chi tiết). */
    public static final String TT_DANG_PHUC_VU = PhieuDichVu.TT_DANG_PHUC_VU;
    public static final String TT_HOAN_THANH = PhieuDichVu.TT_HOAN_THANH;

    private int id;
    private float donGiaTaiThoiDiemPhucVu;
    private String trangThai;
    private DichVu dichVu;
    private ArrayList<SuDungThietBi> dsSuDungThietBi = new ArrayList<>();
    private PhieuDichVu phieuDichVu;
    private ArrayList<PhanCongKTV> dsPhanCong = new ArrayList<>();

    public ChiTietPhieuDichVu() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public float getDonGiaTaiThoiDiemPhucVu() {
        return donGiaTaiThoiDiemPhucVu;
    }

    public void setDonGiaTaiThoiDiemPhucVu(float donGiaTaiThoiDiemPhucVu) {
        this.donGiaTaiThoiDiemPhucVu = donGiaTaiThoiDiemPhucVu;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public DichVu getDichVu() {
        return dichVu;
    }

    public void setDichVu(DichVu dichVu) {
        this.dichVu = dichVu;
    }

    public ArrayList<SuDungThietBi> getDsSuDungThietBi() {
        return dsSuDungThietBi;
    }

    public void setDsSuDungThietBi(ArrayList<SuDungThietBi> dsSuDungThietBi) {
        this.dsSuDungThietBi = dsSuDungThietBi;
    }

    public PhieuDichVu getPhieuDichVu() {
        return phieuDichVu;
    }

    public void setPhieuDichVu(PhieuDichVu phieuDichVu) {
        this.phieuDichVu = phieuDichVu;
    }

    public ArrayList<PhanCongKTV> getDsPhanCong() {
        return dsPhanCong;
    }

    public void setDsPhanCong(ArrayList<PhanCongKTV> dsPhanCong) {
        this.dsPhanCong = dsPhanCong;
    }
}
