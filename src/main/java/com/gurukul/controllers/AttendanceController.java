package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/attendanceAction")
public class AttendanceController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UserProfile user = (session != null) ? (UserProfile) session.getAttribute("user") : null;

        if (user == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            if ("MARK_ATTENDANCE".equals(action)) {
                String date = request.getParameter("date");
                String subject = request.getParameter("subject");
                String[] studentIds = request.getParameterValues("student_id");
                String[] statuses = request.getParameterValues("attendance_status");

                if (studentIds != null && statuses != null && studentIds.length == statuses.length) {
                    String sql = "INSERT INTO attendance (student_id, date, subject, status, marked_by) " +
                                 "VALUES (?, ?, ?, ?, ?) " +
                                 "ON DUPLICATE KEY UPDATE status = VALUES(status), marked_by = VALUES(marked_by), created_at = CURRENT_TIMESTAMP";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        for (int i = 0; i < studentIds.length; i++) {
                            ps.setInt(1, Integer.parseInt(studentIds[i]));
                            ps.setDate(2, Date.valueOf(date));
                            ps.setString(3, subject.trim().toUpperCase());
                            ps.setString(4, statuses[i]);
                            ps.setInt(5, user.getId());
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
                response.sendRedirect("markAttendance.jsp?status=success&date=" + date + "&subject=" + subject);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("markAttendance.jsp?status=error&msg=" + e.getMessage());
        }
    }
}
