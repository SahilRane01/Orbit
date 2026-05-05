<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null || !"Teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    String classIdStr = request.getParameter("class_id");
    if (classIdStr == null || classIdStr.isEmpty()) {
        response.sendRedirect("classes.jsp");
        return;
    }
    int classId = Integer.parseInt(classIdStr);
    
    Classroom classroom = null;
    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        String classSql = "SELECT * FROM classes WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(classSql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                classroom = new Classroom();
                classroom.setId(rs.getInt("id"));
                classroom.setName(rs.getString("name"));
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    if (classroom == null) { response.sendRedirect("classes.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Quiz - Gurukul ILE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255,255,255,0.7); backdrop-filter: blur(12px); border: 1px solid rgba(0,0,0,0.05); }
        .input-tactical { @apply w-full bg-white/50 border border-black/5 p-3 text-[10px] font-bold tracking-widest font-[Inter] focus:border-red-500 outline-none transition-all; }
        .label-tactical { @apply text-[7px] text-gray-400 font-bold tracking-[0.4em] uppercase block mb-2; }
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
            <span>GURUKUL_ILE / QUIZ BUILDER</span>
        </div>
        <div class="flex items-center gap-6">
            <div class="font-[Orbitron] text-red-500 tracking-widest bg-red-500/5 px-3 py-1 border border-red-500/20">USER_ID: <%= user.getUserName() %></div>
        </div>
    </div>

    <!-- MAIN -->
    <main class="flex-grow overflow-y-auto scrollbar-hide relative z-10 p-8">
        <div class="max-w-4xl mx-auto space-y-8">
            <header class="mb-10">
                <h1 class="font-[Orbitron] text-3xl font-black tracking-tighter uppercase text-gray-900 mb-2">Create Quiz</h1>
                <p class="text-[10px] text-gray-400 font-bold tracking-[0.3em] uppercase">Target Class: <%= classroom.getName() %></p>
            </header>

            <form action="quizAction" method="post" id="quizForm" class="space-y-8">
                <input type="hidden" name="action" value="CREATE_QUIZ">
                <input type="hidden" name="class_id" value="<%= classId %>">
                <input type="hidden" name="questionCount" id="questionCount" value="1">

                <div class="glass p-8 border-l-4 border-black">
                    <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-bold text-gray-900 mb-6">Quiz Details</h2>
                    <div class="grid md:grid-cols-2 gap-6">
                        <div class="md:col-span-2">
                            <label class="label-tactical">Quiz Title</label>
                            <input type="text" name="title" class="input-tactical" placeholder="Midterm Exam, Chapter 1 Quiz..." required>
                        </div>
                        <div class="md:col-span-2">
                            <label class="label-tactical">Description / Instructions</label>
                            <textarea name="description" rows="3" class="input-tactical" placeholder="Read carefully before answering..."></textarea>
                        </div>
                        <div>
                            <label class="label-tactical">Duration (Minutes)</label>
                            <input type="number" name="duration" value="30" class="input-tactical" min="1" required>
                        </div>
                    </div>
                </div>

                <div id="questionsContainer" class="space-y-6">
                    <!-- Initial Question -->
                    <div class="glass p-8 border-l-4 border-red-500 question-block" data-qid="1">
                        <div class="flex justify-between items-center mb-6">
                            <h3 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black text-gray-900">Question #<span class="q-num">1</span></h3>
                            <button type="button" class="text-red-500 hover:text-red-700" onclick="removeQuestion(this)"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="label-tactical">Question Text</label>
                                <textarea name="q_text_1" rows="2" class="input-tactical" required></textarea>
                            </div>
                            <div class="grid md:grid-cols-2 gap-4">
                                <div><label class="label-tactical">Option A</label><input type="text" name="q_opt_a_1" class="input-tactical" required></div>
                                <div><label class="label-tactical">Option B</label><input type="text" name="q_opt_b_1" class="input-tactical" required></div>
                                <div><label class="label-tactical">Option C</label><input type="text" name="q_opt_c_1" class="input-tactical" required></div>
                                <div><label class="label-tactical">Option D</label><input type="text" name="q_opt_d_1" class="input-tactical" required></div>
                            </div>
                            <div class="grid md:grid-cols-2 gap-4 mt-4">
                                <div>
                                    <label class="label-tactical">Correct Option</label>
                                    <select name="q_correct_1" class="input-tactical w-full bg-white" required>
                                        <option value="A">A</option>
                                        <option value="B">B</option>
                                        <option value="C">C</option>
                                        <option value="D">D</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="label-tactical">Marks</label>
                                    <input type="number" name="q_marks_1" value="1" class="input-tactical" min="1" required>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex gap-4 pt-4">
                    <button type="button" onclick="addQuestion()" class="flex-1 py-4 border border-black/10 bg-white/50 text-[10px] font-bold uppercase tracking-widest hover:bg-black/5 transition-all flex items-center justify-center gap-2">
                        <i data-lucide="plus" class="w-4 h-4"></i> Add Question
                    </button>
                    <button type="submit" class="flex-1 py-4 bg-red-500 text-white font-[Orbitron] text-[10px] tracking-[0.3em] font-black uppercase hover:bg-black transition-all shadow-xl flex items-center justify-center gap-2">
                        <i data-lucide="check-circle" class="w-4 h-4"></i> Publish Quiz
                    </button>
                </div>
            </form>
        </div>
    </main>

    <script>
        lucide.createIcons();
        let qCount = 1;

        function addQuestion() {
            qCount++;
            document.getElementById('questionCount').value = qCount;
            
            const container = document.getElementById('questionsContainer');
            const qHtml = `
                <div class="glass p-8 border-l-4 border-red-500 question-block" data-qid="${qCount}">
                    <div class="flex justify-between items-center mb-6">
                        <h3 class="font-[Orbitron] text-[10px] tracking-widest uppercase font-black text-gray-900">Question #<span class="q-num">${qCount}</span></h3>
                        <button type="button" class="text-red-500 hover:text-red-700" onclick="removeQuestion(this)"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                    </div>
                    <div class="space-y-4">
                        <div>
                            <label class="label-tactical">Question Text</label>
                            <textarea name="q_text_${qCount}" rows="2" class="input-tactical" required></textarea>
                        </div>
                        <div class="grid md:grid-cols-2 gap-4">
                            <div><label class="label-tactical">Option A</label><input type="text" name="q_opt_a_${qCount}" class="input-tactical" required></div>
                            <div><label class="label-tactical">Option B</label><input type="text" name="q_opt_b_${qCount}" class="input-tactical" required></div>
                            <div><label class="label-tactical">Option C</label><input type="text" name="q_opt_c_${qCount}" class="input-tactical" required></div>
                            <div><label class="label-tactical">Option D</label><input type="text" name="q_opt_d_${qCount}" class="input-tactical" required></div>
                        </div>
                        <div class="grid md:grid-cols-2 gap-4 mt-4">
                            <div>
                                <label class="label-tactical">Correct Option</label>
                                <select name="q_correct_${qCount}" class="input-tactical w-full bg-white" required>
                                    <option value="A">A</option>
                                    <option value="B">B</option>
                                    <option value="C">C</option>
                                    <option value="D">D</option>
                                </select>
                            </div>
                            <div>
                                <label class="label-tactical">Marks</label>
                                <input type="number" name="q_marks_${qCount}" value="1" class="input-tactical" min="1" required>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', qHtml);
            lucide.createIcons();
            updateQuestionNumbers();
        }

        function removeQuestion(btn) {
            const blocks = document.querySelectorAll('.question-block');
            if (blocks.length > 1) {
                btn.closest('.question-block').remove();
                updateQuestionNumbers();
            } else {
                alert("You must have at least one question.");
            }
        }

        function updateQuestionNumbers() {
            const blocks = document.querySelectorAll('.question-block');
            blocks.forEach((block, index) => {
                block.querySelector('.q-num').innerText = index + 1;
            });
        }
    </script>
</body>
</html>
