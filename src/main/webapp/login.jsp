<!DOCTYPE html>
<html lang="en">
<head>
 
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

  <div class="relative z-10 min-h-screen flex flex-col">
    <!-- MICRO HEADER -->
    <div class="border-b border-gray-300 px-6 py-2 flex justify-between text-xs text-gray-500">
      <span>INDEPENDENT LEARNING ENVIRONMENT</span>
      <span>"THE ONLY WAY TO DO GREAT WORK IS TO LOVE WHAT YOU DO." - STEVE JOBS</span>
      <span>GURUKUL</span>
    </div>

    <!-- NAVBAR -->
    <nav class="border-b border-gray-300 px-6 py-3 flex justify-between items-center bg-[#f5f5f5]">
      <h1 class="font-[Orbitron] tracking-widest text-lg">
        <a href="index.html">GURUKUL</a>
      </h1>

      <div class="hidden md:flex gap-4 text-sm text-gray-600 uppercase tracking-widest">
        <span>LMS</span>
        <span>/</span>
        <span>AUTH</span>
        <span>/</span>
        <span>2026</span>
      </div>

      <a href="index.html" class="border border-black px-4 py-1 text-sm hover:bg-black hover:text-white transition uppercase">
        Back to Home
      </a>
    </nav>

    <!-- CENTER WRAPPER -->
    <div class="flex-grow flex items-center justify-center py-10 relative">
      <!-- DECORATIVE ELEMENTS -->
      <div class="absolute top-10 left-10 text-red-500 text-2xl">*</div>
      <div class="absolute bottom-10 right-10 text-gray-300 text-4xl font-[Orbitron]">LOGIN</div>

    <!-- MAIN CARD -->
    <div class="relative z-10 w-full max-w-lg border border-gray-300 bg-white">

      <!-- HEADER -->
      <div class="border-b border-gray-300 p-8 text-center bg-[#f5f5f5]">
        <p class="text-[10px] text-gray-400 tracking-[0.2em] mb-2 uppercase">Welcome to the Platform</p>
        <h1 class="font-[Orbitron] tracking-[0.3em] text-2xl uppercase">
          GURUKUL
        </h1>
        <div class="mt-4 flex justify-center">
             <div class="h-1 w-12 bg-red-500"></div>
        </div>
      </div>

      <!-- TOGGLE -->
      <div class="flex border-b border-gray-300 font-[Orbitron] tracking-widest text-xs">
        <button id="loginToggle" onclick="showLogin()" class="w-1/2 p-4 border-r border-gray-300 bg-black text-white transition-all duration-300">
          LOGIN
        </button>
        <button id="registerToggle" onclick="showRegister()" class="w-1/2 p-4 hover:bg-gray-100 transition-all duration-300">
          REGISTER
        </button>
      </div>

      <!-- SCROLLABLE AREA -->
      <div class="max-h-[80vh] overflow-y-auto">

        <div id="loginForm" class="p-8">
          <form action="login" method="post" class="space-y-6">
            <div>
              <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Username / ID</label>
              <input type="text" name="username" placeholder="ENTER YOUR USERNAME"
                class="w-full border border-gray-300 p-3 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
            </div>

            <div>
              <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Secure Password</label>
              <input type="password" name="password" placeholder="ENTER YOUR SECURE PASSWORD"
                class="w-full border border-gray-300 p-3 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
            </div>

            <button type="submit"
              class="w-full bg-red-500 text-white py-4 font-[Orbitron] tracking-[0.2em] text-sm hover:bg-red-600 transition-all transform hover:scale-[1.01] active:scale-[0.99]">
              AUTHORIZE
            </button>
          </form>
        </div>

        <div id="registerForm" class="p-8 hidden">
          <form action="registration" method="post" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Full Name</label>
                <input type="text" name="full_name" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Username</label>
                <input type="text" name="username" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Email Address</label>
                <input type="email" name="email" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Phone Number</label>
                <input type="text" name="phone" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
            </div>

            <div>
              <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Designated Role</label>
              <select name="role" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
                <option>Student</option>
                <option>Teacher</option>
                <option>Admin</option>
              </select>
            </div>

            <div class="grid grid-cols-3 gap-2">
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Course</label>
                <input type="text" name="course" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Batch</label>
                <input type="text" name="batch" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Spec.</label>
                <input type="text" name="specialization" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Password</label>
                <input type="password" name="password" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
              <div>
                <label class="block text-[10px] text-gray-400 tracking-widest uppercase mb-1">Confirm</label>
                <input type="password" name="cpassword" class="w-full border border-gray-300 p-2 text-sm focus:outline-none focus:border-red-500 transition-colors bg-gray-50">
              </div>
            </div>

            <button type="submit"
              class="w-full bg-black text-white py-4 font-[Orbitron] tracking-[0.2em] text-sm hover:bg-gray-900 transition-all transform hover:scale-[1.01] active:scale-[0.99]">
              INITIALIZE ACCOUNT
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
      
      document.getElementById("loginToggle").classList.add("bg-black", "text-white");
      document.getElementById("loginToggle").classList.remove("hover:bg-gray-100");
      
      document.getElementById("registerToggle").classList.remove("bg-black", "text-white");
      document.getElementById("registerToggle").classList.add("hover:bg-gray-100");
    }

    function showRegister() {
      document.getElementById("registerForm").classList.remove("hidden");
      document.getElementById("loginForm").classList.add("hidden");

      document.getElementById("registerToggle").classList.add("bg-black", "text-white");
      document.getElementById("registerToggle").classList.remove("hover:bg-gray-100");
      
      document.getElementById("loginToggle").classList.remove("bg-black", "text-white");
      document.getElementById("loginToggle").classList.add("hover:bg-gray-100");
    }
  </script>

    </div> <!-- End flex-grow centered area -->

    <!-- FOOTER -->
    <footer class="p-6 border-t border-gray-300 text-sm text-gray-600 flex justify-between">
      <span>© 2026 Gurukul ILE</span>
      <span>ShriyashP | SahilR | SandeshP</span>
    </footer>

  </div> <!-- End relative z-10 outer div -->

</body>
</html>