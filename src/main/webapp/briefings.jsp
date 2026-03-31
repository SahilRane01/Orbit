<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.gurukul.userProfileBean" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    userProfileBean user = (userProfileBean) session.getAttribute("user");
    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());

    List<Map<String, String>> scheduledMeetings = new ArrayList<>();
    try {
        ServletContext context = getServletContext();
        String DB = context.getInitParameter("DB_URL");
        String DB_User = context.getInitParameter("DB_USERNAME");
        String DB_pwd = context.getInitParameter("DB_PWD");
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://" + DB + ":3306/gurukul", DB_User, DB_pwd);

        String sql = "SELECT * FROM meetings WHERE status != 'ENDED' ORDER BY scheduled_time ASC, created_at DESC";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
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
    <title>Briefing Terminal - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        @layer base { body { @apply font-[Inter] bg-[#f8fafc] text-gray-900 overflow-hidden; } }
        .glass { @apply bg-white/80 backdrop-blur-xl border border-white shadow-[0_8px_32px_rgba(0,0,0,0.05)]; }
        .hud-corner { @apply absolute w-4 h-4 border-black/20; }
        .input-tactical { @apply w-full bg-black/5 border-b-2 border-black/10 px-4 py-3 text-[10px] uppercase font-bold tracking-widest focus:border-red-500 focus:outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.3em] uppercase mb-1 block; }
        .terminal-index { @apply font-mono text-[10px] text-red-500/50 mr-4; }
    </style>
</head>
<body class="h-screen flex flex-col">
    <!-- TOP NAV -->
    <div class="h-16 border-b border-black/5 bg-white flex items-center justify-between px-8 shrink-0 relative z-50">
        <div class="flex items-center gap-4">
            <div class="w-8 h-8 bg-red-500 flex items-center justify-center font-[Orbitron] text-[10px] font-bold text-white">GKL</div>
            <h1 class="font-[Orbitron] text-xs tracking-[0.3em] font-black uppercase">Briefing_Terminal</h1>
        </div>
        <div class="flex items-center gap-6">
            <span class="text-[9px] text-gray-400 font-bold tracking-widest uppercase">Encryption_Signal: ACTIVE</span>
            <div class="h-8 w-[1px] bg-black/5"></div>
            <div class="flex items-center gap-3">
                <i data-lucide="user" class="w-4 h-4 text-red-500"></i>
                <span class="text-[10px] font-bold uppercase"><%= user == null ? "UNKNOWN" : user.getFullName() %></span>
            </div>
        </div>
    </div>

    <div class="flex flex-grow overflow-hidden relative">
        <!-- SIDEBAR (Reusing Dashboard Style) -->
        <aside class="w-20 hover:w-64 transition-all duration-500 border-r border-black/5 bg-white flex flex-col items-center md:items-stretch py-8 group/sidebar z-40 overflow-hidden">
            <nav class="flex-grow flex flex-col gap-2 w-full px-4">
                <a href="<%= isTeacher ? "teacherDashboard.jsp" : "dashboard.jsp" %>" class="flex items-center gap-6 p-4 hover:bg-black/5 transition-all text-gray-400 hover:text-red-500">
                    <i data-lucide="<%= isTeacher ? "layout-dashboard" : "home" %>" class="w-5 h-5"></i>
                    <span class="hidden group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Back</span>
                </a>
                <a href="briefings.jsp" class="flex items-center gap-6 p-4 bg-red-500/5 border-l-4 border-red-500 text-red-500 shadow-sm transition-all">
                    <i data-lucide="video" class="w-5 h-5"></i>
                    <span class="hidden group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Briefings</span>
                </a>
            </nav>
            <a href="logout" class="p-8 text-gray-400 hover:text-red-500 transition-colors mt-auto">
                <i data-lucide="log-out" class="w-6 h-6"></i>
            </a>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="flex-grow overflow-y-auto p-12 bg-gray-50 flex flex-col gap-12 scrollbar-hide">
            
            <% if (isTeacher) { %>
            <!-- SCHEDULING FORM -->
            <section class="max-w-4xl">
                <div class="glass p-10 relative overflow-hidden">
                    <div class="hud-corner top-0 left-0 border-t-2 border-l-2"></div>
                    <div class="hud-corner bottom-0 right-0 border-b-2 border-r-2 border-red-500"></div>
                    
                    <div class="flex items-center gap-4 mb-10 text-red-500">
                        <i data-lucide="plus-circle" class="w-5 h-5"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Plan_Future_Engagement</h2>
                    </div>

                    <form action="meetingAction" method="post" class="grid grid-cols-12 gap-8">
                        <input type="hidden" name="action" value="SCHEDULE_MEETING">
                        <div class="col-span-12 md:col-span-6">
                            <label class="label-tactical">Mission_Heading</label>
                            <input type="text" name="heading" placeholder="COORDINATION_ALPHA_V1" class="input-tactical" required>
                        </div>
                        <div class="col-span-12 md:col-span-4">
                            <label class="label-tactical">Temporal_Deployment</label>
                            <input type="datetime-local" name="scheduledTime" class="input-tactical" required>
                        </div>
                        <div class="col-span-12 md:col-span-2 flex items-end">
                            <button type="submit" class="w-full bg-black text-white py-3.5 px-4 font-[Orbitron] text-[10px] tracking-widest uppercase hover:bg-red-500 transition-all shadow-xl">Deploy</button>
                        </div>
                    </form>
                </div>
            </section>
            <% } %>

            <!-- MISSION BOARD -->
            <section class="max-w-6xl">
                <div class="flex items-center justify-between mb-8">
                    <div class="flex items-center gap-4">
                        <i data-lucide="layout-list" class="w-5 h-5 text-gray-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Mission_Ledger</h2>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
                    <% for(Map<String, String> m : scheduledMeetings) { 
                        boolean isActive = "ACTIVE".equalsIgnoreCase(m.get("status"));
                    %>
                    <div class="glass p-8 relative flex flex-col gap-6 group hover:translate-y-[-4px] transition-all duration-500 border-l-4 <%= isActive ? "border-red-500" : "border-black/20" %>">
                        <% if(isActive) { %>
                            <div class="absolute top-4 right-6 flex items-center gap-2">
                                <span class="w-2 h-2 bg-red-500 rounded-full animate-ping"></span>
                                <span class="text-[8px] font-black text-red-500 tracking-widest uppercase">SIGNAL_LIVE</span>
                            </div>
                        <% } %>

                        <div class="flex flex-col gap-2">
                            <span class="text-[8px] text-gray-400 font-bold tracking-[0.3em] uppercase">Msn_Ref: #<%= m.get("id") %></span>
                            <h3 class="font-[Orbitron] text-[12px] font-black uppercase tracking-widest text-gray-900 group-hover:text-red-500 transition-colors"><%= m.get("heading") %></h3>
                        </div>

                        <div class="grid grid-cols-2 gap-4 py-4 border-y border-black/5">
                            <div>
                                <span class="label-tactical">Faculty</span>
                                <span class="text-[10px] font-bold uppercase text-gray-700 truncate w-full inline-block"><%= m.get("teacher") %></span>
                            </div>
                            <div>
                                <span class="label-tactical">Deployment</span>
                                <span class="text-[10px] font-bold text-gray-500 uppercase"><%= m.get("time").replace("T", " ") %></span>
                            </div>
                        </div>

                        <div class="flex items-center gap-4 mt-auto">
                            <% if (isTeacher) { %>
                                <% if (!isActive) { %>
                                    <form action="meetingAction" method="post" class="flex-grow">
                                        <input type="hidden" name="action" value="START_MEETING">
                                        <input type="hidden" name="meetingId" value="<%= m.get("meetId") %>">
                                        <button class="w-full bg-black text-white py-3 text-[9px] font-[Orbitron] tracking-widest uppercase hover:bg-red-500 transition-all font-black">Go_Live</button>
                                    </form>
                                <% } else { %>
                                    <a href="meeting.jsp?id=<%= m.get("meetId") %>&room=<%= m.get("teacher") %>" class="flex-grow bg-red-500 text-white text-center py-3 text-[9px] font-[Orbitron] tracking-widest uppercase hover:bg-black transition-all font-black shadow-lg">In_Session</a>
                                <% } %>
                            <% } else { %>
                                <% if (isActive) { %>
                                    <a href="meeting.jsp?id=<%= m.get("meetId") %>&room=<%= m.get("teacher") %>" class="flex-grow bg-black text-white text-center py-3 text-[9px] font-[Orbitron] tracking-widest uppercase hover:bg-red-500 transition-all font-black shadow-lg">Establish_Link</a>
                                <% } else { %>
                                    <button disabled class="flex-grow bg-gray-100 text-gray-400 py-3 text-[9px] font-[Orbitron] tracking-widest uppercase cursor-not-allowed">Signal_Standby</button>
                                <% } %>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <% if (scheduledMeetings.isEmpty()) { %>
                    <div class="col-span-full py-20 flex flex-col items-center justify-center text-gray-300 gap-4">
                        <i data-lucide="radio" class="w-12 h-12 opacity-20"></i>
                        <span class="font-[Orbitron] text-[10px] tracking-widest uppercase">No_Active_Signals_Detected</span>
                    </div>
                    <% } %>
                </div>
            </section>
        </main>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
