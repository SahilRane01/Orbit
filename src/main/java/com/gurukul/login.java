package com.gurukul;
import jakarta.servlet.ServletContext;
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
        ServletContext context = getServletContext();

        String DB = context.getInitParameter("DB_URL");
        String DB_User = context.getInitParameter("DB_USERNAME");
        String DB_pwd = context.getInitParameter("DB_PWD");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement psmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                    "jdbc:mysql://"+DB+":3306/gurukul",
                    DB_User,
                    DB_pwd
            );

            String sql = "SELECT * FROM users WHERE username = ?";
            psmt = conn.prepareStatement(sql);
            psmt.setString(1, username);

            rs = psmt.executeQuery();

            if (rs.next()) {

                String actual_pwd = rs.getString("password");

                if (password.equals(actual_pwd)) {

                    userProfileBean user = new userProfileBean();
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

                    if ("Teacher".equalsIgnoreCase(user.getRole())) {
                        response.sendRedirect("teacherDashboard.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }

                } else {
                    p.println("<h3>Invalid Password</h3>");
                }

            } else {
                p.println("<h3>User not found</h3>");
            }

        } catch (ClassNotFoundException e) {
            p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
            p.println("<h3>Driver Error</h3><p>MySQL JDBC Driver not found: " + e.getMessage() + "</p>");
            p.println("</div>");
            e.printStackTrace();
        } catch (SQLException e) {
            p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
            p.println("<h3>Database Error</h3>");
            p.println("<p><b>Message:</b> " + e.getMessage() + "</p>");
            p.println("<p><b>SQL State:</b> " + e.getSQLState() + "</p>");
            p.println("<p><b>Vendor Code:</b> " + e.getErrorCode() + "</p>");
            p.println("<p><b>URL attempted:</b> jdbc:mysql://" + DB + ":3306/gurukul</p>");
            p.println("</div>");
            e.printStackTrace();
        } catch (Exception e) {
            p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
            p.println("<h3>System Error</h3><p>" + e.toString() + "</p>");
            p.println("</div>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (psmt != null) psmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}