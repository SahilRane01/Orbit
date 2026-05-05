package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/quizAction")
public class QuizController extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserProfile user = (UserProfile) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            
            if ("CREATE_QUIZ".equals(action)) {
                if (!"Teacher".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("dashboard.jsp");
                    return;
                }
                
                int classId = Integer.parseInt(request.getParameter("class_id"));
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int duration = Integer.parseInt(request.getParameter("duration"));
                
                // Insert Quiz
                String insertQuiz = "INSERT INTO quizzes (class_id, title, description, duration_minutes) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertQuiz, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, classId);
                    ps.setString(2, title);
                    ps.setString(3, description);
                    ps.setInt(4, duration);
                    ps.executeUpdate();
                    
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            int quizId = rs.getInt(1);
                            
                            // Insert Questions
                            int questionCount = Integer.parseInt(request.getParameter("questionCount"));
                            String insertQ = "INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement psQ = conn.prepareStatement(insertQ)) {
                                for (int i = 1; i <= questionCount; i++) {
                                    String qText = request.getParameter("q_text_" + i);
                                    if (qText != null && !qText.trim().isEmpty()) {
                                        psQ.setInt(1, quizId);
                                        psQ.setString(2, qText);
                                        psQ.setString(3, request.getParameter("q_opt_a_" + i));
                                        psQ.setString(4, request.getParameter("q_opt_b_" + i));
                                        psQ.setString(5, request.getParameter("q_opt_c_" + i));
                                        psQ.setString(6, request.getParameter("q_opt_d_" + i));
                                        psQ.setString(7, request.getParameter("q_correct_" + i));
                                        psQ.setInt(8, Integer.parseInt(request.getParameter("q_marks_" + i)));
                                        psQ.addBatch();
                                    }
                                }
                                psQ.executeBatch();
                            }
                        }
                    }
                }
                response.sendRedirect("class_detail.jsp?id=" + classId + "&status=success&tab=quizzes");
                
            } else if ("SUBMIT_QUIZ".equals(action)) {
                if (!"Student".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("teacherDashboard.jsp");
                    return;
                }
                
                int quizId = Integer.parseInt(request.getParameter("quiz_id"));
                int classId = Integer.parseInt(request.getParameter("class_id"));
                
                // Check if already submitted
                String checkSql = "SELECT id FROM quiz_submissions WHERE quiz_id = ? AND student_id = ?";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, quizId);
                    psCheck.setInt(2, user.getId());
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next()) {
                            // Already submitted
                            response.sendRedirect("quizResult.jsp?id=" + quizId + "&class_id=" + classId);
                            return;
                        }
                    }
                }
                
                // Retrieve questions to calculate score
                String qSql = "SELECT id, correct_option, marks FROM quiz_questions WHERE quiz_id = ?";
                int totalScore = 0;
                int totalMarks = 0;
                List<Object[]> answers = new ArrayList<>(); // To store: {questionId, selectedOption, correctOption, marks}
                
                try (PreparedStatement psQ = conn.prepareStatement(qSql)) {
                    psQ.setInt(1, quizId);
                    try (ResultSet rsQ = psQ.executeQuery()) {
                        while (rsQ.next()) {
                            int qId = rsQ.getInt("id");
                            String correctOpt = rsQ.getString("correct_option");
                            int marks = rsQ.getInt("marks");
                            totalMarks += marks;
                            
                            String selectedOpt = request.getParameter("q_" + qId);
                            if (selectedOpt != null && selectedOpt.equalsIgnoreCase(correctOpt)) {
                                totalScore += marks;
                            }
                            answers.add(new Object[]{qId, selectedOpt});
                        }
                    }
                }
                
                // Insert submission
                String insertSub = "INSERT INTO quiz_submissions (quiz_id, student_id, score, total_marks) VALUES (?, ?, ?, ?)";
                try (PreparedStatement psSub = conn.prepareStatement(insertSub, Statement.RETURN_GENERATED_KEYS)) {
                    psSub.setInt(1, quizId);
                    psSub.setInt(2, user.getId());
                    psSub.setInt(3, totalScore);
                    psSub.setInt(4, totalMarks);
                    psSub.executeUpdate();
                    
                    try (ResultSet rsSub = psSub.getGeneratedKeys()) {
                        if (rsSub.next()) {
                            int subId = rsSub.getInt(1);
                            
                            // Insert answers
                            String insertAns = "INSERT INTO quiz_answers (submission_id, question_id, selected_option) VALUES (?, ?, ?)";
                            try (PreparedStatement psAns = conn.prepareStatement(insertAns)) {
                                for (Object[] ans : answers) {
                                    psAns.setInt(1, subId);
                                    psAns.setInt(2, (Integer) ans[0]);
                                    psAns.setString(3, (String) ans[1]);
                                    psAns.addBatch();
                                }
                                psAns.executeBatch();
                            }
                        }
                    }
                }
                response.sendRedirect("quizResult.jsp?id=" + quizId + "&class_id=" + classId + "&status=submitted");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("classes.jsp?status=error");
        }
    }
}
