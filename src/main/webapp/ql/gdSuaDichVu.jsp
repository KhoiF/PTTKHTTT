<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.NhanVienQuanLi, model.DichVu, dao.DichVuDAO" %>
<%
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Sửa thông tin dịch vụ";
    String tuKhoa = request.getParameter("tuKhoa");
    String quayLai = "gdQuanLiDichVu.jsp" + (tuKhoa == null ? "" : "?txtTuKhoa=" + u(tuKhoa));

    DichVu dv = new DichVuDAO().getDichVuTheoId(soNguyen(request.getParameter("id"), 0));
    if (dv == null || DichVu.TT_DA_XOA.equals(dv.getTrangThai())) {
        session.setAttribute("thongBao", "Không tìm thấy dịch vụ");
        response.sendRedirect(quayLai);
        return;
    }

    // Lần đầu: lấy từ CSDL; doSuaDichVu.jsp forward về (trùng tên / nhập sai): giữ dữ liệu đã nhập
    boolean guiLai = request.getParameter("txtTenDichVu") != null;
    String ten = guiLai ? chuoi(request.getParameter("txtTenDichVu")) : dv.getTenDichVu();
    String loai = guiLai ? chuoi(request.getParameter("slLoaiDichVu")) : dv.getLoaiDichVu();
    String thoiGian = guiLai ? chuoi(request.getParameter("txtThoiGianThucHien")) : String.valueOf(dv.getThoiGianThucHien());
    String donGia = guiLai ? chuoi(request.getParameter("txtDonGia")) : tien(dv.getDonGia());
    String moTa = guiLai ? chuoi(request.getParameter("txtMoTa")) : chuoi(dv.getMoTa());
    String trangThai = guiLai ? chuoi(request.getParameter("slTrangThai")) : dv.getTrangThai();
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
    <h1>Sửa thông tin dịch vụ</h1>
    <form method="post" action="doSuaDichVu.jsp">
        <table class="form">
            <tr>
                <td>Mã dịch vụ:</td>
                <td><%= h(dv.getMaDichVu()) %></td>
            </tr>
            <tr>
                <td>Tên dịch vụ:</td>
                <td><input type="text" name="txtTenDichVu" class="o-dai" maxlength="255" required
                           value="<%= h(ten) %>"></td>
            </tr>
            <tr>
                <td>Loại dịch vụ:</td>
                <td>
                    <select name="slLoaiDichVu" required>
<%  for (String l : DichVu.DS_LOAI_DICH_VU) { %>
                        <option value="<%= h(l) %>"<%= chon(l.equals(loai)) %>><%= h(l) %></option>
<%  } %>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Thời gian thực hiện (phút):</td>
                <td><input type="number" name="txtThoiGianThucHien" min="1" step="1" required value="<%= h(thoiGian) %>"></td>
            </tr>
            <tr>
                <td>Đơn giá (VNĐ):</td>
                <td><input type="text" name="txtDonGia" required value="<%= h(donGia) %>"></td>
            </tr>
            <tr>
                <td>Mô tả chi tiết:</td>
                <td><textarea name="txtMoTa" maxlength="255"><%= h(moTa) %></textarea></td>
            </tr>
            <tr>
                <td>Trạng thái:</td>
                <td>
                    <select name="slTrangThai">
<%  for (String t : DichVu.DS_TRANG_THAI) { %>
                        <option value="<%= h(t) %>"<%= chon(t.equals(trangThai)) %>><%= h(t) %></option>
<%  } %>
                    </select>
                </td>
            </tr>
        </table>
        <input type="hidden" name="id" value="<%= dv.getId() %>">
<%  if (tuKhoa != null) { %>
        <input type="hidden" name="tuKhoa" value="<%= h(tuKhoa) %>">
<%  } %>
        <div class="hang-nut">
            <input type="submit" name="btnLuu" value="Lưu">
            <a class="nut nut-phu" href="<%= h(quayLai) %>">Quay lại</a>
        </div>
    </form>
</div>
</div></body></html>
