package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/assignmentAction")
public class AssignmentController extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

        try (Connection conn = DBConnection.getConnection(getServletContext())) {

            if ("CREATE_ASSIGNMENT".equals(action)) {
                // Teacher only
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                int classId = Integer.parseInt(request.getParameter("class_id"));
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String dueDateStr = request.getParameter("due_date");
                String maxMarksStr = request.getParameter("max_marks");
                int maxMarks = (maxMarksStr != null && !maxMarksStr.isEmpty()) ? Integer.parseInt(maxMarksStr) : 100;

                String sql = "INSERT INTO assignments (class_id, title, description, due_date, max_marks) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, classId);
                    ps.setString(2, title);
                    ps.setString(3, description);
                    if (dueDateStr != null && !dueDateStr.isEmpty()) {
                        ps.setDate(4, Date.valueOf(dueDateStr));
                    } else {
                        ps.setNull(4, Types.DATE);
                    }
                    ps.setInt(5, maxMarks);
                    ps.executeUpdate();
                }
                response.sendRedirect("class_detail.jsp?id=" + classId + "&status=success");

            } else if ("DELETE_ASSIGNMENT".equals(action)) {
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                int assignmentId = Integer.parseInt(request.getParameter("assignment_id"));
                int classId = Integer.parseInt(request.getParameter("class_id"));
                String sql = "DELETE FROM assignments WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, assignmentId);
                    ps.executeUpdate();
                }
                response.sendRedirect("class_detail.jsp?id=" + classId + "&status=success");

            } else if ("GRADE_SUBMISSION".equals(action)) {
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                int submissionId = Integer.parseInt(request.getParameter("submission_id"));
                int grade = Integer.parseInt(request.getParameter("grade"));
                String feedback = request.getParameter("feedback");
                int assignmentId = Integer.parseInt(request.getParameter("assignment_id"));
                int classId = Integer.parseInt(request.getParameter("class_id"));

                String sql = "UPDATE submissions SET grade = ?, feedback = ?, graded_at = NOW() WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, grade);
                    ps.setString(2, feedback);
                    ps.setInt(3, submissionId);
                    ps.executeUpdate();
                }
                response.sendRedirect("assignment_detail.jsp?id=" + assignmentId + "&class_id=" + classId + "&status=success");

            } else {
                response.sendRedirect("classes.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("classes.jsp?status=error&msg=" + e.getMessage());
        }
    }
}
