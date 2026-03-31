package com.gurukul;


import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
@WebServlet("/registration")
public class registration extends HttpServlet {
	private static final long serialVersionUID = 1L;
 
	protected void doGet(HttpServletRequest request, HttpServletResponse response) {
		Connection conn = null;
		PreparedStatement  psmt = null;
		try{
		PrintWriter p = response.getWriter() ;
		ServletContext context = getServletContext();

		String DB = context.getInitParameter("DB_URL");
        String DB_User = context.getInitParameter("DB_USERNAME");
        String DB_pwd = context.getInitParameter("DB_PWD");
		
		String fullname,username,email,role,course,batch,specialization,password,c_password,phone;
			try {
				Class.forName("com.mysql.cj.jdbc.Driver");
				conn = DriverManager.getConnection(
	                    "jdbc:mysql://"+DB+":3306/gurukul",
	                    DB_User,
	                    DB_pwd
	            );
				String query = "CREATE TABLE IF NOT EXISTS users (\r\n"
						+ "    id INT AUTO_INCREMENT PRIMARY KEY,\r\n"
						+ "    full_name VARCHAR(100) NOT NULL,\r\n"
						+ "    username VARCHAR(50) NOT NULL UNIQUE,\r\n"
						+ "    email VARCHAR(100) NOT NULL UNIQUE,\r\n"
						+ "    phone VARCHAR(15),\r\n"
						+ "    role VARCHAR(20),\r\n"
						+ "    course VARCHAR(100),\r\n"
						+ "    batch VARCHAR(50),\r\n"
						+ "    specialization VARCHAR(100),\r\n"
						+ "    password VARCHAR(255) NOT NULL,\r\n"
						+ "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\r\n"
						+ ");";
				Statement user = conn.createStatement();
				user.executeUpdate(query);
				
			}catch(Exception e) {
				System.out.print("Error"+e);
				response.setContentType("text/html");
				p.println("Error: ");
				p.println(e);
			}
			try {
				fullname = request.getParameter("full_name");
				username = request.getParameter("username");
				email = request.getParameter("email");
				role = request.getParameter("role");
				course = request.getParameter("course");
				batch = request.getParameter("batch");
				specialization = request.getParameter("specialization");
				password = request.getParameter("password");;
				c_password = request.getParameter("cpassword");
				phone = request.getParameter("phone");
				if (password.equals(c_password)) {
					psmt = conn.prepareStatement(
							"INSERT INTO users"
							+ "(full_name, username, email, phone, role, course, batch, specialization, password) "
							+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
							);
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
				}else {
					response.setContentType("text/html");
					p.println("Password MissMatch");	
				}
				
				
			} catch (SQLException e1) {
				p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
				p.println("<h3>Registration Database Error</h3><p>" + e1.getMessage() + "</p>");
				p.println("</div>");
				e1.printStackTrace();
			} catch (Exception e1) {
				p.println("<div style='color:red; font-family:sans-serif; padding:20px; border:1px solid red;'>");
				p.println("<h3>Registration System Error</h3><p>" + e1.toString() + "</p>");
				p.println("</div>");
				e1.printStackTrace();
			}
		} catch (Exception E) {
			E.printStackTrace();
		}
			

			
		
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
