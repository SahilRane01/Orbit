package com.gurukul;
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

        Connection conn = null;
        PreparedStatement psmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                    "jdbc:mysql://192.168.0.105:3306/gurukul",
                    "root",
                    "Admin"
            );

            String sql = "SELECT * FROM users WHERE username = ?";
            psmt = conn.prepareStatement(sql);
            psmt.setString(1, username);

            rs = psmt.executeQuery();

            if (rs.next()) {

                String actual_pwd = rs.getString("password");

                if (password.equals(actual_pwd)) {

                    userProfile user = new userProfile();
                    user.setId(rs.getInt("id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setUserName(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone"));
                    user.setRole(rs.getString("role"));
                    user.setCourse(rs.getString("course"));
                    user.setBatch(rs.getString("batch"));
                    user.setSpecialization(rs.getString("specialization"));

                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);

                    response.sendRedirect("dashboard.jsp");

                } else {
                    p.println("<h3>Invalid Password</h3>");
                }

            } else {
                p.println("<h3>User not found</h3>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            p.println("<h3>Error: " + e + "</h3>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (psmt != null) psmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}