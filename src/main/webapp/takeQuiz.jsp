<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null || !"Student".equalsIgnoreCase(user.getRole())) {
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

    Quiz quiz = null;
    List<QuizQuestion> questions = new ArrayList<>();
    
    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        // Check if already submitted
        String checkSql = "SELECT id FROM quiz_submissions WHERE quiz_id = ? AND student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, user.getId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                response.sendRedirect("quizResult.jsp?id=" + quizId + "&class_id=" + classId);
                return;
            }
        }
        
        // Fetch Quiz
        String qSql = "SELECT * FROM quizzes WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(qSql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                quiz = new Quiz();
                quiz.setId(rs.getInt("id"));
                quiz.setTitle(rs.getString("title"));
                quiz.setDescription(rs.getString("description"));
                quiz.setDurationMinutes(rs.getInt("duration_minutes"));
            }
        }
        if (quiz == null) { response.sendRedirect("classes.jsp"); return; }
        
        // Fetch Questions
        String quSql = "SELECT * FROM quiz_questions WHERE quiz_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(quSql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                QuizQuestion q = new QuizQuestion();
                q.setId(rs.getInt("id"));
                q.setQuestionText(rs.getString("question_text"));
                q.setOptionA(rs.getString("option_a"));
                q.setOptionB(rs.getString("option_b"));
                q.setOptionC(rs.getString("option_c"));
                q.setOptionD(rs.getString("option_d"));
                q.setMarks(rs.getInt("marks"));
                questions.add(q);
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Take Quiz - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255,255,255,0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0,0,0,0.05); }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
        .radio-custom:checked + div { @apply border-red-500 bg-red-50 text-red-700; }
        .radio-custom:checked + div .indicator { @apply bg-red-500; }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>

    <!-- TOP BAR -->
    <div class="relative z-50 border-b border-black/5 px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
        <div class="flex items-center gap-4">
            <span class="text-red-500 animate-pulse">&#10033;</span>
            <span>GURUKUL_ILE / ACTIVE QUIZ</span>
        </div>
        <div class="flex items-center gap-6">
            <div id="timerDisplay" class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20 text-lg font-black">
                --:--
            </div>
            <div class="font-[Orbitron] text-gray-500 tracking-widest px-3 py-1 border border-black/10">USER_ID: <%= user.getUserName() %></div>
        </div>
    </div>

    <!-- MAIN -->
    <main class="flex-grow overflow-y-auto scrollbar-hide relative z-10 p-8">
        <div class="max-w-4xl mx-auto space-y-8">
            <div class="glass p-8 border-l-4 border-black mb-8">
                <h1 class="font-[Orbitron] text-2xl font-black tracking-tighter uppercase text-gray-900 mb-2"><%= quiz.getTitle() %></h1>
                <p class="text-[12px] text-gray-600 mb-4"><%= quiz.getDescription() %></p>
                <div class="flex gap-6 text-[10px] font-bold tracking-widest uppercase text-gray-400">
                    <span><i data-lucide="clock" class="w-4 h-4 inline mr-1 text-red-500"></i> <%= quiz.getDurationMinutes() %> Minutes</span>
                    <span><i data-lucide="help-circle" class="w-4 h-4 inline mr-1"></i> <%= questions.size() %> Questions</span>
                </div>
            </div>

            <form action="quizAction" method="post" id="quizForm" class="space-y-6">
                <input type="hidden" name="action" value="SUBMIT_QUIZ">
                <input type="hidden" name="quiz_id" value="<%= quizId %>">
                <input type="hidden" name="class_id" value="<%= classId %>">

                <% for (int i = 0; i < questions.size(); i++) {
                    QuizQuestion q = questions.get(i);
                %>
                <div class="glass p-8 border-l-4 border-red-500 relative">
                    <div class="absolute top-4 right-4 text-[10px] text-gray-400 font-bold uppercase tracking-widest"><%= q.getMarks() %> Marks</div>
                    <h3 class="font-[Inter] text-sm font-bold text-gray-900 mb-6 leading-relaxed"><span class="text-red-500 font-[Orbitron] mr-2">Q<%= i + 1 %>.</span> <%= q.getQuestionText() %></h3>
                    
                    <div class="grid md:grid-cols-2 gap-4">
                        <label class="cursor-pointer">
                            <input type="radio" name="q_<%= q.getId() %>" value="A" class="peer hidden radio-custom" required>
                            <div class="border border-black/10 p-4 hover:border-red-500/50 hover:bg-red-500/5 transition-all flex items-center gap-4">
                                <div class="w-4 h-4 border border-gray-400 rounded-full flex items-center justify-center"><div class="w-2 h-2 rounded-full indicator transition-all"></div></div>
                                <span class="text-xs font-medium"><span class="font-bold mr-2 text-gray-400">A.</span><%= q.getOptionA() %></span>
                            </div>
                        </label>
                        <label class="cursor-pointer">
                            <input type="radio" name="q_<%= q.getId() %>" value="B" class="peer hidden radio-custom" required>
                            <div class="border border-black/10 p-4 hover:border-red-500/50 hover:bg-red-500/5 transition-all flex items-center gap-4">
                                <div class="w-4 h-4 border border-gray-400 rounded-full flex items-center justify-center"><div class="w-2 h-2 rounded-full indicator transition-all"></div></div>
                                <span class="text-xs font-medium"><span class="font-bold mr-2 text-gray-400">B.</span><%= q.getOptionB() %></span>
                            </div>
                        </label>
                        <label class="cursor-pointer">
                            <input type="radio" name="q_<%= q.getId() %>" value="C" class="peer hidden radio-custom" required>
                            <div class="border border-black/10 p-4 hover:border-red-500/50 hover:bg-red-500/5 transition-all flex items-center gap-4">
                                <div class="w-4 h-4 border border-gray-400 rounded-full flex items-center justify-center"><div class="w-2 h-2 rounded-full indicator transition-all"></div></div>
                                <span class="text-xs font-medium"><span class="font-bold mr-2 text-gray-400">C.</span><%= q.getOptionC() %></span>
                            </div>
                        </label>
                        <label class="cursor-pointer">
                            <input type="radio" name="q_<%= q.getId() %>" value="D" class="peer hidden radio-custom" required>
                            <div class="border border-black/10 p-4 hover:border-red-500/50 hover:bg-red-500/5 transition-all flex items-center gap-4">
                                <div class="w-4 h-4 border border-gray-400 rounded-full flex items-center justify-center"><div class="w-2 h-2 rounded-full indicator transition-all"></div></div>
                                <span class="text-xs font-medium"><span class="font-bold mr-2 text-gray-400">D.</span><%= q.getOptionD() %></span>
                            </div>
                        </label>
                    </div>
                </div>
                <% } %>

                <button type="submit" class="w-full py-5 bg-red-500 text-white font-[Orbitron] text-[12px] tracking-[0.4em] font-black uppercase hover:bg-black transition-all shadow-xl flex items-center justify-center gap-3 mt-8">
                    <i data-lucide="check-circle" class="w-5 h-5"></i> Submit Quiz
                </button>
            </form>
        </div>
    </main>

    <script>
        lucide.createIcons();
        
        let durationMinutes = <%= quiz.getDurationMinutes() %>;
        let timeRemaining = durationMinutes * 60;
        const timerDisplay = document.getElementById('timerDisplay');
        const form = document.getElementById('quizForm');

        function updateTimer() {
            let minutes = Math.floor(timeRemaining / 60);
            let seconds = timeRemaining % 60;
            
            minutes = minutes < 10 ? "0" + minutes : minutes;
            seconds = seconds < 10 ? "0" + seconds : seconds;
            
            timerDisplay.innerText = minutes + ":" + seconds;
            
            if (timeRemaining <= 60) {
                timerDisplay.classList.add('animate-pulse');
            }
            
            if (timeRemaining <= 0) {
                clearInterval(timerInterval);
                alert("Time is up! Submitting quiz automatically.");
                // Remove required attributes so form submits
                form.querySelectorAll('[required]').forEach(el => el.removeAttribute('required'));
                form.submit();
            }
            timeRemaining--;
        }

        const timerInterval = setInterval(updateTimer, 1000);
        updateTimer();
    </script>
</body>
</html>
