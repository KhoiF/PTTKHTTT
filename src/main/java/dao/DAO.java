package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Lớp cha của mọi DAO (mục 9.1): giữ một Connection dùng chung cho toàn ứng dụng.
 * Hàm khởi tạo mở kết nối nếu chưa có hoặc đã đóng.
 * Quy ước: đọc bằng stored procedure (CallableStatement), ghi bằng transaction.
 */
public class DAO {
    private static final String URL = "jdbc:mysql://localhost:3306/spa_db"
            + "?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";

    protected static Connection con;

    public DAO() {
        moKetNoi();
    }

    private static synchronized void moKetNoi() {
        try {
            // isValid: mở lại cả khi MySQL đã tự cắt kết nối do để lâu không dùng
            if (con == null || con.isClosed() || !con.isValid(2)) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(URL, USER, PASSWORD);
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new RuntimeException("Không kết nối được CSDL spa_db: " + e.getMessage(), e);
        }
    }

    /** Dùng trong catch của thao tác ghi: in lỗi rồi huỷ transaction. */
    protected void rollback(SQLException loi) {
        loi.printStackTrace();
        try {
            con.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** Dùng trong finally của thao tác ghi: trả kết nối về chế độ tự commit. */
    protected void autoCommit() {
        try {
            con.setAutoCommit(true);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
