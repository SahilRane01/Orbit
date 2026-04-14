<%@ page import="java.sql.*, java.util.*, com.gurukul.*" %>
<jsp:useBean id="user" class="com.gurukul.userProfileBean" scope="session" />
<%
    if (session.getAttribute("user") == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, String>> activeMeetings = new ArrayList<>();
    try {
        ServletContext context = getServletContext();
        String DB = context.getInitParameter("DB_URL");
        String DB_User = context.getInitParameter("DB_USERNAME");
        String DB_pwd = context.getInitParameter("DB_PWD");
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://"+DB+":3306/gurukul", DB_User, DB_pwd);

        String meetSql = "SELECT * FROM meetings WHERE status = 'ACTIVE' ORDER BY created_at DESC";
        PreparedStatement psMeet = conn.prepareStatement(meetSql);
        ResultSet rsMeet = psMeet.executeQuery();
        while (rsMeet.next()) {
            Map<String, String> m = new HashMap<>();
            m.put("id", rsMeet.getString("meeting_id"));
            m.put("teacher", rsMeet.getString("teacher_name"));
            activeMeetings.add(m);
        }
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unit Deployment Terminal - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0, 0, 0, 0.05); }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
        .input-tactical { @apply w-full bg-white/50 border border-black/5 p-3 text-[10px] font-bold uppercase tracking-widest font-[Orbitron] focus:border-red-500 outline-none transition-all; }
        .scrollbar-hide::-webkit-scrollbar { display: none; }
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
            <span>GURUKUL_ILE / UNIT_DEPLOYMENT_TERMINAL</span>
            <span class="opacity-30 mx-2">|</span>
            <span class="text-red-500 uppercase tracking-widest">Auth_Level: ALPHA_ADMIN</span>
        </div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0">GKL</div>
                </div>
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10">
                    <a href="teacherDashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5">
                        <i data-lucide="layout-dashboard" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Command</span>
                    </a>
                    <a href="createEvent.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5">
                        <i data-lucide="calendar" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Events</span>
                    </a>
                    <a href="sendNotice.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5">
                        <i data-lucide="megaphone" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Notices</span>
                    </a>
                    <a href="createStudent.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500">
                        <i data-lucide="user-plus" class="w-5 h-5 text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Deploy_Unit</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 mt-auto">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Logout</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN -->
        <main class="flex-grow overflow-y-auto p-10 flex flex-col gap-10 scrollbar-hide">
            <div class="flex justify-between items-start">
                <div>
                    <h1 class="font-[Orbitron] text-4xl font-black tracking-tighter uppercase text-gray-900 mb-2">Unit_Deployment</h1>
                    <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase">Provisioning new learner profiles for the Gurukul network</p>
                </div>
            </div>

            <div class="max-w-4xl">
                <div class="glass p-10 border-l-4 border-red-500 relative overflow-hidden">
                    <div class="flex items-center gap-4 mb-12">
                        <i data-lucide="database" class="w-5 h-5 text-red-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-bold text-gray-900">Unit_Data_Entry</h2>
                    </div>

                    <form action="teacherAction" method="post" class="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-10">
                        <input type="hidden" name="action" value="ADD_STUDENT">
                        <input type="hidden" name="source" value="createStudent.jsp">

                        <div class="col-span-1 md:col-span-2">
                            <label class="label-tactical">Full_Name (Designation)</label>
                            <input type="text" name="full_name" placeholder="JOHN_DOE" class="input-tactical" required>
                        </div>

                        <div>
                            <label class="label-tactical">Auth_ID (Username)</label>
                            <input type="text" name="username" placeholder="USER_01" class="input-tactical" required>
                        </div>

                        <div>
                            <label class="label-tactical">Relay_Email</label>
                            <input type="email" name="email" placeholder="UNIT@GURUKUL.EDU" class="input-tactical" required>
                        </div>

                        <div>
                            <label class="label-tactical">Comms_Line (Phone)</label>
                            <input type="text" name="phone" placeholder="+91 XXXX XXXX" class="input-tactical">
                        </div>

                        <div>
                            <label class="label-tactical">Nav_Stream (Course)</label>
                            <input type="text" name="course" placeholder="COMP_SCI" class="input-tactical" required>
                        </div>

                        <div>
                            <label class="label-tactical">Temporal_Batch</label>
                            <input type="text" name="batch" placeholder="2024_ALPHA" class="input-tactical">
                        </div>

                        <div>
                            <label class="label-tactical">Expertise_Spec</label>
                            <input type="text" name="specialization" placeholder="CYBER_SEC" class="input-tactical">
                        </div>

                        <div class="col-span-1 md:col-span-2">
                            <label class="label-tactical">Access_Cipher (Password)</label>
                            <input type="password" name="password" placeholder="••••••••" class="input-tactical" required>
                        </div>

                        <div class="col-span-1 md:col-span-2 pt-6">
                            <button type="submit" class="w-full bg-[#0a0a0a] text-white py-5 font-[Orbitron] text-[10px] tracking-[0.5em] uppercase hover:bg-red-500 transition-all shadow-2xl flex items-center justify-center gap-4">
                                <i data-lucide="shield-check" class="w-4 h-4"></i> Commit_Unit_Registry
                            </button>
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
