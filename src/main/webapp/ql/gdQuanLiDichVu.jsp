<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, model.NhanVienQuanLi, model.DichVu, dao.DichVuDAO" %>
<%
    NhanVienQuanLi nvql = (NhanVienQuanLi) session.getAttribute("nvql");
    if (nvql == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Quản lí thông tin dịch vụ";

    // txtTuKhoa == null: chưa bấm Tìm kiếm -> bảng trống; có (kể cả rỗng) -> DichVuDAO.timDichVu(tuKhoa)
    String tuKhoa = request.getParameter("txtTuKhoa");
    ArrayList<DichVu> listDV = new ArrayList<DichVu>();
    if (tuKhoa != null) {
        tuKhoa = tuKhoa.trim();
        listDV = new DichVuDAO().timDichVu(tuKhoa);
    }
    // Giữ từ khoá khi sang trang thêm/sửa/xoá rồi quay về
    String thamSoTuKhoa = tuKhoa == null ? "" : "tuKhoa=" + u(tuKhoa);
%>
<%@ include file="/header.jsp" %>
<h1>Quản lí thông tin dịch vụ</h1>
<div class="thanh-cong-cu">
    <form method="get" action="gdQuanLiDichVu.jsp" class="thanh-tim">
        <input type="text" name="txtTuKhoa" class="o-dai" value="<%= h(tuKhoa) %>"
               placeholder="Nhập tên hoặc từ khoá để tìm kiếm">
        <input type="submit" name="btnTimKiem" value="Tìm kiếm">
    </form>
    <a class="nut" href="gdThemDichVu.jsp<%= thamSoTuKhoa.isEmpty() ? "" : "?" + thamSoTuKhoa %>">Thêm dịch vụ mới</a>
</div>
<table class="bang">
    <tr>
        <th>TT</th><th>Mã dịch vụ</th><th>Tên dịch vụ</th><th>Loại dịch vụ</th><th class="so">Thời gian (phút)</th>
        <th class="so">Đơn giá (VNĐ)</th><th>Mô tả</th><th>Trạng thái</th><th class="giua">Sửa</th><th class="giua">Xoá</th>
    </tr>
<%  for (int i = 0; i < listDV.size(); i++) {
        DichVu dv = listDV.get(i);
        String thamSo = "id=" + dv.getId() + (thamSoTuKhoa.isEmpty() ? "" : "&" + thamSoTuKhoa);
%>
    <tr>
        <td><%= i + 1 %></td>
        <td><%= h(dv.getMaDichVu()) %></td>
        <td><%= h(dv.getTenDichVu()) %></td>
        <td><%= h(dv.getLoaiDichVu()) %></td>
        <td class="so"><%= dv.getThoiGianThucHien() %></td>
        <td class="so"><%= tien(dv.getDonGia()) %></td>
        <td><%= h(dv.getMoTa()) %></td>
        <td><%= h(dv.getTrangThai()) %></td>
        <td class="giua"><a href="gdSuaDichVu.jsp?<%= h(thamSo) %>">Sửa</a></td>
        <td class="giua"><a href="doXoaDichVu.jsp?<%= h(thamSo) %>"
               onclick="return xacNhan('<%= h(js("Bạn có chắc muốn xoá dịch vụ \"" + dv.getTenDichVu() + "\"?")) %>')">Xoá</a></td>
    </tr>
<%  }
    if (tuKhoa != null && listDV.isEmpty()) { %>
    <tr><td colspan="10" class="giua">Không có dịch vụ nào phù hợp</td></tr>
<%  } %>
</table>
<div class="hang-nut"><a class="nut nut-phu" href="gdChinhNVQL.jsp">Quay lại</a></div>
</div></body></html>
