<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.NhanVienQuanLi, model.DichVu" %>
<%
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Thêm dịch vụ mới";

    // Khi doThemDichVu.jsp forward về (trùng tên / nhập sai) giữ lại dữ liệu đã nhập
    String ten = chuoi(request.getParameter("txtTenDichVu"));
    String loai = chuoi(request.getParameter("slLoaiDichVu"));
    String thoiGian = chuoi(request.getParameter("txtThoiGianThucHien"));
    String donGia = chuoi(request.getParameter("txtDonGia"));
    String moTa = chuoi(request.getParameter("txtMoTa"));
    String tuKhoa = request.getParameter("tuKhoa");
    String quayLai = "gdQuanLiDichVu.jsp" + (tuKhoa == null ? "" : "?txtTuKhoa=" + u(tuKhoa));
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
    <h1>Thêm dịch vụ mới</h1>
    <form method="post" action="doThemDichVu.jsp">
        <table class="form">
            <tr>
                <td>Tên dịch vụ:</td>
                <td><input type="text" name="txtTenDichVu" class="o-dai" maxlength="255" required
                           value="<%= h(ten) %>"></td>
            </tr>
            <tr>
                <td>Loại dịch vụ:</td>
                <td>
                    <select name="slLoaiDichVu" required>
                        <option value="">-- Chọn loại dịch vụ --</option>
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
                <td><input type="text" name="txtDonGia" required placeholder="vd 400.000" value="<%= h(donGia) %>"></td>
            </tr>
            <tr>
                <td>Mô tả chi tiết:</td>
                <td><textarea name="txtMoTa" maxlength="255"><%= h(moTa) %></textarea></td>
            </tr>
        </table>
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
