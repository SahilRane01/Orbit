package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/teacherAction")
public class TeacherController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        UserProfile user = (session != null) ? (UserProfile) session.getAttribute("user") : null;

        if (user == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String source = request.getParameter("source");
        if (source == null) source = "teacherDashboard.jsp";

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            if ("ADD_NOTICE".equals(action)) {
                String heading = request.getParameter("heading");
                String body = request.getParameter("body");
                String author = user.getFullName();
                String sql = "INSERT INTO noticeboard (heading, body, whom) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, heading);
                    ps.setString(2, body);
                    ps.setString(3, author);
                    ps.executeUpdate();
                }
            } else if ("DELETE_NOTICE".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM noticeboard WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } else if ("ADD_EVENT".equals(action)) {
                String name = request.getParameter("name");
                String date = request.getParameter("date");
                String desc = request.getParameter("description");
                String sql = "INSERT INTO events (event_name, event_date, description) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setDate(2, Date.valueOf(date));
                    ps.setString(3, desc);
                    ps.executeUpdate();
                }
            } else if ("DELETE_EVENT".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM events WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } else if ("ADD_STUDENT".equals(action)) {
                String fullname = request.getParameter("full_name");
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String course = request.getParameter("course");
                String batch = request.getParameter("batch");
                String specialization = request.getParameter("specialization");
                String password = request.getParameter("password");

                String sql = "INSERT INTO users (full_name, username, email, phone, role, course, batch, specialization, password) VALUES (?, ?, ?, ?, 'Student', ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, fullname);
                    ps.setString(2, username);
                    ps.setString(3, email);
                    ps.setString(4, phone);
                    ps.setString(5, course);
                    ps.setString(6, batch);
                    ps.setString(7, specialization);
                    ps.setString(8, password);
                    ps.executeUpdate();
                }
            }
            
            response.sendRedirect(source + "?status=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(source + "?status=error&msg=" + e.getMessage());
        }
    }
}
