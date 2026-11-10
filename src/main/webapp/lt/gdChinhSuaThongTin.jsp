<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, java.util.Arrays" %>
<%@ page import="model.NhanVienLeTan, model.PhieuDichVu, model.ChiTietMatHang, model.MatHang, model.KhuyenMai" %>
<%@ page import="dao.MatHangDAO, dao.KhuyenMaiDAO" %>
<%
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
    String tieuDe = "Chỉnh sửa thông tin";
    // Mọi thay đổi mặt hàng, khuyến mãi được ghi vào pdv trong session (mục 9.3); thông tin khách chỉ lưu khi bấm Xác nhận.

    // Từ gdLapHoaDon.jsp (nút Sửa thông tin): ghi lại phương thức thanh toán đang chọn
    String phuongThuc = request.getParameter("slPhuongThucThanhToan");
    if (phuongThuc != null && Arrays.asList(PhieuDichVu.DS_PHUONG_THUC_THANH_TOAN).contains(phuongThuc)) {
        pdv.setPhuongThucThanhToan(phuongThuc);
    }

    // [mới vào] lấy các khuyến mãi còn hiệu lực hôm nay (mục 10.3 bước 4)
    ArrayList<KhuyenMai> dsKhuyenMai = new KhuyenMaiDAO().getDSKhuyenMaiHieuLuc(new java.util.Date());
    String loi = "";
    boolean tuGuiVe = request.getParameter("tuGuiVe") != null;   // lần gửi từ chính trang này
    if (tuGuiVe) {
        // sửa số lượng các mặt hàng đã chọn
        for (ChiTietMatHang ct : new ArrayList<ChiTietMatHang>(pdv.getDsChiTietMatHang())) {
            String s = request.getParameter("txtSoLuongDaChon_" + ct.getMatHang().getId());
            if (s != null) {
                int soLuong = soNguyen(s, 0);
                if (soLuong >= 1) {
                    pdv.suaSoLuongMatHang(ct.getMatHang().getId(), soLuong);
                } else {
                    loi = "Số lượng phải là số nguyên dương";
                }
            }
        }
        // chọn khuyến mãi (tối đa 1)
        int idKhuyenMai = soNguyen(request.getParameter("slKhuyenMai"), 0);
        pdv.setKhuyenMai(null);
        for (KhuyenMai km : dsKhuyenMai) {
            if (km.getId() == idKhuyenMai) {
                pdv.setKhuyenMai(km);
            }
        }
        // xoá mặt hàng
        if (request.getParameter("btnXoaMatHang") != null) {
            pdv.xoaMatHang(soNguyen(request.getParameter("btnXoaMatHang"), 0));
        }
    }

    // [click tìm] tìm mặt hàng theo tên; đã tìm thì mỗi lần gửi về tìm lại để giữ kết quả
    String tenMatHang = chuoi(request.getParameter("txtTenMatHang"));
    boolean daTimMatHang = request.getParameter("btnTimMatHang") != null || "1".equals(request.getParameter("daTimMatHang"));
    ArrayList<MatHang> dsMatHang = new ArrayList<MatHang>();
    if (daTimMatHang) {
        dsMatHang = new MatHangDAO().timMatHang(tenMatHang);
    }
    // [click thêm] thêm mặt hàng với số lượng nhập ở dòng đó
    if (tuGuiVe && request.getParameter("btnThemMatHang") != null) {
        int idMatHang = soNguyen(request.getParameter("btnThemMatHang"), 0);
        int soLuong = soNguyen(request.getParameter("txtSoLuong_" + idMatHang), 0);
        for (MatHang mh : dsMatHang) {
            if (mh.getId() == idMatHang) {
                if (soLuong >= 1) {
                    pdv.themMatHang(mh, soLuong);
                } else {
                    loi = "Số lượng phải là số nguyên dương";
                }
            }
        }
    }

    // Thông tin khách: lần đầu lấy từ phiếu, các lần gửi về giữ giá trị đang nhập
    String hoTen = tuGuiVe ? chuoi(request.getParameter("txtHoTen")) : pdv.getKhachHang().getHoTen();
    String soDienThoai = tuGuiVe ? chuoi(request.getParameter("txtSoDienThoai")) : pdv.getKhachHang().getSoDienThoai();

    pdv.tinhTongTien();   // hiển thị lại với tổng tiền mới
    if (!loi.isEmpty()) {
        session.setAttribute("thongBao", loi);
    }
%>
<%@ include file="/header.jsp" %>
<div class="hop-vua">
<h1>Chỉnh sửa thông tin</h1>
<form method="post" action="gdChinhSuaThongTin.jsp">
    <input type="hidden" name="tuGuiVe" value="1">
