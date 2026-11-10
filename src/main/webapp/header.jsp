<%--
  header.jsp – phần đầu dùng chung, nhúng tĩnh bằng <%@ include file="/header.jsp" %>
  SAU KHI trang đã xử lí xong (không còn redirect/forward).
  Trang nhúng phải khai báo trước:  String tieuDe = "...";
  Trang tự đóng ở cuối:  </div></body></html>
  Chỉ dùng cú pháp Java 8 trong scriptlet.
--%>
<%@ page import="java.util.Date, java.text.SimpleDateFormat, java.text.DecimalFormat, java.text.DecimalFormatSymbols" %>
<%!
    /** Chuỗi an toàn để in vào HTML (null -> ""). */
    String h(Object o) {
        if (o == null) return "";
        String s = o.toString();
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }

    /** Chuỗi an toàn để đặt trong '...' của JavaScript. */
    String js(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"")
                .replace("\r", "").replace("\n", "\\n").replace("</", "<\\/");
    }

    /** Mã hoá giá trị để đặt vào tham số URL (?a=...). */
    String u(String s) {
        try {
            return java.net.URLEncoder.encode(s == null ? "" : s, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            return "";
        }
    }

    /** null -> "", có cắt khoảng trắng hai đầu. */
    String chuoi(String s) {
        return s == null ? "" : s.trim();
    }

    /** Tiền kiểu 400.000 */
    String tien(double so) {
        DecimalFormatSymbols kyHieu = new DecimalFormatSymbols();
        kyHieu.setGroupingSeparator('.');
        return new DecimalFormat("#,##0", kyHieu).format(so);
    }

    /** Thời gian kiểu 19:00 21/09/2026 (null -> "") */
    String thoiGian(Date d) {
        return d == null ? "" : new SimpleDateFormat("HH:mm dd/MM/yyyy").format(d);
    }

    /** Ngày kiểu 21/09/2026 (null -> "") */
    String ngay(Date d) {
        return d == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(d);
    }

    /** Thuộc tính selected / checked để giữ lựa chọn khi trang tự gửi về. */
    String chon(boolean dung) {
        return dung ? " selected" : "";
    }

    String tick(boolean dung) {
        return dung ? " checked" : "";
    }

    /** Đổi chuỗi sang số nguyên, sai định dạng thì trả giá trị mặc định. */
    int soNguyen(String s, int macDinh) {
        try {
            return Integer.parseInt(chuoi(s));
        } catch (NumberFormatException e) {
            return macDinh;
        }
    }
%>
<%
    String thongBaoChung = (String) session.getAttribute("thongBao");
    if (thongBaoChung != null) {
        session.removeAttribute("thongBao");
    }
    // Tên + chức vụ người đang đăng nhập (hiện trên thanh trên); tên biến có hậu tố "Chung" để không trùng biến của trang
    String tenNguoiDungChung = null;
    String chucVuChung = null;
    Object nvChung = session.getAttribute("nvql");
    if (nvChung instanceof model.NhanVienQuanLi) {
        tenNguoiDungChung = ((model.NhanVienQuanLi) nvChung).getHoTen();
        chucVuChung = ((model.NhanVienQuanLi) nvChung).getChucVu();
    } else {
        nvChung = session.getAttribute("nvlt");
        if (nvChung instanceof model.NhanVienLeTan) {
            tenNguoiDungChung = ((model.NhanVienLeTan) nvChung).getHoTen();
            chucVuChung = ((model.NhanVienLeTan) nvChung).getChucVu();
        }
    }
    // Trang có thể đặt request.setAttribute("lopTrang", "...") để thêm lớp cho <body> (vd trang đăng nhập)
    String lopTrangChung = request.getAttribute("lopTrang") == null ? "" : String.valueOf(request.getAttribute("lopTrang"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= h(tieuDe) %> – Spa</title>
<style>
    /* ---------- Màu chủ đạo xanh dương ---------- */
    :root {
        --xanh: #1f63b5;          /* nút chính, viền nhấn */
        --xanh-dam: #174d8f;      /* thanh trên, tiêu đề */
        --xanh-nhat: #eaf2fc;     /* nền tiêu đề bảng, hộp thông tin */
        --xanh-vien: #bcd0ea;     /* viền bảng, khung */
        --nen: #f2f6fb;
        --chu: #1f2933;
        --chu-phu: #5b6b7c;
        --do: #c62828;
    }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: "Segoe UI", Arial, Helvetica, sans-serif; font-size: 14px; color: var(--chu); background: var(--nen); }
    a { color: var(--xanh); }

    /* ---------- Thanh trên ---------- */
    .thanh-tren { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap;
                  padding: 10px 20px; background: var(--xanh-dam); color: #fff; }
    .thanh-tren .ten-he-thong { font-weight: bold; letter-spacing: .3px; }
    .thanh-tren .nguoi-dung { display: flex; align-items: center; gap: 12px; font-size: 13px; }
    .thanh-tren a { color: #fff; text-decoration: none; padding: 3px 12px; border: 1px solid rgba(255,255,255,.6); border-radius: 14px; }
    .thanh-tren a:hover { background: rgba(255,255,255,.15); }

    /* ---------- Khung nội dung, tiêu đề ---------- */
    .khung { max-width: 1040px; margin: 20px auto; padding: 20px 24px; background: #fff;
             border: 1px solid var(--xanh-vien); border-radius: 8px; box-shadow: 0 2px 8px rgba(23,77,143,.08); }
    h1 { font-size: 22px; text-align: center; margin: 4px 0 18px; color: var(--xanh-dam); }
    h2 { font-size: 15px; margin: 20px 0 8px; padding-bottom: 4px; color: var(--xanh-dam); border-bottom: 1px solid var(--xanh-vien); }
    fieldset { border: 1px solid var(--xanh-vien); border-radius: 6px; margin: 0 0 14px; padding: 10px 14px; }
    legend { font-weight: bold; padding: 0 6px; color: var(--xanh-dam); }
    .hop-nho { max-width: 420px; margin: 0 auto; }
    .hop-vua { max-width: 680px; margin: 0 auto; }

    /* ---------- Bảng ---------- */
    table.bang { width: 100%; border-collapse: collapse; margin: 8px 0; }
    table.bang th, table.bang td { border: 1px solid var(--xanh-vien); padding: 6px 8px; text-align: left; vertical-align: middle; }
    table.bang th { background: var(--xanh-nhat); color: var(--xanh-dam); font-weight: 600; }
    table.bang tr:hover td { background: #f7faff; }
    table.bang td.so, table.bang th.so { text-align: right; }
    table.bang td.giua, table.bang th.giua { text-align: center; }
    table.bang td[colspan] { color: var(--chu-phu); font-style: italic; }
    table.bang button, table.bang input[type=submit] { padding: 3px 10px; font-size: 13px; }
    table.form td { padding: 5px 10px 5px 0; }
    table.tong-tien { margin: 10px 0 10px auto; border-collapse: collapse; }
    table.tong-tien td { padding: 3px 0 3px 28px; text-align: right; }
    table.tong-tien tr.dam td { color: var(--xanh-dam); font-size: 16px; border-top: 1px solid var(--xanh-vien); padding-top: 6px; }

    /* ---------- Ô nhập ---------- */
    input[type=text], input[type=password], input[type=number], select, textarea {
        padding: 6px 8px; border: 1px solid #9fb3c8; border-radius: 4px; font-size: 14px; font-family: inherit; background: #fff; }
    input:focus, select:focus, textarea:focus { outline: none; border-color: var(--xanh); box-shadow: 0 0 0 2px rgba(31,99,181,.2); }
    input[readonly] { background: #eef2f7; color: var(--chu-phu); }
    textarea { width: 100%; min-height: 64px; }
    select[multiple] { min-width: 320px; }
    .o-dai { width: 340px; max-width: 100%; }
    .o-so { width: 80px; }

    /* ---------- Nút: .nut (link dạng nút) cùng kiểu với nút submit; .nut-phu = nút phụ (Quay lại) ---------- */
    button, input[type=submit], .nut { display: inline-block; padding: 7px 16px; font-size: 14px; font-family: inherit;
        background: var(--xanh); border: 1px solid var(--xanh); border-radius: 4px; color: #fff; cursor: pointer;
        text-decoration: none; line-height: 1.2; }
    button:hover, input[type=submit]:hover, .nut:hover { background: var(--xanh-dam); border-color: var(--xanh-dam); }
    .nut-phu { background: #fff; color: var(--xanh); }
    .nut-phu:hover { background: var(--xanh-nhat); color: var(--xanh-dam); }
    .hang-nut { text-align: center; margin-top: 16px; }
    .hang-nut > * { margin: 4px; }

    /* ---------- Thanh tìm kiếm / công cụ ---------- */
    .thanh-cong-cu { display: flex; justify-content: space-between; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 6px; }
    .thanh-tim { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 6px; }
    .thanh-cong-cu .thanh-tim { margin-bottom: 0; }

    /* ---------- Trang đăng nhập: thẻ gọn giữa màn hình ---------- */
    body.trang-dang-nhap .khung { background: transparent; border: none; box-shadow: none;
        min-height: calc(100vh - 100px); display: flex; align-items: center; justify-content: center; }
    .the-dang-nhap { width: 100%; max-width: 380px; background: #fff; border: 1px solid var(--xanh-vien);
        border-top: 4px solid var(--xanh); border-radius: 10px; box-shadow: 0 6px 24px rgba(23,77,143,.15); padding: 28px 32px; }
    .the-dang-nhap .phu-de { text-align: center; color: var(--chu-phu); margin: -10px 0 20px; }
    .the-dang-nhap label { display: block; margin: 12px 0 4px; font-weight: 600; }
    .the-dang-nhap input[type=text], .the-dang-nhap input[type=password] { width: 100%; }
    .the-dang-nhap input[type=submit] { width: 100%; margin-top: 20px; padding: 9px; }

    /* ---------- Trang chủ: hộp thông tin nhân viên + menu dạng thẻ ---------- */
    .thong-tin-nv { background: var(--xanh-nhat); border-radius: 6px; padding: 10px 16px; display: flex; gap: 32px; flex-wrap: wrap; }
    .thong-tin-nv span { color: var(--chu-phu); }
    .luoi-the { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; margin-top: 18px; }
    .the-menu { display: block; padding: 18px 20px; background: #fff; border: 1px solid var(--xanh-vien);
        border-left: 5px solid var(--xanh); border-radius: 8px; color: var(--chu); text-decoration: none;
        transition: box-shadow .15s, transform .15s; }
    .the-menu:hover { box-shadow: 0 6px 18px rgba(23,77,143,.15); transform: translateY(-2px); }
    .the-menu .ten { display: block; font-size: 16px; font-weight: bold; color: var(--xanh-dam); margin-bottom: 6px; }
    .the-menu .mo-ta { display: block; color: var(--chu-phu); font-size: 13px; line-height: 1.45; }

    /* ---------- Chữ ---------- */
    .giua { text-align: center; }
    .phai { text-align: right; }
    .dam { font-weight: bold; }
    .loi { color: var(--do); }
    .ghi-chu { font-size: 12px; color: var(--chu-phu); margin-top: 2px; }
    .chi-in { display: none; }

    @media (max-width: 640px) {
        .khung { margin: 8px; padding: 14px; }
        select[multiple] { min-width: 0; width: 100%; }
    }
    /* ---------- In (hoá đơn): ẩn thanh trên và mọi nút, chỉ in nội dung ---------- */
    @media print {
        body { background: #fff; color: #000; }
        .no-print, .thanh-tren, .hang-nut, button, input[type=submit], .nut { display: none !important; }
        .khung { border: none; box-shadow: none; margin: 0; padding: 0; max-width: none; }
        .chi-in { display: block; }
        table.bang th { background: #fff; color: #000; }
        table.bang th, table.bang td { border-color: #000; }
        table.tong-tien tr.dam td { color: #000; }
    }
</style>
<script>
    /** Tự gửi form chứa phần tử (dùng cho onchange: tick dịch vụ, chọn KTV...). */
    function guiForm(el) {
        el.form.submit();
    }
    /** Hộp xác nhận, dùng: onclick="return xacNhan('...')" */
    function xacNhan(thongDiep) {
        return confirm(thongDiep);
    }
    /** In trang hiện tại (nút In hoá đơn). */
    function inTrang() {
        window.print();
    }
<% if (thongBaoChung != null) { %>
    window.addEventListener('load', function () { alert('<%= js(thongBaoChung) %>'); });
<% } %>
</script>
</head>
<body class="<%= h(lopTrangChung) %>">
<div class="thanh-tren no-print">
    <span class="ten-he-thong">Hệ thống quản lí cửa hàng spa</span>
<% if (tenNguoiDungChung != null) { %>
    <span class="nguoi-dung">
        <span><%= h(tenNguoiDungChung) %> – <%= h(chucVuChung) %></span>
        <a href="<%= request.getContextPath() %>/doDangXuat.jsp">Đăng xuất</a>
    </span>
<% } %>
</div>
<div class="khung">
