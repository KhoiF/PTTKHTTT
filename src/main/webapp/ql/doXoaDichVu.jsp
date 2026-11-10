<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder, model.NhanVienQuanLi, model.DichVu, dao.DichVuDAO" %>
<%
    // Trang xử lí xoá dịch vụ (báo cáo không thiết kế). Quy tắc xoá: xem DichVuDAO.xoaDichVu().
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tuKhoa = request.getParameter("tuKhoa");
    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        // id = 0 -> không xoá được
    }

    DichVu dv = new DichVu();
    dv.setId(id);
    if (new DichVuDAO().xoaDichVu(dv)) {
        session.setAttribute("thongBao", "Xoá dịch vụ thành công");
    } else {
        session.setAttribute("thongBao", "Không thể xoá dịch vụ đang có trong phiếu chưa thanh toán");
    }
    response.sendRedirect("gdQuanLiDichVu.jsp" + (tuKhoa == null ? "" : "?txtTuKhoa=" + URLEncoder.encode(tuKhoa, "UTF-8")));
%>
