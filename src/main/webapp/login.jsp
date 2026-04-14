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
    <title>Authorize - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255, 255, 255, 0.8); backdrop-filter: blur(12px); border: 1px solid rgba(0, 0, 0, 0.05); }
        .input-tactical { @apply w-full bg-gray-50 border border-black/5 p-4 text-[11px] font-bold uppercase tracking-widest font-[Orbitron] focus:border-red-500 focus:bg-white outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 min-h-screen flex flex-col overflow-x-hidden">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>
    <canvas id="particleCanvas" class="fixed inset-0 pointer-events-none z-[1] opacity-30"></canvas>

    <!-- TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / AUTH_GATEWAY</span>
        </div>
        <a href="index.jsp" class="hover:text-red-500 transition-colors">TERMINATE_PROCESS</a>
    </div>

    <div class="flex-grow flex items-center justify-center p-6 relative z-10">
        <div class="max-w-md w-full">
            
            <% String status = request.getParameter("status"); %>
            <% if ("registered".equals(status)) { %>
                <div class="glass border-l-4 border-green-500 p-4 mb-6 bg-green-500/5 flex items-center gap-4 animate-bounce">
                    <i data-lucide="shield-check" class="w-5 h-5 text-green-500"></i>
                    <span class="text-[9px] font-bold uppercase tracking-widest text-green-700">Identity_Provisioned: Please_Authorize</span>
                </div>
            <% } else if ("loggedout".equals(status)) { %>
                <div class="glass border-l-4 border-red-500 p-4 mb-6 bg-red-500/5 flex items-center gap-4">
                    <i data-lucide="log-out" class="w-5 h-5 text-red-500"></i>
                    <span class="text-[9px] font-bold uppercase tracking-widest text-red-700">Signal_Terminated: Session_Invalidated</span>
                </div>
            <% } %>

            <div class="glass border-l-4 border-black shadow-2xl relative overflow-hidden bg-white/90">
                <div class="bg-black p-8 text-center text-white relative">
                    <div class="absolute top-0 right-0 p-4 text-[8px] font-mono opacity-20">V5.0_CORE</div>
                    <h1 class="font-[Orbitron] text-2xl tracking-[0.4em] font-black uppercase">Authorize</h1>
                    <p class="text-[8px] text-gray-500 tracking-[0.6em] mt-2 font-bold uppercase">Gurukul Neural Interface</p>
                </div>

                <div class="flex border-b border-black/5 font-[Orbitron] text-[9px] font-black tracking-widest">
                    <button id="loginBtn" onclick="showForm('login')" class="flex-1 py-4 bg-gray-50 border-r border-black/5 hover:bg-white transition-all text-red-500 border-b-2 border-b-red-500">LOGIN</button>
                    <button id="regBtn" onclick="showForm('reg')" class="flex-1 py-4 bg-gray-50 hover:bg-white transition-all text-gray-400">REGISTER</button>
                </div>

                <div class="p-10">
                    <!-- LOGIN FORM -->
                    <form id="loginForm" action="login" method="post" class="space-y-8">
                        <div>
                            <label class="label-tactical">Auth_ID / Username</label>
                            <input type="text" name="username" placeholder="USER_ALPHA" class="input-tactical" required>
                        </div>
                        <div>
                            <label class="label-tactical">Access_Cipher</label>
                            <input type="password" name="password" placeholder="••••••••" class="input-tactical" required>
                        </div>
                        <button type="submit" class="w-full bg-red-500 text-white py-4 font-[Orbitron] text-[11px] tracking-[0.4em] font-black uppercase hover:bg-black transition-all shadow-xl flex items-center justify-center gap-3">
                            <i data-lucide="key" class="w-4 h-4"></i> Establish_Link
                        </button>
                    </form>

                    <!-- REGISTRATION FORM -->
                    <form id="regForm" action="registration" method="post" class="hidden space-y-6">
                        <div class="grid grid-cols-2 gap-4">
                            <div><label class="label-tactical">Full_Name</label><input type="text" name="full_name" class="input-tactical" required></div>
                            <div><label class="label-tactical">Auth_ID</label><input type="text" name="username" class="input-tactical" required></div>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div><label class="label-tactical">Relay_Email</label><input type="email" name="email" class="input-tactical" required></div>
                            <div><label class="label-tactical">Comms_Ph</label><input type="text" name="phone" class="input-tactical"></div>
                        </div>
                        <div>
                            <label class="label-tactical">Assigned_Role</label>
                            <select name="role" class="input-tactical">
                                <option value="Student">STUDENT_UNIT</option>
                                <option value="Teacher">FACULTY_COMMANDER</option>
                            </select>
                        </div>
                        <div class="grid grid-cols-3 gap-2">
                            <div><label class="label-tactical">Course</label><input type="text" name="course" class="input-tactical" required></div>
                            <div><label class="label-tactical">Batch</label><input type="text" name="batch" class="input-tactical"></div>
                            <div><label class="label-tactical">Spec.</label><input type="text" name="specialization" class="input-tactical"></div>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div><label class="label-tactical">Cipher</label><input type="password" name="password" class="input-tactical" required></div>
                            <div><label class="label-tactical">Confirm</label><input type="password" name="cpassword" class="input-tactical" required></div>
                        </div>
                        <button type="submit" class="w-full bg-black text-white py-4 font-[Orbitron] text-[11px] tracking-[0.4em] font-black uppercase hover:bg-red-500 transition-all shadow-xl flex items-center justify-center gap-3">
                            <i data-lucide="shield-plus" class="w-4 h-4"></i> Provision_ID
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
        function showForm(type) {
            const isLogin = type === 'login';
            document.getElementById('loginForm').classList.toggle('hidden', !isLogin);
            document.getElementById('regForm').classList.toggle('hidden', isLogin);
            document.getElementById('loginBtn').className = isLogin ? 'flex-1 py-4 bg-white text-red-500 border-b-2 border-b-red-500 transition-all' : 'flex-1 py-4 bg-gray-50 text-gray-400 transition-all';
            document.getElementById('regBtn').className = !isLogin ? 'flex-1 py-4 bg-white text-red-500 border-b-2 border-b-red-500 transition-all' : 'flex-1 py-4 bg-gray-50 text-gray-400 transition-all';
        }

        const canvas = document.getElementById("particleCanvas");
        const ctx = canvas.getContext("2d");
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        class P {
            constructor(x,y){this.bx=x;this.by=y;this.x=x;this.y=y;this.vx=0;this.vy=0;}
            update(){
                let dx=this.x-mx,dy=this.y-my,d=Math.sqrt(dx*dx+dy*dy);
                if(d<80){let f=(80-d)/80,a=Math.atan2(dy,dx);this.vx+=Math.cos(a)*f*2;this.vy+=Math.sin(a)*f*2;}
                this.vx+=(this.bx-this.x)*0.05;this.vy+=(this.by-this.y)*0.05;
                this.vx*=0.85;this.vy*=0.85;this.x+=this.vx;this.y+=this.vy;
            }
            draw(){ctx.fillStyle="rgba(0,0,0,0.15)";ctx.fillRect(this.x,this.y,2,2);}
        }
        let ps=[],mx=-100,my=-100;
        window.addEventListener("mousemove",(e)=>{mx=e.clientX;my=e.clientY;});
        for(let x=0;x<canvas.width;x+=40)for(let y=0;y<canvas.height;y+=40)ps.push(new P(x,y));
        function anim(){ctx.clearRect(0,0,canvas.width,canvas.height);ps.forEach(p=>{p.update();p.draw();});requestAnimationFrame(anim);}
        anim();
    </script>
</body>
</html>