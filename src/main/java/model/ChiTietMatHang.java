package model;

import java.io.Serializable;

/** Một mặt hàng mua kèm phiếu. */
public class ChiTietMatHang implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private int soLuong;
    private float donGiaTaiThoiDiemBan;
    private MatHang matHang;
    private PhieuDichVu phieuDichVu;

    public ChiTietMatHang() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public float getDonGiaTaiThoiDiemBan() {
        return donGiaTaiThoiDiemBan;
    }

    public void setDonGiaTaiThoiDiemBan(float donGiaTaiThoiDiemBan) {
        this.donGiaTaiThoiDiemBan = donGiaTaiThoiDiemBan;
    }

    public MatHang getMatHang() {
        return matHang;
    }

    public void setMatHang(MatHang matHang) {
        this.matHang = matHang;
    }

    public PhieuDichVu getPhieuDichVu() {
        return phieuDichVu;
    }

    public void setPhieuDichVu(PhieuDichVu phieuDichVu) {
        this.phieuDichVu = phieuDichVu;
    }

    /** Thành tiền = soLuong × donGiaTaiThoiDiemBan. */
    public float getThanhTien() {
        return soLuong * donGiaTaiThoiDiemBan;
    }
}
