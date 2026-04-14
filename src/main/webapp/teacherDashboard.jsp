<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection, java.text.SimpleDateFormat" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<UserProfile> students = new ArrayList<>();
    Set<String> uniqueStreams = new TreeSet<>();
    List<Map<String, String>> activeMeetings = new ArrayList<>();
    List<Map<String, String>> pendingLeaves = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Fetch Students with COMPLETE details
        String studentSql = "SELECT * FROM users WHERE role = 'Student' ORDER BY full_name ASC";
        try (PreparedStatement psStudent = conn.prepareStatement(studentSql);
             ResultSet rsStudent = psStudent.executeQuery()) {
            while (rsStudent.next()) {
                UserProfile sb = new UserProfile();
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

        // Fetch Pending Leaves
        String leaveSql = "SELECT * FROM leave_requests WHERE status = 'PENDING' ORDER BY applied_at ASC";
        try (PreparedStatement psLeave = conn.prepareStatement(leaveSql);
             ResultSet rsLeave = psLeave.executeQuery()) {
            while (rsLeave.next()) {
                Map<String, String> l = new HashMap<>();
                l.put("id", rsLeave.getString("id"));
                l.put("student_name", rsLeave.getString("student_name"));
                l.put("reason", rsLeave.getString("reason"));
                l.put("start", rsLeave.getString("start_date"));
                l.put("end", rsLeave.getString("end_date"));
                pendingLeaves.add(l);
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
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
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
            <span class="opacity-30 mx-2">|</span>
            <span class="text-[7px] text-red-500/80 tracking-widest uppercase">SIG_STRENGTH: <%= activeMeetings.size() > 0 ? "98%" : "0%" %> [SIGNALS: <%= activeMeetings.size() %>]</span>
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
                    <a href="teacherDashboard.jsp" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] border-l-4 border-red-500 w-full">
                        <i data-lucide="layout-dashboard" class="w-5 h-5 text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[01]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase text-red-500">Command</span>
                    </a>
                    <a href="createEvent.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="calendar" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[02]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Events</span>
                    </a>
                    <a href="sendNotice.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="megaphone" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[03]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Notices</span>
                    </a>
                    <a href="javascript:void(0)" onclick="openDeployModal()" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="user-plus" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[04]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Deploy_Unit</span>
                    </a>
                    <a href="#leave-management" class="group/item flex items-center gap-4 p-4 hover:bg-red-500/5 w-full">
                        <i data-lucide="clipboard-list" class="w-5 h-5 text-gray-400 group-hover:text-red-500"></i>
                        <span class="terminal-index hidden md:group-hover/sidebar:block">[05]</span>
                        <span class="hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-widest font-bold uppercase">Leave_Ops</span>
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
            
            <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="glass border-l-4 border-green-500 p-4 bg-green-500/5 flex items-center gap-4 animate-bounce">
                <i data-lucide="check-circle" class="w-5 h-5 text-green-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-green-700">Protocol_Executed: Data_Commit_Successful</span>
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
                          <h3 class="font-[Orbitron] text-sm tracking-[0.3em] font-black text-gray-900 uppercase">Meeting Live: Signal_Broadcasting</h3>
                          <p class="text-[9px] text-gray-400 tracking-[0.2em] uppercase font-bold mt-1">Status: <span class="text-red-500 border-b border-red-500/20">Operational</span> / AUTH_LEVEL: Teacher</p>
                      </div>
                  </div>
                  <a href="meeting.jsp?id=<%= meeting.get("id") %>&room=<%= meeting.get("teacher") %>" class="bg-[#0a0a0a] text-white px-10 py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase hover:bg-red-500 transition-all shadow-2xl flex items-center gap-3">
                      Enter_Briefing_Room <i data-lucide="arrow-right" class="w-4 h-4"></i>
                  </a>
              </div>
            </div>
            <% } %>
            
            <!-- SECTION 1: FACULTY PERSONA -->
            <section class="grid grid-cols-12 gap-8">
                <div class="col-span-12 xl:col-span-5 glass p-8 border-l-4 border-black relative overflow-hidden group">
                    <div class="absolute top-0 right-0 p-4 opacity-5 text-[10px] font-mono">FACULTY_PROFILE_V5</div>
                    <div class="flex items-center gap-8 mb-8">
                        <div class="w-20 h-20 bg-white border border-black/5 flex items-center justify-center shadow-inner relative">
                            <i data-lucide="user" class="w-10 h-10 text-red-500"></i>
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
                        <p class="text-[10px] tracking-[0.1em] opacity-80 uppercase leading-loose border-l-2 border-white/50 pl-4 py-2">Architecture optimized. Modular controllers active. Access authorized via endpoint <span class="underline">ALPHA_CORE</span>.</p>
                    </div>
                    <div class="flex justify-between items-end mt-6 pt-4 border-t border-white/20 relative z-10 gap-8">
                        <div class="flex gap-10">
                            <div>
                                <div class="text-[12px] font-black font-[Orbitron] uppercase"><%= students.size() %></div>
                                <div class="text-[7px] font-bold opacity-60 tracking-widest uppercase">Units_Managed</div>
                            </div>
                            <div>
                                <div class="text-[12px] font-black font-[Orbitron] uppercase">99%</div>
                                <div class="text-[7px] font-bold opacity-60 tracking-widest uppercase">Sync_Rate</div>
                            </div>
                        </div>
                        <div class="flex-grow max-w-[240px]">
                            <form action="meetingAction" method="post">
                                <input type="hidden" name="action" value="START_MEETING">
                                <input type="hidden" name="meetingId" value="MEET_<%= System.currentTimeMillis() %>">
                                <button type="submit" class="w-full bg-white text-red-500 py-3 px-6 font-[Orbitron] text-[10px] tracking-[0.2em] font-black uppercase hover:bg-black hover:text-white transition-all shadow-xl flex items-center justify-center gap-3">
                                    <i data-lucide="video" class="w-4 h-4"></i> Initiate_Briefing
                                </button>
                            </form>
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
                    <button onclick="filterStudents('<%= stream %>')" id="filter-<%= stream.replaceAll("\\s+", "_") %>" class="filter-btn"><%= stream %></button>
                    <% } %>
                </div>

                <div class="glass p-8 overflow-hidden flex flex-col relative min-h-[500px]">
                    <div class="flex justify-between items-center mb-10">
                        <div class="flex items-center gap-3">
                            <i data-lucide="users" class="w-4 h-4 text-red-500"></i>
                            <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Student_Registry</h2>
                        </div>
                        <button onclick="openDeployModal()" class="bg-red-500 text-white px-4 py-2 font-[Orbitron] text-[8px] tracking-[0.2em] font-black uppercase hover:bg-black transition-all flex items-center gap-2">
                            <i data-lucide="user-plus" class="w-3 h-3"></i> Initiate_New_Unit
                        </button>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="border-b border-black/5 text-[9px] text-gray-400 tracking-widest uppercase font-black bg-black/[0.02]">
                                    <th class="py-4 px-6">ID</th>
                                    <th class="py-4">Unit_Designation</th>
                                    <th class="py-4">Auth_ID</th>
                                    <th class="py-4">Vect_Stream</th>
                                    <th class="py-4 text-right pr-6">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="text-[10px] font-bold" id="student-table-body">
                                <% for(UserProfile s : students) { %>
                                <tr class="student-row border-b border-black/[0.03] hover:bg-black/[0.01] transition-colors group" data-stream="<%= s.getCourse() %>">
                                    <td class="py-5 px-6 text-gray-400">#<%= s.getId() %></td>
                                    <td class="py-5 uppercase tracking-tighter text-gray-900 font-[Orbitron] text-[11px]"><%= s.getFullName() %></td>
                                    <td class="py-5 text-gray-500 uppercase font-mono"><%= s.getUserName() %></td>
                                    <td class="py-5"><span class="bg-red-500/5 text-red-500/80 px-2 py-1 border border-red-500/10 text-[8px] tracking-widest uppercase"><%= s.getCourse() %></span></td>
                                    <td class="py-5 text-right pr-6 flex justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button onclick="showDetails(this)" 
                                            data-fullname="<%= s.getFullName() %>" 
                                            data-username="<%= s.getUserName() %>"
                                            data-email="<%= s.getEmail() %>"
                                            data-phone="<%= s.getPhone() %>"
                                            data-course="<%= s.getCourse() %>"
                                            data-batch="<%= s.getBatch() %>"
                                            data-spec="<%= s.getSpecialization() %>"
                                            class="bg-black text-white px-3 py-1.5 hover:bg-red-500 transition-all uppercase text-[7px] tracking-widest">Scan_Data</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- SECTION 3: LEAVE MANAGEMENT -->
            <section id="leave-management" class="flex flex-col gap-6">
                <div class="glass p-8 overflow-hidden flex flex-col relative min-h-[300px]">
                    <div class="flex items-center gap-3 mb-10">
                        <i data-lucide="clipboard-list" class="w-4 h-4 text-red-500"></i>
                        <h2 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900">Leave_Management_Queue</h2>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="border-b border-black/5 text-[9px] text-gray-400 tracking-widest uppercase font-black bg-black/[0.02]">
                                    <th class="py-4 px-6">Source_Unit</th>
                                    <th class="py-4">Reason</th>
                                    <th class="py-4">Temporal_Range</th>
                                    <th class="py-4 text-right pr-6">Command_Action</th>
                                </tr>
                            </thead>
                            <tbody class="text-[10px] font-bold">
                                <% if (pendingLeaves.isEmpty()) { %>
                                    <tr><td colspan="4" class="py-12 text-center text-gray-300 uppercase tracking-widest">Queue_Empty: No_Pending_Requests</td></tr>
                                <% } else { for(Map<String, String> l : pendingLeaves) { %>
                                <tr class="border-b border-black/[0.03] hover:bg-black/[0.01] transition-colors">
                                    <td class="py-5 px-6 uppercase tracking-tighter text-gray-900 font-[Orbitron] text-[11px]"><%= l.get("student_name") %></td>
                                    <td class="py-5 text-gray-500 uppercase max-w-[200px] truncate"><%= l.get("reason") %></td>
                                    <td class="py-5 font-mono text-[9px] text-gray-400"><%= l.get("start") %> // <%= l.get("end") %></td>
                                    <td class="py-5 text-right pr-6">
                                        <div class="flex justify-end gap-2">
                                            <form action="leaveAction" method="post" class="inline">
                                                <input type="hidden" name="action" value="UPDATE_LEAVE_STATUS">
                                                <input type="hidden" name="id" value="<%= l.get("id") %>">
                                                <input type="hidden" name="status" value="APPROVED">
                                                <button type="submit" class="bg-green-500 text-white px-3 py-1.5 hover:bg-black transition-all uppercase text-[7px] tracking-widest">Authorize</button>
                                            </form>
                                            <form action="leaveAction" method="post" class="inline">
                                                <input type="hidden" name="action" value="UPDATE_LEAVE_STATUS">
                                                <input type="hidden" name="id" value="<%= l.get("id") %>">
                                                <input type="hidden" name="status" value="DENIED">
                                                <button type="submit" class="bg-red-500 text-white px-3 py-1.5 hover:bg-black transition-all uppercase text-[7px] tracking-widest">Decline</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <!-- DETAIL MODAL -->
    <div id="detail-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-white/80 backdrop-blur-md" onclick="closeModal()"></div>
        <div class="glass max-w-2xl w-full p-0 relative border border-black/10 shadow-2xl">
            <div class="bg-red-500 px-8 py-4 flex justify-between items-center text-white">
                <h2 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black">Scanning_Result</h2>
                <button onclick="closeModal()"><i data-lucide="x" class="w-4 h-4"></i></button>
            </div>
            <div class="p-10" id="modal-content"></div>
        </div>
    </div>

    <!-- DEPLOY UNIT MODAL -->
    <div id="deploy-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" onclick="closeDeployModal()"></div>
        <div class="glass max-w-4xl w-full p-0 relative border border-black/10 shadow-2xl bg-white overflow-hidden">
            <div class="bg-black px-8 py-4 flex justify-between items-center text-white">
                <div class="flex items-center gap-3">
                    <i data-lucide="user-plus" class="w-4 h-4 text-red-500"></i>
                    <h2 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black">Unit_Provisioning_Terminal</h2>
                </div>
                <button onclick="closeDeployModal()"><i data-lucide="x" class="w-4 h-4 text-gray-400"></i></button>
            </div>
            
            <div class="p-10">
                <form action="teacherAction" method="post" class="grid grid-cols-2 gap-8">
                    <input type="hidden" name="action" value="ADD_STUDENT">
                    <input type="hidden" name="source" value="teacherDashboard.jsp">
                    
                    <div class="col-span-2">
                        <label class="label-tactical">Full_Name</label>
                        <input type="text" name="full_name" placeholder="ALBEDO_ONE" class="input-tactical" required>
                    </div>
                    <div>
                        <label class="label-tactical">Auth_ID (User)</label>
                        <input type="text" name="username" placeholder="UNIQUE_ID" class="input-tactical" required>
                    </div>
                    <div>
                        <label class="label-tactical">Relay_Email</label>
                        <input type="email" name="email" placeholder="UNIT@GURUKUL.EDU" class="input-tactical" required>
                    </div>
                    <div>
                        <label class="label-tactical">Course</label>
                        <input type="text" name="course" placeholder="B_TECH" class="input-tactical" required>
                    </div>
                    <div>
                        <label class="label-tactical">Temporal_Batch</label>
                        <input type="text" name="batch" placeholder="2024" class="input-tactical">
                    </div>
                    <div class="col-span-2">
                        <label class="label-tactical">Access_Cipher</label>
                        <input type="password" name="password" placeholder="••••••••" class="input-tactical" required>
                    </div>
                    
                    <div class="col-span-2 pt-4">
                        <button type="submit" class="w-full bg-red-500 text-white py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase hover:bg-black transition-all shadow-xl flex items-center justify-center gap-3">
                            <i data-lucide="shield-check" class="w-4 h-4"></i> Commit_Registry
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();

        function filterStudents(stream) {
            const rows = document.querySelectorAll('.student-row');
            const btns = document.querySelectorAll('.filter-btn');
            btns.forEach(b => b.classList.remove('active'));
            const id = 'filter-' + stream.replace(/\s+/g, '_');
            document.getElementById(id).classList.add('active');
            rows.forEach(row => {
                row.style.display = (stream === 'ALL' || row.dataset.stream === stream) ? 'table-row' : 'none';
            });
        }

        function showDetails(btn) {
            const s = btn.dataset;
            document.getElementById('modal-content').innerHTML = `
                <div class="grid grid-cols-2 gap-8">
                    <div class="col-span-2 border-b border-black/5 pb-6">
                        <h3 class="font-[Orbitron] text-xl font-black uppercase text-gray-900">\${s.fullname}</h3>
                        <p class="text-[8px] text-red-500 tracking-widest font-bold uppercase mt-1">Status: Operational</p>
                    </div>
                    <div><span class="label-tactical">Email</span><p class="text-[11px] font-mono">\${s.email}</p></div>
                    <div><span class="label-tactical">Auth_ID</span><p class="text-[11px] font-mono">\${s.username}</p></div>
                    <div><span class="label-tactical">Vect_Stream</span><p class="text-[11px] font-black uppercase">\${s.course}</p></div>
                    <div><span class="label-tactical">Batch</span><p class="text-[11px] uppercase">\${s.batch}</p></div>
                </div>
            `;
            document.getElementById('detail-modal').classList.remove('hidden');
            lucide.createIcons();
        }

        function closeModal() { document.getElementById('detail-modal').classList.add('hidden'); }
        function openDeployModal() { document.getElementById('deploy-modal').classList.remove('hidden'); }
        function closeDeployModal() { document.getElementById('deploy-modal').classList.add('hidden'); }
        
        const sidebarModule = document.getElementById('sidebar-module');
        document.getElementById('mobile-toggle')?.addEventListener('click', () => sidebarModule.classList.remove('-translate-x-full'));
    </script>
</body>
</html>
