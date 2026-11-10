<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.NhanVienLeTan" %>
<%
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Trang chủ nhân viên lễ tân";
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
    <h1>Trang chủ nhân viên lễ tân</h1>
    <div class="thong-tin-nv">
        <div><span>Họ tên:</span> <b><%= h(nvlt.getHoTen()) %></b></div>
        <div><span>Chức vụ:</span> <b><%= h(nvlt.getChucVu()) %></b></div>
    </div>
    <div class="luoi-the">
        <a class="the-menu" href="gdTiepNhanKhachHang.jsp">
            <span class="ten">Nhận khách và phân công nhân viên phục vụ tại quầy</span>
            <span class="mo-ta">Tiếp nhận khách, lập phiếu phục vụ, chọn dịch vụ và phân công kỹ thuật viên.</span>
        </a>
        <a class="the-menu" href="gdTimPhieuCanThanhToan.jsp">
            <span class="ten">Cho khách thanh toán tại quầy</span>
            <span class="mo-ta">Lập hoá đơn cho phiếu đã hoàn thành, áp dụng khuyến mãi và xác nhận thanh toán.</span>
        </a>
    </div>
</div>
</div></body></html>
