package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter p = response.getWriter();

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            String sql = "SELECT * FROM users WHERE username = ?";
            try (PreparedStatement psmt = conn.prepareStatement(sql)) {
                psmt.setString(1, username);
                try (ResultSet rs = psmt.executeQuery()) {
                    if (rs.next()) {
                        String actual_pwd = rs.getString("password");
                        if (password.equals(actual_pwd)) {
                            UserProfile user = new UserProfile();
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
                }
            }
        } catch (Exception e) {
            p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
            p.println("<h3>System Error</h3><p>" + e.toString() + "</p>");
            p.println("</div>");
            e.printStackTrace();
        }
    }
}
