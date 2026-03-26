import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/login")
public class login extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter p = response.getWriter();

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/gurukul",
                    "root",
                    "Shriyash@11"
            );
            String query = "CREATE TABLE IF NOT EXISTS users (\r\n"
					+ "    id INT AUTO_INCREMENT PRIMARY KEY,\r\n"
					+ "    full_name VARCHAR(100) NOT NULL,\r\n"
					+ "    username VARCHAR(50) NOT NULL UNIQUE,\r\n"
					+ "    email VARCHAR(100) NOT NULL UNIQUE,\r\n"
					+ "    phone VARCHAR(15),\r\n"
					+ "    role VARCHAR(20),\r\n"
					+ "    course VARCHAR(100),\r\n"
					+ "    batch VARCHAR(50),\r\n"
					+ "    specialization VARCHAR(100),\r\n"
					+ "    password VARCHAR(255) NOT NULL,\r\n"
					+ "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\r\n"
					+ ");";
			Statement user = conn.createStatement();
			user.executeUpdate(query);

            String sql = "SELECT password FROM users WHERE username = ?";
            PreparedStatement psmt = conn.prepareStatement(sql);
            psmt.setString(1, username);

            ResultSet rs = psmt.executeQuery();

            if (rs.next()) {
                String actual_pwd = rs.getString("password");

                if (password.equals(actual_pwd)) {

                    HttpSession session = request.getSession();
                    session.setAttribute("username", username);

                    response.sendRedirect("dashboard.jsp");

                } else {
                    p.println("Invalid Password");
                }

            } else {
                p.println("User not found");
            }

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            p.println("Error: " + e);
        }
    }
}