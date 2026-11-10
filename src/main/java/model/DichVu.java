package model;

import java.io.Serializable;
import java.util.ArrayList;

/** Dịch vụ của spa. */
public class DichVu implements Serializable {
    private static final long serialVersionUID = 1L;
    public static final String TT_DANG_CUNG_CAP = "Đang cung cấp";
    public static final String TT_NGUNG_CUNG_CAP = "Ngừng cung cấp";
    /** Dịch vụ đã có trong hoá đơn cũ bị xoá: ẩn ở mọi màn hình, không tính khi kiểm tra trùng tên. */
    public static final String TT_DA_XOA = "Đã xoá";
    /** Trạng thái chọn được trên form Sửa (không gồm "Đã xoá"). */
    public static final String[] DS_TRANG_THAI = {TT_DANG_CUNG_CAP, TT_NGUNG_CUNG_CAP};
    /** 5 loại dịch vụ; chuyên môn của KTV là một trong các loại này. */
    public static final String[] DS_LOAI_DICH_VU = {
        "Massage body", "Chăm sóc da mặt", "Gội đầu dưỡng sinh", "Chăm sóc móng", "Tắm trắng"
    };

    private int id;
    private String maDichVu;
    private String tenDichVu;
    private String loaiDichVu;
    private int thoiGianThucHien;
    private float donGia;
    private String moTa;
    private String trangThai;
    private ArrayList<DinhMucNguyenLieu> dsDinhMuc = new ArrayList<>();
    private ArrayList<YeuCauThietBi> dsYeuCauThietBi = new ArrayList<>();

    public DichVu() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaDichVu() {
        return maDichVu;
    }

    public void setMaDichVu(String maDichVu) {
        this.maDichVu = maDichVu;
    }

    public String getTenDichVu() {
        return tenDichVu;
    }

    public void setTenDichVu(String tenDichVu) {
        this.tenDichVu = tenDichVu;
    }

    public String getLoaiDichVu() {
        return loaiDichVu;
    }

    public void setLoaiDichVu(String loaiDichVu) {
        this.loaiDichVu = loaiDichVu;
    }

    public int getThoiGianThucHien() {
        return thoiGianThucHien;
    }

    public void setThoiGianThucHien(int thoiGianThucHien) {
        this.thoiGianThucHien = thoiGianThucHien;
    }

    public float getDonGia() {
        return donGia;
    }

    public void setDonGia(float donGia) {
        this.donGia = donGia;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public ArrayList<DinhMucNguyenLieu> getDsDinhMuc() {
        return dsDinhMuc;
    }

    public void setDsDinhMuc(ArrayList<DinhMucNguyenLieu> dsDinhMuc) {
        this.dsDinhMuc = dsDinhMuc;
    }

    public ArrayList<YeuCauThietBi> getDsYeuCauThietBi() {
        return dsYeuCauThietBi;
    }

    public void setDsYeuCauThietBi(ArrayList<YeuCauThietBi> dsYeuCauThietBi) {
        this.dsYeuCauThietBi = dsYeuCauThietBi;
    }
}
