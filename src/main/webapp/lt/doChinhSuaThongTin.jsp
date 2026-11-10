<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, java.util.Date" %>
<%@ page import="model.NhanVienLeTan, model.PhieuDichVu, model.ChiTietMatHang, model.KhuyenMai, model.KhachHang" %>
<%@ page import="dao.KhuyenMaiDAO, dao.KhachHangDAO" %>
<%
    // Trang xử lí nút Xác nhận của trang Chỉnh sửa thông tin (mục 9.3, 10.3 bước 5)
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
    if (request.getParameter("txtHoTen") == null) {
        response.sendRedirect("gdChinhSuaThongTin.jsp");
        return;
    }

    // Ghi nốt số lượng và khuyến mãi đang chọn trên form vào pdv (có thể chưa được gửi về trang trước khi bấm Xác nhận)
    for (ChiTietMatHang ct : new ArrayList<ChiTietMatHang>(pdv.getDsChiTietMatHang())) {
        try {
            int soLuong = Integer.parseInt(request.getParameter("txtSoLuongDaChon_" + ct.getMatHang().getId()).trim());
            if (soLuong >= 1) {
                pdv.suaSoLuongMatHang(ct.getMatHang().getId(), soLuong);
            }
        } catch (Exception e) {
            // giữ số lượng cũ
        }
    }
    String idKhuyenMai = request.getParameter("slKhuyenMai") == null ? "" : request.getParameter("slKhuyenMai");
    pdv.setKhuyenMai(null);
    for (KhuyenMai km : new KhuyenMaiDAO().getDSKhuyenMaiHieuLuc(new Date())) {
        if (String.valueOf(km.getId()).equals(idKhuyenMai)) {
            pdv.setKhuyenMai(km);
        }
    }

    // Thông tin khách: có thay đổi thì KhachHangDAO.capNhatKhachHang()
    String hoTen = request.getParameter("txtHoTen").trim();
    String soDienThoai = request.getParameter("txtSoDienThoai") == null ? "" : request.getParameter("txtSoDienThoai").trim();
    if (hoTen.isEmpty() || soDienThoai.isEmpty() || hoTen.length() > 255 || soDienThoai.length() > 255) {
        session.setAttribute("thongBao", "Vui lòng nhập họ tên và số điện thoại khách hàng");
        request.getRequestDispatcher("gdChinhSuaThongTin.jsp").forward(request, response);
        return;
    }
    KhachHang khCu = pdv.getKhachHang();
    if (!hoTen.equals(khCu.getHoTen()) || !soDienThoai.equals(khCu.getSoDienThoai())) {
        KhachHang khMoi = new KhachHang();
        khMoi.setId(khCu.getId());
        khMoi.setMaKhachHang(khCu.getMaKhachHang());
        khMoi.setEmail(khCu.getEmail());
        khMoi.setHoTen(hoTen);
        khMoi.setSoDienThoai(soDienThoai);
        if (!new KhachHangDAO().capNhatKhachHang(khMoi)) {
            session.setAttribute("thongBao", "Cập nhật thông tin khách hàng không thành công");
            request.getRequestDispatcher("gdChinhSuaThongTin.jsp").forward(request, response);
            return;
        }
        pdv.setKhachHang(khMoi);
        session.setAttribute("thongBao", "Cập nhật thông tin khách hàng thành công");
    }
    response.sendRedirect("gdLapHoaDon.jsp");
%>
