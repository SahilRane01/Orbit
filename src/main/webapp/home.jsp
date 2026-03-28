<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>

  <meta charset="UTF-8">
  <title>Home - Gurukul</title>

  <script src="https://cdn.tailwindcss.com"></script>

  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
</head>

<body class="font-[Inter] bg-[#f5f5f5] text-black relative">

<!-- GRID -->
<div class="absolute inset-0 pointer-events-none"
  style="
    background-image:
      linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px),
      linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px);
    background-size: 40px 40px;
    z-index: 0;">
</div>

<div class="relative z-10">

  <!-- NAVBAR -->
  <nav class="border-b border-gray-300 px-6 py-3 flex justify-between items-center">

    <h1 class="font-[Orbitron] tracking-widest text-lg">
      GURUKUL
    </h1>

    <div class="text-sm">
      Welcome, <b>${user.userName}</b>
    </div>

  </nav>

  <!-- MAIN -->
  <div class="p-6">

    <!-- TITLE -->
    <h1 class="font-[Orbitron] text-4xl mb-6">
      HOME
    </h1>

    <!-- GRID -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">

      <!-- DASHBOARD -->
      <a href="dashboard.jsp" class="border border-gray-300 p-6 hover:bg-gray-100 transition">
        <h2 class="text-lg mb-2">Dashboard</h2>
        <p class="text-gray-600 text-sm">View full system overview</p>
      </a>

      <!-- ATTENDANCE -->
      <div class="border border-gray-300 p-6 hover:bg-gray-100 transition">
        <h2 class="text-lg mb-2">Attendance</h2>
        <p class="text-gray-600 text-sm">Track your attendance</p>
      </div>

      <!-- COURSES -->
      <div class="border border-gray-300 p-6 hover:bg-gray-100 transition">
        <h2 class="text-lg mb-2">Courses</h2>
        <p class="text-gray-600 text-sm">View enrolled courses</p>
      </div>

      <!-- SOCIAL -->
      <div class="border border-gray-300 p-6 hover:bg-gray-100 transition">
        <h2 class="text-lg mb-2">Social</h2>
        <p class="text-gray-600 text-sm">Connect with peers</p>
      </div>

      <!-- PROFILE -->
      <div class="border border-gray-300 p-6 hover:bg-gray-100 transition">
        <h2 class="text-lg mb-2">Profile</h2>
        <p class="text-gray-600 text-sm">Manage your account</p>
      </div>

      <!-- LOGOUT -->
      <a href="LogoutServlet" class="border border-gray-300 p-6 hover:bg-red-100 transition">
        <h2 class="text-lg mb-2">Logout</h2>
        <p class="text-gray-600 text-sm">Sign out of your account</p>
      </a>

    </div>

  </div>

</div>

</body>
</html>