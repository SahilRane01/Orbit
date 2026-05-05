package com.gurukul.controllers;

import com.gurukul.models.UserProfile;
import com.gurukul.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import jakarta.servlet.annotation.MultipartConfig;

@WebServlet("/teacherAction")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 20)
public class TeacherController extends HttpServlet {
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
            if ("ADD_NOTICE".equals(action)) {
                String heading = request.getParameter("heading");
                String body = request.getParameter("body");
                String author = user.getFullName();
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
            } else if ("ADD_STUDENT".equals(action)) {
                String fullname = request.getParameter("full_name");
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String course = request.getParameter("course");
                String batch = request.getParameter("batch");
                String specialization = request.getParameter("specialization");
                String password = request.getParameter("password");

                String sql = "INSERT INTO users (full_name, username, email, phone, role, course, batch, specialization, password) VALUES (?, ?, ?, ?, 'Student', ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, fullname);
                    ps.setString(2, username);
                    ps.setString(3, email);
                    ps.setString(4, phone);
                    ps.setString(5, course);
                    ps.setString(6, batch);
                    ps.setString(7, specialization);
                    ps.setString(8, password);
                    ps.executeUpdate();
                }
            } else if ("UPDATE_STUDENT".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String fullname = request.getParameter("full_name");
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String course = request.getParameter("course");
                String batch = request.getParameter("batch");
                String specialization = request.getParameter("specialization");
                String password = request.getParameter("password");

                String sql = "UPDATE users SET full_name = ?, username = ?, email = ?, phone = ?, course = ?, batch = ?, specialization = ?" + 
                             (password != null && !password.isEmpty() ? ", password = ?" : "") + 
                             " WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, fullname);
                    ps.setString(2, username);
                    ps.setString(3, email);
                    ps.setString(4, phone);
                    ps.setString(5, course);
                    ps.setString(6, batch);
                    ps.setString(7, specialization);
                    if (password != null && !password.isEmpty()) {
                        ps.setString(8, password);
                        ps.setInt(9, id);
                    } else {
                        ps.setInt(8, id);
                    }
                    ps.executeUpdate();
                }
            } else if ("BULK_UPLOAD_STUDENTS".equals(action)) {
                Part filePart = request.getPart("file");
                if (filePart != null) {
                    try (InputStream fileContent = filePart.getInputStream();
                         BufferedReader reader = new BufferedReader(new InputStreamReader(fileContent))) {
                        
                        String line;
                        boolean isHeader = true;
                        String sql = "INSERT INTO users (full_name, username, email, phone, role, course, batch, specialization, password) VALUES (?, ?, ?, ?, 'Student', ?, ?, ?, ?)";
                        
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            while ((line = reader.readLine()) != null) {
                                if (isHeader) {
                                    isHeader = false;
                                    continue; // Skip header
                                }
                                
                                String[] data = line.split(",", -1);
                                if (data.length >= 8) {
                                    ps.setString(1, data[0].trim()); // full_name
                                    ps.setString(2, data[1].trim()); // username
                                    ps.setString(3, data[2].trim()); // email
                                    ps.setString(4, data[3].trim()); // phone
                                    ps.setString(5, data[4].trim()); // course
                                    ps.setString(6, data[5].trim()); // batch
                                    ps.setString(7, data[6].trim()); // specialization
                                    ps.setString(8, data[7].trim()); // password
                                    ps.addBatch();
                                }
                            }
                            ps.executeBatch();
                        }
                    }
                }
            }
            
            response.sendRedirect(source + "?status=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(source + "?status=error&msg=" + e.getMessage());
        }
    }
}
