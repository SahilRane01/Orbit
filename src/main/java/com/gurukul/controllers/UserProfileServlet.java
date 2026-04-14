package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/userProfile")
public class UserProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserProfile user = (session != null) ? (UserProfile) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("ph");

        // Synchronize values with form inputs
        if (name == null || name.trim().isEmpty()) name = user.getFullName();
        if (email == null || email.trim().isEmpty()) email = user.getEmail();
        if (phone == null || phone.trim().isEmpty()) phone = user.getPhone();

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            String sql = "UPDATE users SET full_name=?, email=?, phone=? WHERE id=?";
            try (PreparedStatement psmt = conn.prepareStatement(sql)) {
                psmt.setString(1, name);
                psmt.setString(2, email);
                psmt.setString(3, phone);
                psmt.setInt(4, user.getId());

                int rows = psmt.executeUpdate();
                if (rows > 0) {
                    user.setFullName(name);
                    user.setEmail(email);
                    user.setPhone(phone);
                    session.setAttribute("user", user);
                }
            }
            response.sendRedirect("userProfile.jsp?status=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("userProfile.jsp?status=error&msg=" + e.getMessage());
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("userProfile.jsp");
    }
}