<%  if (daTimMatHang) { %>
    <input type="hidden" name="daTimMatHang" value="1">
<%  } %>
    <div class="thanh-tim">
        Tên mặt hàng:
        <input type="text" name="txtTenMatHang" maxlength="255" value="<%= h(tenMatHang) %>">
        <input type="submit" name="btnTimMatHang" value="Tìm">
    </div>
<%  if (daTimMatHang) { %>
    <table class="bang">
        <tr>
            <th>Mã MH</th><th>Tên MH</th><th>ĐVT</th><th class="so">Đơn giá</th><th>Số lượng</th><th class="giua">Thêm</th>
        </tr>
<%      for (MatHang mh : dsMatHang) { %>
        <tr>
            <td><%= h(mh.getMaMatHang()) %></td>
            <td><%= h(mh.getTenMatHang()) %></td>
            <td><%= h(mh.getDonViTinh()) %></td>
            <td class="so"><%= tien(mh.getDonGia()) %></td>
            <td><input type="number" name="txtSoLuong_<%= mh.getId() %>" value="1" min="1" step="1" class="o-so"></td>
            <td class="giua"><button type="submit" name="btnThemMatHang" value="<%= mh.getId() %>">Thêm</button></td>
        </tr>
<%      }
        if (dsMatHang.isEmpty()) { %>
        <tr><td colspan="6" class="giua">Không tìm thấy mặt hàng nào</td></tr>
<%      } %>
    </table>
<%  } %>

    <h2>Mặt hàng đã chọn</h2>
    <table class="bang">
        <tr>
            <th>Mã MH</th><th>Tên mặt hàng</th><th>Số lượng</th><th class="so">Đơn giá</th><th class="so">Thành tiền</th>
            <th class="giua">Xoá</th>
        </tr>
<%  for (ChiTietMatHang ct : pdv.getDsChiTietMatHang()) { %>
        <tr>
            <td><%= h(ct.getMatHang().getMaMatHang()) %></td>
            <td><%= h(ct.getMatHang().getTenMatHang()) %></td>
            <td><input type="number" name="txtSoLuongDaChon_<%= ct.getMatHang().getId() %>" value="<%= ct.getSoLuong() %>"
                       min="1" step="1" class="o-so" onchange="guiForm(this)"></td>
            <td class="so"><%= tien(ct.getDonGiaTaiThoiDiemBan()) %></td>
            <td class="so"><%= tien(ct.getThanhTien()) %></td>
            <td class="giua"><button type="submit" name="btnXoaMatHang" value="<%= ct.getMatHang().getId() %>">Xoá</button></td>
        </tr>
<%  }
    if (pdv.getDsChiTietMatHang().isEmpty()) { %>
        <tr><td colspan="6" class="giua">Chưa có mặt hàng nào</td></tr>
<%  } %>
    </table>

    <h2>Khuyến mãi</h2>
    <select name="slKhuyenMai" onchange="guiForm(this)">
        <option value="">-- Không áp dụng --</option>
<%  for (KhuyenMai km : dsKhuyenMai) {
        String giaTri = KhuyenMai.LOAI_PHAN_TRAM.equals(km.getLoaiGiamGia())
                ? tien(km.getGiaTriGiam()) + "%" : tien(km.getGiaTriGiam()) + " VNĐ";
%>
        <option value="<%= km.getId() %>"<%= chon(pdv.getKhuyenMai() != null && pdv.getKhuyenMai().getId() == km.getId()) %>>
            <%= h(km.getMaKhuyenMai() + " – " + km.getTenChuongTrinh() + " (giảm " + giaTri + "; " + km.getDieuKienApDung() + ")") %></option>
<%  } %>
    </select>

    <table class="tong-tien">
        <tr><td>Tổng tiền dịch vụ:</td><td><%= tien(pdv.getTongTienDichVu()) %> VNĐ</td></tr>
        <tr><td>Tổng tiền hàng:</td><td><%= tien(pdv.getTongTienHang()) %> VNĐ</td></tr>
        <tr><td>Giảm giá:</td><td><%= tien(pdv.getTongGiamGia()) %> VNĐ</td></tr>
        <tr class="dam"><td>Tổng tiền hoá đơn:</td><td><%= tien(pdv.getTongThanhToan()) %> VNĐ</td></tr>
    </table>

    <h2>Thông tin khách hàng</h2>
    <table class="form">
        <tr><td>Họ tên:</td><td><input type="text" name="txtHoTen" class="o-dai" maxlength="255" value="<%= h(hoTen) %>"></td></tr>
        <tr><td>Số điện thoại:</td><td><input type="text" name="txtSoDienThoai" maxlength="255" value="<%= h(soDienThoai) %>"></td></tr>
    </table>

    <div class="hang-nut">
        <input type="submit" name="btnXacNhan" value="Xác nhận" formaction="doChinhSuaThongTin.jsp">
        <a class="nut nut-phu" href="gdLapHoaDon.jsp">Quay lại</a>
    </div>
</form>
</div>
</div></body></html>
