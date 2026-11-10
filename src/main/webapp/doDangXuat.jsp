<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Trang xử lí: huỷ phiên làm việc rồi về trang đăng nhập.
    session.invalidate();
    response.sendRedirect("gdDangNhap.jsp");
%>
