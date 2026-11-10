package model;

import java.io.Serializable;
import java.util.Date;

/** Chương trình khuyến mãi (ngayBatDau, ngayKetThuc lấy từ biểu đồ lớp mục 9 và CSDL). */
public class KhuyenMai implements Serializable {
    private static final long serialVersionUID = 1L;
    public static final String TT_DANG_AP_DUNG = "Đang áp dụng";
    /** loaiGiamGia: giaTriGiam là số phần trăm (10 = 10%). */
    public static final String LOAI_PHAN_TRAM = "Phần trăm";
    /** loaiGiamGia: giaTriGiam là số tiền (VNĐ). */
    public static final String LOAI_SO_TIEN = "Số tiền";

    private int id;
    private String maKhuyenMai;
    private String tenChuongTrinh;
    private String loaiGiamGia;
    private float giaTriGiam;
    private String dieuKienApDung;
    private String trangThai;
    private Date ngayBatDau;
    private Date ngayKetThuc;

    public KhuyenMai() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaKhuyenMai() {
        return maKhuyenMai;
    }

    public void setMaKhuyenMai(String maKhuyenMai) {
        this.maKhuyenMai = maKhuyenMai;
    }

    public String getTenChuongTrinh() {
        return tenChuongTrinh;
    }

    public void setTenChuongTrinh(String tenChuongTrinh) {
        this.tenChuongTrinh = tenChuongTrinh;
    }

    public String getLoaiGiamGia() {
        return loaiGiamGia;
    }

    public void setLoaiGiamGia(String loaiGiamGia) {
        this.loaiGiamGia = loaiGiamGia;
    }

    public float getGiaTriGiam() {
        return giaTriGiam;
    }

    public void setGiaTriGiam(float giaTriGiam) {
        this.giaTriGiam = giaTriGiam;
    }

    public String getDieuKienApDung() {
        return dieuKienApDung;
    }

    public void setDieuKienApDung(String dieuKienApDung) {
        this.dieuKienApDung = dieuKienApDung;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public Date getNgayBatDau() {
        return ngayBatDau;
    }

    public void setNgayBatDau(Date ngayBatDau) {
        this.ngayBatDau = ngayBatDau;
    }

    public Date getNgayKetThuc() {
        return ngayKetThuc;
    }

    public void setNgayKetThuc(Date ngayKetThuc) {
        this.ngayKetThuc = ngayKetThuc;
    }
}
