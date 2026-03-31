<%@ page import="com.gurukul.userProfileBean" %>
<%@ page isELIgnored="false" %>
<jsp:useBean id="user" class="com.gurukul.userProfileBean" scope="session" />
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
    <title>User Profile - Gurukul ILE</title>
    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg {
            background-image:
                linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px),
                linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
            background-size: 40px 40px;
        }
        .glass {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(0, 0, 0, 0.05);
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.03);
        }
        .hud-corner { @apply absolute w-5 h-5 border-red-500 shadow-[0_0_15px_rgba(255,51,51,0.4)] z-20; }
        .terminal-index { @apply text-[7px] text-gray-300 font-bold tracking-widest mr-2 transition-colors opacity-0 group-hover/sidebar:opacity-50; }
        .connector-line { @apply absolute top-24 bottom-24 w-[1px] bg-black/[0.04] z-0 transition-all duration-500; }
        .active-bar { @apply absolute left-0 top-0 bottom-0 w-1 bg-red-500 shadow-[0_0_10px_rgba(255,51,51,0.4)]; }
        
        .input-tactical {
            @apply w-full bg-white/50 border border-black/5 p-4 text-[10px] font-bold uppercase tracking-[0.2em] font-[Orbitron] focus:outline-none focus:border-red-500 transition-all placeholder-gray-300 shadow-sm;
        }
        .input-locked {
            @apply w-full bg-black/[0.03] border border-black/5 p-4 text-[10px] font-bold uppercase tracking-[0.2em] font-[Orbitron] text-gray-400 cursor-not-allowed opacity-60;
        }
        .label-tactical {
            @apply text-[8px] text-gray-400 font-bold tracking-[0.4em] uppercase mb-2 block font-sans;
        }

        @keyframes entry { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .animate-entry { animation: entry 0.6s ease-out forwards; }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">
    <!-- TACTICAL GRID BACKGROUND -->
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>
    <div class="fixed inset-0 pointer-events-none bg-gradient-to-tr from-red-500/[0.02] via-transparent to-transparent z-0"></div>

    <!-- SYSTEM TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-4 md:px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <button id="mobile-toggle" class="md:hidden p-2 -ml-2 text-gray-400 hover:text-red-500 transition-colors">
                <i data-lucide="menu" class="w-5 h-5"></i>
            </button>
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / IDENTITY_MANAGEMENT</span>
        </div>
        <div class="flex items-center gap-4">
            <span class="hidden md:inline opacity-60 uppercase">System_Active: Deployment_V4.2</span>
            <span class="font-[Orbitron] text-red-500 tracking-widest px-2 py-0.5 bg-red-500/5 border border-red-500/20">ID: ${user.id}</span>
        </div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        
        <!-- SIDEBAR: STANDARDIZED COMMAND HUD (SAME AS DASHBOARD) -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-4 md:py-6 pr-0 md:pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="connector-line left-[39px] md:group-hover/sidebar:left-[47px] hidden md:block"></div>

            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-8 md:py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <button id="mobile-close" class="md:hidden absolute top-4 right-4 p-2 text-gray-400 hover:text-red-500 z-50">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>

                <div class="hud-corner top-2 left-2 border-t-2 border-l-2"></div>
                <div class="hud-corner top-2 right-2 border-t-2 border-r-2 opacity-10"></div>
                <div class="hud-corner bottom-2 left-2 border-b-2 border-l-2 opacity-10"></div>
                <div class="hud-corner bottom-2 right-2 border-b-2 border-r-2 border-red-500"></div>

                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="flex items-center justify-center w-full md:w-auto gap-4">
                        <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20 cursor-pointer" onclick="location.href='dashboard.jsp'">
                            GKL
                        </div>
                        <div class="block md:hidden md:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">
                            <div class="font-[Orbitron] text-[11px] tracking-[0.2em] text-red-500 font-bold leading-none uppercase">Gurukul_ILE</div>
                            <div class="text-[7px] text-gray-400 tracking-[0.4em] font-bold mt-1 uppercase whitespace-nowrap">SENS_UNIT_V4</div>
                        </div>
                    </div>
                </div>

                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="dashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                        <div class="w-6 h-6 flex items-center justify-center shrink-0">
                            <i data-lucide="home" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all"></i>
                        </div>
                        <span class="terminal-index hidden md:group-hover/sidebar:block transition-all duration-500">[01]</span>
                        <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900">Dashboard</span>
                    </a>
                    <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                        <div class="w-6 h-6 flex items-center justify-center shrink-0">
                            <i data-lucide="video" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all"></i>
                        </div>
                        <span class="terminal-index hidden md:group-hover/sidebar:block transition-all duration-500">[06]</span>
                        <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900">Briefings</span>
                    </a>
                </nav>

                <div class="flex-shrink-0 flex flex-col gap-2 relative z-10 items-center md:items-stretch mt-auto">
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 transition-all w-full justify-center md:justify-start">
                        <div class="w-6 h-6 flex items-center justify-center shrink-0">
                            <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all"></i>
                        </div>
                        <span class="terminal-index hidden md:group-hover/sidebar:block transition-all duration-500">[99]</span>
                        <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-500 group-hover/item:text-red-500">Deauth</span>
                    </a>
                    
                    <a href="userProfile.jsp" class="p-2 border-y border-black/5 flex items-center gap-4 group/profile cursor-pointer relative overflow-hidden bg-gray-50/20 w-full justify-center md:justify-start">
                        <div class="active-bar"></div>
                        <div class="w-10 h-10 bg-white flex items-center justify-center shrink-0 border border-black/5 rounded-sm relative z-10">
                            <i data-lucide="user" class="w-5 h-5 text-red-500"></i>
                        </div>
                        <div class="block md:hidden md:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">
                            <div class="text-[10px] font-bold text-gray-900 truncate w-32 uppercase tracking-[0.2em] font-[Orbitron]">${user.userName}</div>
                            <div class="text-[7px] text-red-500 font-bold tracking-[0.4em] uppercase mt-1">CORE_AUTHORIZED</div>
                        </div>
                    </a>
                </div>
            </div>
        </aside>

        <!-- MAIN AREA -->
        <main class="flex-grow overflow-y-auto p-4 md:p-8 flex flex-col gap-8 scrollbar-hide">
            
            <header class="animate-entry flex flex-col md:flex-row justify-between items-start md:items-center gap-4 opacity-0" style="animation-delay: 0.1s">
                <div>
                    <h1 class="font-[Orbitron] text-4xl tracking-[0.2em] uppercase text-gray-900 leading-none">Account<span class="text-red-500">_Identity</span></h1>
                    <p class="text-[9px] text-gray-400 tracking-[0.4em] uppercase font-bold mt-4">System_Access_ID: <span class="text-red-500 underline"><%= session.getId().toUpperCase() %></span></p>
                </div>
                
                <% if("success".equals(status)) { %>
                <div class="flex items-center gap-4 bg-green-500/5 border border-green-500/20 px-6 py-3">
                    <i data-lucide="shield-check" class="w-5 h-5 text-green-500"></i>
                    <span class="text-[10px] font-[Orbitron] text-green-500 font-bold tracking-widest uppercase">Database_Override_Success</span>
                </div>
                <% } %>
            </header>

            <div class="grid grid-cols-12 gap-8 items-start animate-entry opacity-0" style="animation-delay: 0.2s">
                
                <!-- IDENTITY PREVIEW CARD -->
                <div class="col-span-12 lg:col-span-4 glass border border-black/10 p-10 flex flex-col gap-8 relative overflow-hidden group">
                    <div class="w-24 h-24 bg-white border border-black/5 flex items-center justify-center self-center rounded-sm shadow-inner relative">
                        <i data-lucide="user" class="w-12 h-12 text-gray-200"></i>
                        <div class="absolute inset-x-2 bottom-2 h-0.5 bg-red-500/20"></div>
                    </div>
                    
                    <div class="space-y-6">
                        <div class="border-l-2 border-red-500/30 pl-4 py-1">
                            <span class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-1">Full_Name</span>
                            <span class="text-[13px] font-bold uppercase tracking-wider text-gray-900 font-[Orbitron]">${user.fullName}</span>
                        </div>
                        <div class="border-l-2 border-black/5 pl-4 py-1">
                            <span class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-1">Role_Permission</span>
                            <span class="text-[10px] text-red-500 font-bold tracking-[0.3em] font-[Orbitron]">${user.role}</span>
                        </div>
                    </div>

                    <div class="pt-8 border-t border-black/5 space-y-4">
                        <div class="flex justify-between items-center text-[9px] tracking-widest text-gray-500 uppercase font-medium">
                            <span class="flex items-center gap-2"><i data-lucide="book" class="w-3 h-3 text-red-500/30"></i>Course</span>
                            <span class="text-gray-900 font-bold font-[Orbitron]">${user.course}</span>
                        </div>
                        <div class="flex justify-between items-center text-[9px] tracking-widest text-gray-500 uppercase font-medium">
                            <span class="flex items-center gap-2"><i data-lucide="hash" class="w-3 h-3 text-red-500/30"></i>Batch</span>
                            <span class="text-gray-900 font-bold font-[Orbitron]">${user.batch}</span>
                        </div>
                    </div>
                </div>

                <!-- UPDATE FORM -->
                <div class="col-span-12 lg:col-span-8 glass border border-black/10 p-10 relative">
                    <div class="flex items-center gap-4 mb-10 pb-6 border-b border-black/5">
                        <i data-lucide="terminal" class="w-4 h-4 text-red-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] text-gray-500 uppercase font-black">Identity_Config_Terminal</h2>
                    </div>

                    <form action="userProfile" method="post" class="space-y-10">
                        <div class="grid md:grid-cols-2 gap-8">
                            <!-- EDITABLE -->
                            <div class="group/input">
                                <label class="label-tactical">Name Override</label>
                                <input type="text" name="name" placeholder="${user.fullName}" class="input-tactical">
                            </div>
                            <div class="group/input">
                                <label class="label-tactical">Email Relay</label>
                                <input type="email" name="email" placeholder="${user.email}" class="input-tactical">
                            </div>
                            <div class="group/input">
                                <label class="label-tactical">Phone Comms</label>
                                <input type="text" name="ph" placeholder="${user.phone}" class="input-tactical">
                            </div>

                            <!-- LOCKED -->
                            <div>
                                <label class="label-tactical flex items-center gap-2"><i data-lucide="lock" class="w-3 h-3 text-red-500"></i>Permission Role</label>
                                <input type="text" value="${user.role}" class="input-locked" readonly title="Core data cannot be overridden">
                            </div>
                            <div>
                                <label class="label-tactical flex items-center gap-2"><i data-lucide="lock" class="w-3 h-3 text-red-500"></i>Academic Stream</label>
                                <input type="text" value="${user.course}" class="input-locked" readonly title="Core data cannot be overridden">
                            </div>
                            <div>
                                <label class="label-tactical flex items-center gap-2"><i data-lucide="lock" class="w-3 h-3 text-red-500"></i>Specialization</label>
                                <input type="text" value="${user.specialization}" class="input-locked" readonly title="Core data cannot be overridden">
                            </div>
                            <div>
                                <label class="label-tactical flex items-center gap-2"><i data-lucide="lock" class="w-3 h-3 text-red-500"></i>Auth Username</label>
                                <input type="text" value="${user.userName}" class="input-locked" readonly title="Core data cannot be overridden">
                            </div>
                        </div>

                        <!-- DISCLAIMER NOTICE -->
                        <div class="mt-8 bg-black/[0.02] p-6 border-l-2 border-red-500 flex items-start gap-4">
                            <i data-lucide="alert-circle" class="w-4 h-4 text-red-500 mt-1"></i>
                            <div>
                                <h4 class="text-[9px] font-black uppercase text-gray-900 tracking-widest mb-1 italic">Identity_Enforcement_Policy</h4>
                                <p class="text-[8px] text-gray-500 uppercase tracking-widest leading-loose">Locked fields represent core system identifiers. CONTACT YOUR SYSTEM ADMINISTRATOR for modifications to restricted data blocks.</p>
                            </div>
                        </div>

                        <div class="pt-8 flex justify-end">
                            <button type="submit" class="bg-[#0a0a0a] text-white px-10 py-4 font-[Orbitron] text-[10px] tracking-[0.5em] uppercase hover:bg-red-500 transition-all border border-transparent hover:border-red-500 shadow-[0_0_20px_rgba(255,51,51,0.1)] group">
                                Apply_Override_V4.2
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <footer class="mt-auto py-8 border-t border-black/5 flex justify-between items-center text-[8px] text-gray-400 uppercase tracking-[0.5em] font-bold">
                <div class="flex gap-12 items-center">
                    <span>© 2026_GKL_CORE</span>
                    <span class="opacity-30">|</span>
                    <span>IDENTITY_VERIFIED</span>
                </div>
                <div class="flex gap-4 items-center">
                    <span class="text-red-500 animate-[text-glow_2s_infinite]">&#10033; SYSTEM_ACTIVE</span>
                </div>
            </footer>

        </main>
    </div>

    <script>
        lucide.createIcons();

        // Mobile Logic
        const sidebar = document.getElementById('sidebar-module');
        const toggle = document.getElementById('mobile-toggle');
        const close = document.getElementById('mobile-close');

        if (toggle && sidebar) {
            toggle.addEventListener('click', () => {
                sidebar.classList.remove('-translate-x-full');
            });
        }
        if (close && sidebar) {
            close.addEventListener('click', () => {
                sidebar.classList.add('-translate-x-full');
            });
        }
    </script>
</body>
</html>