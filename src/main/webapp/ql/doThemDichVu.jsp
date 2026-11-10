<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder, java.util.Arrays, model.NhanVienQuanLi, model.DichVu, dao.DichVuDAO" %>
<%
    // Trang xử lí thêm dịch vụ (mục 9.1, 10.1 bước 6)
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    if (request.getParameter("txtTenDichVu") == null) {
        response.sendRedirect("gdThemDichVu.jsp");
        return;
    }

    String ten = request.getParameter("txtTenDichVu").trim();
    String loai = request.getParameter("slLoaiDichVu");
    String moTa = request.getParameter("txtMoTa") == null ? "" : request.getParameter("txtMoTa").trim();
    String tuKhoa = request.getParameter("tuKhoa");
    int thoiGian = -1;
    try {
        thoiGian = Integer.parseInt(request.getParameter("txtThoiGianThucHien").trim());
    } catch (Exception e) {
        // để -1 -> báo nhập sai
    }
    float donGia = -1;
    try {
        // chấp nhận cả 400000 và 400.000
        donGia = Float.parseFloat(request.getParameter("txtDonGia").replace(".", "").replace(",", "").replace(" ", ""));
    } catch (Exception e) {
        // để -1 -> báo nhập sai
    }

    if (ten.isEmpty() || ten.length() > 255 || !Arrays.asList(DichVu.DS_LOAI_DICH_VU).contains(loai)
            || thoiGian <= 0 || !(donGia > 0) || Float.isInfinite(donGia) || moTa.length() > 255) {
        session.setAttribute("thongBao", "Vui lòng nhập đầy đủ và đúng thông tin dịch vụ (thời gian, đơn giá là số dương)");
        request.getRequestDispatcher("gdThemDichVu.jsp").forward(request, response);
        return;
    }

    DichVu dv = new DichVu();
    dv.setTenDichVu(ten);
    dv.setLoaiDichVu(loai);
    dv.setThoiGianThucHien(thoiGian);
    dv.setDonGia(donGia);
    dv.setMoTa(moTa.isEmpty() ? null : moTa);
    dv.setTrangThai(DichVu.TT_DANG_CUNG_CAP);   // trạng thái mặc định (mục 9.1)

    DichVuDAO dichVuDAO = new DichVuDAO();
    if (dichVuDAO.kiemTraTrungTen(ten)) {
        session.setAttribute("thongBao", "Dịch vụ đã tồn tại, vui lòng kiểm tra lại");
        request.getRequestDispatcher("gdThemDichVu.jsp").forward(request, response);
        return;
    }
    if (!dichVuDAO.themDichVu(dv)) {
        session.setAttribute("thongBao", "Thêm dịch vụ không thành công");
        request.getRequestDispatcher("gdThemDichVu.jsp").forward(request, response);
        return;
    }
    session.setAttribute("thongBao", "Thêm dịch vụ thành công");
    response.sendRedirect("gdQuanLiDichVu.jsp" + (tuKhoa == null ? "" : "?txtTuKhoa=" + URLEncoder.encode(tuKhoa, "UTF-8")));
%>
