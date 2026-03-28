<%@ page import="java.sql.*, java.util.*, com.gurukul.*, java.text.SimpleDateFormat" %>
<% 
    if (session.getAttribute("user") == null) { 
        response.sendRedirect("login.jsp"); 
        return;
    } 

    List<noticeBoard> notices = new ArrayList<>();
    List<eventBean> events = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://192.168.0.105:3306/gurukul", "root", "Admin");
        
        String noticeSql = "SELECT * FROM noticeboard ORDER BY created_at DESC LIMIT 5";
        PreparedStatement psNotice = conn.prepareStatement(noticeSql);
        ResultSet rsNotice = psNotice.executeQuery();
        while (rsNotice.next()) {
            noticeBoard nb = new noticeBoard();
            nb.setId(rsNotice.getInt("id"));
            nb.setHeading(rsNotice.getString("heading"));
            nb.setBody(rsNotice.getString("body"));
            nb.setCreatedAt(rsNotice.getTimestamp("created_at"));
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

    <style>
      .grid-bg {
        background-image:
          linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px),
          linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
        background-size: 40px 40px;
      }
      .scrollbar-hide::-webkit-scrollbar {
        display: none;
      }
      .scrollbar-hide {
        -ms-overflow-style: none;
        scrollbar-width: none;
      }
    </style>
  </head>

  <body class="font-[Inter] bg-[#f5f5f5] text-black h-screen overflow-hidden flex">

    <!-- GRID BACKGROUND (Fixed) -->
    <div class="fixed inset-0 pointer-events-none grid-bg z-0"></div>

    <!-- SIDEBAR -->
    <aside class="relative z-10 w-20 md:w-24 border-r border-gray-300 bg-white flex flex-col items-center py-8 gap-10">
      <!-- LOGO -->
      <div class="font-[Orbitron] text-xs tracking-tighter text-center leading-none">
        GURUKUL
      </div>

      <!-- NAV ICONS -->
      <div class="flex flex-col gap-6 flex-grow">
        <a href="#" class="p-3 bg-black text-white rounded-xl shadow-lg transition-transform hover:scale-110">
          <i data-lucide="home" class="w-5 h-5"></i>
        </a>
        <a href="#" class="p-3 text-gray-400 hover:text-black transition-colors">
          <i data-lucide="users" class="w-5 h-5"></i>
        </a>
        <a href="#" class="p-3 text-gray-400 hover:text-black transition-colors">
          <i data-lucide="pen-tool" class="w-5 h-5"></i>
        </a>
        <a href="#" class="p-3 text-gray-400 hover:text-black transition-colors">
          <i data-lucide="calendar" class="w-5 h-5"></i>
        </a>
        <a href="#" class="p-3 text-gray-400 hover:text-black transition-colors">
          <i data-lucide="bell" class="w-5 h-5"></i>
        </a>
        <a href="#" class="p-3 text-gray-400 hover:text-black transition-colors">
          <i data-lucide="settings" class="w-5 h-5"></i>
        </a>
      </div>

      <!-- PROFILE -->
      <div class="mt-auto flex flex-col gap-4 items-center">
        <a href="logout" class="p-3 text-red-500 hover:bg-red-50 transition-colors rounded-xl">
          <i data-lucide="log-out" class="w-5 h-5"></i>
        </a>
        <div class="w-10 h-10 bg-gray-200 border border-gray-300 p-1 flex items-center justify-center">
          <i data-lucide="user" class="text-gray-500"></i>
        </div>
      </div>
    </aside>

    <!-- MAIN AREA -->
    <main class="relative z-10 flex-grow overflow-y-auto p-4 md:p-8 flex flex-col gap-8">

      <!-- TOP UTILITY / HEADER -->
      <header class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold tracking-tight">Hi, ${user.fullName}!</h1>
          <p class="text-sm text-gray-500">Let's take a look at your activity today</p>
        </div>

        <div class="flex gap-4 items-center">
          <!-- SEARCH -->
          <div class="hidden md:flex items-center bg-white border border-gray-300 px-4 py-2 w-64">
            <i data-lucide="search" class="w-4 h-4 text-gray-400 mr-2"></i>
            <input type="text" placeholder="Search for data..."
              class="text-sm focus:outline-none w-full bg-transparent">
          
      </header>

      <!-- CONTENT GRID -->
      <div class="grid grid-cols-12 gap-6 pb-8">

        <!-- NOTICE BOARD / NEWS -->
        <div class="col-span-12 lg:col-span-8 border border-gray-300 bg-white p-6 shadow-sm relative overflow-hidden">
          <div class="flex justify-between items-start mb-6">
            <h2 class="font-[Orbitron] text-xs tracking-[0.2em] text-gray-400 uppercase">Notice Board / News</h2>
            <div class="text-red-500">*__*</div>
          </div>

          <div class="relative overflow-hidden group">
            <div id="noticeSlider" class="flex transition-transform duration-700 ease-in-out">
              <% if (notices.isEmpty()) { %>
                <div class="min-w-full w-full border border-gray-200 p-8 flex items-center justify-center text-gray-400 italic">
                  No notices at the moment.
                </div>
              <% } else { 
                  for (noticeBoard nb : notices) { %>
                <div class="min-w-full w-full px-1">
                  <div class="border border-gray-200 p-6 bg-white hover:border-black transition-colors min-h-[160px] flex flex-col justify-center">
                    <h3 class="font-bold text-lg mb-2 uppercase tracking-wide"><%= nb.getHeading() %></h3>
                    <p class="text-sm text-gray-500 mb-4 line-clamp-2"><%= nb.getBody() %></p>
                    <div class="mt-auto flex justify-between items-center">
                       <span class="text-[10px] text-gray-400 uppercase tracking-tighter"><%= nb.getCreatedAt() %></span>
                       <div class="text-xs font-[Orbitron] text-gray-300">(; GURUKUL ILE</div>
                    </div>
                  </div>
                </div>
              <%    }
                 } %>
            </div>

            <!-- DOTS -->
            <div class="flex justify-center gap-2 mt-4" id="sliderDots">
              <% for(int i=0; i<notices.size(); i++) { %>
                <div class="w-1.5 h-1.5 rounded-full bg-gray-200 transition-colors slider-dot cursor-pointer hover:bg-black" data-index="<%= i %>"></div>
              <% } %>
            </div>
          </div>
        </div>


        <!-- UPCOMING EVENTS -->
        <div class="col-span-12 lg:col-span-4 border border-gray-300 bg-black text-white p-6 shadow-sm flex flex-col">
          <h2 class="font-[Orbitron] text-xs tracking-[0.2em] text-gray-500 uppercase mb-8">Upcoming Events</h2>

          <div class="flex-grow overflow-y-auto pr-2 scrollbar-hide" style="max-height: 220px;">
            <div class="space-y-6">
              <% if (events.isEmpty()) { %>
                <div class="h-32 flex items-center justify-center text-xs text-gray-500 uppercase tracking-widest">
                  No Upcoming Events
                </div>
              <% } else { 
                  for (eventBean eb : events) { %>
                <div class="flex gap-4 items-center border-b border-gray-900 pb-4 last:border-0">
                  <div class="text-2xl font-bold text-red-500 min-w-[32px]"><%= dayFormat.format(eb.getEventDate()) %></div>
                  <div>
                    <div class="text-xs uppercase tracking-widest text-gray-400"><%= monthFormat.format(eb.getEventDate()) %></div>
                    <div class="text-sm font-bold uppercase"><%= eb.getEventName() %></div>
                    <div class="text-[10px] text-gray-500 uppercase mt-1"><%= eb.getDescription() != null ? eb.getDescription() : "" %></div>
                  </div>
                </div>
              <%    }
                 } %>
            </div>
          </div>
        </div>

        <!-- ASSIGNMENT DUE -->
        <div
          class="col-span-12 md:col-span-4 border border-gray-300 bg-white p-6 shadow-sm hover:border-red-500 transition-colors">
          <h2 class="font-[Orbitron] text-xs tracking-[0.2em] text-gray-400 uppercase mb-6">Assignment Due</h2>
          <div class="text-4xl font-bold">03</div>
          <p class="text-xs text-gray-500 mt-2 uppercase tracking-tighter">Pending Submissions</p>
        </div>

        <div class="col-span-12 md:col-span-4 border border-gray-300 bg-white p-6 shadow-sm">
          <h2 class="font-[Orbitron] text-xs tracking-[0.2em] text-gray-400 uppercase mb-6">Overall Attendance</h2>
          <div class="text-4xl font-bold flex items-baseline">
            88<span class="text-lg text-gray-400 ml-1">%</span>
          </div>
          <!-- Simple Progress Bar -->
          <div class="w-full bg-gray-100 h-1 mt-4">
            <div class="bg-red-500 h-full w-[88%]"></div>
          </div>
        </div>

        <div class="col-span-12 lg:col-span-4 border border-gray-300 bg-white p-6 shadow-sm">
          <h2 class="font-[Orbitron] text-xs tracking-[0.2em] text-gray-400 uppercase mb-6">Courses Enrolled</h2>

          <ul class="space-y-4">
            <li class="flex justify-between items-center text-sm border-b border-gray-50 pb-2">
              <span class="font-medium uppercase">${user.course}</span>
              <span class="text-[10px] bg-gray-100 px-2 py-1 uppercase">${user.batch}</span>
            </li>
            <li class="flex justify-between items-center text-sm border-b border-gray-50 pb-2">
              <span class="font-medium uppercase">Cyber Security Fundamental</span>
              <span class="text-[10px] bg-gray-100 px-2 py-1 uppercase">B-3</span>
            </li>
            <li class="flex justify-between items-center text-sm">
              <span class="font-medium uppercase text-red-500">More Courses</span>
              <i data-lucide="arrow-right" class="w-4 h-4 text-red-500"></i>
            </li>
          </ul>
        </div>

      </div>

      <footer
        class="mt-auto border-t border-gray-300 py-4 flex justify-between text-[10px] text-gray-400 uppercase tracking-widest">
        <span>Gurukul ILE System</span>
        <span>Session: 2025-26</span>
      </footer>

    </main>

    <script>
      lucide.createIcons();

      (function() {
        const slider = document.getElementById('noticeSlider');
        const dots = document.querySelectorAll('.slider-dot');
        const slideCount = <%= notices.size() %>;
        let currentIndex = 0;
        let interval;

        console.log("Notice slider initialized with", slideCount, "notices.");

        function updateSlider() {
          if (!slider) return;
          slider.style.transform = "translateX(-" + (currentIndex * 100) + "%)";
          dots.forEach((dot, index) => {
            dot.classList.toggle('bg-black', index === currentIndex);
            dot.classList.toggle('bg-gray-200', index !== currentIndex);
          });
        }

        function startAutoSlide() {
          if (slideCount > 1) {
            interval = setInterval(() => {
              currentIndex = (currentIndex + 1) % slideCount;
              updateSlider();
            }, 5000);
          }
        }

        function resetAutoSlide() {
          clearInterval(interval);
          startAutoSlide();
        }

        dots.forEach(dot => {
          dot.addEventListener('click', () => {
            currentIndex = parseInt(dot.getAttribute('data-index'));
            updateSlider();
            resetAutoSlide();
          });
        });

        startAutoSlide();
        if(slideCount > 0) updateSlider();
      })();
    </script>
  </body>

  </html>