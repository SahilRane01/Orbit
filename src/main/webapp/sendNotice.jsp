<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<NoticeBoard> notices = new ArrayList<>();
    List<Map<String, String>> activeMeetings = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Fetch Notices
        String noticeSql = "SELECT * FROM noticeboard ORDER BY created_at DESC";
        try (PreparedStatement psNotice = conn.prepareStatement(noticeSql);
             ResultSet rsNotice = psNotice.executeQuery()) {
            while (rsNotice.next()) {
                NoticeBoard nb = new NoticeBoard();
                nb.setId(rsNotice.getInt("id"));
                nb.setHeading(rsNotice.getString("heading"));
                nb.setBody(rsNotice.getString("body"));
                nb.setWhom(rsNotice.getString("whom"));
                nb.setCreatedAt(rsNotice.getTimestamp("created_at"));
                notices.add(nb);
            }
        }

        // Fetch Global Active Meetings
        String meetSql = "SELECT * FROM meetings WHERE status = 'ACTIVE' ORDER BY created_at DESC";
        try (PreparedStatement psMeet = conn.prepareStatement(meetSql);
             ResultSet rsMeet = psMeet.executeQuery()) {
            while (rsMeet.next()) {
                Map<String, String> m = new HashMap<>();
                m.put("id", rsMeet.getString("meeting_id"));
                m.put("teacher", rsMeet.getString("teacher_name"));
                activeMeetings.add(m);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Broadcast Terminal - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0, 0, 0, 0.05); }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
        .input-tactical { @apply w-full bg-white/50 border border-black/5 p-3 text-[10px] font-bold uppercase tracking-widest font-[Orbitron] focus:border-red-500 outline-none transition-all shadow-sm; }
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
            <span>GURUKUL_ILE / BROADCAST_GATEWAY</span>
            <span class="opacity-30 mx-2">|</span>
            <span class="text-red-500 animate-pulse">TRANSMITTING: <%= notices.size() %></span>
        </div>
        <div class="font-[Orbitron] text-red-500 tracking-widest px-2 py-0.5 bg-red-500/5 border border-red-500/20">ACCESS: ALPHA_COMMANDER</div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 cursor-pointer" onclick="location.href='teacherDashboard.jsp'">GKL</div>
                </div>
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="teacherDashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 w-full">
                        <i data-lucide="layout-dashboard" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Console</span>
                    </a>
                    <a href="createEvent.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 w-full">
                        <i data-lucide="calendar" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Events</span>
                    </a>
                    <a href="sendNotice.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="megaphone" class="w-5 h-5 text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Notices</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 mt-auto w-full">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Deauth</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN -->
        <main class="flex-grow overflow-y-auto p-10 flex flex-col gap-10 scrollbar-hide">
            <header>
                <h1 class="font-[Orbitron] text-4xl font-black tracking-tighter uppercase text-gray-900 mb-2">Broadcast<span class="text-red-500">_Array</span></h1>
                <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase">Global system transmissions and neural alerts</p>
            </header>

            <div class="grid grid-cols-12 gap-10">
                <!-- FORM -->
                <div class="col-span-12 xl:col-span-5">
                    <div class="glass p-10 border-l-4 border-red-500 relative bg-white/50">
                        <div class="flex items-center gap-4 mb-10 border-b border-black/5 pb-6">
                            <i data-lucide="send" class="w-4 h-4 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Initiate_Transmission</h2>
                        </div>
                        <form action="teacherAction" method="post" class="space-y-8">
                            <input type="hidden" name="action" value="ADD_NOTICE">
                            <input type="hidden" name="source" value="sendNotice.jsp">
                            <div>
                                <label class="label-tactical">Signal_Heading</label>
                                <input type="text" name="heading" placeholder="URGENT_PROTOCOL_ALPHA" class="input-tactical" required>
                            </div>
                            <div>
                                <label class="label-tactical">Signal_Payload</label>
                                <textarea name="body" placeholder="TRANSMISSION_DETAILS..." class="input-tactical h-40 resize-none pt-4" required></textarea>
                            </div>
                            <button type="submit" class="w-full bg-black text-white py-5 font-[Orbitron] text-[11px] tracking-[0.5em] uppercase hover:bg-red-500 transition-all shadow-xl flex items-center justify-center gap-4">
                                <i data-lucide="radio" class="w-4 h-4"></i> Commit_Broadcast
                            </button>
                        </form>
                    </div>
                </div>

                <!-- LIST -->
                <div class="col-span-12 xl:col-span-7">
                    <div class="glass p-10 border-r-4 border-black/10 bg-white/50 min-h-[600px] flex flex-col">
                        <div class="flex items-center gap-4 mb-10 border-b border-black/5 pb-6">
                            <i data-lucide="activity" class="w-4 h-4 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black text-gray-900">Active_Signals</h2>
                        </div>
                        <div class="space-y-6 overflow-y-auto pr-4 scrollbar-hide">
                            <% if (notices.isEmpty()) { %>
                                <div class="text-center py-20 text-[10px] text-gray-400 font-bold tracking-widest uppercase italic">No_Signals_Detected</div>
                            <% } else { for(NoticeBoard n : notices) { %>
                                <div class="flex justify-between items-center p-6 glass border border-black/5 hover:border-red-500/20 transition-all group">
                                    <div class="space-y-2">
                                        <h3 class="text-[13px] font-black uppercase text-gray-900 font-[Orbitron] tracking-widest group-hover:text-red-500 transition-colors"><%= n.getHeading() %></h3>
                                        <p class="text-[9px] text-gray-500 uppercase leading-relaxed max-w-sm"><%= n.getBody() %></p>
                                        <div class="flex items-center gap-4 pt-2">
                                            <span class="text-[7px] text-red-500 font-bold uppercase tracking-widest bg-red-500/5 px-2 py-1">ORIGIN: <%= n.getWhom() %></span>
                                        </div>
                                    </div>
                                    <form action="teacherAction" method="post" onsubmit="return confirm('DEAUTH SIGNAL?');">
                                        <input type="hidden" name="action" value="DELETE_NOTICE">
                                        <input type="hidden" name="id" value="<%= n.getId() %>">
                                        <input type="hidden" name="source" value="sendNotice.jsp">
                                        <button class="w-10 h-10 flex items-center justify-center bg-black/5 text-gray-400 hover:bg-red-500 hover:text-white transition-all rounded-sm border border-black/5">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            <% } } %>
                        </div>
                    </div>
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
