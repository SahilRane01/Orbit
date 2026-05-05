<%@ page import="java.sql.*, java.util.*, com.gurukul.models.*, com.gurukul.utils.DBConnection, java.text.SimpleDateFormat" %>
<jsp:useBean id="user" class="com.gurukul.models.UserProfile" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, String>> marksheet = new ArrayList<>();
    int grandTotalObtained = 0;
    int grandTotalMax = 0;
    boolean hasFailed = false;

    try (Connection conn = DBConnection.getConnection(getServletContext())) {
        String sql = "SELECT sr.*, c.name as class_name, rc.theory_max, rc.internal_max, rc.viva_max " +
                     "FROM student_results sr " +
                     "JOIN classes c ON sr.class_id = c.id " +
                     "JOIN result_configs rc ON sr.class_id = rc.class_id " +
                     "WHERE sr.student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user.getId());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("class_name", rs.getString("class_name"));
                row.put("theory", rs.getString("theory_marks"));
                row.put("internal", rs.getString("internal_marks"));
                row.put("viva", rs.getString("viva_marks"));
                row.put("total", rs.getString("total_marks"));
                row.put("grade", rs.getString("grade"));
                row.put("status", rs.getString("status"));
                
                int tMax = rs.getInt("theory_max");
                int iMax = rs.getInt("internal_max");
                int vMax = rs.getInt("viva_max");
                int maxTotal = tMax + iMax + vMax;
                row.put("max_total", String.valueOf(maxTotal));

                grandTotalObtained += rs.getInt("total_marks");
                grandTotalMax += maxTotal;

                if ("FAIL".equals(rs.getString("status"))) {
                    hasFailed = true;
                }

                marksheet.add(row);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (marksheet.isEmpty()) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    double percent = grandTotalMax > 0 ? ((double) grandTotalObtained / grandTotalMax) * 100 : 0;
    String finalStatus = hasFailed ? "FAIL" : "PASS";
    String finalGrade = "E";
    if (!hasFailed) {
        // Approximate grading based on percentage
        if (percent >= 90) finalGrade = "A";
        else if (percent >= 75) finalGrade = "B";
        else if (percent >= 60) finalGrade = "C";
        else if (percent >= 40) finalGrade = "D";
    }

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comprehensive Marksheet - <%= user.getFullName() %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0,0,0,0.05) 1px, transparent 1px); background-size: 40px 40px; }
        .glass { background: rgba(255,255,255,0.9); backdrop-filter: blur(12px); border: 1px solid rgba(0,0,0,0.1); }
        @media print {
            .no-print { display: none !important; }
            body { background: white; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .glass { border: 2px solid #000; box-shadow: none; background: white; padding: 2rem !important;}
        }
    </style>
</head>
<body class="font-[Inter] bg-[#f8fafc] text-gray-900 min-h-screen relative p-4 md:p-8">
    <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>

    <div class="max-w-5xl mx-auto relative z-10">
        <!-- ACTION BAR -->
        <div class="flex justify-between items-center mb-8 no-print">
            <a href="dashboard.jsp" class="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-gray-500 hover:text-red-500 transition-colors">
                <i data-lucide="arrow-left" class="w-4 h-4"></i> Return to Dashboard
            </a>
            <button onclick="window.print()" class="bg-black text-white px-6 py-3 font-[Orbitron] text-[10px] tracking-[0.2em] font-black uppercase hover:bg-red-500 transition-all shadow-xl flex items-center gap-2">
                <i data-lucide="printer" class="w-4 h-4"></i> Print Marksheet
            </button>
        </div>

        <!-- TRANSCRIPT DOCUMENT -->
        <div class="glass p-8 md:p-12 shadow-2xl relative overflow-hidden bg-white">
            
            <!-- WATERMARK -->
            <div class="absolute inset-0 flex items-center justify-center opacity-[0.03] pointer-events-none">
                <i data-lucide="award" class="w-[600px] h-[600px]"></i>
            </div>

            <!-- HEADER -->
            <div class="border-b-4 border-black pb-8 mb-8 flex justify-between items-end relative z-10">
                <div>
                    <h1 class="font-[Orbitron] text-3xl md:text-5xl font-black text-gray-900 tracking-wider uppercase mb-2">Gurukul ILE</h1>
                    <p class="text-[10px] md:text-xs font-bold tracking-[0.4em] uppercase text-gray-500">Comprehensive Academic Marksheet</p>
                </div>
                <div class="text-right">
                    <p class="text-[9px] font-bold tracking-widest uppercase text-gray-400 mb-1">Issue Date</p>
                    <p class="font-mono text-sm text-gray-900"><%= sdf.format(new java.util.Date()) %></p>
                </div>
            </div>

            <!-- STUDENT DETAILS -->
            <div class="grid grid-cols-2 gap-6 md:gap-8 mb-12 relative z-10 bg-black/5 p-6 border-l-4 border-black">
                <div>
                    <p class="text-[8px] font-bold tracking-[0.3em] uppercase text-gray-500 mb-1">Student Name</p>
                    <p class="font-[Orbitron] text-lg font-bold text-gray-900 uppercase"><%= user.getFullName() %></p>
                </div>
                <div>
                    <p class="text-[8px] font-bold tracking-[0.3em] uppercase text-gray-500 mb-1">Registration ID / Auth ID</p>
                    <p class="font-mono text-sm text-gray-900"><%= user.getUserName() %></p>
                </div>
                <div>
                    <p class="text-[8px] font-bold tracking-[0.3em] uppercase text-gray-500 mb-1">Vector Stream / Course</p>
                    <p class="text-sm font-bold text-gray-900 uppercase tracking-widest"><%= user.getCourse() %></p>
                </div>
                <div>
                    <p class="text-[8px] font-bold tracking-[0.3em] uppercase text-gray-500 mb-1">Temporal Batch</p>
                    <p class="font-mono text-sm text-gray-900"><%= user.getBatch() %></p>
                </div>
            </div>

            <!-- PERFORMANCE TABLE -->
            <div class="mb-12 relative z-10">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-black text-white text-[9px] font-bold tracking-widest uppercase">
                            <th class="py-4 px-4">Subject / Module</th>
                            <th class="py-4 px-3 text-center border-l border-white/20">Theory</th>
                            <th class="py-4 px-3 text-center border-l border-white/20">Internal</th>
                            <th class="py-4 px-3 text-center border-l border-white/20">Viva</th>
                            <th class="py-4 px-4 text-center border-l border-white/20 bg-gray-800">Max</th>
                            <th class="py-4 px-4 text-right border-l border-white/20 bg-red-500">Obtained</th>
                            <th class="py-4 px-4 text-center border-l border-white/20">Grade</th>
                        </tr>
                    </thead>
                    <tbody class="text-[11px] font-bold border-b-2 border-black">
                        <% for (Map<String, String> row : marksheet) { %>
                        <tr class="border-b border-black/10">
                            <td class="py-4 px-4 uppercase tracking-wider text-gray-900"><%= row.get("class_name") %></td>
                            <td class="py-4 px-3 text-center font-mono text-gray-500"><%= row.get("theory") %></td>
                            <td class="py-4 px-3 text-center font-mono text-gray-500"><%= row.get("internal") %></td>
                            <td class="py-4 px-3 text-center font-mono text-gray-500"><%= row.get("viva") %></td>
                            <td class="py-4 px-4 text-center font-mono text-gray-900 bg-gray-50"><%= row.get("max_total") %></td>
                            <td class="py-4 px-4 text-right font-[Orbitron] text-[13px] text-gray-900 bg-red-500/5"><%= row.get("total") %></td>
                            <td class="py-4 px-4 text-center font-[Orbitron] text-[13px] <%= "FAIL".equals(row.get("status")) ? "text-red-500" : "text-gray-900" %>"><%= row.get("grade") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr class="bg-black/5">
                            <td colspan="4" class="py-6 px-4 font-black uppercase tracking-widest text-[12px] text-right">Grand Total</td>
                            <td class="py-6 px-4 text-center font-mono font-bold text-[13px]"><%= grandTotalMax %></td>
                            <td class="py-6 px-4 text-right font-[Orbitron] text-[18px] font-black text-red-600"><%= grandTotalObtained %></td>
                            <td class="py-6 px-4 text-center text-[10px] text-gray-500"><%= String.format("%.2f", percent) %>%</td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <!-- FINAL VERDICT -->
            <div class="flex justify-between items-center border-4 border-black p-6 md:p-8 relative z-10">
                <div class="flex items-center gap-6">
                    <div class="text-[10px] font-bold tracking-[0.4em] uppercase text-gray-500">Academic<br>Verdict</div>
                    <div class="text-3xl md:text-4xl font-[Orbitron] font-black uppercase <%= hasFailed ? "text-red-600" : "text-green-600" %>">
                        <%= finalStatus %>
                    </div>
                </div>
                <div class="flex items-center gap-6 border-l-4 border-black/10 pl-6 md:pl-8">
                    <div class="text-[10px] font-bold tracking-[0.4em] uppercase text-gray-500">Overall<br>Grade</div>
                    <div class="text-4xl md:text-5xl font-[Orbitron] font-black uppercase text-gray-900">
                        <%= finalGrade %>
                    </div>
                </div>
            </div>

            <!-- SIGNATURE -->
            <div class="mt-20 flex justify-end relative z-10">
                <div class="text-center">
                    <div class="w-48 border-b-2 border-black mb-2 pb-2">
                        <!-- Digital Signature Graphic -->
                        <span class="font-[Orbitron] text-lg text-gray-400 opacity-80 italic tracking-widest">Admin</span>
                    </div>
                    <p class="text-[8px] font-bold tracking-[0.3em] uppercase text-gray-500">Authorized System Signature</p>
                </div>
            </div>

        </div>
    </div>
    
    <script>lucide.createIcons();</script>
</body>
</html>
