package com.gurukul;

import jakarta.servlet.ServletContext;
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
        userProfileBean user = (session != null) ? (userProfileBean) session.getAttribute("user") : null;

        if (user == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        ServletContext context = getServletContext();
        String DB = context.getInitParameter("DB_URL");
        String DB_User = context.getInitParameter("DB_USERNAME");
        String DB_pwd = context.getInitParameter("DB_PWD");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://" + DB + ":3306/gurukul", DB_User, DB_pwd)) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            if ("ADD_NOTICE".equals(action)) {
                String heading = request.getParameter("heading");
                String body = request.getParameter("body");
                String author = user.getFullName(); // From session used as 'whom'
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
            } else if ("DELETE_STUDENT".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM users WHERE id = ? AND role = 'Student'";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            }

            response.sendRedirect("teacherDashboard.jsp?status=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("teacherDashboard.jsp?status=error&msg=" + e.getMessage());
        }
    }
}
