<%@ page import="java.sql.*, java.util.*, com.gurukul.*, java.text.SimpleDateFormat" %>
<jsp:useBean id="user" class="com.gurukul.userProfileBean" scope="session" />
<%
    if (session.getAttribute("user") == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<userProfileBean> students = new ArrayList<>();
    List<noticeBoard> notices = new ArrayList<>();
    List<eventBean> events = new ArrayList<>();
    Set<String> uniqueStreams = new TreeSet<>();

    try {
        ServletContext context = getServletContext();
        String DB = context.getInitParameter("DB_URL");
        String DB_User = context.getInitParameter("DB_USERNAME");
        String DB_pwd = context.getInitParameter("DB_PWD");
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://"+DB+":3306/gurukul", DB_User, DB_pwd);

        // Fetch Students with COMPLETE details
        String studentSql = "SELECT * FROM users WHERE role = 'Student' ORDER BY full_name ASC";
        PreparedStatement psStudent = conn.prepareStatement(studentSql);
        ResultSet rsStudent = psStudent.executeQuery();
        while (rsStudent.next()) {
            userProfileBean sb = new userProfileBean();
            sb.setId(rsStudent.getInt("id"));
            sb.setFullName(rsStudent.getString("full_name"));
            sb.setUserName(rsStudent.getString("username"));
            sb.setEmail(rsStudent.getString("email"));
            sb.setPhone(rsStudent.getString("phone"));
            sb.setCourse(rsStudent.getString("course"));
            sb.setBatch(rsStudent.getString("batch"));
            sb.setSpecialization(rsStudent.getString("specialization"));
            students.add(sb);
            if (sb.getCourse() != null) uniqueStreams.add(sb.getCourse());
        }

        // Fetch Notices
        String noticeSql = "SELECT * FROM noticeboard ORDER BY created_at DESC";
        PreparedStatement psNotice = conn.prepareStatement(noticeSql);
        ResultSet rsNotice = psNotice.executeQuery();
        while (rsNotice.next()) {
            noticeBoard nb = new noticeBoard();
            nb.setId(rsNotice.getInt("id"));
            nb.setHeading(rsNotice.getString("heading"));
            nb.setBody(rsNotice.getString("body"));
            nb.setWhom(rsNotice.getString("whom"));
            notices.add(nb);
        }

        // Fetch Events
        String eventSql = "SELECT * FROM events ORDER BY event_date ASC";
        PreparedStatement psEvent = conn.prepareStatement(eventSql);
        ResultSet rsEvent = psEvent.executeQuery();
        while (rsEvent.next()) {
            eventBean eb = new eventBean();
            eb.setId(rsEvent.getInt("id"));
            eb.setEventName(rsEvent.getString("event_name"));
            eb.setEventDate(rsEvent.getDate("event_date"));
            eb.setDescription(rsEvent.getString("description"));
            events.add(eb);
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
    <title>Faculty Command Console - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0, 0, 0, 0.05); }
        .hud-corner { @apply absolute w-4 h-4 border-red-500 z-20; }
        .terminal-index { @apply text-[7px] text-gray-300 font-bold tracking-widest mr-2 transition-colors opacity-0 group-hover/sidebar:opacity-50; }
        .connector-line { @apply absolute top-24 bottom-24 w-[1px] bg-black/[0.04] z-0 transition-all duration-500; }
        .active-bar { @apply absolute left-0 top-0 bottom-0 w-1 bg-red-500; }
        .input-tactical { @apply w-full bg-white/50 border border-black/5 p-3 text-[10px] font-bold uppercase tracking-widest font-[Orbitron] focus:border-red-500 outline-none transition-all; }
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        .filter-btn { @apply px-4 py-2 text-[9px] font-bold uppercase tracking-[0.2em] border border-black/5 bg-white/50 hover:bg-black/5 transition-all cursor-pointer; }
        .filter-btn.active { @apply bg-red-500 text-white border-red-500 shadow-[0_0_15px_rgba(255,51,51,0.2)]; }
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
            <span>GURUKUL_ILE / FACULTY_COMMAND_CENTER</span>
        </div>
        <div class="flex items-center gap-6">
            <span class="hidden md:inline text-gray-300">HUB_DATA_STREAM: ACTIVE</span>
            <div class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20">ACCESS_LEVEL: ALPHA_ADMIN</div>
        </div>
    </div>

    <div class="flex flex-grow overflow-hidden relative z-10">
        <!-- SIDEBAR -->
        <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-6 pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
            <div class="connector-line left-[39px] md:group-hover/sidebar:left-[47px] hidden md:block"></div>
            <div class="glass h-full border-r md:border border-black/10 flex flex-col py-10 overflow-hidden relative shadow-2xl bg-white/95">
                <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20">GKL</div>
                </div>
                <!-- NAV -->
                <nav class="flex-grow flex flex-col gap-1 mt-8 relative z-10 items-center md:items-stretch">
                   <a href="#" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] relative border-l-4 border-red-500 w-full">
                        <i data-lucide="layout-dashboard" class="w-5 h-5 text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[01]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Command</span>
                    </a>
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full mt-auto">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[99]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Deauth</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- CONTENT -->
        <main class="flex-grow overflow-y-auto p-8 flex flex-col gap-8 scrollbar-hide">
            
            <!-- SECTION 1: FACULTY PERSONA -->
            <section class="grid grid-cols-12 gap-8">
                <div class="col-span-12 xl:col-span-5 glass p-8 border-l-4 border-black relative overflow-hidden group">
                    <div class="absolute top-0 right-0 p-4 opacity-5 text-[10px] font-mono">FACULTY_PROFILE_V4</div>
                    <div class="flex items-center gap-8 mb-8">
                        <div class="w-20 h-20 bg-white border border-black/5 flex items-center justify-center shadow-inner relative">
                            <i data-lucide="user-plus" class="w-10 h-10 text-red-500"></i>
                        </div>
                        <div class="flex flex-col gap-1">
                            <h2 class="font-[Orbitron] text-2xl tracking-[0.1em] font-black uppercase text-gray-900 leading-none">${user.fullName}</h2>
                            <span class="text-[10px] text-red-500 font-bold tracking-[0.5em] uppercase">Authorized_Personnel</span>
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-6 border-t border-black/5 pt-6">
                        <div>
                            <span class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-1">Assigned_Dept</span>
                            <span class="text-[10px] font-bold text-gray-900 font-[Orbitron]">${user.course}</span>
                        </div>
                        <div>
                            <span class="text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-1">Comms_Relay</span>
                            <span class="text-[10px] font-bold text-gray-900 font-mono">${user.email}</span>
                        </div>
                    </div>
                </div>
                
                <div class="col-span-12 xl:col-span-7 flex flex-col justify-between p-8 bg-red-500 text-white shadow-[0_20px_40px_rgba(255,51,51,0.1)] relative">
                    <div class="absolute top-4 right-6 text-[40px] font-black opacity-10 font-[Orbitron]">SYSTEM_ACTIVE</div>
                    <div class="relative z-10">
                        <h3 class="font-[Orbitron] text-sm tracking-[0.2em] font-bold mb-2 uppercase">Command_Status</h3>
                        <p class="text-[10px] tracking-[0.1em] opacity-80 uppercase leading-loose border-l-2 border-white/50 pl-4 py-2">System healthy. Secure protocols initiated. Access authorized via endpoint <span class="underline">GKL-ILE_V4</span>. Internal network encryption active.</p>
                    </div>
                    <div class="flex gap-10 mt-6 pt-4 border-t border-white/20 relative z-10">
                        <div>
                            <div class="text-[12px] font-black font-[Orbitron] uppercase"><%= students.size() %></div>
                            <div class="text-[7px] font-bold opacity-60 tracking-widest uppercase">Units_Managed</div>
                        </div>
                        <div>
                            <div class="text-[12px] font-black font-[Orbitron] uppercase">98%</div>
                            <div class="text-[7px] font-bold opacity-60 tracking-widest uppercase">Efficiency_Rate</div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- SECTION 2: STUDENT MANAGEMENT -->
            <section class="flex flex-col gap-6">
                <!-- FILTER ARRAY -->
                <div class="flex flex-wrap items-center gap-3 glass p-3 border-l-4 border-red-500">
                    <div class="text-[8px] font-black uppercase text-gray-400 tracking-[0.4em] px-4 border-r border-black/10">Filter_Stream:</div>
                    <button onclick="filterStudents('ALL')" id="filter-ALL" class="filter-btn active">All_Units</button>
                    <% for(String stream : uniqueStreams) { %>
                    <button onclick="filterStudents('<%= stream %>')" id="filter-<%= stream %>" class="filter-btn"><%= stream %></button>
                    <% } %>
                </div>

                <div class="glass p-8 overflow-hidden flex flex-col relative min-h-[500px]">
                    <div class="flex justify-between items-center mb-10">
                        <div class="flex items-center gap-3">
                            <i data-lucide="users" class="w-4 h-4 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Student_Registry</h2>
                        </div>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="border-b border-black/5 text-[9px] text-gray-400 tracking-widest uppercase font-black bg-black/[0.02]">
                                    <th class="py-4 px-6">ID</th>
                                    <th class="py-4">Unit_Designation (Name)</th>
                                    <th class="py-4">Auth_ID</th>
                                    <th class="py-4">Vect_Stream</th>
                                    <th class="py-4 text-right pr-6">Management_Actions</th>
                                </tr>
                            </thead>
                            <tbody class="text-[10px] font-bold" id="student-table-body">
                                <% for(userProfileBean s : students) { %>
                                <tr class="student-row border-b border-black/[0.03] hover:bg-black/[0.01] transition-colors group" data-stream="<%= s.getCourse() %>">
                                    <td class="py-5 px-6 text-gray-400">#<%= s.getId() %></td>
                                    <td class="py-5 uppercase tracking-tighter text-gray-900 font-[Orbitron] text-[11px]"><%= s.getFullName() %></td>
                                    <td class="py-5 text-gray-500 uppercase font-mono"><%= s.getUserName() %></td>
                                    <td class="py-5"><span class="bg-red-500/5 text-red-500/80 px-2 py-1 border border-red-500/10 text-[8px] tracking-widest uppercase"><%= s.getCourse() %></span></td>
                                    <td class="py-5 text-right pr-6 flex justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button 
                                            onclick="showDetails(this)" 
                                            data-fullname="<%= s.getFullName() %>" 
                                            data-username="<%= s.getUserName() %>"
                                            data-email="<%= s.getEmail() %>"
                                            data-phone="<%= s.getPhone() != null ? s.getPhone() : "N/A" %>"
                                            data-course="<%= s.getCourse() %>"
                                            data-batch="<%= s.getBatch() != null ? s.getBatch() : "N/A" %>"
                                            data-spec="<%= s.getSpecialization() != null ? s.getSpecialization() : "N/A" %>"
                                            class="bg-black text-white px-3 py-1.5 hover:bg-red-500 transition-all uppercase text-[7px] tracking-widest shadow-lg">
                                            Scan_Data
                                        </button>
                                        <form action="teacherAction" method="post" onsubmit="return confirm('EXTERMINATE ACCOUNT #<%= s.getId() %>?');">
                                            <input type="hidden" name="action" value="DELETE_STUDENT">
                                            <input type="hidden" name="id" value="<%= s.getId() %>">
                                            <button class="bg-red-500/10 text-red-500 px-3 py-1.5 hover:bg-red-500 hover:text-white transition-all uppercase text-[7px] tracking-widest border border-red-500/20">Deauth</button>
                                        </form>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- SECTION 3: CHANNELS (NOTICES/EVENTS) -->
            <section class="grid grid-cols-12 gap-8">
                <!-- BROADCAST TERMINAL -->
                <div class="col-span-12 xl:col-span-6 flex flex-col gap-6">
                    <div class="glass p-8 border-l-4 border-red-500">
                        <div class="flex items-center gap-4 mb-8">
                            <i data-lucide="megaphone" class="w-5 h-5 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-[0.3em] uppercase font-bold">Broadcast_Array</h2>
                        </div>
                        <form action="teacherAction" method="post" class="space-y-6">
                            <input type="hidden" name="action" value="ADD_NOTICE">
                            <div class="space-y-2">
                                <label class="label-tactical">Signal_Heading</label>
                                <input type="text" name="heading" placeholder="URGENT_UPDATE_ALPHA" class="input-tactical" required>
                            </div>
                            <div class="space-y-2">
                                <label class="label-tactical">Signal_Payload (Message)</label>
                                <textarea name="body" placeholder="System transmission details..." class="input-tactical h-24" required></textarea>
                            </div>
                            <button type="submit" class="w-full bg-[#0a0a0a] text-white py-5 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase hover:bg-red-500 transition-all shadow-xl">Initiate_Transmission</button>
                        </form>
                    </div>

                    <div class="glass p-8 h-80 overflow-y-auto scrollbar-hide">
                        <div class="flex items-center gap-3 mb-6">
                            <i data-lucide="activity" class="w-4 h-4 text-red-500"></i>
                            <h3 class="text-[10px] text-gray-900 tracking-widest uppercase font-black">Active_Transmissions</h3>
                        </div>
                        <div class="space-y-4">
                            <% for(noticeBoard n : notices) { %>
                            <div class="flex justify-between items-center p-4 border border-black/5 bg-white/50 group/nt cursor-default">
                                <div class="flex flex-col gap-1 truncate pr-4">
                                    <span class="text-[11px] font-black uppercase text-gray-900 font-[Orbitron] truncate"><%= n.getHeading() %></span>
                                    <div class="flex items-center gap-3">
                                        <span class="text-[7px] text-red-500 font-black tracking-widest uppercase items-center flex gap-1">
                                            <i data-lucide="user" class="w-2 h-2"></i> SOURCE: <%= n.getWhom() %>
                                        </span>
                                    </div>
                                </div>
                                <form action="teacherAction" method="post">
                                    <input type="hidden" name="action" value="DELETE_NOTICE">
                                    <input type="hidden" name="id" value="<%= n.getId() %>">
                                    <button class="text-gray-300 hover:text-red-500 transition-colors"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                </form>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- SCHEDULER -->
                <div class="col-span-12 xl:col-span-6 flex flex-col gap-6">
                    <div class="glass p-8 border-b-4 border-red-500">
                        <h3 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-bold mb-8 flex items-center gap-3"><i data-lucide="calendar" class="w-4 h-4 text-red-500"></i> Temporal_Event_Log</h3>
                        <form action="teacherAction" method="post" class="grid grid-cols-2 gap-4">
                            <input type="hidden" name="action" value="ADD_EVENT">
                            <div class="col-span-2">
                                <label class="label-tactical">Event_Tag</label>
                                <input type="text" name="name" placeholder="EVENT_OMEGA" class="input-tactical" required>
                            </div>
                            <div>
                                <label class="label-tactical">Timeline_Stamp</label>
                                <input type="date" name="date" class="input-tactical" required>
                            </div>
                            <div class="flex items-end">
                                <button type="submit" class="w-full h-[47px] bg-[#0a0a0a] text-white font-[Orbitron] text-[10px] tracking-widest uppercase hover:bg-red-500 transition-all">Schedule</button>
                            </div>
                        </form>
                    </div>

                    <div class="glass p-8 h-80 overflow-y-auto scrollbar-hide">
                        <div class="flex items-center gap-3 mb-6">
                            <div class="w-2 h-2 bg-red-500"></div>
                            <h3 class="text-[10px] text-gray-900 tracking-widest uppercase font-black">Active_Sequence_Logs</h3>
                        </div>
                        <div class="space-y-4">
                            <% for(eventBean e : events) { %>
                            <div class="flex justify-between items-center p-4 border border-black/5 bg-white/50 group/ev cursor-default">
                                <div class="flex flex-col gap-1">
                                    <span class="text-[11px] font-black uppercase text-gray-900 font-[Orbitron]"><%= e.getEventName() %></span>
                                    <span class="text-[8px] text-red-500/70 font-black tracking-widest uppercase">TIMESTAMP: <%= e.getEventDate() %></span>
                                </div>
                                <form action="teacherAction" method="post">
                                    <input type="hidden" name="action" value="DELETE_EVENT">
                                    <input type="hidden" name="id" value="<%= e.getId() %>">
                                    <button class="text-gray-300 hover:text-red-500 transition-colors"><i data-lucide="minus-circle" class="w-5 h-5"></i></button>
                                </form>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <!-- DETAIL MODAL OVERLAY -->
    <div id="detail-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-[#f8fafc]/90 backdrop-blur-2xl" onclick="closeModal()"></div>
        <div class="glass max-w-2xl w-full p-0 relative border border-black/10 shadow-[0_30px_100px_rgba(0,0,0,0.1)]">
            <div class="hud-corner top-0 left-0 border-t-2 border-l-2"></div>
            <div class="hud-corner top-0 right-0 border-t-2 border-r-2 border-red-500"></div>
            <div class="hud-corner bottom-0 left-0 border-b-2 border-l-2"></div>
            <div class="hud-corner bottom-0 right-0 border-b-2 border-r-2 border-red-500"></div>
            
            <div class="bg-red-500 px-8 py-4 flex justify-between items-center text-white">
                <div class="flex items-center gap-3">
                    <i data-lucide="search" class="w-4 h-4"></i>
                    <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black">Unit_Deep_Scan</h2>
                </div>
                <button onclick="closeModal()" class="hover:rotate-90 transition-transform"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>

            <div class="p-10 space-y-10" id="modal-content">
                <!-- Content injected via JS -->
            </div>
            
            <div class="px-10 py-6 border-t border-black/5 bg-black/[0.02] text-[8px] text-gray-400 font-bold uppercase tracking-[0.3em] flex justify-between">
                <span>SECURITY_CLEARANCE_ALPHA</span>
                <span>ID_VERIFIED_BY_GURUKUL_CORE</span>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();

        // Filtering Logic
        function filterStudents(stream) {
            const rows = document.querySelectorAll('.student-row');
            const btns = document.querySelectorAll('.filter-btn');
            
            btns.forEach(b => b.classList.remove('active'));
            document.getElementById('filter-' + stream).classList.add('active');

            rows.forEach(row => {
                if (stream === 'ALL' || row.dataset.stream === stream) {
                    row.style.display = 'table-row';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Modal Logic
        const modal = document.getElementById('detail-modal');
        function showDetails(btn) {
            const s = btn.dataset;
            const content = document.getElementById('modal-content');
            content.innerHTML = `
                <div class="grid grid-cols-2 gap-x-12 gap-y-10">
                    <div class="col-span-2 flex items-center gap-8 border-b border-black/5 pb-8">
                        <div class="w-16 h-16 bg-red-500 flex items-center justify-center text-white shadow-lg">
                            <i data-lucide="user" class="w-8 h-8"></i>
                        </div>
                        <div>
                            <h3 class="font-[Orbitron] text-2xl font-black uppercase tracking-widest text-gray-900">${s.fullname}</h3>
                            <span class="text-[9px] text-red-500 font-bold tracking-[0.4em] uppercase">Status: ACTIVE_STUDENT</span>
                        </div>
                    </div>
                    <div>
                        <span class="label-tactical">Auth_Username</span>
                        <p class="text-[12px] font-bold font-mono text-gray-700">${s.username}</p>
                    </div>
                    <div>
                        <span class="label-tactical">Relay_Email</span>
                        <p class="text-[12px] font-bold font-mono text-gray-700">${s.email}</p>
                    </div>
                    <div>
                        <span class="label-tactical">Comms_Line</span>
                        <p class="text-[12px] font-bold font-mono text-gray-700">${s.phone}</p>
                    </div>
                    <div>
                        <span class="label-tactical">Nav_Stream</span>
                        <p class="text-[10px] font-bold font-[Orbitron] text-red-500">${s.course}</p>
                    </div>
                    <div>
                        <span class="label-tactical">Temporal_Batch</span>
                        <p class="text-[12px] font-bold text-gray-700 uppercase">${s.batch}</p>
                    </div>
                    <div>
                        <span class="label-tactical">Expertise_Specialization</span>
                        <p class="text-[12px] font-bold text-gray-700 uppercase">${s.spec}</p>
                    </div>
                </div>
            `;
            modal.classList.remove('hidden');
            lucide.createIcons();
        }

        function closeModal() {
            modal.classList.add('hidden');
        }

        // Mobile Logic
        const sidebarModule = document.getElementById('sidebar-module');
        document.getElementById('mobile-toggle')?.addEventListener('click', () => sidebarModule.classList.remove('-translate-x-full'));
        document.getElementById('mobile-close')?.addEventListener('click', () => sidebarModule.classList.add('-translate-x-full'));
    </script>
</body>
</html>
