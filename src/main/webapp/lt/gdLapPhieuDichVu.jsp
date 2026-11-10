<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, java.util.Arrays, java.util.HashMap, java.util.HashSet, java.util.Map, java.util.Set" %>
<%@ page import="model.NhanVienLeTan, model.KhachHang, model.DichVu, model.KyThuatVien" %>
<%@ page import="dao.KhachHangDAO, dao.DichVuDAO, dao.KyThuatVienDAO" %>
<%
    NhanVienLeTan nvlt = (NhanVienLeTan) session.getAttribute("nvlt");
    if (nvlt == null) {
        response.sendRedirect(request.getContextPath() + "/gdDangNhap.jsp");
        return;
    }
    String tieuDe = "Lập phiếu phục vụ";
    // Trang tự gửi về chính nó (Tìm khách hàng, tick dịch vụ, chọn KTV); doLuuPhieuDichVu.jsp lỗi cũng forward về đây.
    // Mọi lần gửi đều mang đủ SĐT, họ tên, dịch vụ đã tick, KTV đã chọn -> hiển thị lại đúng như cũ.

    // (1) Khách hàng – mục 9.2: tìm thấy thì tự điền họ tên, không thấy thì cho nhập mới
    String soDienThoai = chuoi(request.getParameter("txtSoDienThoai"));
    String hoTen = chuoi(request.getParameter("txtHoTen"));
    boolean daTimKhach = request.getParameter("btnTimKhachHang") != null || "1".equals(request.getParameter("daTimKhach"));
    KhachHang khachCu = null;
    String thongBaoKhach = "";
    if (daTimKhach) {
        if (soDienThoai.isEmpty()) {
            daTimKhach = false;
            thongBaoKhach = "Vui lòng nhập số điện thoại để tìm khách hàng";
        } else {
            khachCu = new KhachHangDAO().timKhachHangTheoSDT(soDienThoai);
            if (khachCu != null) {
                hoTen = khachCu.getHoTen();
            } else {
                thongBaoKhach = "Khách hàng mới. Vui lòng nhập họ tên khách hàng";
            }
        }
    }

    // (2) Dịch vụ đang cung cấp và các dịch vụ đã tick
    ArrayList<DichVu> dsDichVu = new DichVuDAO().getDSDichVuDangCungCap();
    Set<String> dichVuDaChon = new HashSet<String>();
    if (request.getParameterValues("chkDichVu") != null) {
        dichVuDaChon.addAll(Arrays.asList(request.getParameterValues("chkDichVu")));
    }

    // (3) Phân công: với mỗi dịch vụ đã tick lấy KTV phù hợp, thời gian bắt đầu = thời điểm lập phiếu
    java.util.Date thoiGianBatDau = new java.util.Date();
    KyThuatVienDAO kyThuatVienDAO = new KyThuatVienDAO();
    ArrayList<DichVu> dsDaChon = new ArrayList<DichVu>();
    Map<Integer, ArrayList<KyThuatVien>> ktvPhuHop = new HashMap<Integer, ArrayList<KyThuatVien>>();
    Map<Integer, Set<String>> ktvDaChon = new HashMap<Integer, Set<String>>();
    for (DichVu dv : dsDichVu) {
        if (dichVuDaChon.contains(String.valueOf(dv.getId()))) {
            dsDaChon.add(dv);
            ktvPhuHop.put(dv.getId(), kyThuatVienDAO.getDSKTVPhuHop(dv, thoiGianBatDau));
            Set<String> ktvChon = new HashSet<String>();
            String[] giaTri = request.getParameterValues("slKTV_" + dv.getId());
            if (giaTri != null) {
                ktvChon.addAll(Arrays.asList(giaTri));
            }
            ktvDaChon.put(dv.getId(), ktvChon);
        }
    }
%>
<%@ include file="/header.jsp" %>
<h1>Lập phiếu phục vụ</h1>
<form method="post" action="gdLapPhieuDichVu.jsp">
    <fieldset>
        <legend>Thông tin khách hàng</legend>
        <table class="form">
            <tr>
                <td>Số điện thoại:</td>
                <td>
                    <input type="text" name="txtSoDienThoai" maxlength="255" value="<%= h(soDienThoai) %>">
                    <input type="submit" name="btnTimKhachHang" value="Tìm khách hàng">
                </td>
            </tr>
            <tr>
                <td>Họ tên:</td>
                <td><input type="text" name="txtHoTen" class="o-dai" maxlength="255" value="<%= h(hoTen) %>"<%= khachCu != null ? " readonly" : "" %>></td>
            </tr>
