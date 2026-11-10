<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, java.util.Arrays, java.util.Date, java.util.HashSet, java.util.List, java.util.Set" %>
<%@ page import="model.NhanVienLeTan, model.KhachHang, model.DichVu, model.KyThuatVien, model.PhieuDichVu, model.ChiTietPhieuDichVu, model.PhanCongKTV" %>
<%@ page import="dao.KhachHangDAO, dao.DichVuDAO, dao.KyThuatVienDAO, dao.PhieuDichVuDAO" %>
<%
    // Trang xử lí lập phiếu (mục 9.2, 10.2 bước 5). Lỗi -> forward về gdLapPhieuDichVu.jsp, giữ nguyên dữ liệu đã nhập/chọn.
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    if (request.getParameter("txtSoDienThoai") == null) {
        response.sendRedirect("gdLapPhieuDichVu.jsp");
        return;
    }
    String soDienThoai = request.getParameter("txtSoDienThoai").trim();
    String hoTen = request.getParameter("txtHoTen") == null ? "" : request.getParameter("txtHoTen").trim();
    Set<String> dichVuDaChon = new HashSet<String>();
    if (request.getParameterValues("chkDichVu") != null) {
        dichVuDaChon.addAll(Arrays.asList(request.getParameterValues("chkDichVu")));
    }

    String loi = null;
    if (soDienThoai.isEmpty() || hoTen.isEmpty()) {
        loi = "Vui lòng nhập số điện thoại và họ tên khách hàng";
    } else if (soDienThoai.length() > 255 || hoTen.length() > 255) {
        loi = "Số điện thoại hoặc họ tên quá dài";
    }

    // Đóng gói các chi tiết phiếu: chỉ nhận dịch vụ đang cung cấp và KTV đang phù hợp (kiểm tra lại ở máy chủ)
    Date thoiDiemLap = new Date();
    KyThuatVienDAO kyThuatVienDAO = new KyThuatVienDAO();
    List<ChiTietPhieuDichVu> dsChiTiet = new ArrayList<ChiTietPhieuDichVu>();
    if (loi == null) {
        for (DichVu dv : new DichVuDAO().getDSDichVuDangCungCap()) {
            if (!dichVuDaChon.contains(String.valueOf(dv.getId()))) {
                continue;
            }
            String[] ktvChon = request.getParameterValues("slKTV_" + dv.getId());
            if (ktvChon == null || ktvChon.length == 0) {
                loi = "Vui lòng chọn kĩ thuật viên cho tất cả dịch vụ";
                break;
            }
            ChiTietPhieuDichVu ct = new ChiTietPhieuDichVu();
            ct.setDichVu(dv);
            ct.setDonGiaTaiThoiDiemPhucVu(dv.getDonGia());   // giá chốt tại thời điểm phục vụ
            ct.setTrangThai(ChiTietPhieuDichVu.TT_DANG_PHUC_VU);
            List<String> idChon = Arrays.asList(ktvChon);
            for (KyThuatVien ktv : kyThuatVienDAO.getDSKTVPhuHop(dv, thoiDiemLap)) {
                if (idChon.contains(String.valueOf(ktv.getId()))) {
                    PhanCongKTV pc = new PhanCongKTV();
                    pc.setKyThuatVien(ktv);
                    pc.setThoiGianBatDau(thoiDiemLap);
                    pc.setThoiGianKetThuc(new Date(thoiDiemLap.getTime() + dv.getThoiGianThucHien() * 60000L));
                    ct.getDsPhanCong().add(pc);
                }
            }
            if (ct.getDsPhanCong().size() != new HashSet<String>(idChon).size()) {
                loi = "Kĩ thuật viên đã chọn cho dịch vụ \"" + dv.getTenDichVu() + "\" không còn rảnh, vui lòng chọn lại";
                break;
            }
            dsChiTiet.add(ct);
        }
        if (loi == null && dsChiTiet.isEmpty()) {
            loi = "Vui lòng chọn ít nhất một dịch vụ";
        }
    }
    if (loi != null) {
        session.setAttribute("thongBao", loi);
        request.getRequestDispatcher("gdLapPhieuDichVu.jsp").forward(request, response);
        return;
    }

    // Khách hàng: số điện thoại đã có -> dùng khách cũ; chưa có -> KhachHangDAO.themKhachHang() trước (mục 9.2)
    KhachHangDAO khachHangDAO = new KhachHangDAO();
    KhachHang kh = khachHangDAO.timKhachHangTheoSDT(soDienThoai);
    if (kh == null) {
        kh = new KhachHang();
        kh.setHoTen(hoTen);
        kh.setSoDienThoai(soDienThoai);
        if (!khachHangDAO.themKhachHang(kh)) {
            session.setAttribute("thongBao", "Thêm khách hàng mới không thành công");
            request.getRequestDispatcher("gdLapPhieuDichVu.jsp").forward(request, response);
            return;
        }
    }

    PhieuDichVu pdv = new PhieuDichVu();
    pdv.setKhachHang(kh);
    pdv.setNhanVienLeTan(nvlt);
    pdv.setNgayLap(thoiDiemLap);
    pdv.setTrangThai(PhieuDichVu.TT_DANG_PHUC_VU);
    for (ChiTietPhieuDichVu ct : dsChiTiet) {
        ct.setPhieuDichVu(pdv);
        pdv.getDsChiTietPhieuDichVu().add(ct);
    }
    if (!new PhieuDichVuDAO().luuPhieuDichVu(pdv)) {
        session.setAttribute("thongBao", "Lập phiếu phục vụ không thành công, vui lòng kiểm tra lại kĩ thuật viên");
        request.getRequestDispatcher("gdLapPhieuDichVu.jsp").forward(request, response);
        return;
    }
    session.setAttribute("thongBao", "Lập phiếu phục vụ thành công");
    response.sendRedirect("gdTiepNhanKhachHang.jsp");
%>
