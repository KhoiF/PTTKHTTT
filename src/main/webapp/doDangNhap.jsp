<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.NhanVienQuanLi, model.NhanVienLeTan, dao.NhanVienQuanLiDAO, dao.NhanVienLeTanDAO" %>
<%
    // Trang xử lí, không hiển thị (mục 9.1, 9.2): đăng nhập chung cho NV quản lí và lễ tân.
    String tenDangNhap = request.getParameter("txtTenDangNhap");
    String matKhau = request.getParameter("txtMatKhau");
    if (tenDangNhap == null || matKhau == null) {
        response.sendRedirect("gdDangNhap.jsp");
        return;
    }
    tenDangNhap = tenDangNhap.trim();

    NhanVienQuanLi nvql = new NhanVienQuanLi();
    nvql.setTenDangNhap(tenDangNhap);
    nvql.setMatKhau(matKhau);
    if (new NhanVienQuanLiDAO().kiemTraDangNhap(nvql)) {
        session.invalidate();                       // bỏ dữ liệu của phiên cũ
        HttpSession phienMoi = request.getSession(true);
        nvql.setMatKhau(null);                      // không giữ mật khẩu trong session
        phienMoi.setAttribute("nvql", nvql);
        response.sendRedirect("ql/gdChinhNVQL.jsp");
        return;
    }

    NhanVienLeTan nvlt = new NhanVienLeTan();
    nvlt.setTenDangNhap(tenDangNhap);
    nvlt.setMatKhau(matKhau);
    if (new NhanVienLeTanDAO().kiemTraDangNhap(nvlt)) {
        session.invalidate();
        HttpSession phienMoi = request.getSession(true);
        nvlt.setMatKhau(null);
        phienMoi.setAttribute("nvlt", nvlt);
        response.sendRedirect("lt/gdChinhNVLT.jsp");
        return;
    }

    // Sai: quay lại gdDangNhap.jsp kèm thông báo, giữ nguyên dữ liệu đã nhập
    session.setAttribute("thongBao", "Tên đăng nhập hoặc mật khẩu không đúng");
    request.getRequestDispatcher("gdDangNhap.jsp").forward(request, response);
%>
