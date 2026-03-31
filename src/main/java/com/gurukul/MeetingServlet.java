package com.gurukul;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/meetingAction")
public class MeetingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        userProfileBean user = (userProfileBean) session.getAttribute("user");

        if (user == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            ServletContext context = getServletContext();
            String DB = context.getInitParameter("DB_URL");
            String DB_User = context.getInitParameter("DB_USERNAME");
            String DB_pwd = context.getInitParameter("DB_PWD");
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://" + DB + ":3306/gurukul", DB_User, DB_pwd);

            if ("START_MEETING".equals(action)) {
                String meetingId = request.getParameter("meetingId");
                // Attempt to update existing scheduled meeting first
                String sqlUpdate = "UPDATE meetings SET status = 'ACTIVE' WHERE meeting_id = ? AND teacher_id = ?";
                int rows = 0;
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setString(1, meetingId);
                    ps.setInt(2, user.getId());
                    rows = ps.executeUpdate();
                }

                // If no row updated, it's a new ad-hoc meeting
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

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("teacherDashboard.jsp?error=SIGNAL_FAILURE");
        }
    }
}
