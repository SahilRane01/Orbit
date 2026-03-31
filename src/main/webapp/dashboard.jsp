<%@ page import="java.sql.*, java.util.*, com.gurukul.*, java.text.SimpleDateFormat, jakarta.servlet.ServletContext" %>
<jsp:useBean id="user" class="com.gurukul.userProfileBean" scope="session" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<noticeBoard> notices = new ArrayList<>();
    List<eventBean> events = new ArrayList<>();
    List<Map<String, String>> activeMeetings = new ArrayList<>();
%>

<% 
          try {
          ServletContext context = getServletContext();
          String DB = context.getInitParameter("DB_URL");
          String DB_User = context.getInitParameter("DB_USERNAME");
          String DB_pwd = context.getInitParameter("DB_PWD");
          Class.forName("com.mysql.cj.jdbc.Driver");
          Connection conn = DriverManager.getConnection(
          "jdbc:mysql://"+DB+":3306/gurukul",
          DB_User,
          DB_pwd
          );

          // Fetch Global Active Meetings (De-restricted)
          String meetSql = "SELECT * FROM meetings WHERE status = 'ACTIVE' ORDER BY created_at DESC";
          PreparedStatement psMeet = conn.prepareStatement(meetSql);
          ResultSet rsMeet = psMeet.executeQuery();
          while (rsMeet.next()) {
              Map<String, String> m = new HashMap<>();
              m.put("id", rsMeet.getString("meeting_id"));
              m.put("teacher", rsMeet.getString("teacher_name"));
              activeMeetings.add(m);
          }
          rsMeet.close();
          psMeet.close();

          String noticeSql = "SELECT * FROM noticeboard ORDER BY created_at DESC LIMIT 5";
          PreparedStatement psNotice = conn.prepareStatement(noticeSql);
          ResultSet rsNotice = psNotice.executeQuery();
          while (rsNotice.next()) {
          noticeBoard nb = new noticeBoard();
          nb.setId(rsNotice.getInt("id"));
          nb.setHeading(rsNotice.getString("heading"));
          nb.setBody(rsNotice.getString("body"));
          nb.setCreatedAt(rsNotice.getTimestamp("created_at"));
          nb.setWhom(rsNotice.getString("whom"));
          notices.add(nb);
          }
          rsNotice.close();
          psNotice.close();

          String eventSql = "SELECT * FROM events WHERE event_date >= CURDATE() ORDER BY event_date ASC";
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
          rsEvent.close();
          psEvent.close();

          conn.close();
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
            <title>Dashboard - Gurukul ILE</title>

            <!-- Tailwind -->
            <script src="https://cdn.tailwindcss.com"></script>

            <!-- Fonts -->
            <link
              href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap"
              rel="stylesheet">

            <!-- Lucide Icons -->
            <script src="https://unpkg.com/lucide@latest"></script>

            <style type="text/tailwindcss">
              .grid-bg {
                background-image:
                  linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px),
                  linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
                background-size: 40px 40px;
              }

              .glass {
                background: rgba(255, 255, 255, 0.7);
                backdrop-filter: blur(12px);
                border: 1px solid rgba(0, 0, 0, 0.05);
                box-shadow: 0 4px 30px rgba(0, 0, 0, 0.03);
              }

              .neon-glow:hover {
                box-shadow: 0 10px 40px rgba(255, 51, 51, 0.1);
                border-color: rgba(255, 51, 51, 0.3);
              }

              .scrollbar-hide::-webkit-scrollbar { display: none; }
              .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }

              @keyframes blink { 0%, 50%, 100% { opacity: 1; } 25%, 75% { opacity: 0; } }
              @keyframes scan { 0% { transform: translateY(-100%); } 100% { transform: translateY(300%); } }
              @keyframes entry { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

              #cursor { animation: blink 1.2s infinite; margin-left: 4px; }
              .animate-entry { animation: entry 0.6s ease-out forwards; }
              
              /* PRECISION HUD SIDEBAR ACCENTS */
              .hud-corner { @apply absolute w-5 h-5 border-red-500 shadow-[0_0_15px_rgba(255,51,51,0.4)] z-20; }
              .terminal-index { @apply text-[7px] text-gray-300 font-bold tracking-widest mr-2 group-hover:text-red-500 transition-colors opacity-0 group-hover/sidebar:opacity-50; }
              .connector-line { @apply absolute top-24 bottom-24 w-[1px] bg-black/[0.04] z-0 transition-all duration-500; }
              .active-bar { @apply absolute left-0 top-0 bottom-0 w-1 bg-red-500 shadow-[0_0_10px_rgba(255,51,51,0.4)]; }
            </style>
          </head>

          <body class="font-[Inter] bg-[#f8fafc] text-gray-900 h-screen overflow-hidden flex flex-col">

            <!-- TACTICAL GRID BACKGROUND -->
            <div class="fixed inset-0 pointer-events-none grid-bg z-0 opacity-100"></div>
            <div class="fixed inset-0 pointer-events-none bg-gradient-to-tr from-red-500/[0.02] via-transparent to-transparent z-0"></div>

            <!-- SYSTEM TOP BAR -->
            <div class="relative z-50 border-b border-black/5 px-4 md:px-6 py-2 flex justify-between items-center text-[9px] text-gray-400 bg-white/80 backdrop-blur-md uppercase tracking-[0.3em] font-bold">
              <div class="flex items-center gap-4">
                <button id="mobile-toggle" class="md:hidden p-2 -ml-2 text-gray-400 hover:text-red-500 transition-colors">
                  <i data-lucide="menu" class="w-5 h-5"></i>
                </button>
                <span class="text-red-500 animate-pulse">&#10033;</span>
                <span>GURUKUL_ILE / ONLINE</span>
                <span class="opacity-30 mx-2">|</span>
                <span class="text-[7px] text-red-500/80 tracking-widest uppercase">SIG_STRENGTH: <%= activeMeetings.size() > 0 ? "98%" : "0%" %> [SIGNALS: <%= activeMeetings.size() %>]</span>
                <script>
                  if (!window.isSecureContext && window.location.hostname !== "localhost") {
                    document.write('<span class="opacity-30 mx-2">|</span><span class="text-[7px] text-red-500 animate-pulse font-black">[LAN_MODE: SEC_OVERRIDE_REQUIRED]</span>');
                  }
                </script>
              </div>
              <span class="hidden md:inline opacity-60">"Innovation distinguishes between a leader and a follower."</span>
              <div class="flex items-center gap-4">
                <span>GURUKUL_CORE_V2.0</span>
                <span class="font-[Orbitron] text-red-500">ILE</span>
              </div>
            </div>

            <div class="flex flex-grow overflow-hidden relative z-10">

              <!-- SIDEBAR: PRECISION COMMAND HUD (MOBILE RESPONSIVE) -->
              <aside id="sidebar-module" class="fixed md:relative inset-y-0 left-0 z-40 transform -translate-x-full md:translate-x-0 flex flex-col h-full py-4 md:py-6 pr-0 md:pr-4 transition-all duration-500 group/sidebar w-64 md:w-20 hover:md:w-64 bg-white/95 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none">
                <!-- CIRCUITRY CONNECTOR LINE (DYNAMIC POSITION) -->
                <div class="connector-line left-[39px] md:group-hover/sidebar:left-[47px] hidden md:block"></div>

                <div class="glass h-full border-r md:border border-black/10 flex flex-col py-8 md:py-10 overflow-hidden relative shadow-2xl bg-white/95">
                  <button id="mobile-close" class="md:hidden absolute top-4 right-4 p-2 text-gray-400 hover:text-red-500 z-50">
                    <i data-lucide="x" class="w-5 h-5"></i>
                  </button>

                  <!-- MECHANICAL HUD CORNERS (INTERNAL ANCHORS) -->
                  <div class="hud-corner top-2 left-2 border-t-2 border-l-2"></div>
                  <div class="hud-corner top-2 right-2 border-t-2 border-r-2 opacity-10"></div>
                  <div class="hud-corner bottom-2 left-2 border-b-2 border-l-2 opacity-10"></div>
                  <div class="hud-corner bottom-2 right-2 border-b-2 border-r-2 border-red-500"></div>

                  <!-- LOGO SECTION: SENSOR FRAME -->
                  <div class="w-full flex md:flex-col items-center md:items-start transition-all duration-500 px-6 md:px-0 md:group-hover/sidebar:px-8 relative z-10 md:justify-center">
                    <div class="flex items-center justify-center w-full md:w-auto gap-4">
                      <div class="w-12 h-12 bg-red-500 flex items-center justify-center font-[Orbitron] text-base font-bold text-white shadow-[0_0_30px_rgba(255,51,51,0.4)] shrink-0 border border-white/20">
                        GKL
                      </div>
                      <div class="block md:hidden md:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">
                        <div class="font-[Orbitron] text-[11px] tracking-[0.2em] text-red-500 font-bold leading-none">GURUKUL_ILE</div>
                        <div class="text-[7px] text-gray-400 tracking-[0.4em] font-bold mt-1 uppercase whitespace-nowrap">SENS_UNIT_V4</div>
                      </div>
                    </div>
                    <div class="hidden md:block w-full h-[1px] bg-black/5 mt-6 opacity-0 group-hover/sidebar:opacity-100 transition-opacity"></div>
                  </div>

                  <!-- NAV HUD ITEMS: TECHNICAL ARRAY (SCROLLABLE) -->
                  <nav class="flex-grow flex flex-col gap-1 mt-4 relative z-10 items-center md:items-stretch overflow-y-auto scrollbar-hide">
                    <a href="#" class="group/item flex items-center gap-4 p-4 bg-red-500/[0.03] relative transition-all w-full justify-center md:justify-start">
                      <div class="active-bar"></div>
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="home" class="w-5 h-5 text-red-500 shadow-[0_0_15px_rgba(255,51,51,0.2)]"></i>
                      </div>
                      <span class="terminal-index hidden md:group-hover/sidebar:block transition-all duration-500">[01]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-red-500">Dashboard</span>
                    </a>

                    <a href="#" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="users" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all group-hover/item:scale-110"></i>
                      </div>
                      <span class="terminal-index hidden md:group-hover/sidebar:block transition-all duration-500">[02]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900 group-hover/item:text-red-500">Students</span>
                    </a>

                    <a href="#" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="pen-tool" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all group-hover/item:scale-110"></i>
                      </div>
                      <span class="terminal-index hidden md:block lg:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">[03]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900 group-hover/item:text-red-500">Academic</span>
                    </a>

                    <a href="#" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="calendar" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all group-hover/item:scale-110"></i>
                      </div>
                      <span class="terminal-index hidden md:block lg:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">[04]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900 group-hover/item:text-red-500">Schedule</span>
                    </a>

                    <a href="#" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="bell" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all group-hover/item:scale-110"></i>
                      </div>
                      <span class="terminal-index hidden md:block lg:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">[05]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900 group-hover/item:text-red-500">Alerts</span>
                    <a href="briefings.jsp" class="group/item flex items-center gap-4 p-4 hover:bg-black/[0.02] transition-all relative border-l border-transparent hover:border-red-500/20 w-full justify-center md:justify-start">
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="video" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all group-hover/item:scale-110"></i>
                      </div>
                      <span class="terminal-index hidden md:block lg:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500">[06]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-900 group-hover/item:text-red-500">Briefings</span>
                    </a>
                  </nav>

                  <!-- AUTH HUD MODULE (SHRINK-0) -->
                  <div class="flex-shrink-0 flex flex-col gap-2 relative z-10 items-center md:items-stretch mt-auto">
                    <a href="logout" class="group/item flex items-center gap-4 p-4 hover:text-red-500 transition-all border-l border-transparent hover:bg-red-500/5 w-full justify-center md:justify-start">
                      <div class="w-6 h-6 flex items-center justify-center shrink-0">
                        <i data-lucide="log-out" class="w-5 h-5 text-gray-400 group-hover/item:text-red-500 transition-all"></i>
                      </div>
                      <span class="terminal-index hidden md:group-hover/sidebar:block transition-all duration-500">[99]</span>
                      <span class="block md:hidden md:group-hover/sidebar:block font-[Orbitron] text-[10px] tracking-[0.4em] font-bold uppercase md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 whitespace-nowrap text-gray-500 group-hover/item:text-red-500">Deauth</span>
                    </a>
                    
                    <a href="userProfile.jsp"
   class="p-2 border-y border-black/5 flex items-center gap-4 group/profile cursor-pointer relative overflow-hidden bg-gray-50/20 hover:bg-white transition-all w-full justify-center md:justify-start">

  <div class="w-10 h-10 bg-white flex items-center justify-center shrink-0 border border-black/5 relative z-10 rounded-sm">
    <i data-lucide="user" class="w-5 h-5 text-gray-400 group-hover/profile:text-red-500 transition-colors"></i>
  </div>

  <div class="block md:hidden md:group-hover/sidebar:block md:opacity-0 md:group-hover/sidebar:opacity-100 transition-all duration-500 relative z-10">
    
    <div class="text-[10px] font-bold text-gray-900 truncate w-32 uppercase tracking-[0.2em] font-[Orbitron]">
      ${user.userName}
    </div>

    <div class="text-[7px] text-red-500 font-bold tracking-[0.4em] uppercase mt-1">
      CORE_AUTHORIZED
    </div>

  </div>
</a>
                  </div>
                </div>
              </aside>

              <!-- MAIN AREA -->
              <main class="flex-grow overflow-y-auto p-4 md:p-8 flex flex-col gap-12 scrollbar-hide">

                <!-- HEADER: SYSTEM HUD -->
                <header class="border-b border-black/5 pb-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-8 animate-entry">
                  <div>
                    <h1 class="font-[Orbitron] text-4xl md:text-5xl tracking-[0.2em] mb-3 uppercase text-gray-900">
                      Hi, <span id="heroText" class="text-red-500"></span><span id="cursor" class="text-red-500">|</span>
                    </h1>
                    <p class="text-[9px] text-gray-400 tracking-[0.5em] uppercase font-bold">
                      <span class="text-red-500/50">Welcome TO</span> / GURUKUL_ILE/ 2026
                    </p>
                  </div>

                  <div class="flex gap-4 items-center w-full md:w-auto">
                    <div class="flex items-center bg-white border border-black/5 px-6 py-3 w-full md:w-96 group focus-within:border-red-500 transition-all shadow-sm">
                      <i data-lucide="search" class="w-4 h-4 text-gray-400 mr-4 group-focus-within:text-red-500"></i>
                      <input type="text" placeholder="QUERY_DIRECTORY..."
                        class="text-[9px] focus:outline-none w-full bg-transparent font-[Orbitron] tracking-[0.3em] uppercase text-gray-900 placeholder-gray-300">
                    </div>

                    <button class="p-3 border border-red-500/20 bg-red-500/5 text-red-500 hover:bg-red-500 hover:text-white transition-all cursor-pointer relative group overflow-hidden">
                      <div class="absolute inset-0 bg-red-500 translate-x-full group-hover:translate-x-0 transition-transform"></div>
                      <i data-lucide="bell" class="w-5 h-5 relative z-10"></i>
                    </button>
                  </div>
                </header>

                <!-- CONTENT GRID -->
                <div class="grid grid-cols-12 gap-8 pb-12 items-start">

                  <!-- LIVE BRIEFING SIGNAL (DYNAMIC ALERT) -->
                  <% if (!activeMeetings.isEmpty()) { 
                      Map<String, String> meeting = activeMeetings.get(0); // Take the latest
                  %>
                  <div class="col-span-12 animate-pulse">
                    <div class="glass border-l-4 border-red-500 p-6 flex flex-col md:flex-row justify-between items-center gap-6 bg-red-500/[0.02]">
                        <div class="flex items-center gap-6">
                            <div class="relative">
                                <i data-lucide="radio" class="w-8 h-8 text-red-500"></i>
                                <div class="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full animate-ping"></div>
                            </div>
                            <div>
                                <h3 class="font-[Orbitron] text-sm tracking-[0.3em] font-black text-gray-900 uppercase">Signal_Intercepted: Live_Briefing</h3>
                                <p class="text-[9px] text-gray-400 tracking-[0.2em] uppercase font-bold mt-1">Source: <span class="text-red-500 border-b border-red-500/20"><%= meeting.get("teacher") %></span> / AUTH_LEVEL: ALPHA</p>
                                <div class="mt-2 flex items-center gap-2">
                                    <div class="w-1.5 h-1.5 bg-green-500 rounded-full animate-pulse"></div>
                                    <span class="text-[7px] text-gray-400 font-bold tracking-widest uppercase">Target_Match: <%= user.getCourse() != null ? user.getCourse().trim().toUpperCase() : "NULL" %></span>
                                </div>
                            </div>
                        </div>
                        <a href="meeting.jsp?id=<%= meeting.get("id") %>&room=<%= meeting.get("teacher") %>" class="bg-[#0a0a0a] text-white px-10 py-4 font-[Orbitron] text-[10px] tracking-[0.4em] uppercase hover:bg-red-500 transition-all shadow-2xl flex items-center gap-3 group">
                            Establish_Connection <i data-lucide="arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform"></i>
                        </a>
                    </div>
                  </div>
                  <% } else { %>
                  <!-- SIGNAL SCANNING DEBUG (Subtle) -->
                  <div class="col-span-12 px-6 py-2 border-x border-black/5 flex justify-between items-center bg-gray-50/50">
                    <span class="text-[7px] text-gray-400 font-bold tracking-[0.3em] uppercase italic">System_Scanning: Active_Signal_Search [Course: <%= user.getCourse() != null ? user.getCourse().trim().toUpperCase() : "NOT_SPECIFIED" %>]</span>
                    <span class="text-[7px] text-gray-300 font-bold tracking-widest animate-pulse">NO_SIGNALS_DETECTED</span>
                  </div>
                  <% } %>

                  <!-- NOTICE BOARD: BROADCAST MONITOR -->
                  <div class="col-span-12 lg:col-span-8 glass border border-black/10 p-8 relative overflow-hidden group neon-glow transition-all duration-500">
                    <!-- MECHANICAL CORNERS -->
                    <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-red-500 shadow-[0_0_10px_rgba(255,51,51,0.5)]"></div>
                    <div class="absolute top-0 right-0 w-2 h-2 border-t-2 border-r-2 border-white/20"></div>
                    <div class="absolute bottom-0 left-0 w-2 h-2 border-b-2 border-l-2 border-white/20"></div>
                    <div class="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-red-500 shadow-[0_0_10px_rgba(255,51,51,0.5)]"></div>

                    <div class="flex justify-between items-center mb-10 pb-4 border-b border-black/5">
                      <div class="flex items-center gap-4">
                        <div class="flex flex-col">
                          <span class="text-red-500 font-bold tracking-[0.5em] mb-1">GURUKUL NOTICE NEWS</span>
                          <h2 class="font-[Orbitron] text-xs tracking-[0.4em] text-gray-400 uppercase flex items-center gap-2">
                            Live_Notices_Feed 
                          </h2>
                        </div>
                      </div>
                      <div class="flex gap-3" id="sliderDots">
                        <% for(int i=0; i<notices.size(); i++) { %>
                          <div class="h-1.5 transition-all duration-300 slider-dot cursor-pointer rounded-full" data-index="<%= i %>"></div>
                        <% } %>
                      </div>
                    </div>

                    <div class="relative overflow-hidden min-h-[180px]">
                      <!-- SUBTLE INNER GRID -->
                      <div class="absolute inset-0 opacity-[0.03] pointer-events-none"
                        style="background-image: radial-gradient(circle, #000 1px, transparent 1px); background-size: 20px 20px;">
                      </div>

                      <!-- SCAN LINE ANIMATION -->
                      <div
                        class="absolute inset-0 bg-gradient-to-b from-transparent via-red-500/5 to-transparent h-12 w-full animate-[scan_4s_linear_infinite] pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity">
                      </div>

                      <div id="noticeSlider" class="flex transition-transform duration-700 ease-in-out">
                        <% if (notices.isEmpty()) { %>
                          <div
                            class="min-w-full w-full py-16 flex flex-col items-center justify-center text-gray-300 gap-6 uppercase tracking-[0.4em] text-[10px] font-bold">
                            <div class="relative">
                              <i data-lucide="scan" class="w-12 h-12 opacity-20 animate-pulse"></i>
                              <div class="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full animate-ping"></div>
                            </div>
                            <span>NO BROADCAST</span>
                            <div class="text-[8px] opacity-40">SYSTEM_RETRYING / 300ms</div>
                          </div>
                          <% } else { for (noticeBoard nb : notices) { %>
                            <div class="min-w-full w-full">
                              <div class="pr-12">
                                <div
                                  class="flex items-center gap-3 mb-4 text-red-500 text-[9px] font-bold tracking-widest uppercase opacity-70">
                                  <span>&#x2731; BROADCAST_0<%= notices.indexOf(nb) + 1 %></span>
                                  <span class="w-8 h-[1px] bg-red-500"></span>
                                </div>
                                <h3 class="font-[Orbitron] font-bold text-4xl mb-6 uppercase tracking-tighter leading-tight text-gray-900 line-clamp-2 transition-all group-hover:text-red-500">
                                  <%= nb.getHeading() %>
                                </h3>
                                <p class="text-base text-gray-600 mb-10 leading-relaxed max-w-3xl border-l border-red-500/20 pl-8 py-3 bg-gray-50/50 font-medium italic">
                                  <%= nb.getBody() %>
                                </p>
                                <div class="flex items-center gap-12 pt-4">
                                  <div class="flex flex-col">
                                    <span class="text-[7px] text-gray-400 uppercase tracking-widest mb-1 font-bold">entry_timestamp</span>
                                    <span class="text-[10px] text-gray-900 uppercase tracking-widest font-bold font-mono">
                                      <%= nb.getCreatedAt() %>
                                    </span>
                                  </div>
                                  <div class="flex flex-col">
                                    <span class="text-[7px] text-gray-400 uppercase tracking-widest mb-1 font-bold">relay_origin</span>
                                    <span class="text-[10px] text-red-500/80 font-[Orbitron] tracking-[0.4em]">
                                      <%= nb.getWhom() !=null ? nb.getWhom() : "SOURCE_UNKNOWN" %>
                                    </span>
                                  </div>
                                  <div class="hidden md:flex flex-col">
                                    <span class="text-[7px] text-gray-300 uppercase tracking-widest mb-1 font-bold">integrity_sign</span>
                                    <span class="text-[9px] text-gray-300 font-mono tracking-tighter">0x<%= Integer.toHexString(nb.hashCode()).toUpperCase() %></span>
                                  </div>
                                </div>
                              </div>
                            </div>
                            <% } } %>
                      </div>
                    </div>
                  </div>

                  <!-- ACTIVITY LOG: EVENTS -->
                  <div class="col-span-12 lg:col-span-4 bg-[#0a0a0a] border border-black p-8 flex flex-col relative overflow-hidden group neon-glow transition-all duration-500">
                    <div class="absolute top-4 right-4 text-red-500 text-xl group-hover:rotate-90 transition-transform duration-500">&#x2731;</div>

                    <h2 class="font-[Orbitron] text-[10px] tracking-[0.5em] text-gray-500 uppercase mb-12">Activity Timeline</h2>

                    <div class="flex-grow overflow-y-auto pr-4 scrollbar-hide relative" style="height: 220px;">
                      <!-- VERTICAL DATA STREAM LINE -->
                      <div class="absolute left-[20px] top-4 bottom-4 w-[1px] bg-gradient-to-b from-red-500/40 via-white/5 to-white/5 z-0"></div>

                      <div class="space-y-12 relative z-10">
                        <% if (events.isEmpty()) { %>
                          <div class="h-full flex items-center justify-center text-[10px] text-gray-500 uppercase tracking-[0.4em]">
                            NO_SCHEDULED_DATA
                          </div>
                        <% } else { for (eventBean eb : events) { %>
                          <div class="flex gap-10 items-start group/item">
                            <div class="relative">
                              <div class="text-4xl font-[Orbitron] text-white leading-none relative z-10 drop-shadow-sm group-hover/item:text-red-500 transition-colors">
                                <%= dayFormat.format(eb.getEventDate()) %>
                              </div>
                              <div class="absolute -inset-2 bg-red-500/10 scale-0 group-hover/item:scale-100 transition-transform rounded-full"></div>
                            </div>
                            <div class="flex-grow pt-1">
                              <div class="text-[8px] font-bold uppercase tracking-[0.3em] text-red-500/70 mb-2">
                                <%= monthFormat.format(eb.getEventDate()) %> // EVENT_LOG
                              </div>
                              <div class="text-[11px] font-bold uppercase tracking-widest text-white group-hover/item:text-red-500 transition-colors">
                                <%= eb.getEventName() %>
                              </div>
                              <div class="text-[8px] text-gray-400 uppercase mt-3 tracking-widest line-clamp-1 opacity-80">
                                <%= eb.getDescription() !=null ? eb.getDescription() : "NULL_DESC" %>
                              </div>
                            </div>
                          </div>
                        <% } } %>
                      </div>
                    </div>

                    <div class="mt-10 pt-6 border-t border-white/10">
                      <button class="w-full border border-red-500/30 bg-red-500/5 py-4 text-[9px] font-bold uppercase tracking-[0.5em] text-red-500/80 hover:bg-red-500 hover:text-white transition-all shadow-sm">
                        OPEN CALENDAR
                      </button>
                    </div>
                  </div>

                  <!-- SECTION DIVIDER -->
                  <div class="col-span-12 mt-16 mb-8 flex items-center gap-10">
                    <div class="flex items-center gap-4">
                      <span class="font-[Orbitron] text-red-500 text-xl font-bold tracking-[0.6em] text-gray-800 uppercase whitespace-nowrap">Student Activity</span>
                    </div>
                    <div class="flex-grow h-[1px] bg-black/5"></div>
                    
                  </div>

                  <!-- STATS CARDS -->
                  <div class="col-span-12 md:col-span-4 glass border border-black/10 p-8 group flex flex-col h-full neon-glow transition-all duration-500 relative overflow-hidden">
                    <div class="flex justify-between items-start mb-10 relative z-10">
                      <div class="flex flex-col">
                        <span class="text-[7px] text-red-500 font-bold tracking-[0.4em] mb-1">MODULE_01 //</span>
                        <h2 class="font-[Orbitron] text-[10px] tracking-[0.4em] text-gray-400 uppercase">Pending_Submissions</h2>
                      </div>
                      <span class="text-red-500 text-xl group-hover:rotate-90 transition-transform duration-500">@*</span>
                    </div>
                    <div class="flex-grow flex flex-col justify-center relative z-10">
                      <div class="text-7xl font-[Orbitron] tracking-tighter mb-4 text-gray-900 drop-shadow-sm group-hover:text-red-500 transition-colors">03</div>
                      <p class="text-[8px] text-gray-400 uppercase tracking-[0.3em] leading-relaxed font-medium">
						Attendance Report                       </p>
                    </div>
                    <div class="absolute bottom-0 right-0 p-2 opacity-10 text-[6px] font-mono text-gray-400">0xDEADBEEF</div>
                  </div>

                  <div class="col-span-12 md:col-span-4 glass border border-black/10 p-8 group flex flex-col h-full neon-glow transition-all duration-500 relative overflow-hidden">
                    <div class="flex justify-between items-start mb-10 relative z-10">
                      <div class="flex flex-col">
                        <span class="text-[7px] text-red-500 font-bold tracking-[0.4em] mb-1">MODULE_02 // </span>
                        <h2 class="font-[Orbitron] text-[10px] tracking-[0.4em] text-gray-400 uppercase">Attendance_Record</h2>
                      </div>
                      <span class="text-red-500 text-xl group-hover:rotate-90 transition-transform">&#x2731;</span>
                    </div>
                    <div class="flex-grow flex flex-col justify-center relative z-10">
                      <div class="text-7xl font-[Orbitron] tracking-tighter mb-8 flex items-baseline text-gray-900 group-hover:text-red-500 transition-colors">
                        88<span class="text-2xl text-red-500 font-sans ml-2 opacity-50">%</span>
                      </div>
                      <div class="w-full bg-gray-100 h-2 rounded-full border border-black/5 p-0.5 overflow-hidden">
                        <div class="bg-gradient-to-r from-red-500 to-red-600 h-full w-[88%] rounded-full shadow-sm"></div>
                      </div>
                    </div>
                    <div class="absolute bottom-0 right-0 p-2 opacity-20 text-[6px] font-mono text-gray-400 italic">STATUS: NOMINAL</div>
                  </div>

                  <div class="col-span-12 md:col-span-4 glass border border-black/10 p-8 group flex flex-col h-full neon-glow transition-all duration-500 relative overflow-hidden">
                    <div class="flex justify-between items-start mb-10 relative z-10">
                      <div class="flex flex-col">
                        <span class="text-[7px] text-red-500 font-bold tracking-[0.4em] mb-1">MODULE_03 // </span>
                        <h2 class="font-[Orbitron] text-[10px] tracking-[0.4em] text-gray-400 uppercase">Active_Curriculums</h2>
                      </div>
                      <span class="text-red-500 text-xl group-hover:rotate-90 transition-transform duration-500">*</span>
                    </div>
                    <div class="flex-grow flex flex-col justify-center relative z-10">
                      <div class="space-y-6">
                        <div class="border-l-2 border-red-500/40 bg-gray-50/50 pb-3 pl-4 group-hover:border-red-500 transition-colors">
                          <span class="text-[11px] font-bold uppercase tracking-widest block text-gray-900	">${user.course}</span>
                          <span class="text-[8px] text-gray-400 uppercase tracking-[0.3em] font-bold mt-1 block">${user.batch} // STAGE_01</span>
                        </div>
                        <div class="border-l-2 border-black/5 pb-3 pl-4 opacity-40 group-hover:opacity-100 transition-all">
                          <span class="text-[11px] font-bold uppercase tracking-widest block text-gray-900">Cyber_Security_Fund.</span>
                          <span class="text-[8px] text-gray-400 uppercase tracking-[0.3em] font-bold mt-1 block">B-3 // STAGE_01</span>
                        </div>
                      </div>
                    </div>
                  </div>

                </div>

                <footer class="mt-auto py-8 border-t border-black/5 flex justify-between items-center text-[8px] text-gray-400 uppercase tracking-[0.5em] font-bold">
                  <div class="flex gap-12 items-center">
                    <div class="flex gap-4 text-gray-500 hover:text-red-500 transition-colors cursor-pointer">
                      <span>@ 2026_GKL_CORE</span>
                      <span class="opacity-30 self-center h-1 w-1 bg-gray-400 rounded-full"></span>
                      <span>SECURE_LINKv2</span>
                    </div>
                  </div>
                  <div class="flex gap-10 items-center">
                    <div class="flex items-center gap-4 group cursor-help text-gray-500">
                      <span class="text-red-500 group-hover:rotate-90 transition-transform duration-500">&#x2731;</span>
                      <span class="group-hover:text-gray-900 transition-colors uppercase">OS_STATUS: AUTHENTICATED</span>
                    </div>
                    <span class="hidden lg:inline opacity-30">|</span>
                    <span class="hidden lg:inline text-gray-400">TERMINAL_ID: HUB-<%= session.getId().toUpperCase() %></span>
                  </div>
                </footer>

              </main>
            </div>

            <script>
              lucide.createIcons();

              (function () {
                // --- TECHNICAL TYPING EFFECT ---
                const text = "${user.fullName}";
                let index = 0;
                let isDeleting = false;
                const element = document.getElementById("heroText");

                function typeLoop() {
                  if (!element) return;

                  element.innerHTML = text.substring(0, index + 1);
                  index++;

                  if (index < text.length) {
                    setTimeout(typeLoop, 150);
                  } else {
                    // Stop here and hide the blinking cursor after a small delay
                    setTimeout(() => {
                      const cursor = document.getElementById("cursor");
                      if (cursor) cursor.style.display = "none";
                    }, 1500);
                  }
                }

                if (text && text.length > 0) typeLoop();

                // --- BULLETIN SLIDER ---
                const slider = document.getElementById('noticeSlider');
                const dots = document.querySelectorAll('.slider-dot');
                const slideCount = parseInt('<%= notices.size() %>') || 0;
                let currentIndex = 0;
                let interval;

                function updateSlider() {
                  if (!slider || slideCount === 0) return;
                  slider.style.transform = "translateX(-" + (currentIndex * 100) + "%)";
                  dots.forEach((dot, index) => {
                    dot.classList.toggle('bg-red-500', index === currentIndex);
                    dot.classList.toggle('bg-black/10', index !== currentIndex);
                    dot.classList.toggle('w-10', index === currentIndex);
                    dot.classList.toggle('w-3', index !== currentIndex);
                  });
                }

                function startAutoSlide() {
                  if (slideCount > 1) {
                    interval = setInterval(() => {
                      currentIndex = (currentIndex + 1) % slideCount;
                      updateSlider();
                    }, 6000);
                  }
                }

                dots.forEach(dot => {
                  dot.addEventListener('click', () => {
                    currentIndex = parseInt(dot.getAttribute('data-index'));
                    updateSlider();
                    clearInterval(interval);
                    startAutoSlide();
                  });
                });

                if (slideCount > 0) {
                  updateSlider();
                  startAutoSlide();
                }
              })();

              // MOBILE SIDEBAR TOGGLE LOGIC
              document.getElementById('mobile-toggle')?.addEventListener('click', () => {
                document.getElementById('sidebar-module')?.classList.remove('-translate-x-full');
              });
              document.getElementById('mobile-close')?.addEventListener('click', () => {
                document.getElementById('sidebar-module')?.classList.add('-translate-x-full');
              });
            </script>
          </body>

          </html>

