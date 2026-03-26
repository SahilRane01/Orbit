<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login - Gurukul</title>

  <!-- Tailwind -->
  <script src="https://cdn.tailwindcss.com"></script>

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
</head>

<body class="font-[Inter] bg-[#f5f5f5] text-black flex items-center justify-center h-screen relative">

  <!-- GRID BACKGROUND -->
  <div class="absolute inset-0 pointer-events-none"
    style="
      background-image:
        linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px),
        linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px);
      background-size: 40px 40px;
      z-index: 0;">
  </div>

  <!-- MAIN CONTAINER -->
  <div class="relative z-10 w-full max-w-md border border-gray-300 bg-white">

    <!-- HEADER -->
    <div class="border-b border-gray-300 p-4 text-center">
      <h1 class="font-[Orbitron] tracking-widest text-xl">
        GURUKUL
      </h1>
    </div>

    <!-- TOGGLE BUTTONS -->
    <div class="flex border-b border-gray-300">
      <button onclick="showLogin()" class="w-1/2 p-3 text-sm border-r border-gray-300">
        LOGIN
      </button>
      <button onclick="showRegister()" class="w-1/2 p-3 text-sm">
        REGISTER
      </button>
    </div>

    <!-- LOGIN FORM -->
<div id="loginForm" class="p-6">

  <form action="LoginServlet" method="post">

    <!-- Username -->
    <div class="mb-4">
      <label class="text-xs text-gray-500">USERNAME</label>
      <input type="text" name="username"
        class="w-full border border-gray-300 p-2 focus:outline-none focus:border-black">
    </div>

    <!-- Password -->
    <div class="mb-4">
      <label class="text-xs text-gray-500">PASSWORD</label>
      <input type="password" name="password"
        class="w-full border border-gray-300 p-2 focus:outline-none focus:border-black">
    </div>

    <!-- Button -->
    <button type="submit"
      class="w-full bg-red-500 text-white py-2 hover:bg-red-600 transition">
      LOGIN
    </button>

  </form>

</div>

  </div>

</body>
</html>
</html>