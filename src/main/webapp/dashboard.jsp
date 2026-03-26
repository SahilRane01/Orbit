<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Dashboard - Gurukul</title>

  <script src="https://cdn.tailwindcss.com"></script>

  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
</head>

<body class="font-[Inter] bg-[#f5f5f5] text-black">

  <!-- NAVBAR -->
  <nav class="border-b border-gray-300 px-6 py-3 flex justify-between items-center bg-white">
    <h1 class="font-[Orbitron] tracking-widest text-lg">GURUKUL</h1>

    <div class="text-sm">
      Welcome, <b>Student</b>
    </div>
  </nav>

  <!-- MAIN -->
  <div class="p-6">

    <h1 class="font-[Orbitron] text-3xl mb-6">DASHBOARD</h1>

    <!-- GRID -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">

      <!-- CARD 1 -->
      <div class="border border-gray-300 p-6 bg-white">
        <h2 class="text-lg mb-2">Attendance</h2>
        <p class="text-gray-600">View your attendance records.</p>
      </div>

      <!-- CARD 2 -->
      <div class="border border-gray-300 p-6 bg-white">
        <h2 class="text-lg mb-2">Academic Records</h2>
        <p class="text-gray-600">Check your performance.</p>
      </div>

      <!-- CARD 3 -->
      <div class="border border-gray-300 p-6 bg-white">
        <h2 class="text-lg mb-2">Courses</h2>
        <p class="text-gray-600">View enrolled courses.</p>
      </div>

      <!-- CARD 4 -->
      <div class="border border-gray-300 p-6 bg-white">
        <h2 class="text-lg mb-2">Social Feed</h2>
        <p class="text-gray-600">Interact with peers.</p>
      </div>

    </div>

  </div>

</body>
</html>