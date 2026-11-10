package model;

import java.io.Serializable;
import java.util.Date;

/** Một kỹ thuật viên thực hiện một chi tiết phiếu (thoiGianKetThuc: lúc lập là dự kiến, lúc hoàn thành là thực tế). */
public class PhanCongKTV implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private Date thoiGianBatDau;
    private Date thoiGianKetThuc;
    private KyThuatVien kyThuatVien;

    public PhanCongKTV() {
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

    public KyThuatVien getKyThuatVien() {
        return kyThuatVien;
    }

    public void setKyThuatVien(KyThuatVien kyThuatVien) {
        this.kyThuatVien = kyThuatVien;
    }
}
