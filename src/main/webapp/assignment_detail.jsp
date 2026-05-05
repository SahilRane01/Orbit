<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection, java.text.SimpleDateFormat" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());
    int assignmentId = 0, classId = 0;
    try {
        assignmentId = Integer.parseInt(request.getParameter("id"));
        classId = Integer.parseInt(request.getParameter("class_id"));
    } catch (Exception e) { response.sendRedirect("classes.jsp"); return; }

    Assignment assignment = null;
    Classroom classroom = null;
    List<Submission> submissions = new ArrayList<>();
    Submission mySubmission = null;
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    String[] cardColors = {"#4285F4", "#0F9D58", "#DB4437", "#F4B400", "#AB47BC", "#00ACC1", "#FF7043", "#5C6BC0"};

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Fetch class info
        String clsSql = "SELECT c.*, u.full_name AS teacher_name FROM classes c JOIN users u ON u.id = c.teacher_id WHERE c.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(clsSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                classroom = new Classroom();
                classroom.setId(rs.getInt("id"));
                classroom.setName(rs.getString("name"));
                classroom.setTeacherName(rs.getString("teacher_name"));
            }
        }

        // Fetch assignment
        String asgSql = "SELECT * FROM assignments WHERE id = ? AND class_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(asgSql)) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, classId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                assignment = new Assignment();
                assignment.setId(rs.getInt("id"));
                assignment.setClassId(rs.getInt("class_id"));
                assignment.setTitle(rs.getString("title"));
                assignment.setDescription(rs.getString("description"));
                assignment.setDueDate(rs.getDate("due_date"));
                assignment.setMaxMarks(rs.getInt("max_marks"));
                assignment.setCreatedAt(rs.getTimestamp("created_at"));
            }
        }
        if (assignment == null || classroom == null) { response.sendRedirect("classes.jsp"); return; }

        if (isTeacher) {
            // Fetch all submissions
            String subSql = "SELECT s.*, u.full_name AS student_name FROM submissions s JOIN users u ON u.id = s.student_id WHERE s.assignment_id = ? ORDER BY s.submitted_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(subSql)) {
                ps.setInt(1, assignmentId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Submission sub = new Submission();
                    sub.setId(rs.getInt("id"));
                    sub.setStudentId(rs.getInt("student_id"));
                    sub.setStudentName(rs.getString("student_name"));
                    sub.setTextContent(rs.getString("text_content"));
                    sub.setFileName(rs.getString("file_name"));
                    sub.setFilePath(rs.getString("file_path"));
                    sub.setGrade(rs.getObject("grade") != null ? rs.getInt("grade") : null);
                    sub.setFeedback(rs.getString("feedback"));
                    sub.setSubmittedAt(rs.getTimestamp("submitted_at"));
                    sub.setGradedAt(rs.getTimestamp("graded_at"));
                    submissions.add(sub);
                }
            }
        } else {
            // Fetch my submission
            String mySql = "SELECT * FROM submissions WHERE assignment_id = ? AND student_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(mySql)) {
                ps.setInt(1, assignmentId);
                ps.setInt(2, user.getId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    mySubmission = new Submission();
                    mySubmission.setId(rs.getInt("id"));
                    mySubmission.setTextContent(rs.getString("text_content"));
                    mySubmission.setFileName(rs.getString("file_name"));
                    mySubmission.setFilePath(rs.getString("file_path"));
                    mySubmission.setGrade(rs.getObject("grade") != null ? rs.getInt("grade") : null);
                    mySubmission.setFeedback(rs.getString("feedback"));
                    mySubmission.setSubmittedAt(rs.getTimestamp("submitted_at"));
                    mySubmission.setGradedAt(rs.getTimestamp("graded_at"));
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String bannerColor = cardColors[classId % cardColors.length];
    boolean isPastDue = assignment.getDueDate() != null && assignment.getDueDate().before(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= assignment.getTitle() %> - Gurukul ILE</title>
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
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>

    <!-- TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <a href="class_detail.jsp?id=<%= classId %>" class="p-2 -ml-2 text-gray-400 hover:text-red-500 transition-colors">
                <i data-lucide="arrow-left" class="w-5 h-5"></i>
            </a>
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / ASSIGNMENT DETAILS</span>
        </div>
        <div class="flex items-center gap-6">
            <div class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20">USER_ID: <%= user.getUserName() %></div>
        </div>
    </div>

    <!-- CONTENT -->
    <div class="flex-grow overflow-y-auto scrollbar-hide relative z-10">
        <div class="max-w-5xl mx-auto p-8 space-y-8">

            <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="glass border-l-4 border-green-500 p-4 bg-green-500/5 flex items-center gap-4">
                <i data-lucide="check-circle" class="w-5 h-5 text-green-500"></i>
                <span class="text-[10px] font-bold uppercase tracking-widest text-green-700">Success</span>
            </div>
            <% } %>

            <div class="grid grid-cols-12 gap-8">
                <!-- LEFT: Assignment Details -->
                <div class="col-span-12 lg:col-span-8 space-y-6">
                    <!-- Assignment Header -->
                    <div class="glass p-8 border-l-4 animate-entry" style="border-color: <%= bannerColor %>">
                        <div class="flex items-start gap-6">
                            <div class="w-14 h-14 flex items-center justify-center shrink-0" style="background: <%= bannerColor %>">
                                <i data-lucide="file-text" class="w-7 h-7 text-white"></i>
                            </div>
                            <div class="flex-grow">
                                <h1 class="font-[Orbitron] text-xl font-black uppercase tracking-wider text-gray-900 mb-2"><%= assignment.getTitle() %></h1>
                                <div class="flex items-center gap-6 text-[9px] text-gray-400 tracking-widest uppercase font-bold">
                                    <span><%= classroom.getTeacherName() %></span>
                                    <span>Posted: <%= dateFormat.format(assignment.getCreatedAt()) %></span>
                                    <span class="<%= isPastDue ? "text-red-500" : "" %>"><%= assignment.getMaxMarks() %> Marks</span>
                                </div>
                            </div>
                        </div>
                        <% if (assignment.getDueDate() != null) { %>
                        <div class="mt-6 pt-4 border-t border-black/5 flex items-center gap-3">
                            <i data-lucide="clock" class="w-4 h-4 <%= isPastDue ? "text-red-500" : "text-green-600" %>"></i>
                            <span class="text-[10px] font-bold tracking-widest uppercase <%= isPastDue ? "text-red-500" : "text-green-600" %>">
                                Due: <%= dateFormat.format(assignment.getDueDate()) %> <%= isPastDue ? "(PAST DUE)" : "" %>
                            </span>
                        </div>
                        <% } %>
                    </div>

                    <!-- Description -->
                    <% if (assignment.getDescription() != null && !assignment.getDescription().isEmpty()) { %>
                    <div class="glass p-8 animate-entry" style="animation-delay: 0.1s">
                        <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 mb-4">Instructions</h3>
                        <p class="text-[13px] text-gray-700 leading-relaxed whitespace-pre-wrap"><%= assignment.getDescription() %></p>
                    </div>
                    <% } %>

                    <!-- TEACHER: View Submissions -->
                    <% if (isTeacher) { %>
                    <div class="glass p-8 animate-entry" style="animation-delay: 0.2s">
                        <div class="flex items-center justify-between mb-8">
                            <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 flex items-center gap-3">
                                <i data-lucide="inbox" class="w-4 h-4 text-red-500"></i> Student Submissions
                            </h3>
                            <span class="text-[9px] text-gray-400 tracking-widest uppercase font-bold"><%= submissions.size() %> Received</span>
                        </div>

                        <% if (submissions.isEmpty()) { %>
                        <p class="text-[10px] text-gray-400 tracking-widest uppercase text-center py-8">No Submissions Yet</p>
                        <% } %>

                        <div class="space-y-4">
                            <% for (int i = 0; i < submissions.size(); i++) {
                                Submission sub = submissions.get(i);
                            %>
                            <div class="border border-black/5 p-6 bg-white/50 hover:shadow-md transition-all">
                                <div class="flex items-center justify-between mb-4">
                                    <div class="flex items-center gap-4">
                                        <div class="w-10 h-10 bg-gray-100 flex items-center justify-center text-gray-500 font-[Orbitron] text-xs font-bold"><%= sub.getStudentName().substring(0,1).toUpperCase() %></div>
                                        <div>
                                            <h4 class="text-[12px] font-bold uppercase tracking-wider"><%= sub.getStudentName() %></h4>
                                            <span class="text-[8px] text-gray-400 tracking-widest"><%= timeFormat.format(sub.getSubmittedAt()) %></span>
                                        </div>
                                    </div>
                                    <% if (sub.getGrade() != null) { %>
                                    <div class="bg-green-500/10 text-green-600 px-4 py-2 font-[Orbitron] text-sm font-black"><%= sub.getGrade() %>/<%= assignment.getMaxMarks() %></div>
                                    <% } else { %>
                                    <div class="bg-yellow-500/10 text-yellow-600 px-3 py-1 text-[8px] font-bold uppercase tracking-widest">Needs Grading</div>
                                    <% } %>
                                </div>

                                <% if (sub.getTextContent() != null && !sub.getTextContent().isEmpty()) { %>
                                <div class="bg-gray-50 p-4 mb-4 border border-black/5">
                                    <p class="text-[11px] text-gray-600 whitespace-pre-wrap"><%= sub.getTextContent() %></p>
                                </div>
                                <% } %>

                                <% if (sub.getFileName() != null) { %>
                                <div class="flex items-center gap-3 mb-4 bg-blue-50 p-3 border border-blue-100">
                                    <i data-lucide="file" class="w-4 h-4 text-blue-500"></i>
                                    <a href="<%= sub.getFilePath() %>" target="_blank" class="text-[10px] text-blue-600 font-bold tracking-widest uppercase hover:underline"><%= sub.getFileName() %></a>
                                </div>
                                <% } %>

                                <!-- Grading Form -->
                                <form action="assignmentAction" method="post" class="flex items-end gap-4 pt-4 border-t border-black/5">
                                    <input type="hidden" name="action" value="GRADE_SUBMISSION">
                                    <input type="hidden" name="submission_id" value="<%= sub.getId() %>">
                                    <input type="hidden" name="assignment_id" value="<%= assignmentId %>">
                                    <input type="hidden" name="class_id" value="<%= classId %>">
                                    <div class="flex-shrink-0">
                                        <label class="label-tactical">Grade (/<%= assignment.getMaxMarks() %>)</label>
                                        <input type="number" name="grade" min="0" max="<%= assignment.getMaxMarks() %>" value="<%= sub.getGrade() != null ? sub.getGrade() : "" %>" class="input-tactical w-24" required>
                                    </div>
                                    <div class="flex-grow">
                                        <label class="label-tactical">Feedback</label>
                                        <input type="text" name="feedback" value="<%= sub.getFeedback() != null ? sub.getFeedback() : "" %>" class="input-tactical" placeholder="Add Feedback (Optional)">
                                    </div>
                                    <button type="submit" class="bg-green-500 text-white px-4 py-3 font-[Orbitron] text-[8px] tracking-[0.2em] font-black uppercase hover:bg-black transition-all shrink-0 flex items-center gap-2">
                                        <i data-lucide="check" class="w-3 h-3"></i> Grade
                                    </button>
                                </form>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>

                <!-- RIGHT: Student Submission Panel -->
                <div class="col-span-12 lg:col-span-4 space-y-6">
                    <% if (!isTeacher) { %>
                    <!-- Submission Status -->
                    <div class="glass p-6 animate-entry" style="animation-delay: 0.15s">
                        <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 mb-4 flex items-center gap-3">
                            <i data-lucide="send" class="w-4 h-4 text-red-500"></i> Your Submission
                        </h3>

                        <% if (mySubmission != null) { %>
                        <!-- Already submitted -->
                        <div class="mb-4 p-4 bg-green-50 border border-green-200">
                            <div class="flex items-center gap-2 mb-2">
                                <i data-lucide="check-circle" class="w-4 h-4 text-green-500"></i>
                                <span class="text-[10px] text-green-700 font-bold tracking-widest uppercase">Submitted</span>
                            </div>
                            <span class="text-[9px] text-gray-400 tracking-widest"><%= timeFormat.format(mySubmission.getSubmittedAt()) %></span>

                            <% if (mySubmission.getFileName() != null) { %>
                            <div class="flex items-center gap-2 mt-3 bg-white p-2 border border-black/5">
                                <i data-lucide="file" class="w-3 h-3 text-blue-500"></i>
                                <span class="text-[9px] text-gray-600 font-bold tracking-widest uppercase truncate"><%= mySubmission.getFileName() %></span>
                            </div>
                            <% } %>

                            <% if (mySubmission.getGrade() != null) { %>
                            <div class="mt-4 pt-4 border-t border-green-200">
                                <div class="text-center">
                                    <div class="font-[Orbitron] text-3xl font-black" style="color: <%= bannerColor %>"><%= mySubmission.getGrade() %><span class="text-sm text-gray-400">/<%= assignment.getMaxMarks() %></span></div>
                                    <span class="text-[8px] text-gray-400 tracking-widest uppercase">Your Grade</span>
                                </div>
                                <% if (mySubmission.getFeedback() != null && !mySubmission.getFeedback().isEmpty()) { %>
                                <div class="mt-3 bg-white p-3 border border-black/5">
                                    <span class="text-[7px] text-gray-400 tracking-widest uppercase block mb-1">Feedback</span>
                                    <p class="text-[11px] text-gray-700"><%= mySubmission.getFeedback() %></p>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <% } %>

                        <!-- Submit / Resubmit Form -->
                        <form action="submitAction" method="post" enctype="multipart/form-data" class="space-y-4">
                            <input type="hidden" name="action" value="SUBMIT_ASSIGNMENT">
                            <input type="hidden" name="assignment_id" value="<%= assignmentId %>">
                            <input type="hidden" name="class_id" value="<%= classId %>">
                            <div>
                                <label class="label-tactical">Your Answer</label>
                                <textarea name="text_content" rows="5" class="input-tactical" placeholder="Type your answer here..."><%= mySubmission != null && mySubmission.getTextContent() != null ? mySubmission.getTextContent() : "" %></textarea>
                            </div>
                            <div>
                                <label class="label-tactical">Attach File</label>
                                <div class="border border-dashed border-black/10 p-6 text-center bg-white/30 hover:border-red-500/30 transition-all cursor-pointer relative">
                                    <i data-lucide="upload-cloud" class="w-8 h-8 text-gray-300 mx-auto mb-2"></i>
                                    <p class="text-[9px] text-gray-400 tracking-widest uppercase">PDF, DOC, or Image (Max 10MB)</p>
                                    <input type="file" name="submission_file" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" accept=".pdf,.doc,.docx,.png,.jpg,.jpeg">
                                </div>
                            </div>
                            <button type="submit" class="w-full py-3 font-[Orbitron] text-[10px] tracking-[0.3em] uppercase font-black transition-all flex items-center justify-center gap-3 <%= mySubmission != null ? "bg-black text-white hover:bg-red-500" : "bg-red-500 text-white hover:bg-black" %> shadow-xl">
                                <i data-lucide="<%= mySubmission != null ? "refresh-cw" : "send" %>" class="w-4 h-4"></i>
                                <%= mySubmission != null ? "Resubmit" : "Submit Assignment" %>
                            </button>
                        </form>
                    </div>
                    <% } %>

                    <!-- Quick Info -->
                    <div class="glass p-6 animate-entry" style="animation-delay: 0.25s">
                        <h3 class="font-[Orbitron] text-xs tracking-widest uppercase font-bold text-gray-900 mb-4">Details</h3>
                        <div class="space-y-4 text-[10px]">
                            <div class="flex justify-between items-center pb-3 border-b border-black/5">
                                <span class="text-gray-400 uppercase tracking-widest font-bold">Class</span>
                                <span class="font-bold uppercase"><%= classroom.getName() %></span>
                            </div>
                            <div class="flex justify-between items-center pb-3 border-b border-black/5">
                                <span class="text-gray-400 uppercase tracking-widest font-bold">Max Marks</span>
                                <span class="font-bold"><%= assignment.getMaxMarks() %></span>
                            </div>
                            <% if (assignment.getDueDate() != null) { %>
                            <div class="flex justify-between items-center pb-3 border-b border-black/5">
                                <span class="text-gray-400 uppercase tracking-widest font-bold">Due</span>
                                <span class="font-bold <%= isPastDue ? "text-red-500" : "text-green-600" %>"><%= dateFormat.format(assignment.getDueDate()) %></span>
                            </div>
                            <% } %>
                            <% if (isTeacher) { %>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-400 uppercase tracking-widest font-bold">Submissions</span>
                                <span class="font-bold"><%= submissions.size() %></span>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
