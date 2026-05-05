package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/resultAction")
public class ResultController extends HttpServlet {
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
            if ("SAVE_CONFIG".equals(action)) {
                int classId = Integer.parseInt(request.getParameter("class_id"));
                int tm = Integer.parseInt(request.getParameter("theory_max"));
                int tp = Integer.parseInt(request.getParameter("theory_pass"));
                int im = Integer.parseInt(request.getParameter("internal_max"));
                int ip = Integer.parseInt(request.getParameter("internal_pass"));
                int vm = Integer.parseInt(request.getParameter("viva_max"));
                int vp = Integer.parseInt(request.getParameter("viva_pass"));
                int ga = Integer.parseInt(request.getParameter("grade_a"));
                int gb = Integer.parseInt(request.getParameter("grade_b"));
                int gc = Integer.parseInt(request.getParameter("grade_c"));
                int gd = Integer.parseInt(request.getParameter("grade_d"));

                String sql = "INSERT INTO result_configs (class_id, theory_max, theory_pass, internal_max, internal_pass, viva_max, viva_pass, grade_a, grade_b, grade_c, grade_d) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                             "ON DUPLICATE KEY UPDATE theory_max=?, theory_pass=?, internal_max=?, internal_pass=?, viva_max=?, viva_pass=?, grade_a=?, grade_b=?, grade_c=?, grade_d=?";
                
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, classId);
                    ps.setInt(2, tm); ps.setInt(3, tp);
                    ps.setInt(4, im); ps.setInt(5, ip);
                    ps.setInt(6, vm); ps.setInt(7, vp);
                    ps.setInt(8, ga); ps.setInt(9, gb);
                    ps.setInt(10, gc); ps.setInt(11, gd);
                    
                    ps.setInt(12, tm); ps.setInt(13, tp);
                    ps.setInt(14, im); ps.setInt(15, ip);
                    ps.setInt(16, vm); ps.setInt(17, vp);
                    ps.setInt(18, ga); ps.setInt(19, gb);
                    ps.setInt(20, gc); ps.setInt(21, gd);
                    ps.executeUpdate();
                }
            } else if ("SAVE_MARKS".equals(action)) {
                int classId = Integer.parseInt(request.getParameter("class_id"));
                int studentId = Integer.parseInt(request.getParameter("student_id"));
                int tMarks = Integer.parseInt(request.getParameter("theory_marks"));
                int iMarks = Integer.parseInt(request.getParameter("internal_marks"));
                int vMarks = Integer.parseInt(request.getParameter("viva_marks"));
                
                // Fetch config to calculate grade and status
                int tp=0, ip=0, vp=0, tm=1, im=0, vm=0, ga=90, gb=75, gc=60, gd=40;
                String confSql = "SELECT * FROM result_configs WHERE class_id = ?";
                try (PreparedStatement psC = conn.prepareStatement(confSql)) {
                    psC.setInt(1, classId);
                    try (ResultSet rsC = psC.executeQuery()) {
                        if (rsC.next()) {
                            tm = rsC.getInt("theory_max"); tp = rsC.getInt("theory_pass");
                            im = rsC.getInt("internal_max"); ip = rsC.getInt("internal_pass");
                            vm = rsC.getInt("viva_max"); vp = rsC.getInt("viva_pass");
                            ga = rsC.getInt("grade_a"); gb = rsC.getInt("grade_b");
                            gc = rsC.getInt("grade_c"); gd = rsC.getInt("grade_d");
                        }
                    }
                }
                
                int totalMarks = tMarks + iMarks + vMarks;
                int totalMax = tm + im + vm;
                if (totalMax == 0) totalMax = 1; // Prevent division by zero
                double percent = ((double)totalMarks / totalMax) * 100;
                
                String status = (tMarks >= tp && iMarks >= ip && vMarks >= vp) ? "PASS" : "FAIL";
                String grade = "F";
                if (status.equals("PASS")) {
                    if (percent >= ga) grade = "A";
                    else if (percent >= gb) grade = "B";
                    else if (percent >= gc) grade = "C";
                    else if (percent >= gd) grade = "D";
                    else grade = "E";
                }
                
                String sql = "INSERT INTO student_results (class_id, student_id, theory_marks, internal_marks, viva_marks, total_marks, grade, status) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                             "ON DUPLICATE KEY UPDATE theory_marks=?, internal_marks=?, viva_marks=?, total_marks=?, grade=?, status=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, classId); ps.setInt(2, studentId);
                    ps.setInt(3, tMarks); ps.setInt(4, iMarks); ps.setInt(5, vMarks);
                    ps.setInt(6, totalMarks); ps.setString(7, grade); ps.setString(8, status);
                    
                    ps.setInt(9, tMarks); ps.setInt(10, iMarks); ps.setInt(11, vMarks);
                    ps.setInt(12, totalMarks); ps.setString(13, grade); ps.setString(14, status);
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