<%  if (!thongBaoKhach.isEmpty()) { %>
            <tr><td></td><td class="loi"><%= h(thongBaoKhach) %></td></tr>
<%  } %>
        </table>
<%  if (daTimKhach) { %>
        <input type="hidden" name="daTimKhach" value="1">
<%  } %>
    </fieldset>

    <fieldset>
        <legend>Chọn dịch vụ</legend>
        <table class="bang">
            <tr>
                <th>TT</th><th>Mã dịch vụ</th><th>Tên dịch vụ</th><th>Loại dịch vụ</th>
                <th class="so">Thời gian (phút)</th><th class="so">Đơn giá (VNĐ)</th><th class="giua">Chọn</th>
            </tr>
<%  for (int i = 0; i < dsDichVu.size(); i++) {
        DichVu dv = dsDichVu.get(i);
%>
            <tr>
                <td><%= i + 1 %></td>
                <td><%= h(dv.getMaDichVu()) %></td>
                <td><%= h(dv.getTenDichVu()) %></td>
                <td><%= h(dv.getLoaiDichVu()) %></td>
                <td class="so"><%= dv.getThoiGianThucHien() %></td>
                <td class="so"><%= tien(dv.getDonGia()) %></td>
                <td class="giua"><input type="checkbox" name="chkDichVu" value="<%= dv.getId() %>"
                    <%= tick(dichVuDaChon.contains(String.valueOf(dv.getId()))) %> onchange="guiForm(this)"></td>
            </tr>
<%  }
    if (dsDichVu.isEmpty()) { %>
            <tr><td colspan="7" class="giua">Không có dịch vụ nào đang cung cấp</td></tr>
<%  } %>
        </table>
    </fieldset>

    <fieldset>
        <legend>Phân công kỹ thuật viên</legend>
        <table class="bang">
            <tr>
                <th>Dịch vụ</th><th>Thời gian</th><th>Chuyên môn yêu cầu</th>
                <th>Kỹ thuật viên (chỉ hiện KTV đang rảnh)</th><th>Trạng thái</th>
            </tr>
<%  for (DichVu dv : dsDaChon) {
        ArrayList<KyThuatVien> dsKTV = ktvPhuHop.get(dv.getId());
        Set<String> ktvChon = ktvDaChon.get(dv.getId());
        int soDaChon = 0;
%>
            <tr>
                <td><%= h(dv.getTenDichVu()) %></td>
                <td><%= dv.getThoiGianThucHien() %> phút</td>
                <td><%= h(dv.getLoaiDichVu()) %></td>
                <td>
<%      if (dsKTV.isEmpty()) { %>
                    <span class="loi">Không có kĩ thuật viên rảnh</span>
<%      } else { %>
                    <select name="slKTV_<%= dv.getId() %>" multiple size="<%= Math.min(Math.max(dsKTV.size(), 2), 4) %>"
                            onchange="guiForm(this)">
<%          for (KyThuatVien ktv : dsKTV) {
                boolean daChon = ktvChon.contains(String.valueOf(ktv.getId()));
                if (daChon) {
                    soDaChon++;
                }
%>
                        <option value="<%= ktv.getId() %>"<%= chon(daChon) %>><%= h(ktv.getMaNhanVien() + " – " + ktv.getHoTen()
                                + " – " + ktv.getChuyenMon() + " – " + ktv.getTrangThai()) %></option>
<%          } %>
                    </select>
                    <div class="ghi-chu">Giữ Ctrl (Cmd trên Mac) để chọn nhiều kĩ thuật viên</div>
<%      } %>
                </td>
                <td><%= soDaChon > 0 ? "Đã phân công" : "Chưa phân công" %></td>
            </tr>
<%  }
    if (dsDaChon.isEmpty()) { %>
            <tr><td colspan="5" class="giua">Chưa chọn dịch vụ</td></tr>
<%  } %>
        </table>
    </fieldset>

    <div class="hang-nut">
        <input type="submit" name="btnXacNhanLapPhieu" value="Xác nhận lập phiếu" formaction="doLuuPhieuDichVu.jsp">
        <a class="nut nut-phu" href="gdTiepNhanKhachHang.jsp">Quay lại</a>
    </div>
</form>
</div></body></html>
