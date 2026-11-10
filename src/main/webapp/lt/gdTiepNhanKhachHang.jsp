<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, model.NhanVienLeTan, model.PhieuDichVu, model.ChiTietPhieuDichVu, model.PhanCongKTV, dao.PhieuDichVuDAO" %>
<%
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Tiếp nhận khách hàng";
    // Khi mở: lấy danh sách phiếu phục vụ hiện tại (chưa thanh toán) – mục 9.2, 10.2 bước 3
    ArrayList<PhieuDichVu> dsPhieu = new PhieuDichVuDAO().getDSPhieuHienTai();
%>
<%@ include file="/header.jsp" %>
<h1>Tiếp nhận khách hàng</h1>
<table class="bang">
    <tr>
        <th>TT</th><th>Mã phiếu</th><th>Tên khách hàng</th><th>SĐT</th><th>Dịch vụ</th>
        <th>Nhân viên phục vụ</th><th>Thời gian bắt đầu</th><th>Trạng thái</th><th class="giua">Hoàn thành</th>
    </tr>
<%  for (int i = 0; i < dsPhieu.size(); i++) {
        PhieuDichVu pdv = dsPhieu.get(i);
        // Mỗi dịch vụ một dòng; cột nhân viên ghi các KTV của dịch vụ tương ứng
        StringBuilder dichVu = new StringBuilder();
        StringBuilder nhanVien = new StringBuilder();
        for (ChiTietPhieuDichVu ct : pdv.getDsChiTietPhieuDichVu()) {
            if (dichVu.length() > 0) {
                dichVu.append("<br>");
                nhanVien.append("<br>");
            }
            dichVu.append(h(ct.getDichVu().getTenDichVu()));
            for (int j = 0; j < ct.getDsPhanCong().size(); j++) {
                PhanCongKTV pc = ct.getDsPhanCong().get(j);
                nhanVien.append(j > 0 ? ", " : "").append(h(pc.getKyThuatVien().getHoTen()));
            }
        }
%>
    <tr>
        <td><%= i + 1 %></td>
        <td><%= h(pdv.getMaPhieu()) %></td>
        <td><%= h(pdv.getKhachHang().getHoTen()) %></td>
        <td><%= h(pdv.getKhachHang().getSoDienThoai()) %></td>
        <td><%= dichVu %></td>
        <td><%= nhanVien %></td>
        <td><%= thoiGian(pdv.getThoiGianBatDau()) %></td>
        <td><%= h(pdv.getTrangThai()) %></td>
        <td class="giua">
<%      if (PhieuDichVu.TT_DANG_PHUC_VU.equals(pdv.getTrangThai())) { %>
            <form method="post" action="doHoanThanhPhucVu.jsp"
                  onsubmit="return xacNhan('<%= h(js("Xác nhận hoàn thành phục vụ phiếu " + pdv.getMaPhieu() + "?")) %>')">
                <input type="hidden" name="id" value="<%= pdv.getId() %>">
                <input type="submit" name="btnHoanThanh" value="Hoàn thành">
            </form>
<%      } %>
        </td>
    </tr>
<%  }
    if (dsPhieu.isEmpty()) { %>
    <tr><td colspan="9" class="giua">Không có phiếu phục vụ nào</td></tr>
<%  } %>
</table>
<div class="hang-nut">
    <a class="nut" href="gdLapPhieuDichVu.jsp">Tiếp nhận khách mới</a>
    <a class="nut nut-phu" href="gdChinhNVLT.jsp">Quay lại</a>
</div>
</div></body></html>
