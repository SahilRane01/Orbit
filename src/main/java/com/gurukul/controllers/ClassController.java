package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.UUID;

@WebServlet("/classAction")
public class ClassController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String generateClassCode() {
        return UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UserProfile user = (session != null) ? (UserProfile) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String source = request.getParameter("source");
        if (source == null) source = "classes.jsp";

        try (Connection conn = DBConnection.getConnection(getServletContext())) {

            if ("CREATE_CLASS".equals(action)) {
                // Teacher only
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String classCode = generateClassCode();

                // Ensure unique code
                boolean unique = false;
                while (!unique) {
                    try (PreparedStatement check = conn.prepareStatement("SELECT id FROM classes WHERE class_code = ?")) {
                        check.setString(1, classCode);
                        ResultSet rs = check.executeQuery();
                        if (!rs.next()) unique = true;
                        else classCode = generateClassCode();
                    }
                }

                String sql = "INSERT INTO classes (name, description, teacher_id, class_code) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, description);
                    ps.setInt(3, user.getId());
                    ps.setString(4, classCode);
                    ps.executeUpdate();
                }

            } else if ("JOIN_CLASS".equals(action)) {
                // Student only
                if (!"Student".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                String code = request.getParameter("class_code");
                if (code != null) code = code.trim().toUpperCase();

                // Find class by code
                String findSql = "SELECT id FROM classes WHERE class_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                    ps.setString(1, code);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int classId = rs.getInt("id");
                        // Enroll student (ignore if already enrolled due to UNIQUE constraint)
                        String enrollSql = "INSERT IGNORE INTO class_students (class_id, student_id) VALUES (?, ?)";
                        try (PreparedStatement enrollPs = conn.prepareStatement(enrollSql)) {
                            enrollPs.setInt(1, classId);
                            enrollPs.setInt(2, user.getId());
                            enrollPs.executeUpdate();
                        }
                    } else {
                        response.sendRedirect(source + "?status=error&msg=Invalid+class+code");
                        return;
                    }
                }

            } else if ("DELETE_CLASS".equals(action)) {
                // Teacher only
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                int classId = Integer.parseInt(request.getParameter("class_id"));
                String sql = "DELETE FROM classes WHERE id = ? AND teacher_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, classId);
                    ps.setInt(2, user.getId());
                    ps.executeUpdate();
                }

            } else if ("POST_ANNOUNCEMENT".equals(action)) {
                int classId = Integer.parseInt(request.getParameter("class_id"));
                String content = request.getParameter("content");
                String sql = "INSERT INTO class_announcements (class_id, author_id, content) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, classId);
                    ps.setInt(2, user.getId());
                    ps.setString(3, content);
                    ps.executeUpdate();
                }
                response.sendRedirect("class_detail.jsp?id=" + classId + "&status=success");
                return;

            } else if ("LEAVE_CLASS".equals(action)) {
                // Student leaves a class
                int classId = Integer.parseInt(request.getParameter("class_id"));
                String sql = "DELETE FROM class_students WHERE class_id = ? AND student_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, classId);
                    ps.setInt(2, user.getId());
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
