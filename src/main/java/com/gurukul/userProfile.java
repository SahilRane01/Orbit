package com.gurukul;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/userProfile")
public class userProfile extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		userProfileBean user = (userProfileBean) session.getAttribute("user");

		if (user == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String phone = request.getParameter("ph");

		// Synchronize values with form inputs
		if (name == null || name.trim().isEmpty()) name = user.getFullName();
		if (email == null || email.trim().isEmpty()) email = user.getEmail();
		if (phone == null || phone.trim().isEmpty()) phone = user.getPhone();

		ServletContext context = getServletContext();
		String DB = context.getInitParameter("DB_URL");
		String DB_User = context.getInitParameter("DB_USERNAME");
		String DB_pwd = context.getInitParameter("DB_PWD");

		Connection conn = null;
		PreparedStatement psmt = null;
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			conn = DriverManager.getConnection(
					"jdbc:mysql://" + DB + ":3306/gurukul",
					DB_User,
					DB_pwd
			);

			String sql = "UPDATE users SET full_name=?, email=?, phone=? WHERE id=?";
			psmt = conn.prepareStatement(sql);
			psmt.setString(1, name);
			psmt.setString(2, email);
			psmt.setString(3, phone);
			psmt.setInt(4, user.getId());

			int rows = psmt.executeUpdate();

			if (rows > 0) {
				user.setFullName(name);
				user.setEmail(email);
				user.setPhone(phone);
				session.setAttribute("user", user);
			}

			response.sendRedirect("userProfile.jsp?status=success");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("userProfile.jsp?status=error&msg=" + e.getMessage());
		} finally {
			try {
				if (psmt != null) psmt.close();
				if (conn != null) conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.sendRedirect("userProfile.jsp");
	}
}
