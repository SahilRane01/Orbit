<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.gurukul.models.UserProfile, com.gurukul.utils.DBConnection" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    UserProfile user = (UserProfile) session.getAttribute("user");
    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());

    List<Map<String, String>> records = new ArrayList<>();
    List<Map<String, String>> defaulters = new ArrayList<>();
    int totalClasses = 0, presentCount = 0;
    double percentage = 0.0;
    String filterMonth = request.getParameter("month");
    String filterSubject = request.getParameter("subject");

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        if (isTeacher) {
            // Teacher: Defaulter list (<75%)
            String defSql = "SELECT u.id, u.full_name, u.course, u.batch, " +
                "COUNT(a.id) as total, SUM(CASE WHEN a.status='PRESENT' THEN 1 ELSE 0 END) as present_count " +
                "FROM users u LEFT JOIN attendance a ON u.id = a.student_id " +
                "WHERE u.role = 'Student' GROUP BY u.id HAVING total > 0 ORDER BY (present_count/total) ASC";
            try (PreparedStatement ps = conn.prepareStatement(defSql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int t = rs.getInt("total"); int p = rs.getInt("present_count");
                    double pct = t > 0 ? (p * 100.0 / t) : 0;
                    Map<String, String> d = new HashMap<>();
                    d.put("id", rs.getString("id"));
                    d.put("name", rs.getString("full_name"));
                    d.put("course", rs.getString("course") != null ? rs.getString("course") : "N/A");
                    d.put("batch", rs.getString("batch") != null ? rs.getString("batch") : "N/A");
                    d.put("total", String.valueOf(t));
                    d.put("present", String.valueOf(p));
                    d.put("pct", String.format("%.1f", pct));
                    d.put("defaulter", pct < 75 ? "true" : "false");
                    defaulters.add(d);
                }
            }
        } else {
            // Student: Own attendance
            StringBuilder sb = new StringBuilder("SELECT date, subject, status, created_at FROM attendance WHERE student_id = ?");
            List<Object> params = new ArrayList<>(); params.add(user.getId());
            if (filterMonth != null && !filterMonth.isEmpty()) {
                sb.append(" AND DATE_FORMAT(date, '%Y-%m') = ?"); params.add(filterMonth);
            }
            if (filterSubject != null && !filterSubject.isEmpty()) {
                sb.append(" AND subject = ?"); params.add(filterSubject.trim().toUpperCase());
            }
            sb.append(" ORDER BY date DESC");
            try (PreparedStatement ps = conn.prepareStatement(sb.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    if (params.get(i) instanceof Integer) ps.setInt(i+1, (Integer)params.get(i));
                    else ps.setString(i+1, (String)params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> r = new HashMap<>();
                        r.put("date", rs.getString("date"));
                        r.put("subject", rs.getString("subject"));
                        r.put("status", rs.getString("status"));
                        records.add(r);
                    }
                }
            }
            // Overall stats
            String statsSql = "SELECT COUNT(*) as total, SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) as present_count FROM attendance WHERE student_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(statsSql)) {
                ps.setInt(1, user.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) { totalClasses = rs.getInt("total"); presentCount = rs.getInt("present_count"); }
                }
            }
            percentage = totalClasses > 0 ? (presentCount * 100.0 / totalClasses) : 0;
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Reports - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { @apply bg-white/80 backdrop-blur-xl border border-black/5 shadow-[0_8px_32px_rgba(0,0,0,0.05)]; }
        .input-tactical { @apply w-full bg-black/5 border-b-2 border-black/10 px-4 py-3 text-[10px] uppercase font-bold tracking-widest font-[Orbitron] focus:border-red-500 focus:outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.3em] uppercase mb-1 block; }
        .terminal-index { @apply text-[7px] text-gray-300 font-bold tracking-widest mr-2; }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0"></div>

    <!-- TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / ATTENDANCE_REPORTS</span>
        </div>
        <div class="font-[Orbitron] text-red-500 tracking-widest px-2 py-0.5 bg-red-500/5 border border-red-500/20">UNIT: <%= user.getUserName() %></div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="connector-line left-[39px] md:group-hover/sidebar:left-[47px] hidden md:block"></div>
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20 cursor-pointer" onclick="location.href='<%= isTeacher ? "teacherDashboard.jsp" : "dashboard.jsp" %>'">GKL</div>
                </div>
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <% if (isTeacher) { %>
                        <a href="teacherDashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="layout-dashboard" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[01]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Dashboard</span>
                        </a>
                        <a href="classes.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="book-open" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[02]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Classes</span>
                        </a>
                        <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="video" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[03]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Sessions</span>
                        </a>
                        <a href="markAttendance.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="clipboard-check" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[04]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Attendance</span>
                        </a>
                        <a href="viewAttendance.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                            <i data-lucide="bar-chart-3" class="w-5 h-5 text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[05]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Reports</span>
                        </a>
                        <a href="createEvent.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="calendar" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[06]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Events</span>
                        </a>
                        <a href="sendNotice.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="megaphone" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[07]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Notices</span>
                        </a>
                        <a href="teacherDashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="user-plus" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[08]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Deploy_Unit</span>
                        </a>
                        <a href="teacherDashboard.jsp#leave-management" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="clipboard-list" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[09]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Leave_Ops</span>
                        </a>
                    <% } else { %>
                        <a href="dashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="home" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[01]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Terminal</span>
                        </a>
                        <a href="classes.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="book-open" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[02]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Classes</span>
                        </a>
                        <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="video" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[03]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Briefings</span>
                        </a>
                        <a href="viewAttendance.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                            <i data-lucide="bar-chart-3" class="w-5 h-5 text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[04]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Attendance</span>
                        </a>
                        <a href="userProfile.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="user" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[05]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Profile</span>
                        </a>
                    <% } %>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 mt-auto w-full">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[99]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Logout</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN -->
        <main class="flex-grow overflow-y-auto p-10 flex flex-col gap-10 scrollbar-hide">
            <header>
                <h1 class="font-[Orbitron] text-4xl font-black tracking-tighter uppercase text-gray-900 mb-2">Attendance<span class="text-red-500">_Reports</span></h1>
                <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase"><%= isTeacher ? "Unit performance analytics and defaulter surveillance" : "Personal attendance log and compliance metrics" %></p>
            </header>

            <% if (!isTeacher) { %>
            <!-- STUDENT VIEW -->
            <!-- STATS -->
            <div class="grid grid-cols-12 gap-8">
                <div class="col-span-12 md:col-span-4 glass p-8 border-l-4 <%= percentage < 75 ? "border-red-500" : "border-green-500" %>">
                    <span class="text-[7px] <%= percentage < 75 ? "text-red-500" : "text-green-500" %> font-bold tracking-[0.4em] mb-2 block uppercase">Attendance Rate</span>
                    <div class="text-7xl font-[Orbitron] text-gray-900 mb-4"><%= String.format("%.0f", percentage) %><span class="text-2xl opacity-30">%</span></div>
                    <div class="w-full h-1.5 bg-black/5 overflow-hidden rounded-full"><div class="h-full rounded-full <%= percentage < 75 ? "bg-red-500" : "bg-green-500" %>" style="width:<%= Math.min(percentage, 100) %>%"></div></div>
                    <% if (percentage < 75) { %>
                    <div class="mt-4 flex items-center gap-2 text-[8px] text-red-500 font-bold uppercase tracking-widest">
                        <i data-lucide="alert-triangle" class="w-3 h-3"></i> WARNING: Low Attendance
                    </div>
                    <% } %>
                </div>
                <div class="col-span-6 md:col-span-4 glass p-8">
                    <span class="label-tactical">Total Classes</span>
                    <div class="text-5xl font-[Orbitron] text-gray-900"><%= totalClasses %></div>
                </div>
                <div class="col-span-6 md:col-span-4 glass p-8">
                    <span class="label-tactical">Classes Attended</span>
                    <div class="text-5xl font-[Orbitron] text-green-500"><%= presentCount %></div>
                </div>
            </div>

            <!-- FILTERS -->
            <div class="glass p-6 border-l-4 border-black">
                <form method="get" class="flex flex-wrap gap-6 items-end">
                    <div>
                        <label class="label-tactical">Filter by Month</label>
                        <input type="month" name="month" value="<%= filterMonth != null ? filterMonth : "" %>" class="input-tactical">
                    </div>
                    <div>
                        <label class="label-tactical">Filter by Subject</label>
                        <input type="text" name="subject" value="<%= filterSubject != null ? filterSubject : "" %>" placeholder="ALL" class="input-tactical">
                    </div>
                    <button type="submit" class="bg-black text-white px-8 py-3 font-[Orbitron] text-[10px] tracking-widest uppercase hover:bg-red-500 transition-all font-bold">Apply</button>
                </form>
            </div>

            <!-- RECORDS TABLE -->
            <div class="glass p-8 border-l-4 border-black">
                <div class="flex items-center gap-4 mb-6">
                    <i data-lucide="list" class="w-4 h-4 text-gray-500"></i>
                    <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Attendance Records</h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-[10px] font-bold">
                        <thead>
                            <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/10">
                                <th class="py-4 text-left">Date</th>
                                <th class="py-4 text-left">Subject</th>
                                <th class="py-4 text-center">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (records.isEmpty()) { %>
                            <tr><td colspan="3" class="py-10 text-center text-gray-300 uppercase tracking-widest">No_Records_Found</td></tr>
                            <% } else { for (Map<String, String> r : records) { %>
                            <tr class="border-b border-black/5">
                                <td class="py-4 font-mono text-gray-500"><%= r.get("date") %></td>
                                <td class="py-4 uppercase text-gray-700"><%= r.get("subject") %></td>
                                <td class="py-4 text-center">
                                    <span class="px-3 py-1 text-[7px] tracking-widest uppercase font-bold <%= "PRESENT".equals(r.get("status")) ? "bg-green-500/10 text-green-600" : "bg-red-500/10 text-red-500" %>"><%= r.get("status") %></span>
                                </td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <% } else { %>
            <!-- TEACHER VIEW: DEFAULTER LIST -->
            <div class="glass p-8 border-l-4 border-red-500">
                <div class="flex items-center gap-4 mb-8">
                    <i data-lucide="shield-alert" class="w-5 h-5 text-red-500"></i>
                    <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Unit_Performance_Matrix</h2>
                    <span class="text-[7px] text-gray-400 font-bold tracking-widest uppercase ml-auto">Threshold: 75%</span>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-[10px] font-bold">
                        <thead>
                            <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/10">
                                <th class="py-4 text-left">Unit_Name</th>
                                <th class="py-4 text-left">Course</th>
                                <th class="py-4 text-left">Batch</th>
                                <th class="py-4 text-center">Total</th>
                                <th class="py-4 text-center">Present</th>
                                <th class="py-4 text-right">Compliance_%</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (defaulters.isEmpty()) { %>
                            <tr><td colspan="6" class="py-10 text-center text-gray-300 uppercase tracking-widest">No_Data_Available</td></tr>
                            <% } else { for (Map<String, String> d : defaulters) { boolean isDef = "true".equals(d.get("defaulter")); %>
                            <tr class="border-b border-black/5 <%= isDef ? "bg-red-500/[0.02]" : "" %>">
                                <td class="py-4">
                                    <div class="flex items-center gap-2">
                                        <% if (isDef) { %><i data-lucide="alert-triangle" class="w-3 h-3 text-red-500"></i><% } %>
                                        <span class="uppercase <%= isDef ? "text-red-500" : "text-gray-900" %>"><%= d.get("name") %></span>
                                    </div>
                                </td>
                                <td class="py-4 uppercase text-gray-500"><%= d.get("course") %></td>
                                <td class="py-4 uppercase text-gray-500"><%= d.get("batch") %></td>
                                <td class="py-4 text-center font-mono"><%= d.get("total") %></td>
                                <td class="py-4 text-center font-mono"><%= d.get("present") %></td>
                                <td class="py-4 text-right">
                                    <span class="font-[Orbitron] text-sm <%= isDef ? "text-red-500" : "text-green-500" %>"><%= d.get("pct") %></span>
                                    <span class="text-[8px] text-gray-300 ml-1">%</span>
                                </td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>
        </main>
    </div>
    <script>lucide.createIcons();</script>
</body>
</html>
