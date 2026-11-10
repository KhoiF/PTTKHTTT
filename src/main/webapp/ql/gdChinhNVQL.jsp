<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.NhanVienQuanLi" %>
<%
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Trang chủ nhân viên quản lí";
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
    <h1>Trang chủ nhân viên quản lí</h1>
    <div class="thong-tin-nv">
        <div><span>Họ tên:</span> <b><%= h(nvql.getHoTen()) %></b></div>
        <div><span>Chức vụ:</span> <b><%= h(nvql.getChucVu()) %></b></div>
    </div>
    <div class="luoi-the">
        <a class="the-menu" href="gdQuanLiDichVu.jsp">
            <span class="ten">Quản lí thông tin dịch vụ</span>
            <span class="mo-ta">Tìm kiếm, thêm, sửa, xoá thông tin dịch vụ của cửa hàng.</span>
        </a>
    </div>
</div>
</div></body></html>
