package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/meetingAction")
public class MeetingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserProfile user = (session != null) ? (UserProfile) session.getAttribute("user") : null;

        if (user == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            if ("START_MEETING".equals(action)) {
                String meetingId = request.getParameter("meetingId");
                
                String sqlUpdate = "UPDATE meetings SET status = 'ACTIVE' WHERE meeting_id = ? AND teacher_id = ?";
                int rows = 0;
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setString(1, meetingId);
                    ps.setInt(2, user.getId());
                    rows = ps.executeUpdate();
                }

                if (rows == 0) {
                    String sqlInsert = "INSERT INTO meetings (teacher_id, teacher_name, meeting_id, course, status) VALUES (?, ?, ?, ?, 'ACTIVE')";
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                        ps.setInt(1, user.getId());
                        ps.setString(2, user.getFullName());
                        ps.setString(3, meetingId);
                        ps.setString(4, user.getCourse().trim());
                        ps.executeUpdate();
                    }
                }
                response.sendRedirect("meeting.jsp?id=" + meetingId + "&room=" + user.getFullName());
            } else if ("SCHEDULE_MEETING".equals(action)) {
                String heading = request.getParameter("heading");
                String scheduledTime = request.getParameter("scheduledTime");
                String meetingId = "MEET_" + System.currentTimeMillis();
                String sql = "INSERT INTO meetings (teacher_id, teacher_name, meeting_id, course, heading, status, scheduled_time) VALUES (?, ?, ?, ?, ?, 'SCHEDULED', ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, user.getId());
                    ps.setString(2, user.getFullName());
                    ps.setString(3, meetingId);
                    ps.setString(4, user.getCourse().trim());
                    ps.setString(5, heading);
                    ps.setString(6, scheduledTime);
                    ps.executeUpdate();
                }
                response.sendRedirect("briefings.jsp");
            } else if ("END_MEETING".equals(action)) {
                String meetingId = request.getParameter("meetingId");
                String sql = "UPDATE meetings SET status = 'ENDED' WHERE meeting_id = ? AND teacher_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, meetingId);
                    ps.setInt(2, user.getId());
                    ps.executeUpdate();
                }
                response.sendRedirect("teacherDashboard.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("teacherDashboard.jsp?error=SIGNAL_FAILURE");
        }
    }
}
