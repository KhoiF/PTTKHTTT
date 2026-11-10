<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, model.NhanVienLeTan, model.PhieuDichVu, model.ChiTietPhieuDichVu, model.ChiTietMatHang" %>
<%
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Lập hoá đơn thanh toán";
    String tenKhachHangTim = (String) session.getAttribute("tenKhachHangTim");
    String trangTim = "gdTimPhieuCanThanhToan.jsp" + (tenKhachHangTim == null ? "" : "?txtTenKhachHang=" + u(tenKhachHangTim));

    // Đến từ trang Tìm (bấm Lập hoá đơn): lấy phiếu được chọn trong danh sách vừa tìm, đưa vào session "pdv".
    // Quay về từ trang Chỉnh sửa thông tin / Xác nhận: dùng "pdv" đang có trong session.
    PhieuDichVu pdv = null;
    if (request.getParameter("btnLapHoaDon") != null) {
        int idChon = soNguyen(request.getParameter("radChonPhieu"), 0);
        @SuppressWarnings("unchecked")
        ArrayList<PhieuDichVu> dsPhieu = (ArrayList<PhieuDichVu>) session.getAttribute("dsPhieuCanThanhToan");
        if (dsPhieu != null) {
            for (PhieuDichVu p : dsPhieu) {
                if (p.getId() == idChon) {
                    pdv = p;
                }
            }
        }
        if (pdv != null) {
            // Hoá đơn mới cho phiếu: chưa có mặt hàng, chưa có khuyến mãi, phương thức mặc định
            pdv.getDsChiTietMatHang().clear();
            pdv.setKhuyenMai(null);
            pdv.setPhuongThucThanhToan(PhieuDichVu.DS_PHUONG_THUC_THANH_TOAN[0]);
            session.setAttribute("pdv", pdv);
        }
    } else {
        pdv = (PhieuDichVu) session.getAttribute("pdv");
    }
    if (pdv == null || !PhieuDichVu.TT_HOAN_THANH.equals(pdv.getTrangThai())) {
        session.setAttribute("thongBao", "Vui lòng chọn một phiếu cần thanh toán");
        response.sendRedirect(trangTim);
        return;
    }
    pdv.tinhTongTien();   // tổng tiền dịch vụ, tiền hàng, giảm giá, tổng thanh toán (mục 10.3 bước 3)
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
<h1>Lập hoá đơn thanh toán</h1>
<table class="form">
    <tr><td>Khách hàng:</td><td><%= h(pdv.getKhachHang().getHoTen()) %></td></tr>
    <tr><td>Số điện thoại:</td><td><%= h(pdv.getKhachHang().getSoDienThoai()) %></td></tr>
</table>

<h2>Danh sách phiếu dịch vụ</h2>
<table class="bang">
    <tr>
        <th>Mã phiếu</th><th>Thời gian bắt đầu</th><th>Thời gian kết thúc</th><th>Trạng thái</th>
        <th class="so">Tổng tiền phiếu (VNĐ)</th>
    </tr>
    <tr>
        <td><%= h(pdv.getMaPhieu()) %></td>
        <td><%= thoiGian(pdv.getThoiGianBatDau()) %></td>
        <td><%= thoiGian(pdv.getThoiGianKetThuc()) %></td>
        <td><%= h(pdv.getTrangThai()) %></td>
        <td class="so"><%= tien(pdv.getTongTienDichVu()) %></td>
    </tr>
</table>

<h2>Chi tiết dịch vụ – Phiếu <%= h(pdv.getMaPhieu()) %></h2>
<table class="bang">
    <tr>
        <th>Tên dịch vụ</th><th class="so">Số lượng</th><th class="so">Đơn giá (VNĐ)</th><th class="so">Thành tiền (VNĐ)</th>
    </tr>
<%  for (ChiTietPhieuDichVu ct : pdv.getDsChiTietPhieuDichVu()) { %>
    <tr>
        <td><%= h(ct.getDichVu().getTenDichVu()) %></td>
        <td class="so">1</td>
        <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemPhucVu()) %></td>
        <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemPhucVu()) %></td>
    </tr>
<%  } %>
</table>

<h2>Mặt hàng đã chọn</h2>
<table class="bang">
    <tr>
        <th>Mã MH</th><th>Tên mặt hàng</th><th class="so">Số lượng</th><th class="so">Đơn giá (VNĐ)</th>
        <th class="so">Thành tiền (VNĐ)</th>
    </tr>
<%  for (ChiTietMatHang ct : pdv.getDsChiTietMatHang()) { %>
    <tr>
        <td><%= h(ct.getMatHang().getMaMatHang()) %></td>
        <td><%= h(ct.getMatHang().getTenMatHang()) %></td>
        <td class="so"><%= ct.getSoLuong() %></td>
        <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemBan()) %></td>
        <td class="so"><%= tien(ct.getThanhTien()) %></td>
    </tr>
<%  }
    if (pdv.getDsChiTietMatHang().isEmpty()) { %>
    <tr><td colspan="5" class="giua">Chưa có mặt hàng nào</td></tr>
<%  } %>
</table>

<table class="tong-tien">
    <tr><td>Tổng tiền dịch vụ:</td><td><%= tien(pdv.getTongTienDichVu()) %> VNĐ</td></tr>
    <tr><td>Tổng tiền hàng:</td><td><%= tien(pdv.getTongTienHang()) %> VNĐ</td></tr>
    <tr>
        <td>Giảm giá<%= pdv.getKhuyenMai() == null ? "" : " (" + h(pdv.getKhuyenMai().getMaKhuyenMai() + " – "
                + pdv.getKhuyenMai().getTenChuongTrinh()) + ")" %>:</td>
        <td><%= tien(pdv.getTongGiamGia()) %> VNĐ</td>
    </tr>
    <tr class="dam"><td>Tổng tiền hoá đơn:</td><td><%= tien(pdv.getTongThanhToan()) %> VNĐ</td></tr>
</table>

<form method="post" action="gdXacNhan.jsp">
    <div class="thanh-tim">
        Phương thức thanh toán:
        <select name="slPhuongThucThanhToan">
<%  for (String pt : PhieuDichVu.DS_PHUONG_THUC_THANH_TOAN) { %>
            <option value="<%= h(pt) %>"<%= chon(pt.equals(pdv.getPhuongThucThanhToan())) %>><%= h(pt) %></option>
<%  } %>
        </select>
    </div>
    <div class="hang-nut">
        <input type="submit" name="btnSuaThongTin" value="Sửa thông tin" formaction="gdChinhSuaThongTin.jsp">
        <input type="submit" name="btnTiepTuc" value="Tiếp tục">
        <a class="nut nut-phu" href="<%= h(trangTim + (tenKhachHangTim == null ? "?" : "&") + "radChonPhieu=" + pdv.getId()) %>">Quay lại</a>
    </div>
</form>
</div>
</div></body></html>
