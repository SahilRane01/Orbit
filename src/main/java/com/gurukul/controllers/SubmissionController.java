package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;

@WebServlet("/submitAction")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize       = 10 * 1024 * 1024,  // 10 MB
    maxRequestSize    = 15 * 1024 * 1024   // 15 MB
)
public class SubmissionController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UserProfile user = (session != null) ? (UserProfile) session.getAttribute("user") : null;

        if (user == null || !"Student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("SUBMIT_ASSIGNMENT".equals(action)) {
            int assignmentId = Integer.parseInt(request.getParameter("assignment_id"));
            int classId = Integer.parseInt(request.getParameter("class_id"));
            String textContent = request.getParameter("text_content");

            // Handle file upload
            String fileName = null;
            String filePath = null;
            Part filePart = request.getPart("submission_file");
            if (filePart != null && filePart.getSize() > 0) {
                fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                // Create uploads directory
                String uploadDir = getServletContext().getRealPath("/uploads/submissions");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                // Make filename unique
                String uniqueName = System.currentTimeMillis() + "_" + fileName;
                filePath = "uploads/submissions/" + uniqueName;
                filePart.write(uploadDir + File.separator + uniqueName);
            }

            try (Connection conn = DBConnection.getConnection(getServletContext())) {
                // Use INSERT ... ON DUPLICATE KEY UPDATE so students can resubmit
                String sql = "INSERT INTO submissions (assignment_id, student_id, text_content, file_name, file_path) " +
                             "VALUES (?, ?, ?, ?, ?) " +
                             "ON DUPLICATE KEY UPDATE text_content = VALUES(text_content), " +
                             "file_name = VALUES(file_name), file_path = VALUES(file_path), " +
                             "submitted_at = CURRENT_TIMESTAMP, grade = NULL, feedback = NULL, graded_at = NULL";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, assignmentId);
                    ps.setInt(2, user.getId());
                    ps.setString(3, textContent);
                    ps.setString(4, fileName);
                    ps.setString(5, filePath);
                    ps.executeUpdate();
                }
                response.sendRedirect("assignment_detail.jsp?id=" + assignmentId + "&class_id=" + classId + "&status=success");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("assignment_detail.jsp?id=" + assignmentId + "&class_id=" + classId + "&status=error&msg=" + e.getMessage());
            }
        } else {
            response.sendRedirect("classes.jsp");
        }
    }
}
