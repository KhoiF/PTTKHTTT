package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

/** Phiếu dịch vụ; khi đã thanh toán chính là hoá đơn (các thuộc tính thanh toán chỉ có giá trị khi đó). */
public class PhieuDichVu implements Serializable {
    private static final long serialVersionUID = 1L;
    public static final String TT_DANG_PHUC_VU = "Đang phục vụ";
    public static final String TT_HOAN_THANH = "Hoàn thành";
    public static final String TT_DA_THANH_TOAN = "Đã thanh toán";
    /** Các phương thức thanh toán (UC Chọn phương thức thanh toán); phần tử đầu là mặc định. */
    public static final String[] DS_PHUONG_THUC_THANH_TOAN = {"Tiền mặt", "Chuyển khoản", "Thẻ"};

    private int id;
    private String maPhieu;
    private Date ngayLap;
    private String trangThai;
    private float tongTienDichVu;
    private float tongTienHang;
    private float tongGiamGia;
    private float tongThanhToan;
    private String phuongThucThanhToan;
    private Date ngayGioThanhToan;
    private NhanVienLeTan nhanVienLeTan;
    private KhachHang khachHang;
    private KhuyenMai khuyenMai;
    private ArrayList<ChiTietPhieuDichVu> dsChiTietPhieuDichVu = new ArrayList<>();
    private ArrayList<ChiTietMatHang> dsChiTietMatHang = new ArrayList<>();

    public PhieuDichVu() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaPhieu() {
        return maPhieu;
    }

    public void setMaPhieu(String maPhieu) {
        this.maPhieu = maPhieu;
    }

    public Date getNgayLap() {
        return ngayLap;
    }

