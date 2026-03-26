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

<body class="font-[Inter] bg-[#f5f5f5] text-black relative">

  <!-- GRID BACKGROUND -->
  <div class="absolute inset-0 pointer-events-none"
    style="
      background-image:
        linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px),
        linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px);
      background-size: 40px 40px;
      z-index: 0;">
  </div>

  <!-- CENTER WRAPPER -->
  <div class="min-h-screen flex items-center justify-center py-10">

    <!-- MAIN CARD -->
    <div class="relative z-10 w-full max-w-lg border border-gray-300 bg-white">

      <!-- HEADER -->
      <div class="border-b border-gray-300 p-4 text-center">
        <h1 class="font-[Orbitron] tracking-widest text-xl">
          GURUKUL
        </h1>
      </div>

      <!-- TOGGLE -->
      <div class="flex border-b border-gray-300">
        <button onclick="showLogin()" class="w-1/2 p-3 text-sm border-r border-gray-300 hover:bg-gray-100">
          LOGIN
        </button>
        <button onclick="showRegister()" class="w-1/2 p-3 text-sm hover:bg-gray-100">
          REGISTER
        </button>
      </div>

      <!-- SCROLLABLE AREA -->
      <div class="max-h-[80vh] overflow-y-auto">

        <!-- LOGIN FORM -->
        <div id="loginForm" class="p-6">

          <form action="LoginServlet" method="post">

            <div class="mb-4">
              <label class="text-xs text-gray-500">USERNAME</label>
              <input type="text" name="username"
                class="w-full border border-gray-300 p-2 focus:outline-none focus:border-black">
            </div>

            <div class="mb-4">
              <label class="text-xs text-gray-500">PASSWORD</label>
              <input type="password" name="password"
                class="w-full border border-gray-300 p-2 focus:outline-none focus:border-black">
            </div>

            <button type="submit"
              class="w-full bg-red-500 text-white py-2 hover:bg-red-600 transition">
              LOGIN
            </button>

          </form>

        </div>

        <!-- REGISTER FORM -->
        <div id="registerForm" class="p-6 hidden">

          <form action="RegisterServlet" method="post">

            <div class="mb-3">
              <label class="text-xs text-gray-500">FULL NAME</label>
              <input type="text" name="full_name"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">USERNAME</label>
              <input type="text" name="username"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">EMAIL</label>
              <input type="email" name="email"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">PHONE</label>
              <input type="text" name="phone"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">ROLE</label>
              <select name="role" class="w-full border border-gray-300 p-2">
                <option>Student</option>
                <option>Teacher</option>
                <option>Admin</option>
              </select>
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">COURSE</label>
              <input type="text" name="course"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">BATCH</label>
              <input type="text" name="batch"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-3">
              <label class="text-xs text-gray-500">SPECIALIZATION</label>
              <input type="text" name="specialization"
                class="w-full border border-gray-300 p-2">
            </div>

            <div class="mb-4">
              <label class="text-xs text-gray-500">PASSWORD</label>
              <input type="password" name="password"
                class="w-full border border-gray-300 p-2">
            </div>

            <button type="submit"
              class="w-full bg-red-500 text-white py-2 hover:bg-red-600 transition">
              REGISTER
            </button>

          </form>

        </div>

      </div>

    </div>

  </div>

  <!-- TOGGLE SCRIPT -->
  <script>
    function showLogin() {
      document.getElementById("loginForm").classList.remove("hidden");
      document.getElementById("registerForm").classList.add("hidden");
    }

    function showRegister() {
      document.getElementById("registerForm").classList.remove("hidden");
      document.getElementById("loginForm").classList.add("hidden");
    }
  </script>

</body>
</html>