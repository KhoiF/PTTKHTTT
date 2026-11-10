<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String tieuDe = "Đăng nhập";
    // Khi doDangNhap.jsp forward về (đăng nhập sai) form giữ lại dữ liệu đã nhập (kịch bản ngoại lệ 2.2)
    String tenDangNhap = chuoi(request.getParameter("txtTenDangNhap"));
    String matKhau = request.getParameter("txtMatKhau") == null ? "" : request.getParameter("txtMatKhau");
    request.setAttribute("lopTrang", "trang-dang-nhap");   // header.jsp: căn thẻ đăng nhập giữa màn hình
%>
<%@ include file="/header.jsp" %>
<div class="the-dang-nhap">
    <h1>Đăng nhập</h1>
    <p class="phu-de">Nhân viên cửa hàng spa</p>
    <form method="post" action="doDangNhap.jsp">
        <label for="txtTenDangNhap">Tên đăng nhập</label>
        <input type="text" id="txtTenDangNhap" name="txtTenDangNhap" value="<%= h(tenDangNhap) %>" autofocus>
        <label for="txtMatKhau">Mật khẩu</label>
        <input type="password" id="txtMatKhau" name="txtMatKhau" value="<%= h(matKhau) %>">
        <input type="submit" name="btnDangNhap" value="Đăng nhập">
    </form>
</div>
</div></body></html>
