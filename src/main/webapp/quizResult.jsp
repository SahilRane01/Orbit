<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String quizIdStr = request.getParameter("id");
    String classIdStr = request.getParameter("class_id");
    if (quizIdStr == null || classIdStr == null) {
        response.sendRedirect("classes.jsp");
        return;
    }
    int quizId = Integer.parseInt(quizIdStr);
    int classId = Integer.parseInt(classIdStr);
    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());

    Quiz quiz = null;
    QuizSubmission mySubmission = null;
    List<QuizSubmission> allSubmissions = new ArrayList<>();
    
    // Detailed feedback data structure
    // Key: Question ID
    // Value: Map containing 'text', 'selected', 'correct', 'marks', 'awarded'
    Map<Integer, Map<String, Object>> reviewDetails = new LinkedHashMap<>();

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Fetch Quiz
        String qSql = "SELECT * FROM quizzes WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(qSql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                quiz = new Quiz();
                quiz.setId(rs.getInt("id"));
                quiz.setTitle(rs.getString("title"));
            }
        }
        if (quiz == null) { response.sendRedirect("classes.jsp"); return; }
        
        if (isTeacher) {
            // Fetch all submissions for teacher
            String subSql = "SELECT s.*, u.full_name FROM quiz_submissions s JOIN users u ON u.id = s.student_id WHERE s.quiz_id = ? ORDER BY s.score DESC";
            try (PreparedStatement ps = conn.prepareStatement(subSql)) {
                ps.setInt(1, quizId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    QuizSubmission qs = new QuizSubmission();
                    qs.setId(rs.getInt("id"));
                    qs.setStudentId(rs.getInt("student_id"));
                    qs.setStudentName(rs.getString("full_name"));
                    qs.setScore(rs.getInt("score"));
                    qs.setTotalMarks(rs.getInt("total_marks"));
                    qs.setSubmittedAt(rs.getTimestamp("submitted_at"));
                    allSubmissions.add(qs);
                }
            }
        } else {
            // Fetch specific student submission
            String mySubSql = "SELECT * FROM quiz_submissions WHERE quiz_id = ? AND student_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(mySubSql)) {
                ps.setInt(1, quizId);
                ps.setInt(2, user.getId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    mySubmission = new QuizSubmission();
                    mySubmission.setId(rs.getInt("id"));
                    mySubmission.setScore(rs.getInt("score"));
                    mySubmission.setTotalMarks(rs.getInt("total_marks"));
                    mySubmission.setSubmittedAt(rs.getTimestamp("submitted_at"));
                    
                    // Fetch detailed review
                    String reviewSql = "SELECT q.id, q.question_text, q.correct_option, q.marks, a.selected_option " +
                                     "FROM quiz_questions q " +
                                     "LEFT JOIN quiz_answers a ON q.id = a.question_id AND a.submission_id = ? " +
                                     "WHERE q.quiz_id = ?";
                    try (PreparedStatement psR = conn.prepareStatement(reviewSql)) {
                        psR.setInt(1, mySubmission.getId());
                        psR.setInt(2, quizId);
                        ResultSet rsR = psR.executeQuery();
                        while (rsR.next()) {
                            Map<String, Object> detail = new HashMap<>();
                            detail.put("text", rsR.getString("question_text"));
                            String correctOpt = rsR.getString("correct_option");
                            String selectedOpt = rsR.getString("selected_option");
                            int marks = rsR.getInt("marks");
                            
                            detail.put("correct", correctOpt);
                            detail.put("selected", selectedOpt);
                            detail.put("marks", marks);
                            detail.put("awarded", (selectedOpt != null && selectedOpt.equalsIgnoreCase(correctOpt)) ? marks : 0);
                            
                            reviewDetails.put(rsR.getInt("id"), detail);
                        }
                    }
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Results - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255,255,255,0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0,0,0,0.05); }
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
            <span>GURUKUL_ILE / QUIZ RESULTS</span>
        </div>
    </div>

    <!-- MAIN -->
    <main class="flex-grow overflow-y-auto scrollbar-hide relative z-10 p-8">
        <div class="max-w-5xl mx-auto space-y-8">
            <div class="glass p-8 border-l-4 border-black">
                <h1 class="font-[Orbitron] text-2xl font-black tracking-tighter uppercase text-gray-900 mb-2"><%= quiz.getTitle() %></h1>
                <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase">Performance Metrics & Feedback</p>
            </div>

            <% if (isTeacher) { %>
                <!-- TEACHER VIEW: All Submissions -->
                <div class="glass p-8 border-l-4 border-red-500">
                    <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-bold text-gray-900 mb-6">Student Scores (<%= allSubmissions.size() %>)</h2>
                    
                    <% if (allSubmissions.isEmpty()) { %>
                        <p class="text-center text-gray-400 text-xs tracking-widest uppercase py-8">No submissions yet.</p>
                    <% } else { %>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-xs">
                                <thead>
                                    <tr class="text-[9px] text-gray-400 uppercase tracking-widest border-b border-black/10">
                                        <th class="py-3">Student Name</th>
                                        <th class="py-3">Score</th>
                                        <th class="py-3">Percentage</th>
                                        <th class="py-3 text-right">Submitted At</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (QuizSubmission sub : allSubmissions) { 
                                        double percentage = sub.getTotalMarks() > 0 ? ((double) sub.getScore() / sub.getTotalMarks()) * 100 : 0;
                                    %>
                                    <tr class="border-b border-black/5 hover:bg-black/5">
                                        <td class="py-4 font-bold uppercase"><%= sub.getStudentName() %></td>
                                        <td class="py-4 font-[Orbitron] text-sm"><%= sub.getScore() %> / <%= sub.getTotalMarks() %></td>
                                        <td class="py-4">
                                            <span class="px-2 py-1 text-[10px] font-bold rounded-sm <%= percentage >= 75 ? "bg-green-100 text-green-700" : (percentage >= 40 ? "bg-yellow-100 text-yellow-700" : "bg-red-100 text-red-700") %>">
                                                <%= String.format("%.0f", percentage) %>%
                                            </span>
                                        </td>
                                        <td class="py-4 text-right text-gray-500 text-[10px]"><%= sub.getSubmittedAt() %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <!-- STUDENT VIEW: My Result -->
                <% if (mySubmission == null) { %>
                    <div class="glass p-12 text-center">
                        <i data-lucide="alert-circle" class="w-12 h-12 text-yellow-500 mx-auto mb-4"></i>
                        <h2 class="font-[Orbitron] text-lg font-black uppercase mb-2">Quiz Not Attempted</h2>
                        <a href="takeQuiz.jsp?id=<%= quizId %>&class_id=<%= classId %>" class="inline-block mt-4 bg-red-500 text-white px-8 py-3 font-[Orbitron] text-[10px] tracking-widest font-black uppercase hover:bg-black transition-all">Start Quiz</a>
                    </div>
                <% } else { 
                    double percentage = mySubmission.getTotalMarks() > 0 ? ((double) mySubmission.getScore() / mySubmission.getTotalMarks()) * 100 : 0;
                %>
                    <div class="grid md:grid-cols-3 gap-8">
                        <div class="md:col-span-1 glass p-8 text-center flex flex-col items-center justify-center border-l-4 <%= percentage >= 40 ? "border-green-500" : "border-red-500" %>">
                            <span class="text-[9px] text-gray-400 font-bold tracking-widest uppercase mb-4 block">Final Score</span>
                            <div class="text-6xl font-[Orbitron] font-black <%= percentage >= 40 ? "text-green-600" : "text-red-500" %> mb-2">
                                <%= mySubmission.getScore() %>
                            </div>
                            <div class="text-xl text-gray-400 font-[Orbitron] font-bold mb-4">/ <%= mySubmission.getTotalMarks() %></div>
                            <span class="px-3 py-1 text-[10px] font-bold rounded-sm <%= percentage >= 75 ? "bg-green-100 text-green-700" : (percentage >= 40 ? "bg-yellow-100 text-yellow-700" : "bg-red-100 text-red-700") %>">
                                <%= String.format("%.0f", percentage) %>%
                            </span>
                        </div>
                        
                        <div class="md:col-span-2 glass p-8">
                            <h3 class="font-[Orbitron] text-xs tracking-[0.3em] uppercase font-bold text-gray-900 mb-6">Detailed Review</h3>
                            <div class="space-y-6">
                                <% 
                                int qNum = 1;
                                for (Map.Entry<Integer, Map<String, Object>> entry : reviewDetails.entrySet()) {
                                    Map<String, Object> detail = entry.getValue();
                                    boolean isCorrect = (Integer) detail.get("awarded") > 0;
                                %>
                                <div class="p-4 border <%= isCorrect ? "border-green-200 bg-green-50/50" : "border-red-200 bg-red-50/50" %>">
                                    <div class="flex justify-between items-start mb-2">
                                        <h4 class="text-sm font-medium"><span class="font-[Orbitron] <%= isCorrect ? "text-green-600" : "text-red-500" %> mr-2">Q<%= qNum++ %>.</span> <%= detail.get("text") %></h4>
                                        <span class="text-xs font-bold <%= isCorrect ? "text-green-600" : "text-red-500" %> shrink-0">
                                            <%= detail.get("awarded") %> / <%= detail.get("marks") %>
                                        </span>
                                    </div>
                                    <div class="text-xs mt-3 flex items-center gap-4">
                                        <div class="flex items-center gap-2">
                                            <span class="text-gray-500 uppercase tracking-widest text-[9px] font-bold">Your Answer:</span>
                                            <span class="font-bold <%= isCorrect ? "text-green-600" : "text-red-500" %>"><%= detail.get("selected") != null ? detail.get("selected") : "None" %></span>
                                        </div>
                                        <% if (!isCorrect) { %>
                                        <div class="flex items-center gap-2">
                                            <span class="text-gray-500 uppercase tracking-widest text-[9px] font-bold">Correct:</span>
                                            <span class="font-bold text-green-600"><%= detail.get("correct") %></span>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </main>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