    public void setNgayLap(Date ngayLap) {
        this.ngayLap = ngayLap;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public float getTongTienDichVu() {
        return tongTienDichVu;
    }

    public void setTongTienDichVu(float tongTienDichVu) {
        this.tongTienDichVu = tongTienDichVu;
    }

    public float getTongTienHang() {
        return tongTienHang;
    }

    public void setTongTienHang(float tongTienHang) {
        this.tongTienHang = tongTienHang;
    }

    public float getTongGiamGia() {
        return tongGiamGia;
    }

    public void setTongGiamGia(float tongGiamGia) {
        this.tongGiamGia = tongGiamGia;
    }

    public float getTongThanhToan() {
        return tongThanhToan;
    }

    public void setTongThanhToan(float tongThanhToan) {
        this.tongThanhToan = tongThanhToan;
    }

    public String getPhuongThucThanhToan() {
        return phuongThucThanhToan;
    }

    public void setPhuongThucThanhToan(String phuongThucThanhToan) {
        this.phuongThucThanhToan = phuongThucThanhToan;
    }

    public Date getNgayGioThanhToan() {
        return ngayGioThanhToan;
    }

    public void setNgayGioThanhToan(Date ngayGioThanhToan) {
        this.ngayGioThanhToan = ngayGioThanhToan;
    }

    public NhanVienLeTan getNhanVienLeTan() {
        return nhanVienLeTan;
    }

    public void setNhanVienLeTan(NhanVienLeTan nhanVienLeTan) {
        this.nhanVienLeTan = nhanVienLeTan;
    }

    public KhachHang getKhachHang() {
        return khachHang;
    }

    public void setKhachHang(KhachHang khachHang) {
        this.khachHang = khachHang;
    }

    public KhuyenMai getKhuyenMai() {
        return khuyenMai;
    }

    public void setKhuyenMai(KhuyenMai khuyenMai) {
        this.khuyenMai = khuyenMai;
    }

    public ArrayList<ChiTietPhieuDichVu> getDsChiTietPhieuDichVu() {
        return dsChiTietPhieuDichVu;
    }

    public void setDsChiTietPhieuDichVu(ArrayList<ChiTietPhieuDichVu> dsChiTietPhieuDichVu) {
        this.dsChiTietPhieuDichVu = dsChiTietPhieuDichVu;
    }

    public ArrayList<ChiTietMatHang> getDsChiTietMatHang() {
        return dsChiTietMatHang;
    }

    public void setDsChiTietMatHang(ArrayList<ChiTietMatHang> dsChiTietMatHang) {
        this.dsChiTietMatHang = dsChiTietMatHang;
    }

    /**
     * tinhTongTien() (mục 5.3): tính tổng tiền từ chi tiết dịch vụ, chi tiết mặt hàng và khuyến mãi,
     * gán vào tongTienDichVu, tongTienHang, tongGiamGia, tongThanhToan và trả về tongThanhToan.
     * - Giảm "Phần trăm": (tiền dịch vụ + tiền hàng) × giaTriGiam / 100, làm tròn đến đồng.
     * - Giảm "Số tiền": giaTriGiam. Giảm không vượt quá tổng trước giảm.
     * - Phiếu đã thanh toán giữ nguyên tongGiamGia đã lưu (mục 8.5: khuyến mãi có thể bị sửa sau này).
     */
    public float tinhTongTien() {
        float tienDichVu = 0;
        for (ChiTietPhieuDichVu ct : dsChiTietPhieuDichVu) {
            tienDichVu += ct.getDonGiaTaiThoiDiemPhucVu();
        }
        float tienHang = 0;
        for (ChiTietMatHang ct : dsChiTietMatHang) {
            tienHang += ct.getThanhTien();
        }
        float truocGiam = tienDichVu + tienHang;

        float giam;
        if (TT_DA_THANH_TOAN.equals(trangThai)) {
            giam = tongGiamGia;
        } else if (khuyenMai == null) {
            giam = 0;
        } else if (KhuyenMai.LOAI_PHAN_TRAM.equals(khuyenMai.getLoaiGiamGia())) {
            giam = Math.round(truocGiam * khuyenMai.getGiaTriGiam() / 100);
        } else {
            giam = khuyenMai.getGiaTriGiam();
        }
        giam = Math.max(0, Math.min(giam, truocGiam));

        tongTienDichVu = tienDichVu;
        tongTienHang = tienHang;
        tongGiamGia = giam;
        tongThanhToan = truocGiam - giam;
        return tongThanhToan;
    }

    /**
     * Thêm mặt hàng mua kèm (trang Chỉnh sửa thông tin): đã có trong danh sách thì cộng số lượng,
     * chưa có thì thêm ChiTietMatHang mới với đơn giá bán = đơn giá hiện hành của mặt hàng.
     */
    public void themMatHang(MatHang matHang, int soLuong) {
        for (ChiTietMatHang ct : dsChiTietMatHang) {
            if (ct.getMatHang().getId() == matHang.getId()) {
                ct.setSoLuong(ct.getSoLuong() + soLuong);
                return;
            }
        }
        ChiTietMatHang ct = new ChiTietMatHang();
        ct.setMatHang(matHang);
        ct.setSoLuong(soLuong);
        ct.setDonGiaTaiThoiDiemBan(matHang.getDonGia());
        ct.setPhieuDichVu(this);
        dsChiTietMatHang.add(ct);
    }

    /** Sửa số lượng của mặt hàng đã chọn. */
    public void suaSoLuongMatHang(int idMatHang, int soLuong) {
        for (ChiTietMatHang ct : dsChiTietMatHang) {
            if (ct.getMatHang().getId() == idMatHang) {
                ct.setSoLuong(soLuong);
            }
        }
    }

    /** Xoá mặt hàng khỏi danh sách đã chọn. */
    public void xoaMatHang(int idMatHang) {
        for (int i = dsChiTietMatHang.size() - 1; i >= 0; i--) {
            if (dsChiTietMatHang.get(i).getMatHang().getId() == idMatHang) {
                dsChiTietMatHang.remove(i);
            }
        }
    }

    /** Thời gian bắt đầu của phiếu = phân công KTV bắt đầu sớm nhất (null nếu chưa có). */
    public Date getThoiGianBatDau() {
        Date kq = null;
        for (ChiTietPhieuDichVu ct : dsChiTietPhieuDichVu) {
            for (PhanCongKTV pc : ct.getDsPhanCong()) {
                if (pc.getThoiGianBatDau() != null && (kq == null || pc.getThoiGianBatDau().before(kq))) {
                    kq = pc.getThoiGianBatDau();
                }
            }
        }
        return kq;
    }

    /** Thời gian kết thúc của phiếu = phân công KTV kết thúc muộn nhất (null nếu chưa có). */
    public Date getThoiGianKetThuc() {
        Date kq = null;
        for (ChiTietPhieuDichVu ct : dsChiTietPhieuDichVu) {
            for (PhanCongKTV pc : ct.getDsPhanCong()) {
                if (pc.getThoiGianKetThuc() != null && (kq == null || pc.getThoiGianKetThuc().after(kq))) {
                    kq = pc.getThoiGianKetThuc();
                }
            }
        }
        return kq;
    }
}
