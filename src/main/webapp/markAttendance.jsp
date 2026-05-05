<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.gurukul.models.UserProfile, com.gurukul.utils.DBConnection" %>
<%
    if (session.getAttribute("user") == null || !"Teacher".equalsIgnoreCase(((UserProfile)session.getAttribute("user")).getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    UserProfile user = (UserProfile) session.getAttribute("user");

    // Fetch distinct courses and batches for filter
    List<String> courses = new ArrayList<>();
    List<String> batches = new ArrayList<>();
    List<Map<String, String>> students = new ArrayList<>();
    String selectedCourse = request.getParameter("course");
    String selectedBatch = request.getParameter("batch");

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        String courseSql = "SELECT DISTINCT course FROM users WHERE role = 'Student' AND course IS NOT NULL ORDER BY course";
        try (PreparedStatement ps = conn.prepareStatement(courseSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                courses.add(rs.getString("course"));
            }
        }

        // Fetch distinct batches (optionally filtered by course)
        StringBuilder batchSql = new StringBuilder("SELECT DISTINCT batch FROM users WHERE role = 'Student' AND batch IS NOT NULL");
        if (selectedCourse != null && !selectedCourse.isEmpty()) batchSql.append(" AND course = ?");
        batchSql.append(" ORDER BY batch");
        try (PreparedStatement ps = conn.prepareStatement(batchSql.toString())) {
            if (selectedCourse != null && !selectedCourse.isEmpty()) ps.setString(1, selectedCourse);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) batches.add(rs.getString("batch"));
            }
        }

        // If course is selected, fetch students (optionally filtered by batch)
        if (selectedCourse != null && !selectedCourse.isEmpty()) {
            StringBuilder studentSql = new StringBuilder("SELECT id, full_name, username, batch FROM users WHERE role = 'Student' AND course = ?");
            if (selectedBatch != null && !selectedBatch.isEmpty()) studentSql.append(" AND batch = ?");
            studentSql.append(" ORDER BY batch ASC, full_name ASC");
            try (PreparedStatement ps = conn.prepareStatement(studentSql.toString())) {
                ps.setString(1, selectedCourse);
                if (selectedBatch != null && !selectedBatch.isEmpty()) ps.setString(2, selectedBatch);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> s = new HashMap<>();
                        s.put("id", rs.getString("id"));
                        s.put("name", rs.getString("full_name"));
                        s.put("username", rs.getString("username"));
                        s.put("batch", rs.getString("batch") != null ? rs.getString("batch") : "N/A");
                        students.add(s);
                    }
                }
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
    <title>Mark Attendance - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { @apply bg-white/80 backdrop-blur-xl border border-black/5 shadow-[0_8px_32px_rgba(0,0,0,0.05)]; }
        .input-tactical { @apply w-full bg-black/5 border-b-2 border-black/10 px-4 py-3 text-[10px] uppercase font-bold tracking-widest font-[Orbitron] focus:border-red-500 focus:outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.3em] uppercase mb-1 block; }
        .terminal-index { @apply text-[7px] text-gray-300 font-bold tracking-widest mr-2; }
        .connector-line { @apply absolute top-0 bottom-0 w-px bg-gradient-to-b from-transparent via-red-500/20 to-transparent transition-all duration-500; }
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
            <span>GURUKUL_ILE / ATTENDANCE_TERMINAL</span>
            <span class="opacity-30 mx-2">|</span>
            <span class="text-red-500">UNITS_LOADED: <%= students.size() %></span>
        </div>
        <div class="font-[Orbitron] text-red-500 tracking-widest px-2 py-0.5 bg-red-500/5 border border-red-500/20">CMD: <%= user.getUserName() %></div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="connector-line left-[39px] md:group-hover/sidebar:left-[47px] hidden md:block"></div>
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20 cursor-pointer" onclick="location.href='teacherDashboard.jsp'">GKL</div>
                </div>
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
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
                    <a href="markAttendance.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="clipboard-check" class="w-5 h-5 text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[04]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Attendance</span>
                    </a>
                    <a href="viewAttendance.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="bar-chart-3" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[05]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Reports</span>
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
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Add Student</span>
                    </a>
                    <a href="teacherDashboard.jsp#leave-management" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="clipboard-list" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[09]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Leave Request</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full mt-auto">
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
                <h1 class="font-[Orbitron] text-4xl font-black tracking-tighter uppercase text-gray-900 mb-2">Mark<span class="text-red-500"> Attendance</span></h1>
                <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase">Register student attendance for the selected session</p>
            </header>

            <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="glass border-l-4 border-green-500 p-4 bg-green-500/5 flex items-center gap-4">
                <i data-lucide="check-circle" class="w-5 h-5 text-green-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-green-700">Attendance Recorded Successfully // Date: <%= request.getParameter("date") %> // Subject: <%= request.getParameter("subject") %></span>
            </div>
            <% } else if ("error".equals(request.getParameter("status"))) { %>
            <div class="glass border-l-4 border-red-500 p-4 bg-red-500/5 flex items-center gap-4">
                <i data-lucide="alert-triangle" class="w-5 h-5 text-red-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-red-700">Submission Error: <%= request.getParameter("msg") != null ? request.getParameter("msg") : "UNKNOWN" %></span>
            </div>
            <% } %>

            <!-- FILTER PANEL -->
            <div class="glass p-8 border-l-4 border-black">
                <div class="flex items-center gap-4 mb-8">
                    <i data-lucide="filter" class="w-5 h-5 text-gray-500"></i>
                    <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Selection Filters</h2>
                </div>
                <form method="get" class="grid grid-cols-12 gap-8 items-end">
                    <div class="col-span-12 md:col-span-3">
                        <label class="label-tactical">Select Course</label>
                        <select name="course" class="input-tactical" onchange="this.form.submit()">
                            <option value="">-- SELECT COURSE --</option>
                            <% for (String c : courses) { %>
                                <option value="<%= c %>" <%= c.equals(selectedCourse) ? "selected" : "" %>><%= c %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-span-12 md:col-span-2">
                        <label class="label-tactical">Filter by Batch</label>
                        <select name="batch" class="input-tactical" onchange="this.form.submit()">
                            <option value="">ALL BATCHES</option>
                            <% for (String b : batches) { %>
                                <option value="<%= b %>" <%= b.equals(selectedBatch) ? "selected" : "" %>><%= b %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-span-12 md:col-span-3">
                        <label class="label-tactical">Select Date</label>
                        <input type="date" name="date" value="<%= request.getParameter("date") != null ? request.getParameter("date") : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" class="input-tactical">
                    </div>
                    <div class="col-span-12 md:col-span-2">
                        <label class="label-tactical">Subject Name</label>
                        <input type="text" name="subject" value="<%= request.getParameter("subject") != null ? request.getParameter("subject") : "" %>" placeholder="JAVA_ADV" class="input-tactical">
                    </div>
                    <div class="col-span-12 md:col-span-2">
                        <button type="submit" class="w-full bg-black text-white py-4 font-[Orbitron] text-[10px] tracking-[0.4em] font-black uppercase hover:bg-red-500 transition-all shadow-xl">Load</button>
                    </div>
                </form>
            </div>

            <!-- STUDENT ROSTER -->
            <% if (selectedCourse != null && !selectedCourse.isEmpty()) { %>
            <div class="glass p-8 border-l-4 border-red-500">
                <div class="flex justify-between items-center mb-8">
                    <div class="flex items-center gap-4">
                        <i data-lucide="users" class="w-5 h-5 text-red-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Student List: <%= selectedCourse %></h2>
                    </div>
                    <div class="flex items-center gap-4">
                        <button type="button" onclick="markAll('PRESENT')" class="bg-green-500/10 text-green-600 px-4 py-2 text-[8px] font-bold uppercase tracking-widest hover:bg-green-500 hover:text-white transition-all">Mark All Present</button>
                        <button type="button" onclick="markAll('ABSENT')" class="bg-red-500/10 text-red-500 px-4 py-2 text-[8px] font-bold uppercase tracking-widest hover:bg-red-500 hover:text-white transition-all">Mark All Absent</button>
                    </div>
                </div>

                <% if (students.isEmpty()) { %>
                    <div class="py-16 flex flex-col items-center justify-center text-gray-300 gap-4">
                        <i data-lucide="user-x" class="w-12 h-12 opacity-20"></i>
                        <span class="font-[Orbitron] text-[10px] tracking-widest uppercase">No Students Found</span>
                    </div>
                <% } else { %>
                <form action="attendanceAction" method="post" id="attendanceForm">
                    <input type="hidden" name="action" value="MARK_ATTENDANCE">
                    <input type="hidden" name="date" value="<%= request.getParameter("date") != null ? request.getParameter("date") : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    <input type="hidden" name="subject" value="<%= request.getParameter("subject") != null ? request.getParameter("subject") : "GENERAL" %>">

                    <div class="overflow-x-auto">
                        <table class="w-full text-[10px] font-bold">
                            <thead>
                                <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/10">
                                    <th class="py-4 text-left w-10">#</th>
                                    <th class="py-4 text-left">Student Name</th>
                                    <th class="py-4 text-left">Username</th>
                                    <th class="py-4 text-left">Batch</th>
                                    <th class="py-4 text-center">Attendance Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% int idx = 1; for (Map<String, String> s : students) { %>
                                <tr class="border-b border-black/5 group hover:bg-black/[0.02] transition-colors attendance-row" data-student-id="<%= s.get("id") %>">
                                    <td class="py-4 text-gray-300 font-[Orbitron]"><%= String.format("%02d", idx++) %></td>
                                    <td class="py-4">
                                        <div class="flex flex-col">
                                            <span class="uppercase text-gray-900 group-hover:text-red-500 transition-colors"><%= s.get("name") %></span>
                                            <span class="text-[7px] text-gray-400 mt-0.5">UID: #<%= s.get("id") %></span>
                                        </div>
                                    </td>
                                    <td class="py-4 uppercase text-gray-500 font-mono"><%= s.get("username") %></td>
                                    <td class="py-4 uppercase text-gray-500"><%= s.get("batch") %></td>
                                    <td class="py-4 text-center">
                                        <input type="hidden" name="student_id" value="<%= s.get("id") %>">
                                        <div class="flex justify-center gap-2">
                                            <label class="cursor-pointer">
                                                <input type="radio" name="status_<%= s.get("id") %>" value="PRESENT" checked class="hidden peer attendance-radio" data-id="<%= s.get("id") %>">
                                                <span class="px-4 py-2 text-[8px] tracking-widest uppercase bg-black/5 text-gray-400 peer-checked:bg-green-500 peer-checked:text-white transition-all font-bold inline-block">Present</span>
                                            </label>
                                            <label class="cursor-pointer">
                                                <input type="radio" name="status_<%= s.get("id") %>" value="ABSENT" class="hidden peer attendance-radio" data-id="<%= s.get("id") %>">
                                                <span class="px-4 py-2 text-[8px] tracking-widest uppercase bg-black/5 text-gray-400 peer-checked:bg-red-500 peer-checked:text-white transition-all font-bold inline-block">Absent</span>
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <div class="mt-8 flex justify-end">
                        <button type="submit" class="bg-red-500 text-white px-12 py-4 font-[Orbitron] text-[10px] tracking-[0.4em] font-black uppercase hover:bg-black transition-all shadow-xl flex items-center gap-3">
                            <i data-lucide="send" class="w-4 h-4"></i> Deploy_Attendance
                        </button>
                    </div>
                </form>
                <% } %>
            </div>
            <% } %>
        </main>
    </div>

    <script>
        lucide.createIcons();
        document.getElementById('mobile-toggle')?.addEventListener('click', () => document.getElementById('sidebar-module').classList.remove('-translate-x-full'));

        // Mark all present or absent
        function markAll(status) {
            document.querySelectorAll('.attendance-radio').forEach(radio => {
                if (radio.value === status) radio.checked = true;
            });
        }

        // Before submit, map individual radio values to hidden attendance_status fields
        document.getElementById('attendanceForm')?.addEventListener('submit', function(e) {
            // Remove old hidden fields
            this.querySelectorAll('.dynamic-status').forEach(el => el.remove());
            // Add attendance_status for each student
            document.querySelectorAll('.attendance-row').forEach(row => {
                const sid = row.dataset.studentId;
                const checked = row.querySelector('input[name="status_' + sid + '"]:checked');
                if (checked) {
                    const hidden = document.createElement('input');
                    hidden.type = 'hidden';
                    hidden.name = 'attendance_status';
                    hidden.value = checked.value;
                    hidden.className = 'dynamic-status';
                    this.appendChild(hidden);
                }
            });
        });
    </script>
</body>
</html>
