import jakarta.servlet.ServletException;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/auth_activity")
public class auth_activity extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection conn = null;
        response.setContentType("text/html");
        PrintWriter p = response.getWriter();
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        HttpSession session = request.getSession();

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                    "jdbc:mysql://192.168.0.105:3306/GURUKUL",
                    "root",
                    "Admin"
            );

            String query = "SELECT * FROM STUDENT_LOGIN WHERE USERNAME=? AND PASSWORD=?";

            PreparedStatement ps = conn.prepareStatement(query);

            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                System.out.println("Login Success");
                session.setAttribute("username", username);
                session.setAttribute("password", password);
                response.sendRedirect("./dashboard.html");

            } else {

                System.out.println("Login Failed");
                response.getWriter().println("Invalid Username or Password");

            }

        } catch (Exception e) {

            System.out.println("Error: " + e);

        }
    }
}