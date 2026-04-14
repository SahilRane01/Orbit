<%@ page import="com.gurukul.models.UserProfile" %>
<%@ page isELIgnored="false" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String status = request.getParameter("status");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Identity Hub - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0, 0, 0, 0.05); }
        .hud-corner { @apply absolute w-5 h-5 border-red-500 z-20; }
        .input-tactical { @apply w-full bg-white/50 border border-black/5 p-4 text-[10px] font-bold uppercase tracking-[0.2em] font-[Orbitron] focus:border-red-500 outline-none transition-all shadow-sm; }
        .input-locked { @apply w-full bg-black/[0.03] border border-black/5 p-4 text-[10px] font-bold uppercase tracking-[0.2em] font-[Orbitron] text-gray-400 cursor-not-allowed opacity-60; }
        .label-tactical { @apply text-[8px] text-gray-400 font-bold tracking-[0.4em] uppercase mb-2 block font-sans; }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>

    <!-- TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <button id="mobile-toggle" class="md:hidden p-2 -ml-2 text-gray-400 hover:text-red-500 transition-colors">
                <i data-lucide="menu" class="w-5 h-5"></i>
            </button>
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / IDENTITY_CONTROL</span>
        </div>
        <div class="font-[Orbitron] text-red-500 tracking-widest px-2 py-0.5 bg-red-500/5 border border-red-500/20">UNIT_ID: <%= user.getId() %></div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20 cursor-pointer" onclick="location.href='dashboard.jsp'">GKL</div>
                </div>

                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="dashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 w-full">
                        <i data-lucide="layout-dashboard" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Console</span>
                    </a>
                    <a href="userProfile.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="user" class="w-5 h-5 text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Identity</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 mt-auto w-full">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Deauth</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN -->
        <main class="flex-grow overflow-y-auto p-8 flex flex-col gap-8 scrollbar-hide">
            
            <header class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h1 class="font-[Orbitron] text-4xl tracking-widest uppercase text-gray-900 leading-none">Vect<span class="text-red-500">_Identity</span></h1>
                    <p class="text-[9px] text-gray-400 tracking-[0.4em] uppercase font-bold mt-4">Node_Status: <span class="text-red-500 underline">VERIFIED_ALPHA</span></p>
                </div>
                
                <% if("success".equals(status)) { %>
                <div class="flex items-center gap-4 bg-green-500/5 border border-green-500/20 px-6 py-3 animate-pulse">
                    <i data-lucide="check-circle" class="w-5 h-5 text-green-500"></i>
                    <span class="text-[10px] font-[Orbitron] text-green-500 font-bold tracking-widest uppercase">Identity_Override_Success</span>
                </div>
                <% } %>
            </header>

            <div class="grid grid-cols-12 gap-8 items-start">
                <!-- PREVIEW -->
                <div class="col-span-12 lg:col-span-4 glass border border-black/10 p-10 flex flex-col gap-8">
                    <div class="w-24 h-24 bg-white border border-black/5 flex items-center justify-center self-center shadow-inner relative">
                        <i data-lucide="user" class="w-12 h-12 text-red-500/20"></i>
                        <div class="absolute bottom-2 left-2 right-2 h-0.5 bg-red-500/30"></div>
                    </div>
                    <div class="space-y-6">
                        <div class="border-l-2 border-red-500/30 pl-4">
                            <span class="label-tactical">Full_Name</span>
                            <span class="text-[14px] font-bold uppercase tracking-wider text-gray-900 font-[Orbitron]"><%= user.getFullName() %></span>
                        </div>
                        <div class="border-l-2 border-black/5 pl-4">
                            <span class="label-tactical">Role_Permission</span>
                            <span class="text-[10px] text-red-500 font-bold tracking-[0.3em] font-[Orbitron]"><%= user.getRole() %></span>
                        </div>
                    </div>
                </div>

                <!-- CONFIG TERMINAL -->
                <div class="col-span-12 lg:col-span-8 glass border border-black/10 p-10">
                    <div class="flex items-center gap-4 mb-10 pb-6 border-b border-black/5">
                        <i data-lucide="settings" class="w-4 h-4 text-red-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] text-gray-500 uppercase font-black">Identity_Override_Terminal</h2>
                    </div>

                    <form action="userProfile" method="post" class="space-y-10">
                        <div class="grid md:grid-cols-2 gap-8">
                            <div><label class="label-tactical">Name Override</label><input type="text" name="name" placeholder="<%= user.getFullName() %>" class="input-tactical"></div>
                            <div><label class="label-tactical">Email Relay</label><input type="email" name="email" placeholder="<%= user.getEmail() %>" class="input-tactical"></div>
                            <div><label class="label-tactical">Phone Comms</label><input type="text" name="ph" placeholder="<%= user.getPhone() != null ? user.getPhone() : "" %>" class="input-tactical"></div>
                            <div><label class="label-tactical">Access Role (Locked)</label><input type="text" value="<%= user.getRole() %>" class="input-locked" readonly></div>
                            <div><label class="label-tactical">Vect Stream (Locked)</label><input type="text" value="<%= user.getCourse() %>" class="input-locked" readonly></div>
                            <div><label class="label-tactical">Auth Username (Locked)</label><input type="text" value="<%= user.getUserName() %>" class="input-locked" readonly></div>
                        </div>

                        <div class="bg-black/5 p-6 border-l-2 border-red-500">
                            <h4 class="text-[9px] font-black uppercase text-gray-900 tracking-widest mb-1 italic">Security_Note</h4>
                            <p class="text-[8px] text-gray-500 uppercase tracking-widest leading-loose">Restricted data blocks require system-level privileges for modification. Contact Command for core record overrides.</p>
                        </div>

                        <div class="pt-8 flex justify-end">
                            <button type="submit" class="bg-black text-white px-12 py-4 font-[Orbitron] text-[10px] tracking-[0.6em] font-black uppercase hover:bg-red-500 transition-all shadow-xl">Apply_Override</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

    <script>
        lucide.createIcons();
        document.getElementById('mobile-toggle')?.addEventListener('click', () => document.getElementById('sidebar-module').classList.remove('-translate-x-full'));
    </script>
</body>
</html>