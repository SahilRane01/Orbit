package com.gurukul.controllers;

import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/registration")
public class RegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter p = response.getWriter();

        String fullname = request.getParameter("full_name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        String course = request.getParameter("course");
        String batch = request.getParameter("batch");
        String specialization = request.getParameter("specialization");
        String password = request.getParameter("password");
        String c_password = request.getParameter("cpassword");
        String phone = request.getParameter("phone");

        if (!password.equals(c_password)) {
            p.println("<h3>Password Mismatch</h3>");
            return;
        }

        try (Connection conn = DBConnection.getConnection(getServletContext())) {
            // Ensure table exists
            String createTableSql = "CREATE TABLE IF NOT EXISTS users ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "full_name VARCHAR(100) NOT NULL, "
                    + "username VARCHAR(50) NOT NULL UNIQUE, "
                    + "email VARCHAR(100) NOT NULL UNIQUE, "
                    + "phone VARCHAR(15), "
                    + "role VARCHAR(20), "
                    + "course VARCHAR(100), "
                    + "batch VARCHAR(50), "
                    + "specialization VARCHAR(100), "
                    + "password VARCHAR(255) NOT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ");";
            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(createTableSql);
            }

            String insertSql = "INSERT INTO users (full_name, username, email, phone, role, course, batch, specialization, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement psmt = conn.prepareStatement(insertSql)) {
                psmt.setString(1, fullname);
                psmt.setString(2, username);
                psmt.setString(3, email);
                psmt.setString(4, phone);
                psmt.setString(5, role);
                psmt.setString(6, course);
                psmt.setString(7, batch);
                psmt.setString(8, specialization);
                psmt.setString(9, password);
                psmt.executeUpdate();
                
                response.sendRedirect("login.jsp?status=registered");
            }
        } catch (Exception e) {
            p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
            p.println("<h3>Registration Error</h3><p>" + e.toString() + "</p>");
            p.println("</div>");
            e.printStackTrace();
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
