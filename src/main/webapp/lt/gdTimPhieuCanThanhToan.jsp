<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, model.NhanVienLeTan, model.PhieuDichVu, model.ChiTietPhieuDichVu, dao.PhieuDichVuDAO" %>
<%
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Tìm phiếu cần thanh toán";

    // txtTenKhachHang == null: chưa tìm -> bảng trống; có (kể cả rỗng) -> PhieuDichVuDAO.getPhieuCanThanhToan()
    String tenKhachHang = request.getParameter("txtTenKhachHang");
    ArrayList<PhieuDichVu> dsPhieu = new ArrayList<PhieuDichVu>();
    if (tenKhachHang != null) {
        tenKhachHang = tenKhachHang.trim();
        dsPhieu = new PhieuDichVuDAO().getPhieuCanThanhToan(tenKhachHang);
        for (PhieuDichVu pdv : dsPhieu) {
            pdv.tinhTongTien();
        }
        // gdLapHoaDon.jsp lấy phiếu được chọn từ danh sách này; tên tìm kiếm dùng khi bấm Quay lại
        session.setAttribute("dsPhieuCanThanhToan", dsPhieu);
        session.setAttribute("tenKhachHangTim", tenKhachHang);
    }
    int idPhieuChon = soNguyen(request.getParameter("radChonPhieu"), 0);
%>
<%@ include file="/header.jsp" %>
<h1>Tìm phiếu cần thanh toán</h1>
<form method="get" action="gdTimPhieuCanThanhToan.jsp">
    <div class="thanh-tim">
        Tên khách hàng:
        <input type="text" name="txtTenKhachHang" class="o-dai" value="<%= h(tenKhachHang) %>">
        <input type="submit" name="btnTimKiem" value="Tìm kiếm">
    </div>
    <table class="bang">
        <tr>
            <th class="giua">Chọn</th><th>Mã phiếu</th><th>Tên KH</th><th>SĐT</th><th>Bắt đầu</th><th>Kết thúc</th>
            <th>Dịch vụ</th><th class="so">Tổng tiền (VNĐ)</th><th>Trạng thái</th>
        </tr>
<%  for (PhieuDichVu pdv : dsPhieu) {
        StringBuilder dichVu = new StringBuilder();
        for (ChiTietPhieuDichVu ct : pdv.getDsChiTietPhieuDichVu()) {
            dichVu.append(dichVu.length() > 0 ? "<br>" : "").append(h(ct.getDichVu().getTenDichVu()));
        }
%>
        <tr>
            <td class="giua"><input type="radio" name="radChonPhieu" value="<%= pdv.getId() %>"<%= tick(pdv.getId() == idPhieuChon) %>></td>
            <td><%= h(pdv.getMaPhieu()) %></td>
            <td><%= h(pdv.getKhachHang().getHoTen()) %></td>
            <td><%= h(pdv.getKhachHang().getSoDienThoai()) %></td>
            <td><%= thoiGian(pdv.getThoiGianBatDau()) %></td>
            <td><%= thoiGian(pdv.getThoiGianKetThuc()) %></td>
            <td><%= dichVu %></td>
            <td class="so"><%= tien(pdv.getTongTienDichVu()) %></td>
            <td><%= h(pdv.getTrangThai()) %></td>
        </tr>
<%  }
    if (tenKhachHang != null && dsPhieu.isEmpty()) { %>
        <tr><td colspan="9" class="giua">Không có phiếu nào cần thanh toán</td></tr>
<%  } %>
    </table>
    <div class="hang-nut">
        <input type="submit" name="btnLapHoaDon" value="Lập hoá đơn thanh toán" formaction="gdLapHoaDon.jsp" formmethod="post">
        <a class="nut nut-phu" href="gdChinhNVLT.jsp">Quay lại</a>
    </div>
</form>
</div></body></html>
