

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
		
		
		String fullname,username,email,role,course,batch,specialization,password,c_password;
		Long phone;
			try {
				Class.forName("com.mysql.cj.jdbc.Driver");
				conn = DriverManager.getConnection(
						"jdbc:mysql://localhost:3306/gurukul",
						"root",
						"Shriyash@11"
						);
				
				
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
				phone = Long.parseLong(request.getParameter("phone"));
				if (password.equals(c_password)) {
					psmt = conn.prepareStatement(
							"INSERT INTO users"
							+ "(full_name, username, email, phone, role, course, batch, specialization, password) "
							+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
							);
					psmt.setString(1, fullname);
					psmt.setString(2, username);
					psmt.setString(3, email);
					psmt.setLong(4, phone);
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
				
				
			}catch(Exception e1) {
				System.out.print("Error"+e1);
				response.setContentType("text/html");
				p.println("Error: ");
				p.println(e1);
			}
		}catch(Exception E) {
			
		}
			

			
		
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
