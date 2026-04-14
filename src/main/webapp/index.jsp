<%@ page import="com.gurukul.models.UserProfile" %>
<% 
    UserProfile userProfile = (UserProfile) session.getAttribute("user");
    if (userProfile != null) { 
        if ("Teacher".equalsIgnoreCase(userProfile.getRole())) {
            response.sendRedirect("teacherDashboard.jsp");
        } else {
            response.sendRedirect("dashboard.jsp");
        }
        return; 
    } 
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GURUKUL_ILE / PRIMARY_GATEWAY</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    @keyframes blink { 0%, 50%, 100% { opacity: 1; } 25%, 75% { opacity: 0; } }
    #cursor { animation: blink 1.2s infinite; margin-left: 4px; }
    .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
  </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-black overflow-x-hidden">
  <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>
  <canvas id="particleCanvas" class="fixed inset-0 pointer-events-none z-[1] opacity-40"></canvas>

  <div class="relative z-10 min-h-screen flex flex-col">
    <div class="border-b border-black/5 px-6 py-2 flex justify-between text-[9px] text-gray-400 uppercase tracking-[0.3em] font-bold bg-white/80 backdrop-blur-md">
        <span>GURUKUL_ILE // SYSTEM_GATEWAY_V5</span>
        <span class="hidden md:inline italic">"Knowledge is power. Information is liberating."</span>
        <span>AUTH_STATUS: UNSECURED</span>
    </div>

    <nav class="border-b border-black/5 px-6 py-4 flex justify-between items-center bg-white/50 backdrop-blur-md">
      <h1 class="font-[Orbitron] tracking-[0.4em] text-lg font-black text-gray-900 uppercase">Gurukul</h1>
      <div class="flex items-center gap-8">
          <div class="hidden md:flex gap-6 text-[9px] font-bold text-gray-400 uppercase tracking-[0.2em]">
            <span>LMS_CORE</span>
            <span>/</span>
            <span>NEURAL_NET</span>
            <span>/</span>
            <span>2026</span>
          </div>
          <a href="login.jsp" class="bg-red-500 text-white px-8 py-2 text-[10px] font-[Orbitron] tracking-[0.2em] font-bold hover:bg-black transition-all shadow-[0_10px_30px_rgba(255,51,51,0.2)]">
            AUTHORIZE
          </a>
      </div>
    </nav>

    <main class="flex-grow flex flex-col pt-20">
      <section class="px-6 md:px-20 mb-20">
        <p class="text-[10px] text-red-500 font-black tracking-[0.6em] mb-4 uppercase">
          ✱ NEURAL_EDUCATION_INTERFACE
        </p>
        <h1 class="font-[Orbitron] text-6xl md:text-9xl tracking-tighter font-black text-gray-900 leading-none">
          <span id="heroText"></span><span id="cursor" class="text-red-500">|</span>
        </h1>
        <div class="grid md:grid-cols-2 mt-12 gap-12 items-end">
            <div class="border-l-4 border-black pl-8 py-4">
                <p class="text-2xl font-medium text-gray-800 mb-4 leading-tight uppercase tracking-tight">The ultimate Command Center for modern academic excellence.</p>
                <p class="text-gray-400 text-xs leading-loose max-w-md font-bold uppercase tracking-widest italic opacity-60">Integrated Learning Environment optimized for precision Briefings and centralized Student Provisioning.</p>
            </div>
            <div class="bg-black text-white p-12 relative overflow-hidden group">
                <div class="absolute top-0 right-0 p-4 text-[9px] font-mono opacity-20">STATUS_ACTIVE</div>
                <h3 class="font-[Orbitron] text-xl tracking-[0.3em] font-black italic relative z-10">LEARN / SYNC / EVOLVE</h3>
                <div class="mt-4 w-20 h-1 bg-red-500 group-hover:w-full transition-all duration-700"></div>
            </div>
        </div>
      </section>

      <section class="grid grid-cols-1 md:grid-cols-3 border-y border-black/5 bg-white/30 backdrop-blur-sm">
        <div class="p-10 border-r border-black/5 group hover:bg-white transition-all">
            <span class="text-[8px] text-red-500 font-bold tracking-widest block mb-4 uppercase">MODULE_01</span>
            <h3 class="font-[Orbitron] text-xs font-black uppercase mb-4 tracking-widest">Tactical_Dashboard</h3>
            <p class="text-[10px] text-gray-400 font-bold uppercase leading-relaxed tracking-widest opacity-60">Real-time signal monitoring and academic data relays for both units and commanders.</p>
        </div>
        <div class="p-10 border-r border-black/5 group hover:bg-white transition-all">
            <span class="text-[8px] text-red-500 font-bold tracking-widest block mb-4 uppercase">MODULE_02</span>
            <h3 class="font-[Orbitron] text-xs font-black uppercase mb-4 tracking-widest">Signal_Briefings</h3>
            <p class="text-[10px] text-gray-400 font-bold uppercase leading-relaxed tracking-widest opacity-60">Encrypted live-stream corridors for instant tactical knowledge transfer.</p>
        </div>
        <div class="p-10 group hover:bg-white transition-all">
            <span class="text-[8px] text-red-500 font-bold tracking-widest block mb-4 uppercase">MODULE_03</span>
            <h3 class="font-[Orbitron] text-xs font-black uppercase mb-4 tracking-widest">Auth_Registry</h3>
            <p class="text-[10px] text-gray-400 font-bold uppercase leading-relaxed tracking-widest opacity-60">Secure identity management with high-density student provisioning protocols.</p>
        </div>
      </section>
    </main>

    <footer class="p-8 border-t border-black/5 text-[9px] text-gray-400 font-bold uppercase tracking-[0.4em] flex justify-between bg-white/50 backdrop-blur-md">
      <span>© 2026 GURUKUL_SYSTEMS_CORE</span>
      <div class="flex gap-8">
        <span>S_PANDIT</span>
        <span>S_RANE</span>
        <span>S_PAWAR</span>
      </div>
    </footer>
  </div>

  <script>
    const text = "GURUKUL";
    let index = 0;
    function type() {
      if (index < text.length) {
        document.getElementById("heroText").innerHTML += text.charAt(index++);
        setTimeout(type, 150);
      } else {
        setTimeout(() => { document.getElementById("cursor").style.display = "none"; }, 2000);
      }
    }
    window.onload = type;

    const canvas = document.getElementById("particleCanvas");
    const ctx = canvas.getContext("2d");
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    class P {
      constructor(x, y) { this.bx = x; this.by = y; this.x = x; this.y = y; this.vx = 0; this.vy = 0; }
      update() {
        let dx = this.x - mx, dy = this.y - my, d = Math.sqrt(dx*dx+dy*dy);
        if (d < 80) { let f = (80-d)/80, a = Math.atan2(dy, dx); this.vx += Math.cos(a)*f*2; this.vy += Math.sin(a)*f*2; }
        this.vx += (this.bx-this.x)*0.05; this.vy += (this.by-this.y)*0.05;
        this.vx *= 0.85; this.vy *= 0.85; this.x += this.vx; this.y += this.vy;
      }
      draw() { ctx.fillStyle = "rgba(0,0,0,0.15)"; ctx.fillRect(this.x, this.y, 2, 2); }
    }
    let ps = [], mx = -100, my = -100;
    window.addEventListener("mousemove", (e) => { mx = e.clientX; my = e.clientY; });
    for (let x = 0; x < canvas.width; x += 40) for (let y = 0; y < canvas.height; y += 40) ps.push(new P(x, y));
    function anim() {
      ctx.clearRect(0,0,canvas.width,canvas.height);
      ps.forEach(p => { p.update(); p.draw(); });
      requestAnimationFrame(anim);
    }
    anim();
  </script>
</body>
</html>