<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.NhanVienLeTan, model.PhieuDichVu, dao.PhieuDichVuDAO" %>
<%
    // Trang xử lí Hoàn thành phục vụ (UC mục 1.2; báo cáo không thiết kế trang)
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        // id = 0 -> không hoàn thành được
    }

    PhieuDichVu pdv = new PhieuDichVu();
    pdv.setId(id);
    if (new PhieuDichVuDAO().hoanThanhPhucVu(pdv)) {
        session.setAttribute("thongBao", "Hoàn thành phục vụ thành công");
    } else {
        session.setAttribute("thongBao", "Hoàn thành phục vụ không thành công");
    }
    response.sendRedirect("gdTiepNhanKhachHang.jsp");
%>
