<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());
    List<Classroom> myClasses = new ArrayList<>();
    List<Map<String, String>> activeMeetings = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Fetch Active Meetings
        String meetSql = "SELECT * FROM meetings WHERE status = 'ACTIVE' ORDER BY created_at DESC";
        try (PreparedStatement psMeet = conn.prepareStatement(meetSql);
             ResultSet rsMeet = psMeet.executeQuery()) {
            while (rsMeet.next()) {
                Map<String, String> m = new HashMap<>();
                m.put("id", rsMeet.getString("meeting_id"));
                m.put("teacher", rsMeet.getString("teacher_name"));
                m.put("heading", rsMeet.getString("heading"));
                activeMeetings.add(m);
            }
        }
        if (isTeacher) {
            String sql = "SELECT c.*, (SELECT COUNT(*) FROM class_students cs WHERE cs.class_id = c.id) AS student_count " +
                         "FROM classes c WHERE c.teacher_id = ? ORDER BY c.created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Classroom cl = new Classroom();
                    cl.setId(rs.getInt("id"));
                    cl.setName(rs.getString("name"));
                    cl.setDescription(rs.getString("description"));
                    cl.setClassCode(rs.getString("class_code"));
                    cl.setTeacherId(rs.getInt("teacher_id"));
                    cl.setCreatedAt(rs.getTimestamp("created_at"));
                    cl.setStudentCount(rs.getInt("student_count"));
                    myClasses.add(cl);
                }
            }
        } else {
            String sql = "SELECT c.*, u.full_name AS teacher_name, " +
                         "(SELECT COUNT(*) FROM class_students cs WHERE cs.class_id = c.id) AS student_count " +
                         "FROM classes c " +
                         "JOIN class_students cs2 ON cs2.class_id = c.id " +
                         "JOIN users u ON u.id = c.teacher_id " +
                         "WHERE cs2.student_id = ? ORDER BY c.created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Classroom cl = new Classroom();
                    cl.setId(rs.getInt("id"));
                    cl.setName(rs.getString("name"));
                    cl.setDescription(rs.getString("description"));
                    cl.setClassCode(rs.getString("class_code"));
                    cl.setTeacherName(rs.getString("teacher_name"));
                    cl.setCreatedAt(rs.getTimestamp("created_at"));
                    cl.setStudentCount(rs.getInt("student_count"));
                    myClasses.add(cl);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Color palette for class cards
    String[] cardColors = {"#4285F4", "#0F9D58", "#DB4437", "#F4B400", "#AB47BC", "#00ACC1", "#FF7043", "#5C6BC0"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Classroom Hub - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255,255,255,0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0,0,0,0.05); }
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        .input-tactical { @apply w-full bg-white/50 border border-black/5 p-3 text-[10px] font-bold uppercase tracking-widest font-[Orbitron] focus:border-red-500 outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
        @keyframes entry { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .animate-entry { animation: entry 0.5s ease-out forwards; opacity: 0; }
        .class-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .class-card:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.08); }
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
            <span>GURUKUL_ILE / CLASSROOM_HUB</span>
            <span class="opacity-30 mx-2">|</span>
            <span class="text-[7px] text-red-500/80 tracking-widest uppercase">ACTIVE_CLASSES: <%= myClasses.size() %></span>
        </div>
        <div class="flex items-center gap-6">
            <span class="hidden md:inline text-gray-300 whitespace-nowrap">ROLE: <%= user.getRole().toUpperCase() %></span>
            <div class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20">UNIT_ID: <%= user.getUserName() %></div>
        </div>
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
                        <a href="classes.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                            <i data-lucide="book-open" class="w-5 h-5 text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[02]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Classes</span>
                        </a>
                        <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="video" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[03]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Briefings</span>
                        </a>
                        <a href="markAttendance.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="clipboard-check" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[04]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Attendance</span>
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
                    <% } else { %>
                        <a href="dashboard.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                            <i data-lucide="home" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[01]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Dashboard</span>
                        </a>
                        <a href="classes.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                            <i data-lucide="book-open" class="w-5 h-5 text-red-500"></i>
                            <span class="terminal-index hidden md:group-hover/sidebar:block">[02]</span>
                            <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Classes</span>
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
                    <% } %>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 mt-auto w-full">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[99]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Logout</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="flex-grow overflow-y-auto p-8 flex flex-col gap-8 scrollbar-hide">

            <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="glass border-l-4 border-green-500 p-4 bg-green-500/5 flex items-center gap-4">
                <i data-lucide="check-circle" class="w-5 h-5 text-green-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-green-700">Success</span>
            </div>
            <% } else if ("error".equals(request.getParameter("status"))) { %>
            <div class="glass border-l-4 border-red-500 p-4 bg-red-500/5 flex items-center gap-4">
                <i data-lucide="alert-circle" class="w-5 h-5 text-red-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-red-700">Error: <%= request.getParameter("msg") != null ? request.getParameter("msg") : "Unknown" %></span>
            </div>
            <% } %>

            <!-- LIVE BRIEFING SIGNAL -->
            <% if (!activeMeetings.isEmpty()) {
                Map<String, String> meeting = activeMeetings.get(0);
            %>
            <div class="animate-pulse">
                <div class="glass border-l-4 border-red-500 p-6 flex flex-col md:flex-row justify-between items-center gap-6 bg-red-500/[0.02]">
                    <div class="flex items-center gap-6">
                        <div class="relative">
                            <i data-lucide="radio" class="w-8 h-8 text-red-500"></i>
                            <div class="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full animate-ping"></div>
                        </div>
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

            <!-- HEADER -->
            <header class="border-b border-black/5 pb-8 animate-entry">
                <div class="flex justify-between items-center">
                    <div>
                        <h1 class="font-[Orbitron] text-3xl tracking-[0.15em] uppercase text-gray-900 font-black">Classroom</h1>
                        <p class="text-[9px] text-gray-400 tracking-[0.5em] uppercase font-bold mt-2">
                            <span class="text-red-500/50">ACTIVE</span> / <%= isTeacher ? "YOUR CLASSES" : "ENROLLED CLASSES" %>
                        </p>
                    </div>
                    <% if (isTeacher) { %>
                    <button onclick="openCreateModal()" class="bg-red-500 text-white px-6 py-3 font-[Orbitron] text-[10px] tracking-[0.2em] font-black uppercase hover:bg-black transition-all shadow-xl flex items-center gap-3">
                        <i data-lucide="plus" class="w-4 h-4"></i> Create Class
                    </button>
                    <% } else { %>
                    <button onclick="openJoinModal()" class="bg-red-500 text-white px-6 py-3 font-[Orbitron] text-[10px] tracking-[0.2em] font-black uppercase hover:bg-black transition-all shadow-xl flex items-center gap-3">
                        <i data-lucide="log-in" class="w-4 h-4"></i> Join Class
                    </button>
                    <% } %>
                </div>
            </header>

            <!-- CLASS GRID -->
            <% if (myClasses.isEmpty()) { %>
            <div class="glass p-16 text-center flex flex-col items-center gap-6 animate-entry" style="animation-delay: 0.1s">
                <i data-lucide="book-open" class="w-16 h-16 text-gray-200"></i>
                <h3 class="font-[Orbitron] text-sm tracking-widest uppercase text-gray-400">No Classes Found</h3>
                <p class="text-[10px] text-gray-300 tracking-widest uppercase">
                    <%= isTeacher ? "Create your first class to get started" : "Join a class using the class code from your teacher" %>
                </p>
            </div>
            <% } else { %>
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                <% for (int i = 0; i < myClasses.size(); i++) {
                    Classroom cl = myClasses.get(i);
                    String color = cardColors[i % cardColors.length];
                %>
                <a href="class_detail.jsp?id=<%= cl.getId() %>" class="class-card animate-entry block" style="animation-delay: <%= (i * 0.08) %>s">
                    <div class="overflow-hidden border border-black/5 bg-white hover:shadow-xl transition-all">
                        <!-- Color Banner -->
                        <div class="h-28 relative flex items-end p-6" style="background: <%= color %>;">
                            <div class="absolute top-4 right-4 text-white/20 font-[Orbitron] text-[40px] font-black leading-none"><%= cl.getName().substring(0, Math.min(2, cl.getName().length())).toUpperCase() %></div>
                            <h3 class="font-[Orbitron] text-lg text-white font-black uppercase tracking-wider relative z-10 leading-tight"><%= cl.getName() %></h3>
                        </div>
                        <!-- Body -->
                        <div class="p-6">
                            <% if (cl.getDescription() != null && !cl.getDescription().isEmpty()) { %>
                            <p class="text-[11px] text-gray-500 mb-4 leading-relaxed line-clamp-2"><%= cl.getDescription() %></p>
                            <% } %>
                            <div class="flex justify-between items-center pt-4 border-t border-black/5">
                                <div class="flex items-center gap-2 text-[8px] text-gray-400 uppercase tracking-widest font-bold">
                                    <i data-lucide="users" class="w-3 h-3"></i>
                                    <span><%= cl.getStudentCount() %> Students</span>
                                </div>
                                <% if (isTeacher) { %>
                                <div class="bg-black/5 px-3 py-1 text-[8px] font-[Orbitron] text-gray-500 tracking-widest uppercase"><%= cl.getClassCode() %></div>
                                <% } else { %>
                                <div class="text-[8px] text-gray-400 tracking-widest font-bold uppercase"><%= cl.getTeacherName() %></div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </a>
                <% } } %>
            </div>
        </main>
    </div>

    <!-- CREATE CLASS MODAL (Teacher) -->
    <div id="create-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" onclick="closeCreateModal()"></div>
        <div class="glass max-w-lg w-full p-0 relative border border-black/10 shadow-2xl bg-white">
            <div class="bg-[#0a0a0a] px-8 py-4 flex justify-between items-center text-white">
                <div class="flex items-center gap-3">
                    <i data-lucide="plus-circle" class="w-4 h-4 text-red-500"></i>
                    <h2 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black">Create_New_Class</h2>
                </div>
                <button onclick="closeCreateModal()"><i data-lucide="x" class="w-4 h-4 text-gray-400"></i></button>
            </div>
            <div class="p-10">
                <form action="classAction" method="post" class="space-y-6">
                    <input type="hidden" name="action" value="CREATE_CLASS">
                    <input type="hidden" name="source" value="classes.jsp">
                    <div>
                        <label class="label-tactical">Class_Name</label>
                        <input type="text" name="name" placeholder="ADVANCED_ALGORITHMS" class="input-tactical" required>
                    </div>
                    <div>
                        <label class="label-tactical">Description</label>
                        <textarea name="description" rows="3" class="input-tactical" placeholder="COURSE_DESCRIPTION..."></textarea>
                    </div>
                    <button type="submit" class="w-full bg-red-500 text-white py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase font-black hover:bg-black transition-all shadow-xl flex items-center justify-center gap-3">
                        <i data-lucide="rocket" class="w-4 h-4"></i> Deploy_Class
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- JOIN CLASS MODAL (Student) -->
    <div id="join-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" onclick="closeJoinModal()"></div>
        <div class="glass max-w-lg w-full p-0 relative border border-black/10 shadow-2xl bg-white">
            <div class="bg-[#0a0a0a] px-8 py-4 flex justify-between items-center text-white">
                <div class="flex items-center gap-3">
                    <i data-lucide="log-in" class="w-4 h-4 text-red-500"></i>
                    <h2 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black">Join_Class</h2>
                </div>
                <button onclick="closeJoinModal()"><i data-lucide="x" class="w-4 h-4 text-gray-400"></i></button>
            </div>
            <div class="p-10">
                <form action="classAction" method="post" class="space-y-6">
                    <input type="hidden" name="action" value="JOIN_CLASS">
                    <input type="hidden" name="source" value="classes.jsp">
                    <div>
                        <label class="label-tactical">Class_Code</label>
                        <input type="text" name="class_code" placeholder="ENTER_CODE" class="input-tactical text-center text-xl tracking-[1em]" maxlength="6" required style="letter-spacing: 0.8em; text-transform: uppercase;">
                        <p class="text-[8px] text-gray-400 tracking-widest uppercase mt-3">Ask your teacher for the 6-character class code</p>
                    </div>
                    <button type="submit" class="w-full bg-red-500 text-white py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase font-black hover:bg-black transition-all shadow-xl flex items-center justify-center gap-3">
                        <i data-lucide="link" class="w-4 h-4"></i> Connect_to_Class
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
        function openCreateModal() { document.getElementById('create-modal').classList.remove('hidden'); }
        function closeCreateModal() { document.getElementById('create-modal').classList.add('hidden'); }
        function openJoinModal() { document.getElementById('join-modal').classList.remove('hidden'); }
        function closeJoinModal() { document.getElementById('join-modal').classList.add('hidden'); }
        document.getElementById('mobile-toggle')?.addEventListener('click', () => document.getElementById('sidebar-module').classList.remove('-translate-x-full'));
    </script>
</body>
</html>
