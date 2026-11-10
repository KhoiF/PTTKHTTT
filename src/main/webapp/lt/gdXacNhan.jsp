<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Arrays, model.NhanVienLeTan, model.PhieuDichVu, model.ChiTietPhieuDichVu, model.ChiTietMatHang" %>
<%
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    PhieuDichVu pdv = (PhieuDichVu) session.getAttribute("pdv");
    if (pdv == null || !PhieuDichVu.TT_HOAN_THANH.equals(pdv.getTrangThai())) {
        session.setAttribute("thongBao", "Vui lòng chọn một phiếu cần thanh toán");
        response.sendRedirect("gdTimPhieuCanThanhToan.jsp");
        return;
    }
    String tieuDe = "Xác nhận hoá đơn";
    // Từ gdLapHoaDon.jsp (nút Tiếp tục): set phương thức thanh toán cho pdv (mục 11.3 bước 37)
    String phuongThuc = request.getParameter("slPhuongThucThanhToan");
    if (phuongThuc != null && Arrays.asList(PhieuDichVu.DS_PHUONG_THUC_THANH_TOAN).contains(phuongThuc)) {
        pdv.setPhuongThucThanhToan(phuongThuc);
    }
    pdv.tinhTongTien();
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
<h1 class="no-print">Xác nhận hoá đơn</h1>
<div class="chi-in">
    <h1>HOÁ ĐƠN THANH TOÁN</h1>
    <p class="giua">Cửa hàng spa – In lúc <%= thoiGian(new java.util.Date()) %></p>
</div>
<table class="form">
    <tr><td>Khách hàng:</td><td><%= h(pdv.getKhachHang().getHoTen() + " – " + pdv.getKhachHang().getSoDienThoai()) %></td></tr>
    <tr><td>Nhân viên lập phiếu:</td><td><%= h(pdv.getNhanVienLeTan().getHoTen()) %></td></tr>
</table>
<table class="bang">
    <tr>
        <th>Mã phiếu</th><th>Dịch vụ / Mặt hàng</th><th class="so">Số lượng</th><th class="so">Đơn giá (VNĐ)</th>
        <th class="so">Thành tiền (VNĐ)</th>
    </tr>
<%  for (ChiTietPhieuDichVu ct : pdv.getDsChiTietPhieuDichVu()) { %>
    <tr>
        <td><%= h(pdv.getMaPhieu()) %></td>
        <td><%= h(ct.getDichVu().getTenDichVu()) %></td>
        <td class="so">1</td>
        <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemPhucVu()) %></td>
        <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemPhucVu()) %></td>
    </tr>
<%  }
    for (ChiTietMatHang ct : pdv.getDsChiTietMatHang()) { %>
    <tr>
        <td><%= h(pdv.getMaPhieu()) %></td>
        <td><%= h(ct.getMatHang().getTenMatHang()) %></td>
        <td class="so"><%= ct.getSoLuong() %></td>
        <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemBan()) %></td>
        <td class="so"><%= tien(ct.getThanhTien()) %></td>
    </tr>
<%  } %>
</table>
<table class="tong-tien">
    <tr><td>Tổng tiền:</td><td><%= tien(pdv.getTongTienDichVu() + pdv.getTongTienHang()) %> VNĐ</td></tr>
    <tr>
        <td>Giảm giá<%= pdv.getKhuyenMai() == null ? "" : " (" + h(pdv.getKhuyenMai().getMaKhuyenMai() + " – "
                + pdv.getKhuyenMai().getTenChuongTrinh()) + ")" %>:</td>
        <td><%= tien(pdv.getTongGiamGia()) %> VNĐ</td>
    </tr>
    <tr class="dam"><td>Tổng thanh toán:</td><td><%= tien(pdv.getTongThanhToan()) %> VNĐ</td></tr>
    <tr><td>Phương thức thanh toán:</td><td><%= h(pdv.getPhuongThucThanhToan()) %></td></tr>
</table>
<form method="post" action="doLuuHoaDon.jsp" class="hang-nut no-print">
    <input type="submit" name="btnXacNhan" value="Xác nhận">
    <button type="button" onclick="inTrang()">In hoá đơn</button>
    <a class="nut nut-phu" href="gdLapHoaDon.jsp">Quay lại</a>
</form>
</div>
</div></body></html>
