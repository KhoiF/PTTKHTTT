package model;

import java.io.Serializable;
import java.util.Date;

/** Thiết bị dùng cho một chi tiết phiếu (3 module không dùng). */
public class SuDungThietBi implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private Date thoiGianBatDau;
    private Date thoiGianKetThuc;
    private ThietBiPhucVu thietBi;
    private ChiTietPhieuDichVu chiTietPhieuDichVu;

    public SuDungThietBi() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getThoiGianBatDau() {
        return thoiGianBatDau;
    }

    public void setThoiGianBatDau(Date thoiGianBatDau) {
        this.thoiGianBatDau = thoiGianBatDau;
    }

    public Date getThoiGianKetThuc() {
        return thoiGianKetThuc;
    }

    public void setThoiGianKetThuc(Date thoiGianKetThuc) {
        this.thoiGianKetThuc = thoiGianKetThuc;
    }

    public ThietBiPhucVu getThietBi() {
        return thietBi;
    }

    public void setThietBi(ThietBiPhucVu thietBi) {
        this.thietBi = thietBi;
    }

    public ChiTietPhieuDichVu getChiTietPhieuDichVu() {
        return chiTietPhieuDichVu;
    }

    public void setChiTietPhieuDichVu(ChiTietPhieuDichVu chiTietPhieuDichVu) {
        this.chiTietPhieuDichVu = chiTietPhieuDichVu;
    }
}
