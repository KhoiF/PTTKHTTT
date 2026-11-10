<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Date, model.NhanVienLeTan, model.PhieuDichVu, dao.PhieuDichVuDAO" %>
<%
    // Trang xử lí lưu thanh toán (mục 9.3, 10.3 bước 7, 11.3 bước 44–53)
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
    if (pdv.getPhuongThucThanhToan() == null) {
        pdv.setPhuongThucThanhToan(PhieuDichVu.DS_PHUONG_THUC_THANH_TOAN[0]);
    }
    pdv.tinhTongTien();   // chốt tongGiamGia trước khi chuyển trạng thái

    // set ngày giờ thanh toán = hiện tại, trạng thái "Đã thanh toán" rồi lưu
    pdv.setNgayGioThanhToan(new Date());
    pdv.setTrangThai(PhieuDichVu.TT_DA_THANH_TOAN);
    if (new PhieuDichVuDAO().luuThanhToan(pdv)) {
        session.removeAttribute("pdv");
        session.removeAttribute("dsPhieuCanThanhToan");
        session.setAttribute("thongBao", "Thanh toán thành công");
        response.sendRedirect("gdTimPhieuCanThanhToan.jsp");
    } else {
        // trả phiếu về trạng thái cũ để có thể thử lại
        pdv.setNgayGioThanhToan(null);
        pdv.setTrangThai(PhieuDichVu.TT_HOAN_THANH);
        session.setAttribute("thongBao", "Thanh toán không thành công");
        response.sendRedirect("gdXacNhan.jsp");
    }
%>
