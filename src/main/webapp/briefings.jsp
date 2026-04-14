<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.gurukul.models.UserProfile, com.gurukul.utils.DBConnection" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    UserProfile user = (UserProfile) session.getAttribute("user");
    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());

    List<Map<String, String>> scheduledMeetings = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        String sql = "SELECT * FROM meetings WHERE status != 'ENDED' ORDER BY scheduled_time ASC, created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> m = new HashMap<>();
                m.put("id", rs.getString("id"));
                m.put("meetId", rs.getString("meeting_id"));
                m.put("teacher", rs.getString("teacher_name"));
                m.put("heading", rs.getString("heading") != null ? rs.getString("heading") : "UNNAMED_MISSION");
                m.put("status", rs.getString("status"));
                m.put("time", rs.getString("scheduled_time") != null ? rs.getString("scheduled_time") : "REAL_TIME");
                scheduledMeetings.add(m);
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
    <title>Briefing Terminal - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { @apply bg-white/80 backdrop-blur-xl border border-black/5 shadow-[0_8px_32px_rgba(0,0,0,0.05)]; }
        .hud-corner { @apply absolute w-4 h-4 border-red-500 z-20; }
        .input-tactical { @apply w-full bg-black/5 border-b-2 border-black/10 px-4 py-3 text-[10px] uppercase font-bold tracking-widest font-[Orbitron] focus:border-red-500 focus:outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.3em] uppercase mb-1 block; }
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
            <span>GURUKUL_ILE / BRIEFING_TERMINAL</span>
            <span class="opacity-30 mx-2">|</span>
            <span class="text-red-500 animate-pulse">MISSION_SIGNALS: <%= scheduledMeetings.size() %></span>
        </div>
        <div class="font-[Orbitron] text-red-500 tracking-widest px-2 py-0.5 bg-red-500/5 border border-red-500/20">UNIT: <%= user.getUserName() %></div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 cursor-pointer" onclick="location.href='dashboard.jsp'">GKL</div>
                </div>
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="<%= isTeacher ? "teacherDashboard.jsp" : "dashboard.jsp" %>" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 w-full">
                        <i data-lucide="layout-dashboard" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Console</span>
                    </a>
                    <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="video" class="w-5 h-5 text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Briefings</span>
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
                <h1 class="font-[Orbitron] text-4xl font-black tracking-tighter uppercase text-gray-900 mb-2">Signal<span class="text-red-500">_Briefings</span></h1>
                <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase">Scheduled mission engagements and tactical knowledge relays</p>
            </header>

            <div class="grid grid-cols-12 gap-10">
                <% if (isTeacher) { %>
                <!-- SCHEDULING FORM -->
                <div class="col-span-12">
                    <div class="glass p-10 relative overflow-hidden border-l-4 border-red-500 bg-white/50">
                        <div class="flex items-center gap-4 mb-8">
                            <i data-lucide="plus-circle" class="w-5 h-5 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Plan_Future_Engagement</h2>
                        </div>
                        <form action="meeting" method="post" class="grid grid-cols-12 gap-8 items-end">
                            <input type="hidden" name="action" value="SCHEDULE">
                            <div class="col-span-12 md:col-span-6">
                                <label class="label-tactical">Mission_Heading</label>
                                <input type="text" name="heading" placeholder="OPERATIONAL_SYNC_V1" class="input-tactical" required>
                            </div>
                            <div class="col-span-12 md:col-span-4">
                                <label class="label-tactical">Deployment_Coordinate (Date/Time)</label>
                                <input type="datetime-local" name="scheduledTime" class="input-tactical" required>
                            </div>
                            <div class="col-span-12 md:col-span-2">
                                <button type="submit" class="w-full bg-black text-white py-4 font-[Orbitron] text-[10px] tracking-[0.4em] font-black uppercase hover:bg-red-500 transition-all shadow-xl">Deploy</button>
                            </div>
                        </form>
                    </div>
                </div>
                <% } %>

                <!-- MISSION BOARD -->
                <div class="col-span-12">
                    <div class="flex items-center gap-4 mb-8">
                        <i data-lucide="layout-list" class="w-4 h-4 text-gray-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Mission_Ledger</h2>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
                        <% if (scheduledMeetings.isEmpty()) { %>
                            <div class="col-span-full py-20 flex flex-col items-center justify-center text-gray-300 gap-4 glass">
                                <i data-lucide="radio" class="w-12 h-12 opacity-20"></i>
                                <span class="font-[Orbitron] text-[10px] tracking-widest uppercase">No_Active_Signals_Detected</span>
                            </div>
                        <% } else { for(Map<String, String> m : scheduledMeetings) { 
                            boolean isActive = "ACTIVE".equalsIgnoreCase(m.get("status"));
                        %>
                        <div class="glass p-8 relative flex flex-col gap-6 group hover:translate-y-[-4px] transition-all duration-500 border-l-4 <%= isActive ? "border-red-500" : "border-black/20" %> bg-white/90">
                            <% if(isActive) { %>
                                <div class="absolute top-4 right-6 flex items-center gap-2">
                                    <span class="w-2 h-2 bg-red-500 rounded-full animate-ping"></span>
                                    <span class="text-[8px] font-black text-red-500 tracking-widest uppercase">SIGNAL_LIVE</span>
                                </div>
                            <% } %>

                            <div class="flex flex-col gap-2">
                                <span class="text-[8px] text-gray-400 font-bold tracking-[0.3em] uppercase">UID: #<%= m.get("meetId") %></span>
                                <h3 class="font-[Orbitron] text-[12px] font-black uppercase tracking-widest text-gray-900 group-hover:text-red-500 transition-colors"><%= m.get("heading") %></h3>
                            </div>

                            <div class="grid grid-cols-2 gap-4 py-4 border-y border-black/5">
                                <div><span class="label-tactical">Faculty</span><span class="text-[10px] font-bold uppercase text-gray-700 truncate w-full inline-block"><%= m.get("teacher") %></span></div>
                                <div><span class="label-tactical">Deployment</span><span class="text-[10px] font-bold text-gray-500 uppercase"><%= m.get("time").replace("T", " ") %></span></div>
                            </div>

                            <div class="mt-auto pt-4">
                                <% if (isTeacher) { %>
                                    <% if (!isActive) { %>
                                        <form action="meeting" method="post" class="w-full">
                                            <input type="hidden" name="action" value="START">
                                            <input type="hidden" name="meetingId" value="<%= m.get("meetId") %>">
                                            <button class="w-full bg-black text-white py-3 text-[10px] font-[Orbitron] tracking-widest uppercase hover:bg-red-500 transition-all font-black">Go_Live</button>
                                        </form>
                                    <% } else { %>
                                        <a href="meeting.jsp?id=<%= m.get("meetId") %>&room=<%= m.get("teacher") %>" class="block w-full bg-red-500 text-white text-center py-3 text-[10px] font-[Orbitron] tracking-widest uppercase hover:bg-black transition-all font-black shadow-lg">In_Progress</a>
                                    <% } %>
                                <% } else { %>
                                    <% if (isActive) { %>
                                        <a href="meeting.jsp?id=<%= m.get("meetId") %>&room=<%= m.get("teacher") %>" class="block w-full bg-black text-white text-center py-3 text-[10px] font-[Orbitron] tracking-widest uppercase hover:bg-red-500 transition-all font-black shadow-lg">Establish_Link</a>
                                    <% } else { %>
                                        <button disabled class="w-full bg-gray-100 text-gray-400 py-3 text-[10px] font-[Orbitron] tracking-widest uppercase cursor-not-allowed">Signal_Standby</button>
                                    <% } %>
                                <% } %>
                            </div>
                        </div>
                        <% } } %>
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
