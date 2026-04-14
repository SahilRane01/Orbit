package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/leaveAction")
public class LeaveController extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
        if (source == null) {
            source = "Teacher".equalsIgnoreCase(user.getRole()) ? "teacherDashboard.jsp" : "dashboard.jsp";
        }

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            if ("APPLY_LEAVE".equals(action)) {
                String reason = request.getParameter("reason");
                String startDate = request.getParameter("start_date");
                String endDate = request.getParameter("end_date");
                int studentId = user.getId();
                String studentName = user.getFullName();

                String sql = "INSERT INTO leave_requests (student_id, student_name, reason, start_date, end_date, status) VALUES (?, ?, ?, ?, ?, 'PENDING')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, studentId);
                    ps.setString(2, studentName);
                    ps.setString(3, reason);
                    ps.setDate(4, Date.valueOf(startDate));
                    ps.setDate(5, Date.valueOf(endDate));
                    ps.executeUpdate();
                }
            } else if ("UPDATE_LEAVE_STATUS".equals(action)) {
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status"); // APPROVED or DENIED

                String sql = "UPDATE leave_requests SET status = ? WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, status);
                    ps.setInt(2, id);
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
