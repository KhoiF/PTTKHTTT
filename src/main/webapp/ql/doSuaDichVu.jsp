<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder, java.util.Arrays, model.NhanVienQuanLi, model.DichVu, dao.DichVuDAO" %>
<%
    // Trang xử lí sửa dịch vụ (báo cáo không thiết kế; làm theo mẫu doThemDichVu.jsp)
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tuKhoa = request.getParameter("tuKhoa");
    String quayLai = "gdQuanLiDichVu.jsp" + (tuKhoa == null ? "" : "?txtTuKhoa=" + URLEncoder.encode(tuKhoa, "UTF-8"));
    if (request.getParameter("txtTenDichVu") == null) {
        response.sendRedirect(quayLai);
        return;
    }

    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        // id = 0 -> không sửa được
    }
    String ten = request.getParameter("txtTenDichVu").trim();
    String loai = request.getParameter("slLoaiDichVu");
    String trangThai = request.getParameter("slTrangThai");
    String moTa = request.getParameter("txtMoTa") == null ? "" : request.getParameter("txtMoTa").trim();
    int thoiGian = -1;
    try {
        thoiGian = Integer.parseInt(request.getParameter("txtThoiGianThucHien").trim());
    } catch (Exception e) {
        // để -1 -> báo nhập sai
    }
    float donGia = -1;
    try {
        donGia = Float.parseFloat(request.getParameter("txtDonGia").replace(".", "").replace(",", "").replace(" ", ""));
    } catch (Exception e) {
        // để -1 -> báo nhập sai
    }

    if (ten.isEmpty() || ten.length() > 255 || !Arrays.asList(DichVu.DS_LOAI_DICH_VU).contains(loai)
            || !Arrays.asList(DichVu.DS_TRANG_THAI).contains(trangThai)
            || thoiGian <= 0 || !(donGia > 0) || Float.isInfinite(donGia) || moTa.length() > 255) {
        session.setAttribute("thongBao", "Vui lòng nhập đầy đủ và đúng thông tin dịch vụ (thời gian, đơn giá là số dương)");
        request.getRequestDispatcher("gdSuaDichVu.jsp").forward(request, response);
        return;
    }

    DichVu dv = new DichVu();
    dv.setId(id);
    dv.setTenDichVu(ten);
    dv.setLoaiDichVu(loai);
    dv.setThoiGianThucHien(thoiGian);
    dv.setDonGia(donGia);
    dv.setMoTa(moTa.isEmpty() ? null : moTa);
    dv.setTrangThai(trangThai);

    DichVuDAO dichVuDAO = new DichVuDAO();
    if (dichVuDAO.kiemTraTrungTen(ten, id)) {
        session.setAttribute("thongBao", "Dịch vụ đã tồn tại, vui lòng kiểm tra lại");
        request.getRequestDispatcher("gdSuaDichVu.jsp").forward(request, response);
        return;
    }
    if (!dichVuDAO.suaDichVu(dv)) {
        session.setAttribute("thongBao", "Sửa dịch vụ không thành công");
        request.getRequestDispatcher("gdSuaDichVu.jsp").forward(request, response);
        return;
    }
    session.setAttribute("thongBao", "Sửa dịch vụ thành công");
    response.sendRedirect(quayLai);
%>
