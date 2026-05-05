<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection, java.text.SimpleDateFormat" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());
    int classId = 0;
    try { classId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { response.sendRedirect("classes.jsp"); return; }

    Classroom classroom = null;
    List<Announcement> announcements = new ArrayList<>();
    List<Assignment> assignments = new ArrayList<>();
    List<UserProfile> students = new ArrayList<>();
    List<Quiz> quizzes = new ArrayList<>();
    ResultConfig resultConfig = null;
    List<StudentResult> studentResults = new ArrayList<>();

    String[] cardColors = {"#4285F4", "#0F9D58", "#DB4437", "#F4B400", "#AB47BC", "#00ACC1", "#FF7043", "#5C6BC0"};
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("dd MMM, hh:mm a");

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Fetch class details
        String classSql = "SELECT c.*, u.full_name AS teacher_name FROM classes c JOIN users u ON u.id = c.teacher_id WHERE c.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(classSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                classroom = new Classroom();
                classroom.setId(rs.getInt("id"));
                classroom.setName(rs.getString("name"));
                classroom.setDescription(rs.getString("description"));
                classroom.setTeacherId(rs.getInt("teacher_id"));
                classroom.setTeacherName(rs.getString("teacher_name"));
                classroom.setClassCode(rs.getString("class_code"));
                classroom.setCreatedAt(rs.getTimestamp("created_at"));
            }
        }
        if (classroom == null) { response.sendRedirect("classes.jsp"); return; }

        // Fetch announcements
        String annSql = "SELECT a.*, u.full_name AS author_name FROM class_announcements a JOIN users u ON u.id = a.author_id WHERE a.class_id = ? ORDER BY a.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(annSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Announcement ann = new Announcement();
                ann.setId(rs.getInt("id"));
                ann.setAuthorName(rs.getString("author_name"));
                ann.setContent(rs.getString("content"));
                ann.setCreatedAt(rs.getTimestamp("created_at"));
                announcements.add(ann);
            }
        }

        // Fetch assignments with submission counts
        String asgSql = "SELECT a.*, (SELECT COUNT(*) FROM submissions s WHERE s.assignment_id = a.id) AS sub_count FROM assignments a WHERE a.class_id = ? ORDER BY a.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(asgSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Assignment asg = new Assignment();
                asg.setId(rs.getInt("id"));
                asg.setTitle(rs.getString("title"));
                asg.setDescription(rs.getString("description"));
                asg.setDueDate(rs.getDate("due_date"));
                asg.setMaxMarks(rs.getInt("max_marks"));
                asg.setCreatedAt(rs.getTimestamp("created_at"));
                asg.setSubmissionCount(rs.getInt("sub_count"));
                assignments.add(asg);
            }
        }

        // Fetch quizzes
        String quizSql = "SELECT * FROM quizzes WHERE class_id = ? ORDER BY created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(quizSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Quiz q = new Quiz();
                q.setId(rs.getInt("id"));
                q.setTitle(rs.getString("title"));
                q.setDescription(rs.getString("description"));
                q.setDurationMinutes(rs.getInt("duration_minutes"));
                q.setDueDate(rs.getDate("due_date"));
                q.setCreatedAt(rs.getTimestamp("created_at"));
                quizzes.add(q);
            }
        }

        // Fetch enrolled students
        String stuSql = "SELECT u.* FROM users u JOIN class_students cs ON cs.student_id = u.id WHERE cs.class_id = ? ORDER BY u.full_name ASC";
        try (PreparedStatement ps = conn.prepareStatement(stuSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                UserProfile s = new UserProfile();
                s.setId(rs.getInt("id"));
                s.setFullName(rs.getString("full_name"));
                s.setUserName(rs.getString("username"));
                s.setEmail(rs.getString("email"));
                students.add(s);
            }
        }

        // Fetch Result Config
        try {
            String configSql = "SELECT * FROM result_configs WHERE class_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(configSql)) {
                ps.setInt(1, classId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    resultConfig = new ResultConfig();
                    resultConfig.setClassId(classId);
                    resultConfig.setTheoryMax(rs.getInt("theory_max"));
                    resultConfig.setTheoryPass(rs.getInt("theory_pass"));
                    resultConfig.setInternalMax(rs.getInt("internal_max"));
                    resultConfig.setInternalPass(rs.getInt("internal_pass"));
                    resultConfig.setVivaMax(rs.getInt("viva_max"));
                    resultConfig.setVivaPass(rs.getInt("viva_pass"));
                    resultConfig.setGradeA(rs.getInt("grade_a"));
                    resultConfig.setGradeB(rs.getInt("grade_b"));
                    resultConfig.setGradeC(rs.getInt("grade_c"));
                    resultConfig.setGradeD(rs.getInt("grade_d"));
                }
            }
        } catch (Exception e) {
            System.err.println("Notice: result_configs table might not exist yet. Please run results_tables.sql");
        }

        // Fetch Student Results
        try {
            String resultSql = "SELECT sr.*, u.full_name FROM student_results sr JOIN users u ON u.id = sr.student_id WHERE sr.class_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(resultSql)) {
                ps.setInt(1, classId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    StudentResult sr = new StudentResult();
                    sr.setId(rs.getInt("id"));
                    sr.setClassId(classId);
                    sr.setStudentId(rs.getInt("student_id"));
                    sr.setStudentName(rs.getString("full_name"));
                    sr.setTheoryMarks(rs.getInt("theory_marks"));
                    sr.setInternalMarks(rs.getInt("internal_marks"));
                    sr.setVivaMarks(rs.getInt("viva_marks"));
                    sr.setTotalMarks(rs.getInt("total_marks"));
                    sr.setGrade(rs.getString("grade"));
                    sr.setStatus(rs.getString("status"));
                    studentResults.add(sr);
                }
            }
        } catch (Exception e) {
            System.err.println("Notice: student_results table might not exist yet. Please run results_tables.sql");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String bannerColor = cardColors[classId % cardColors.length];
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= classroom.getName() %> - Gurukul ILE</title>
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
        .tab-btn { @apply px-6 py-3 text-[10px] font-bold uppercase tracking-[0.2em] border-b-2 border-transparent cursor-pointer transition-all hover:text-red-500; }
        .tab-btn.active { @apply border-red-500 text-red-500; }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>

    <!-- TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <a href="classes.jsp" class="p-2 -ml-2 text-gray-400 hover:text-red-500 transition-colors">
                <i data-lucide="arrow-left" class="w-5 h-5"></i>
            </a>
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / CLASSROOM</span>
        </div>
        <div class="flex items-center gap-6">
            <div class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20">USER_ID: <%= user.getUserName() %></div>
        </div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR (mini) -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20">GKL</div>
                </div>
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="<%= isTeacher ? "teacherDashboard.jsp" : "dashboard.jsp" %>" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="home" class="w-5 h-5 text-gray-400"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Dashboard</span>
                    </a>
                    <a href="classes.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="book-open" class="w-5 h-5 text-gray-400"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Classes</span>
                    </a>
                    <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="video" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Sessions</span>
                    </a>
                    <a href="#" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="layout-list" class="w-5 h-5 text-red-500"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Stream</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-black/5 mt-auto w-full">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400"></i>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Logout</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN -->
        <main class="flex-grow overflow-y-auto scrollbar-hide">

            <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="mx-8 mt-4 glass border-l-4 border-green-500 p-4 bg-green-500/5 flex items-center gap-4">
                <i data-lucide="check-circle" class="w-5 h-5 text-green-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-green-700">Success</span>
            </div>
            <% } %>

            <!-- CLASS BANNER -->
            <div class="h-44 relative flex items-end p-8 animate-entry" style="background: <%= bannerColor %>;">
                <div class="absolute top-6 right-8 text-white/10 font-[Orbitron] text-[60px] font-black leading-none"><%= classroom.getName().substring(0, Math.min(3, classroom.getName().length())).toUpperCase() %></div>
                <div class="relative z-10">
                    <h1 class="font-[Orbitron] text-3xl text-white font-black uppercase tracking-wider mb-2"><%= classroom.getName() %></h1>
                    <div class="flex items-center gap-6 text-white/70 text-[10px] font-bold tracking-widest uppercase">
                        <span><i data-lucide="user" class="w-3 h-3 inline mr-1"></i> <%= classroom.getTeacherName() %></span>
                        <span><i data-lucide="users" class="w-3 h-3 inline mr-1"></i> <%= students.size() %> Students</span>
                        <% if (isTeacher) { %>
                        <span class="bg-white/20 px-3 py-1 rounded-sm"><i data-lucide="copy" class="w-3 h-3 inline mr-1"></i> Code: <%= classroom.getClassCode() %></span>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- TABS -->
            <div class="flex items-center gap-0 px-8 border-b border-black/5 bg-white/60 backdrop-blur-md sticky top-0 z-30">
                <button onclick="showTab('stream')" id="tab-stream" class="tab-btn active">Stream</button>
                <button onclick="showTab('assignments')" id="tab-assignments" class="tab-btn">Assignments</button>
                <button onclick="showTab('quizzes')" id="tab-quizzes" class="tab-btn">Quizzes</button>
                <button onclick="showTab('results')" id="tab-results" class="tab-btn">Results</button>
                <button onclick="showTab('people')" id="tab-people" class="tab-btn">People</button>
            </div>

            <div class="p-8">

                <!-- STREAM TAB -->
                <div id="panel-stream" class="tab-panel">
                    <div class="max-w-3xl mx-auto space-y-6">
                        <!-- Announcement Form -->
                        <div class="glass p-6 animate-entry" style="animation-delay: 0.1s">
                            <form action="classAction" method="post" class="flex gap-4 items-start">
                                <input type="hidden" name="action" value="POST_ANNOUNCEMENT">
                                <input type="hidden" name="class_id" value="<%= classId %>">
                                <div class="w-10 h-10 bg-red-500 flex items-center justify-center text-white font-[Orbitron] text-xs font-bold shrink-0"><%= user.getFullName().substring(0,1).toUpperCase() %></div>
                                <div class="flex-grow">
                                    <textarea name="content" rows="2" class="w-full bg-transparent border border-black/5 p-3 text-[12px] focus:border-red-500 outline-none transition-all resize-none" placeholder="Announce something to your class..." required></textarea>
                                    <div class="flex justify-end mt-2">
                                        <button type="submit" class="bg-red-500 text-white px-4 py-2 font-[Orbitron] text-[8px] tracking-[0.2em] font-black uppercase hover:bg-black transition-all flex items-center gap-2">
                                            <i data-lucide="send" class="w-3 h-3"></i> Post
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <!-- Announcement Feed -->
                        <% if (announcements.isEmpty() && assignments.isEmpty()) { %>
                        <div class="glass p-12 text-center animate-entry" style="animation-delay: 0.2s">
                            <i data-lucide="message-square" class="w-12 h-12 text-gray-200 mx-auto mb-4"></i>
                            <p class="text-[10px] text-gray-400 tracking-widest uppercase">No Activity Yet — Post an announcement to get started</p>
                        </div>
                        <% } %>

                        <% for (int i = 0; i < announcements.size(); i++) {
                            Announcement ann = announcements.get(i); %>
                        <div class="glass p-6 animate-entry" style="animation-delay: <%= 0.15 + (i * 0.05) %>s">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="w-10 h-10 flex items-center justify-center text-white font-[Orbitron] text-xs font-bold shrink-0" style="background: <%= bannerColor %>"><%= ann.getAuthorName().substring(0,1).toUpperCase() %></div>
                                <div>
                                    <h4 class="text-[11px] font-bold uppercase tracking-wider"><%= ann.getAuthorName() %></h4>
                                    <span class="text-[8px] text-gray-400 tracking-widest"><%= timeFormat.format(ann.getCreatedAt()) %></span>
                                </div>
                            </div>
                            <p class="text-[12px] text-gray-700 leading-relaxed pl-14"><%= ann.getContent() %></p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- ASSIGNMENTS TAB -->
                <div id="panel-assignments" class="tab-panel hidden">
                    <div class="max-w-3xl mx-auto space-y-6">
                        <% if (isTeacher) { %>
                        <!-- Create Assignment -->
                        <div class="glass p-6 border-l-4 border-red-500 animate-entry">
                            <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 mb-6 flex items-center gap-3">
                                <i data-lucide="file-plus" class="w-4 h-4 text-red-500"></i> Create Assignment
                            </h3>
                            <form action="assignmentAction" method="post" class="space-y-4">
                                <input type="hidden" name="action" value="CREATE_ASSIGNMENT">
                                <input type="hidden" name="class_id" value="<%= classId %>">
                                <div>
                                    <label class="label-tactical">Title</label>
                                    <input type="text" name="title" class="input-tactical" placeholder="Assignment Title" required>
                                </div>
                                <div>
                                    <label class="label-tactical">Description</label>
                                    <textarea name="description" rows="3" class="input-tactical" placeholder="Instructions and Details..."></textarea>
                                </div>
                                <div class="grid grid-cols-2 gap-4">
                                    <div>
                                        <label class="label-tactical">Due Date</label>
                                        <input type="date" name="due_date" class="input-tactical">
                                    </div>
                                    <div>
                                        <label class="label-tactical">Max Marks</label>
                                        <input type="number" name="max_marks" value="100" class="input-tactical">
                                    </div>
                                </div>
                                <button type="submit" class="w-full bg-red-500 text-white py-3 font-[Orbitron] text-[10px] tracking-[0.3em] uppercase font-black hover:bg-black transition-all flex items-center justify-center gap-3">
                                    <i data-lucide="plus" class="w-4 h-4"></i> Publish Assignment
                                </button>
                            </form>
                        </div>
                        <% } %>

                        <!-- Assignment List -->
                        <% if (assignments.isEmpty()) { %>
                        <div class="glass p-12 text-center">
                            <i data-lucide="clipboard" class="w-12 h-12 text-gray-200 mx-auto mb-4"></i>
                            <p class="text-[10px] text-gray-400 tracking-widest uppercase">No Assignments Posted</p>
                        </div>
                        <% } %>

                        <% for (int i = 0; i < assignments.size(); i++) {
                            Assignment asg = assignments.get(i);
                            boolean isPastDue = asg.getDueDate() != null && asg.getDueDate().before(new java.util.Date());
                        %>
                        <a href="assignment_detail.jsp?id=<%= asg.getId() %>&class_id=<%= classId %>" class="glass p-6 flex items-center gap-6 hover:shadow-lg transition-all group block animate-entry" style="animation-delay: <%= i * 0.05 %>s">
                            <div class="w-12 h-12 flex items-center justify-center shrink-0" style="background: <%= bannerColor %>">
                                <i data-lucide="file-text" class="w-6 h-6 text-white"></i>
                            </div>
                            <div class="flex-grow">
                                <h4 class="text-[12px] font-bold uppercase tracking-wider text-gray-900 group-hover:text-red-500 transition-colors"><%= asg.getTitle() %></h4>
                                <div class="flex items-center gap-4 mt-1">
                                    <span class="text-[8px] text-gray-400 tracking-widest uppercase">Posted: <%= dateFormat.format(asg.getCreatedAt()) %></span>
                                    <% if (asg.getDueDate() != null) { %>
                                    <span class="text-[8px] tracking-widest uppercase font-bold <%= isPastDue ? "text-red-500" : "text-green-600" %>">Due: <%= dateFormat.format(asg.getDueDate()) %></span>
                                    <% } %>
                                </div>
                            </div>
                            <div class="text-right shrink-0">
                                <% if (isTeacher) { %>
                                <div class="text-[9px] text-gray-400 tracking-widest uppercase"><%= asg.getSubmissionCount() %> Submissions</div>
                                <% } %>
                                <div class="text-[8px] text-gray-300 tracking-widest uppercase mt-1"><%= asg.getMaxMarks() %> Marks</div>
                            </div>
                        </a>
                        <% } %>
                    </div>
                </div>

                <!-- QUIZZES TAB -->
                <div id="panel-quizzes" class="tab-panel hidden">
                    <div class="max-w-3xl mx-auto space-y-6">
                        <% if (isTeacher) { %>
                        <div class="flex justify-end mb-4">
                            <a href="createQuiz.jsp?class_id=<%= classId %>" class="bg-red-500 text-white px-6 py-3 font-[Orbitron] text-[10px] tracking-[0.3em] uppercase font-black hover:bg-black transition-all flex items-center gap-2">
                                <i data-lucide="plus" class="w-4 h-4"></i> Create Quiz
                            </a>
                        </div>
                        <% } %>

                        <% if (quizzes.isEmpty()) { %>
                        <div class="glass p-12 text-center">
                            <i data-lucide="help-circle" class="w-12 h-12 text-gray-200 mx-auto mb-4"></i>
                            <p class="text-[10px] text-gray-400 tracking-widest uppercase">No Quizzes Posted</p>
                        </div>
                        <% } %>

                        <% for (int i = 0; i < quizzes.size(); i++) {
                            Quiz q = quizzes.get(i);
                        %>
                        <a href="<%= isTeacher ? "quizResult.jsp" : "takeQuiz.jsp" %>?id=<%= q.getId() %>&class_id=<%= classId %>" class="glass p-6 flex items-center gap-6 hover:shadow-lg transition-all group block animate-entry" style="animation-delay: <%= i * 0.05 %>s">
                            <div class="w-12 h-12 flex items-center justify-center shrink-0" style="background: <%= bannerColor %>">
                                <i data-lucide="help-circle" class="w-6 h-6 text-white"></i>
                            </div>
                            <div class="flex-grow">
                                <h4 class="text-[12px] font-bold uppercase tracking-wider text-gray-900 group-hover:text-red-500 transition-colors"><%= q.getTitle() %></h4>
                                <div class="flex items-center gap-4 mt-1">
                                    <span class="text-[8px] text-gray-400 tracking-widest uppercase">Duration: <%= q.getDurationMinutes() %> Min</span>
                                </div>
                            </div>
                            <div class="text-right shrink-0">
                                <% if (isTeacher) { %>
                                <div class="text-[9px] text-gray-400 tracking-widest uppercase">View Results</div>
                                <% } else { %>
                                <div class="text-[9px] text-gray-400 tracking-widest uppercase">Take Quiz</div>
                                <% } %>
                            </div>
                        </a>
                        <% } %>
                    </div>
                </div>

                <!-- RESULTS TAB -->
                <div id="panel-results" class="tab-panel hidden">
                    <div class="max-w-5xl mx-auto space-y-8">
                        <% if (isTeacher) { %>
                        <!-- Teacher: Grading Configuration -->
                        <div class="glass p-8 animate-entry">
                            <div class="flex items-center gap-3 mb-6">
                                <i data-lucide="settings-2" class="w-5 h-5 text-gray-900"></i>
                                <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Grading Configuration</h3>
                            </div>
                            <form action="resultAction" method="post" class="grid grid-cols-2 md:grid-cols-4 gap-6">
                                <input type="hidden" name="action" value="SAVE_CONFIG">
                                <input type="hidden" name="class_id" value="<%= classId %>">
                                <input type="hidden" name="source" value="class_detail.jsp?id=<%= classId %>">
                                
                                <div class="col-span-2 md:col-span-4 bg-black/5 p-2 text-[8px] font-bold uppercase tracking-widest mt-2 mb-2">Marks Criteria</div>
                                
                                <div><label class="label-tactical">Theory Max</label><input type="number" name="theory_max" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getTheoryMax() : 100 %>" required></div>
                                <div><label class="label-tactical">Theory Pass</label><input type="number" name="theory_pass" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getTheoryPass() : 40 %>" required></div>
                                <div><label class="label-tactical">Internal Max</label><input type="number" name="internal_max" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getInternalMax() : 50 %>" required></div>
                                <div><label class="label-tactical">Internal Pass</label><input type="number" name="internal_pass" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getInternalPass() : 20 %>" required></div>
                                <div><label class="label-tactical">Viva Max</label><input type="number" name="viva_max" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getVivaMax() : 50 %>" required></div>
                                <div><label class="label-tactical">Viva Pass</label><input type="number" name="viva_pass" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getVivaPass() : 20 %>" required></div>
                                
                                <div class="col-span-2 md:col-span-4 bg-black/5 p-2 text-[8px] font-bold uppercase tracking-widest mt-4 mb-2">Grade Thresholds (%)</div>
                                
                                <div><label class="label-tactical">Grade A (Min %)</label><input type="number" name="grade_a" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getGradeA() : 90 %>" required></div>
                                <div><label class="label-tactical">Grade B (Min %)</label><input type="number" name="grade_b" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getGradeB() : 75 %>" required></div>
                                <div><label class="label-tactical">Grade C (Min %)</label><input type="number" name="grade_c" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getGradeC() : 60 %>" required></div>
                                <div><label class="label-tactical">Grade D (Min %)</label><input type="number" name="grade_d" class="input-tactical" value="<%= resultConfig != null ? resultConfig.getGradeD() : 40 %>" required></div>
                                
                                <div class="col-span-2 md:col-span-4 flex justify-end mt-4">
                                    <button type="submit" class="bg-black text-white px-8 py-3 font-[Orbitron] text-[10px] tracking-[0.2em] font-black uppercase hover:bg-red-500 transition-all shadow-xl">
                                        Update Schema
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Teacher: Input Marks -->
                        <div class="glass p-8 animate-entry" style="animation-delay: 0.1s">
                            <div class="flex items-center gap-3 mb-6">
                                <i data-lucide="clipboard-edit" class="w-5 h-5 text-gray-900"></i>
                                <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Student Results Entry</h3>
                            </div>
                            
                            <% if (resultConfig == null) { %>
                                <div class="text-[10px] text-red-500 font-bold uppercase tracking-widest p-4 bg-red-500/10 border-l-4 border-red-500">
                                    Warning: Please configure grading schema above before entering marks.
                                </div>
                            <% } else { %>
                                <div class="overflow-x-auto">
                                    <table class="w-full text-left">
                                        <thead>
                                            <tr class="border-b border-black/10 text-[8px] text-gray-400 tracking-widest uppercase font-black">
                                                <th class="py-3">Student</th>
                                                <th class="py-3 w-24">Theory</th>
                                                <th class="py-3 w-24">Internal</th>
                                                <th class="py-3 w-24">Viva</th>
                                                <th class="py-3 w-24 text-center">Status</th>
                                                <th class="py-3 text-right">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody class="text-[10px] font-bold">
                                            <% for(UserProfile s : students) { 
                                                StudentResult existingResult = null;
                                                for(StudentResult r : studentResults) {
                                                    if(r.getStudentId() == s.getId()) {
                                                        existingResult = r; break;
                                                    }
                                                }
                                            %>
                                            <tr class="border-b border-black/5 hover:bg-black/[0.02]">
                                                <form action="resultAction" method="post">
                                                    <input type="hidden" name="action" value="SAVE_MARKS">
                                                    <input type="hidden" name="class_id" value="<%= classId %>">
                                                    <input type="hidden" name="student_id" value="<%= s.getId() %>">
                                                    <input type="hidden" name="source" value="class_detail.jsp?id=<%= classId %>">
                                                    <td class="py-4 uppercase tracking-wider text-[11px]"><%= s.getFullName() %></td>
                                                    <td class="py-4 pr-2"><input type="number" name="theory_marks" class="input-tactical" value="<%= existingResult != null ? existingResult.getTheoryMarks() : 0 %>" required></td>
                                                    <td class="py-4 pr-2"><input type="number" name="internal_marks" class="input-tactical" value="<%= existingResult != null ? existingResult.getInternalMarks() : 0 %>" required></td>
                                                    <td class="py-4 pr-2"><input type="number" name="viva_marks" class="input-tactical" value="<%= existingResult != null ? existingResult.getVivaMarks() : 0 %>" required></td>
                                                    <td class="py-4 text-center">
                                                        <% if (existingResult != null) { %>
                                                            <span class="px-2 py-1 text-[8px] tracking-widest uppercase <%= "PASS".equals(existingResult.getStatus()) ? "bg-green-500/10 text-green-600" : "bg-red-500/10 text-red-600" %>">
                                                                <%= existingResult.getGrade() %> / <%= existingResult.getStatus() %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-gray-300">--</span>
                                                        <% } %>
                                                    </td>
                                                    <td class="py-4 text-right">
                                                        <button type="submit" class="bg-red-500 text-white px-3 py-2 text-[8px] uppercase tracking-widest hover:bg-black transition-colors">Save</button>
                                                    </td>
                                                </form>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            <% } %>
                        </div>
                        <% } else { 
                            // Student View Report Card
                            StudentResult myResult = null;
                            for(StudentResult r : studentResults) {
                                if(r.getStudentId() == user.getId()) {
                                    myResult = r; break;
                                }
                            }
                        %>
                        <div class="glass p-8 max-w-2xl mx-auto animate-entry border-l-4" style="border-color: <%= bannerColor %>">
                            <div class="flex items-center gap-4 mb-8 border-b border-black/10 pb-6">
                                <i data-lucide="award" class="w-8 h-8 text-gray-900"></i>
                                <div>
                                    <h3 class="font-[Orbitron] text-lg tracking-widest uppercase font-black text-gray-900">Academic Report</h3>
                                    <p class="text-[9px] text-gray-400 font-bold tracking-[0.2em] uppercase"><%= classroom.getName() %></p>
                                </div>
                            </div>
                            
                            <% if (resultConfig == null || myResult == null) { %>
                                <div class="text-center py-10 text-[10px] text-gray-400 font-bold uppercase tracking-widest">
                                    <i data-lucide="clock" class="w-10 h-10 mx-auto mb-3 opacity-20"></i>
                                    Results have not been published yet.
                                </div>
                            <% } else { %>
                                <div class="grid grid-cols-2 gap-8 mb-8">
                                    <div class="bg-black/5 p-6 relative overflow-hidden">
                                        <div class="absolute -right-4 -bottom-4 opacity-5"><i data-lucide="check-circle" class="w-32 h-32"></i></div>
                                        <span class="block text-[8px] text-gray-500 font-bold tracking-[0.3em] uppercase mb-1">Final Status</span>
                                        <span class="font-[Orbitron] text-3xl font-black <%= "PASS".equals(myResult.getStatus()) ? "text-green-600" : "text-red-600" %>"><%= myResult.getStatus() %></span>
                                    </div>
                                    <div class="bg-black/5 p-6 relative overflow-hidden">
                                        <div class="absolute -right-4 -bottom-4 opacity-5"><i data-lucide="bar-chart" class="w-32 h-32"></i></div>
                                        <span class="block text-[8px] text-gray-500 font-bold tracking-[0.3em] uppercase mb-1">Obtained Grade</span>
                                        <span class="font-[Orbitron] text-3xl font-black text-gray-900"><%= myResult.getGrade() %></span>
                                    </div>
                                </div>
                                
                                <table class="w-full text-left border-collapse text-[10px] font-bold">
                                    <thead>
                                        <tr class="border-b-2 border-black tracking-widest uppercase text-gray-400">
                                            <th class="py-3">Module</th>
                                            <th class="py-3 text-center">Passing</th>
                                            <th class="py-3 text-center">Max Marks</th>
                                            <th class="py-3 text-right">Obtained</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr class="border-b border-black/5">
                                            <td class="py-4 uppercase tracking-wider">Theory Assessment</td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getTheoryPass() %></td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getTheoryMax() %></td>
                                            <td class="py-4 text-right font-[Orbitron] text-[12px]"><%= myResult.getTheoryMarks() %></td>
                                        </tr>
                                        <tr class="border-b border-black/5">
                                            <td class="py-4 uppercase tracking-wider">Internal Assessment</td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getInternalPass() %></td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getInternalMax() %></td>
                                            <td class="py-4 text-right font-[Orbitron] text-[12px]"><%= myResult.getInternalMarks() %></td>
                                        </tr>
                                        <tr class="border-b border-black/5">
                                            <td class="py-4 uppercase tracking-wider">Viva Voce</td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getVivaPass() %></td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getVivaMax() %></td>
                                            <td class="py-4 text-right font-[Orbitron] text-[12px]"><%= myResult.getVivaMarks() %></td>
                                        </tr>
                                    </tbody>
                                    <tfoot>
                                        <tr class="bg-black/5">
                                            <td class="py-4 px-2 uppercase tracking-wider font-black">Total Aggregate</td>
                                            <td class="py-4 text-center font-mono">--</td>
                                            <td class="py-4 text-center font-mono"><%= resultConfig.getTheoryMax() + resultConfig.getInternalMax() + resultConfig.getVivaMax() %></td>
                                            <td class="py-4 text-right font-[Orbitron] text-[14px] px-2 text-red-600"><%= myResult.getTotalMarks() %></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- PEOPLE TAB -->
                <div id="panel-people" class="tab-panel hidden">
                    <div class="max-w-3xl mx-auto space-y-6">
                        <!-- Teacher -->
                        <div class="glass p-6 border-l-4 animate-entry" style="border-color: <%= bannerColor %>">
                            <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 mb-6">Teacher</h3>
                            <div class="flex items-center gap-4">
                                <div class="w-10 h-10 flex items-center justify-center text-white font-[Orbitron] text-xs font-bold" style="background: <%= bannerColor %>"><%= classroom.getTeacherName().substring(0,1).toUpperCase() %></div>
                                <span class="text-[12px] font-bold uppercase tracking-wider"><%= classroom.getTeacherName() %></span>
                            </div>
                        </div>

                        <!-- Students -->
                        <div class="glass p-6 animate-entry" style="animation-delay: 0.1s">
                            <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 mb-6 flex items-center gap-3">
                                Classmates <span class="text-gray-400">(<%= students.size() %>)</span>
                            </h3>
                            <% if (students.isEmpty()) { %>
                            <p class="text-[10px] text-gray-400 tracking-widest uppercase text-center py-8">No Students Enrolled</p>
                            <% } %>
                            <div class="space-y-3">
                                <% for (UserProfile s : students) { %>
                                <div class="flex items-center gap-4 py-3 border-b border-black/[0.03] last:border-0">
                                    <div class="w-10 h-10 bg-gray-100 flex items-center justify-center text-gray-500 font-[Orbitron] text-xs font-bold"><%= s.getFullName().substring(0,1).toUpperCase() %></div>
                                    <div>
                                        <span class="text-[12px] font-bold uppercase tracking-wider block"><%= s.getFullName() %></span>
                                        <span class="text-[9px] text-gray-400 tracking-widest"><%= s.getEmail() %></span>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        lucide.createIcons();

        function showTab(tab) {
            document.querySelectorAll('.tab-panel').forEach(p => p.classList.add('hidden'));
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.getElementById('panel-' + tab).classList.remove('hidden');
            document.getElementById('tab-' + tab).classList.add('active');
        }

        document.getElementById('mobile-toggle')?.addEventListener('click', () => document.getElementById('sidebar-module').classList.remove('-translate-x-full'));

        const urlParams = new URLSearchParams(window.location.search);
        const tab = urlParams.get('tab');
        if (tab) {
            showTab(tab);
        }
    </script>
</body>
</html>
