<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection, java.text.SimpleDateFormat" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<NoticeBoard> notices = new ArrayList<>();
    List<EventBean> events = new ArrayList<>();
    List<Map<String, String>> activeMeetings = new ArrayList<>();
    List<Map<String, String>> myLeaves = new ArrayList<>();
    List<Map<String, String>> myAssignments = new ArrayList<>();
    List<Map<String, String>> myQuizzes = new ArrayList<>();
    List<Map<String, String>> myResults = new ArrayList<>();
    int attendTotal = 0; int attendPresent = 0; double attendPct = 0.0;


    try (Connection conn = DBConnection.getConnection(getServletContext())) {
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

        // Fetch Notices
        String noticeSql = "SELECT * FROM noticeboard ORDER BY created_at DESC LIMIT 5";
        try (PreparedStatement psNotice = conn.prepareStatement(noticeSql);
             ResultSet rsNotice = psNotice.executeQuery()) {
            while (rsNotice.next()) {
                NoticeBoard nb = new NoticeBoard();
                nb.setId(rsNotice.getInt("id"));
                nb.setHeading(rsNotice.getString("heading"));
                nb.setBody(rsNotice.getString("body"));
                nb.setCreatedAt(rsNotice.getTimestamp("created_at"));
                nb.setWhom(rsNotice.getString("whom"));
                notices.add(nb);
            }
        }

        // Fetch Events
        String eventSql = "SELECT * FROM events WHERE event_date >= CURDATE() ORDER BY event_date ASC";
        try (PreparedStatement psEvent = conn.prepareStatement(eventSql);
             ResultSet rsEvent = psEvent.executeQuery()) {
            while (rsEvent.next()) {
                EventBean eb = new EventBean();
                eb.setId(rsEvent.getInt("id"));
                eb.setEventName(rsEvent.getString("event_name"));
                eb.setEventDate(rsEvent.getDate("event_date"));
                eb.setDescription(rsEvent.getString("description"));
                events.add(eb);
            }
        }

        // Fetch My Leaves
        String leaveSql = "SELECT * FROM leave_requests WHERE student_id = ? ORDER BY applied_at DESC";
        try (PreparedStatement psLeave = conn.prepareStatement(leaveSql)) {
            psLeave.setInt(1, user.getId());
            try (ResultSet rsLeave = psLeave.executeQuery()) {
                while (rsLeave.next()) {
                    Map<String, String> l = new HashMap<>();
                    l.put("reason", rsLeave.getString("reason"));
                    l.put("start", rsLeave.getString("start_date"));
                    l.put("end", rsLeave.getString("end_date"));
                    l.put("status", rsLeave.getString("status"));
                    myLeaves.add(l);
                }
            }
        }

        // Fetch My Assignments & Grades
        String assignmentSql = "SELECT a.id, a.title, a.due_date, c.name as class_name, s.grade, " +
                               "(CASE WHEN s.grade IS NOT NULL THEN 'GRADED' " +
                               "WHEN s.id IS NOT NULL THEN 'SUBMITTED' " +
                               "ELSE 'NOT_SUBMITTED' END) as submission_status " +
                               "FROM assignments a " +
                               "JOIN classes c ON a.class_id = c.id " +
                               "JOIN class_students cs ON c.id = cs.class_id " +
                               "LEFT JOIN submissions s ON a.id = s.assignment_id AND s.student_id = cs.student_id " +
                               "WHERE cs.student_id = ? " +
                               "ORDER BY a.due_date ASC LIMIT 10";
        try (PreparedStatement psAss = conn.prepareStatement(assignmentSql)) {
            psAss.setInt(1, user.getId());
            try (ResultSet rsAss = psAss.executeQuery()) {
                while (rsAss.next()) {
                    Map<String, String> a = new HashMap<>();
                    a.put("id", rsAss.getString("id"));
                    a.put("title", rsAss.getString("title"));
                    a.put("due_date", rsAss.getString("due_date"));
                    a.put("class_name", rsAss.getString("class_name"));
                    a.put("grade", rsAss.getString("grade"));
                    a.put("status", rsAss.getString("submission_status"));
                    myAssignments.add(a);
                }
            }
        }

        // Fetch My Quizzes
        String quizSql = "SELECT q.id, q.title, c.id as class_id, c.name as class_name, qs.score, qs.total_marks " +
                         "FROM quizzes q " +
                         "JOIN classes c ON q.class_id = c.id " +
                         "JOIN class_students cs ON c.id = cs.class_id " +
                         "LEFT JOIN quiz_submissions qs ON q.id = qs.quiz_id AND qs.student_id = cs.student_id " +
                         "WHERE cs.student_id = ? ORDER BY q.created_at DESC LIMIT 5";
        try (PreparedStatement psQz = conn.prepareStatement(quizSql)) {
            psQz.setInt(1, user.getId());
            try (ResultSet rsQz = psQz.executeQuery()) {
                while (rsQz.next()) {
                    Map<String, String> qMap = new HashMap<>();
                    qMap.put("id", rsQz.getString("id"));
                    qMap.put("title", rsQz.getString("title"));
                    qMap.put("class_id", rsQz.getString("class_id"));
                    qMap.put("class_name", rsQz.getString("class_name"));
                    String score = rsQz.getString("score");
                    String totalMarks = rsQz.getString("total_marks");
                    if (score != null) {
                        qMap.put("status", "COMPLETED");
                        qMap.put("score_text", score + " / " + totalMarks);
                    } else {
                        qMap.put("status", "PENDING");
                        qMap.put("score_text", "--");
                    }
                    myQuizzes.add(qMap);
                }
            }
        }

        // Fetch Attendance Stats
        String attSql = "SELECT COUNT(*) as total, SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) as present_count FROM attendance WHERE student_id = ?";
        try (PreparedStatement psAtt = conn.prepareStatement(attSql)) {
            psAtt.setInt(1, user.getId());
            try (ResultSet rsAtt = psAtt.executeQuery()) {
                if (rsAtt.next()) { attendTotal = rsAtt.getInt("total"); attendPresent = rsAtt.getInt("present_count"); }
            }
        }
        attendPct = attendTotal > 0 ? (attendPresent * 100.0 / attendTotal) : 0;

        // Fetch Academic Results
        try {
            String resultSql = "SELECT r.*, c.name as class_name FROM student_results r JOIN classes c ON r.class_id = c.id WHERE r.student_id = ?";
            try (PreparedStatement psR = conn.prepareStatement(resultSql)) {
                psR.setInt(1, user.getId());
                try (ResultSet rsR = psR.executeQuery()) {
                    while (rsR.next()) {
                        Map<String, String> res = new HashMap<>();
                        res.put("class_id", rsR.getString("class_id"));
                        res.put("class_name", rsR.getString("class_name"));
                        res.put("grade", rsR.getString("grade"));
                        res.put("status", rsR.getString("status"));
                        res.put("total_marks", rsR.getString("total_marks"));
                        myResults.add(res);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Notice: result tables might not exist yet.");
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    SimpleDateFormat dayFormat = new SimpleDateFormat("dd");
    SimpleDateFormat monthFormat = new SimpleDateFormat("MMMM");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Network Terminal - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0, 0, 0, 0.05); }
        .neon-glow:hover { box-shadow: 0 10px 40px rgba(255, 51, 51, 0.1); border-color: rgba(255, 51, 51, 0.3); }
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        @keyframes blink { 0%, 50%, 100% { opacity: 1; } 25%, 75% { opacity: 0; } }
        @keyframes scan { 0% { transform: translateY(-100%); } 100% { transform: translateY(300%); } }
        @keyframes entry { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        #cursor { animation: blink 1.2s infinite; margin-left: 4px; }
        .animate-entry { animation: entry 0.6s ease-out forwards; }
        .hud-corner { @apply absolute w-5 h-5 border-red-500 z-20; }
        .terminal-index { @apply text-[7px] text-gray-300 font-bold tracking-widest mr-2; }
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
            <span>GURUKUL_ILE / STUDENT_NODE</span>
            <span class="opacity-30 mx-2">|</span>
            <span class="text-[7px] text-red-500/80 tracking-widest uppercase">SIG_STRENGTH: <%= activeMeetings.size() > 0 ? "98%" : "0%" %></span>
        </div>
        <div class="flex items-center gap-6">
            <span class="hidden md:inline text-gray-300 whitespace-nowrap">STATUS: ENCRYPTED // ARCH_V5</span>
            <div class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20">UNIT_ID: <%= user.getUserName() %></div>
        </div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="connector-line left-[39px] md:group-hover/sidebar:left-[47px] hidden md:block"></div>
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="hud-corner bottom-2 right-2 border-b-2 border-r-2 border-red-500"></div>
                
                <div class="w-full flex md:flex-col items-center md:items-start px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20 cursor-pointer" onclick="location.href='dashboard.jsp'">GKL</div>
                </div>

                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="dashboard.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="home" class="w-5 h-5 text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[01]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Dashboard</span>
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
                    <a href="viewAttendance.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="bar-chart-3" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[04]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Attendance</span>
                    </a>
                    <a href="userProfile.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="user" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[05]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Profile</span>
                    </a>
                    <a href="javascript:void(0)" onclick="openLeaveModal()" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="file-text" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[06]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Leave Request</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 mt-auto w-full">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[99]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Logout</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN -->
        <main class="flex-grow overflow-y-auto p-8 flex flex-col gap-12 scrollbar-hide">
            <header class="border-b border-black/5 pb-10 animate-entry">
                <h1 class="font-[Orbitron] text-5xl tracking-[0.2em] mb-3 uppercase text-gray-900">
                    HI, <span id="heroText" class="text-red-500"></span><span id="cursor" class="text-red-500">|</span>
                </h1>
                <p class="text-[9px] text-gray-400 tracking-[0.5em] uppercase font-bold">
                    <span class="text-red-500/50">READY</span> / GURUKUL / <%= user.getCourse() %>
                </p>
            </header>

            <div class="grid grid-cols-12 gap-8">
                <!-- LIVE BROADCAST -->
                <% if (!activeMeetings.isEmpty()) { 
                    Map<String, String> meeting = activeMeetings.get(0);
                %>
                <div class="col-span-12 animate-pulse">
                    <div class="glass border-l-4 border-red-500 p-6 flex flex-col md:flex-row justify-between items-center gap-6 bg-red-500/[0.02]">
                        <div class="flex items-center gap-6">
                            <i data-lucide="radio" class="w-8 h-8 text-red-500"></i>
                            <div>
                                <h3 class="font-[Orbitron] text-sm tracking-[0.3em] font-black text-gray-900 uppercase">Live Session: Join Now</h3>
                                <p class="text-[9px] text-gray-400 tracking-[0.2em] uppercase font-bold mt-1">From: <%= meeting.get("teacher") %></p>
                            </div>
                        </div>
                        <a href="meeting.jsp?id=<%= meeting.get("id") %>&room=<%= meeting.get("teacher") %>" class="bg-[#0a0a0a] text-white px-10 py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase hover:bg-red-500 transition-all shadow-2xl flex items-center gap-3 group">
                            Join Session <i data-lucide="arrow-right" class="w-4 h-4 group-hover:translate-x-1"></i>
                        </a>
                    </div>
                </div>
                <% } %>

                <!-- NOTICES -->
                <div class="col-span-12 lg:col-span-8 glass border-l-4 border-black p-8 relative overflow-hidden group neon-glow transition-all">
                    <div class="flex justify-between items-center mb-10 pb-4 border-b border-black/5">
                        <h2 class="font-[Orbitron] text-xs tracking-[0.4em] text-gray-400 uppercase">Announcements</h2>
                        <div class="flex gap-2" id="sliderDots">
                            <% for(int i=0; i<notices.size(); i++) { %>
                                <div class="h-1 w-3 bg-black/10 transition-all slider-dot" data-index="<%= i %>"></div>
                            <% } %>
                        </div>
                    </div>
                    <div class="relative overflow-hidden min-h-[160px]">
                        <div id="noticeSlider" class="flex transition-transform duration-700">
                            <% if (notices.isEmpty()) { %>
                                <div class="min-w-full text-center text-[10px] text-gray-300 font-bold tracking-widest py-10 uppercase">No New Announcements</div>
                            <% } else { for (NoticeBoard nb : notices) { %>
                                <div class="min-w-full">
                                    <h3 class="font-[Orbitron] font-bold text-3xl mb-4 uppercase tracking-tighter text-gray-900"><%= nb.getHeading() %></h3>
                                    <p class="text-sm text-gray-600 mb-8 leading-relaxed"><%= nb.getBody() %></p>
                                    <div class="flex gap-8 text-[8px] text-gray-400 font-bold uppercase tracking-widest">
                                        <span>From: <%= nb.getWhom() %></span>
                                        <span>Date: <%= dayFormat.format(nb.getCreatedAt()) %>/<%= monthFormat.format(nb.getCreatedAt()) %></span>
                                    </div>
                                </div>
                            <% } } %>
                        </div>
                    </div>
                </div>

                <!-- EVENTS -->
                <div class="col-span-12 lg:col-span-4 bg-[#0a0a0a] p-8 relative group neon-glow transition-all">
                    <h2 class="font-[Orbitron] text-[10px] tracking-[0.5em] text-gray-500 uppercase mb-8">Upcoming Events</h2>
                    <div class="space-y-8 h-[200px] overflow-y-auto scrollbar-hide">
                        <% if (events.isEmpty()) { %>
                            <div class="text-[8px] text-gray-600 uppercase tracking-widest text-center mt-10">No Upcoming Events</div>
                        <% } else { for (EventBean eb : events) { %>
                            <div class="flex gap-6 items-start">
                                <div class="text-3xl font-[Orbitron] text-white leading-none"><%= dayFormat.format(eb.getEventDate()) %></div>
                                <div>
                                    <div class="text-[8px] font-bold text-red-500/70 mb-1 uppercase tracking-widest"><%= monthFormat.format(eb.getEventDate()) %></div>
                                    <div class="text-[10px] font-bold text-white uppercase tracking-widest"><%= eb.getEventName() %></div>
                                </div>
                            </div>
                        <% } } %>
                    </div>
                </div>

                <!-- STATS -->
                <div class="col-span-12 md:col-span-4 glass p-8">
                    <span class="text-[7px] <%= attendPct < 75 ? "text-red-500" : "text-red-500" %> font-bold tracking-[0.4em] mb-2 block uppercase">Attendance Status</span>
                    <div class="text-7xl font-[Orbitron] text-gray-900 mb-4"><%= attendTotal > 0 ? String.format("%.0f", attendPct) : "--" %><span class="text-2xl opacity-30">%</span></div>
                    <div class="w-full h-1 bg-black/5 overflow-hidden"><div class="h-full <%= attendPct < 75 ? "bg-red-500" : "bg-green-500" %>" style="width:<%= attendTotal > 0 ? Math.min(attendPct, 100) : 0 %>%"></div></div>
                    <span class="text-[8px] text-gray-400 mt-4 block uppercase font-bold tracking-widest">Total Attendance Registry</span>
                    <% if (attendTotal > 0 && attendPct < 75) { %>
                    <div class="mt-2 flex items-center gap-2 text-[8px] text-red-500 font-bold uppercase tracking-widest">
                        <i data-lucide="alert-triangle" class="w-3 h-3"></i> Low Attendance
                    </div>
                    <% } %>
                </div>

                <div class="col-span-12 md:col-span-8 glass p-8 flex flex-col justify-between">
                    <div class="flex justify-between items-start">
                        <div>
                            <span class="text-[7px] text-red-500 font-bold tracking-[0.4em] mb-2 block uppercase">Current_Vect</span>
                            <h2 class="font-[Orbitron] text-lg font-black text-gray-900 uppercase"><%= user.getCourse() %></h2>
                        </div>
                        <div class="bg-red-500 text-white text-[8px] px-3 py-1 font-bold tracking-widest uppercase">ACTIVE_NODE</div>
                    </div>
                    <div class="grid grid-cols-3 gap-8 mt-10 pt-8 border-t border-black/5">
                        <div><span class="label-tactical">Batch</span><p class="text-[10px] font-bold"><%= user.getBatch() %></p></div>
                        <div><span class="label-tactical">Node_Relay</span><p class="text-[10px] font-bold font-mono truncate"><%= user.getEmail() %></p></div>
                        <div><span class="label-tactical">Security</span><p class="text-[10px] font-bold text-green-600">CERTIFIED</p></div>
                    </div>
                </div>

                <!-- ASSIGNMENT LEDGER -->
                <div class="col-span-12 glass border-l-4 border-black p-8">
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-3">
                            <i data-lucide="book-check" class="w-4 h-4 text-gray-900"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Assignment_Ledger</h2>
                        </div>
                        <span class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase">Active_Missions: <%= myAssignments.size() %></span>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-[10px] font-bold">
                            <thead>
                                <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/5">
                                    <th class="py-4 text-left">Mission_Objective</th>
                                    <th class="py-4 text-left">Sector</th>
                                    <th class="py-4 text-left">Deadline</th>
                                    <th class="py-4 text-center">Status</th>
                                    <th class="py-4 text-right">Rating</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myAssignments.isEmpty()) { %>
                                    <tr><td colspan="5" class="py-10 text-center text-gray-300 uppercase tracking-widest">No_Assignments_Assigned</td></tr>
                                <% } else { for (Map<String, String> a : myAssignments) { 
                                    String grade = a.get("grade");
                                    String status = a.get("status");
                                    if (status == null) status = "NOT_SUBMITTED";
                                %>
                                    <tr class="border-b border-black/5 group hover:bg-black/[0.01] transition-colors cursor-pointer" onclick="location.href='assignment_detail.jsp?id=<%= a.get("id") %>'">
                                        <td class="py-4">
                                            <div class="flex flex-col">
                                                <span class="uppercase text-gray-900 group-hover:text-red-500 transition-colors"><%= a.get("title") %></span>
                                                <span class="text-[7px] text-gray-400 mt-0.5">UID: #<%= a.get("id") %></span>
                                            </div>
                                        </td>
                                        <td class="py-4 uppercase text-gray-500"><%= a.get("class_name") %></td>
                                        <td class="py-4 font-mono text-[9px] text-gray-400"><%= a.get("due_date") %></td>
                                        <td class="py-4 text-center">
                                            <span class="px-2 py-1 text-[7px] tracking-widest uppercase <%= "GRADED".equals(status) ? "bg-green-500/10 text-green-500" : "SUBMITTED".equals(status) ? "bg-blue-500/10 text-blue-500" : "bg-red-500/10 text-red-500" %>">
                                                <%= status %>
                                            </span>
                                        </td>
                                        <td class="py-4 text-right">
                                            <% if (grade != null && !grade.isEmpty()) { %>
                                                <span class="font-[Orbitron] text-sm text-gray-900"><%= grade %></span>
                                                <span class="text-[8px] text-gray-300 ml-1">PTS</span>
                                            <% } else { %>
                                                <span class="text-gray-300 font-[Orbitron] text-[10px]">--</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- QUIZ LEDGER -->
                <div class="col-span-12 glass border-l-4 border-black p-8">
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-3">
                            <i data-lucide="help-circle" class="w-4 h-4 text-gray-900"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Quiz Ledger</h2>
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-[10px] font-bold">
                            <thead>
                                <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/5">
                                    <th class="py-4 text-left">Quiz Title</th>
                                    <th class="py-4 text-left">Class</th>
                                    <th class="py-4 text-center">Status</th>
                                    <th class="py-4 text-right">Score</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myQuizzes.isEmpty()) { %>
                                    <tr><td colspan="4" class="py-10 text-center text-gray-300 uppercase tracking-widest">No Quizzes Available</td></tr>
                                <% } else { for (Map<String, String> q : myQuizzes) { 
                                    String status = q.get("status");
                                %>
                                    <tr class="border-b border-black/5 group hover:bg-black/[0.01] transition-colors cursor-pointer" onclick="location.href='<%= "COMPLETED".equals(status) ? "quizResult.jsp" : "takeQuiz.jsp" %>?id=<%= q.get("id") %>&class_id=<%= q.get("class_id") %>'">
                                        <td class="py-4">
                                            <div class="flex flex-col">
                                                <span class="uppercase text-gray-900 group-hover:text-red-500 transition-colors"><%= q.get("title") %></span>
                                            </div>
                                        </td>
                                        <td class="py-4 uppercase text-gray-500"><%= q.get("class_name") %></td>
                                        <td class="py-4 text-center">
                                            <span class="px-2 py-1 text-[7px] tracking-widest uppercase <%= "COMPLETED".equals(status) ? "bg-green-500/10 text-green-500" : "bg-yellow-500/10 text-yellow-500" %>">
                                                <%= status %>
                                            </span>
                                        </td>
                                        <td class="py-4 text-right">
                                            <span class="font-[Orbitron] text-sm text-gray-900"><%= q.get("score_text") %></span>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- ACADEMIC RESULTS LEDGER -->
                <div class="col-span-12 glass border-l-4 border-black p-8">
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-3">
                            <i data-lucide="award" class="w-4 h-4 text-gray-900"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Academic Results</h2>
                        </div>
                        <button onclick="location.href='detailedResult.jsp'" class="bg-black text-white px-4 py-2 font-[Orbitron] text-[8px] tracking-[0.2em] font-black uppercase hover:bg-red-500 transition-all flex items-center gap-2">
                            <i data-lucide="file-text" class="w-3 h-3"></i> Generate Marksheet
                        </button>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-[10px] font-bold">
                            <thead>
                                <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/5">
                                    <th class="py-4 text-left">Class Name</th>
                                    <th class="py-4 text-center">Grade</th>
                                    <th class="py-4 text-center">Status</th>
                                    <th class="py-4 text-right">Total Marks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myResults.isEmpty()) { %>
                                    <tr><td colspan="4" class="py-10 text-center text-gray-300 uppercase tracking-widest">No Results Published Yet</td></tr>
                                <% } else { for (Map<String, String> r : myResults) { 
                                    String status = r.get("status");
                                %>
                                    <tr class="border-b border-black/5 group hover:bg-black/[0.01] transition-colors">
                                        <td class="py-4 uppercase text-gray-900 group-hover:text-red-500 transition-colors"><%= r.get("class_name") %></td>
                                        <td class="py-4 text-center">
                                            <span class="font-[Orbitron] text-sm text-gray-900"><%= r.get("grade") %></span>
                                        </td>
                                        <td class="py-4 text-center">
                                            <span class="px-2 py-1 text-[7px] tracking-widest uppercase <%= "PASS".equals(status) ? "bg-green-500/10 text-green-500" : "bg-red-500/10 text-red-500" %>">
                                                <%= status %>
                                            </span>
                                        </td>
                                        <td class="py-4 text-right font-[Orbitron] text-sm text-gray-900">
                                            <%= r.get("total_marks") %>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- LEAVE STATUS -->
                <div class="col-span-12 glass border-l-4 border-red-500 p-8">
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-3">
                            <i data-lucide="clock" class="w-4 h-4 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Leave_Registry</h2>
                        </div>
                        <button onclick="openLeaveModal()" class="bg-black text-white px-4 py-2 font-[Orbitron] text-[8px] tracking-[0.2em] font-black uppercase hover:bg-red-500 transition-all flex items-center gap-2">
                            <i data-lucide="plus" class="w-3 h-3"></i> Apply_New
                        </button>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-[10px] font-bold">
                            <thead>
                                <tr class="text-[8px] text-gray-400 uppercase tracking-widest border-b border-black/5">
                                    <th class="py-4 text-left">Reason</th>
                                    <th class="py-4 text-left">Duration</th>
                                    <th class="py-4 text-right">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myLeaves.isEmpty()) { %>
                                    <tr><td colspan="3" class="py-10 text-center text-gray-300 uppercase tracking-widest">No_History_Logged</td></tr>
                                <% } else { for (Map<String, String> l : myLeaves) { %>
                                    <tr class="border-b border-black/5">
                                        <td class="py-4 uppercase text-gray-600"><%= l.get("reason") %></td>
                                        <td class="py-4 font-mono text-[9px] text-gray-400"><%= l.get("start") %> // <%= l.get("end") %></td>
                                        <td class="py-4 text-right">
                                            <span class="px-2 py-1 text-[7px] tracking-widest uppercase <%= "APPROVED".equals(l.get("status")) ? "bg-green-500/10 text-green-500" : "PENDING".equals(l.get("status")) ? "bg-yellow-500/10 text-yellow-500" : "bg-red-500/10 text-red-500" %>">
                                                <%= l.get("status") %>
                                            </span>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- LEAVE MODAL -->
    <div id="leave-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-white/80 backdrop-blur-md" onclick="closeLeaveModal()"></div>
        <div class="glass max-w-lg w-full p-0 relative border border-black/10 shadow-2xl bg-white">
            <div class="bg-[#0a0a0a] px-8 py-4 flex justify-between items-center text-white">
                <h2 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black">Leave_Application_Protocol</h2>
                <button onclick="closeLeaveModal()"><i data-lucide="x" class="w-4 h-4 text-gray-400"></i></button>
            </div>
            <div class="p-10">
                <form action="leaveAction" method="post" class="space-y-6">
                    <input type="hidden" name="action" value="APPLY_LEAVE">
                    <input type="hidden" name="source" value="dashboard.jsp">
                    
                    <div>
                        <label class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2">Reason_for_Leave</label>
                        <textarea name="reason" rows="3" class="w-full bg-black/[0.02] border border-black/5 p-4 text-[11px] font-bold uppercase tracking-widest outline-none focus:border-red-500 transition-all placeholder:text-gray-300" placeholder="ENTER_EXPLANATION..." required></textarea>
                    </div>
                    <div class="grid grid-cols-2 gap-6">
                        <div>
                            <label class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2">Start_Vect</label>
                            <input type="date" name="start_date" class="w-full bg-black/[0.02] border border-black/5 p-3 text-[10px] font-bold uppercase tracking-widest outline-none focus:border-red-500 transition-all" required>
                        </div>
                        <div>
                            <label class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2">End_Vect</label>
                            <input type="date" name="end_date" class="w-full bg-black/[0.02] border border-black/5 p-3 text-[10px] font-bold uppercase tracking-widest outline-none focus:border-red-500 transition-all" required>
                        </div>
                    </div>
                    <button type="submit" class="w-full bg-red-500 text-white py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase font-black hover:bg-black transition-all shadow-xl flex items-center justify-center gap-3">
                        <i data-lucide="send" class="w-4 h-4"></i> Commit_Signal
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
        (function() {
            const text = "<%= user.getFullName() %>";
            let index = 0;
            const element = document.getElementById("heroText");
            function type() {
                if (index < text.length) {
                    element.innerHTML += text.charAt(index++);
                    setTimeout(type, 100);
                } else {
                    document.getElementById("cursor").style.display = "none";
                }
            }
            type();

            const slider = document.getElementById('noticeSlider');
            const dots = document.querySelectorAll('.slider-dot');
            const count = <%= notices.size() %>;
            let current = 0;
            if (count > 1) {
                setInterval(() => {
                    current = (current + 1) % count;
                    slider.style.transform = `translateX(-\${current * 100}%)`;
                    dots.forEach((d, i) => d.style.background = i === current ? '#ef4444' : 'rgba(0,0,0,0.1)');
                }, 6000);
            }
        })();
        document.getElementById('mobile-toggle')?.addEventListener('click', () => document.getElementById('sidebar-module').classList.remove('-translate-x-full'));

        function openLeaveModal() { document.getElementById('leave-modal').classList.remove('hidden'); }
        function closeLeaveModal() { document.getElementById('leave-modal').classList.add('hidden'); }
    </script>
</body>
</html>
