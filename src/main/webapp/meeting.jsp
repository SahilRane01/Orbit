<%@ page import="com.gurukul.models.UserProfile" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    UserProfile user = (UserProfile) session.getAttribute("user");
    String meetingId = request.getParameter("id");
    String roomName = request.getParameter("room");
    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Briefing_Room - <%= roomName %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(255, 255, 255, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(255, 255, 255, 0.05) 1px, transparent 1px); background-size: 30px 30px; }
        .glass { background: rgba(10, 10, 10, 0.85); backdrop-filter: blur(25px); border: 1px solid rgba(255, 255, 255, 0.1); }
        .video-box { @apply relative bg-black aspect-video overflow-hidden border border-white/5 shadow-2xl rounded-sm; }
        .hud-scan { @apply absolute inset-0 pointer-events-none bg-gradient-to-b from-transparent via-red-500/[0.03] to-transparent h-40 w-full animate-[scan_8s_linear_infinite] opacity-50; }
        @keyframes scan { 0% { transform: translateY(-100%); } 100% { transform: translateY(500%); } }
        .control-btn { @apply w-14 h-14 rounded-full border border-white/10 bg-white/5 hover:bg-white/20 flex items-center justify-center transition-all duration-300; }
        .control-btn.active { @apply bg-red-600 border-red-600 text-white shadow-[0_0_30px_rgba(255,51,51,0.5)]; }
        .label-tactical { @apply text-[7px] text-gray-500 font-bold tracking-[0.4em] uppercase mb-1 block; }
    </style>
</head>
<body class="bg-[#020202] text-white font-[Inter] h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 grid-bg opacity-30 pointer-events-none"></div>

    <!-- TOP HUD -->
    <div class="relative z-50 border-b border-white/5 px-8 py-4 flex justify-between items-center bg-black/80 backdrop-blur-xl">
        <div class="flex items-center gap-6">
            <div class="w-10 h-10 bg-red-600 flex items-center justify-center font-[Orbitron] text-xs font-black text-white shadow-[0_0_25px_rgba(255,51,51,0.4)]">GKL</div>
            <div>
                <h1 class="font-[Orbitron] text-xs tracking-[0.4em] font-black uppercase text-red-500">Briefing_Node: <%= roomName %></h1>
                <p class="text-[8px] text-gray-500 tracking-[0.5em] font-bold mt-1 uppercase">Relay_ID: <%= meetingId %> // STATUS: SECURE_ALPHA</p>
            </div>
        </div>
        <div class="flex items-center gap-8">
            <div class="hidden md:flex flex-col items-end">
                <span class="text-[7px] text-gray-600 font-bold tracking-widest">SIGNAL_STABILITY</span>
                <div class="flex gap-1 mt-1">
                    <div class="w-4 h-0.5 bg-red-600"></div>
                    <div class="w-4 h-0.5 bg-red-600"></div>
                    <div class="w-4 h-0.5 bg-red-600"></div>
                    <div class="w-4 h-0.5 bg-gray-800 animate-pulse"></div>
                </div>
            </div>
            <% if (isTeacher) { %>
            <form action="meeting" method="post">
                <input type="hidden" name="action" value="END">
                <input type="hidden" name="meetingId" value="<%= meetingId %>">
                <button type="submit" class="bg-red-600 text-white px-8 py-2.5 font-[Orbitron] text-[10px] tracking-[0.3em] font-black uppercase hover:bg-white hover:text-black transition-all shadow-[0_0_30px_rgba(255,51,51,0.2)] border border-transparent">
                    Terminate_Relay
                </button>
            </form>
            <% } else { %>
            <a href="dashboard.jsp" class="bg-white/5 text-gray-400 px-8 py-2.5 font-[Orbitron] text-[10px] tracking-widest font-black uppercase hover:bg-white/10 transition-all border border-white/10">
                Deauth_Node
            </a>
            <% } %>
        </div>
    </div>

    <!-- MAIN GRID -->
    <main class="flex-grow relative z-10 p-10 flex items-center justify-center bg-transparent">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-10 w-full max-w-7xl h-full max-h-[700px]">
            <!-- LOCAL NODE -->
            <div class="video-box group">
                <video id="localVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
                <div class="hud-scan"></div>
                <!-- HUD -->
                <div class="absolute top-4 left-6 py-1.5 px-4 bg-red-600/10 border-l-2 border-red-600 text-[8px] font-black tracking-[0.4em] text-red-500 uppercase">
                    USER_FEED: <%= user.getFullName().toUpperCase() %>
                </div>
                <div class="absolute bottom-4 right-6 text-[7px] font-mono text-white/10 tracking-widest uppercase">Node_Source_Prime</div>
            </div>

            <!-- REMOTE NODE -->
            <div class="video-box group">
                <video id="remoteVideo" class="w-full h-full object-cover" autoplay playsinline></video>
                <div id="wait-message" class="absolute inset-0 flex flex-col items-center justify-center text-gray-600 gap-6 uppercase tracking-[0.4em] bg-black/40">
                    <div class="relative">
                        <i data-lucide="radio" class="w-12 h-12 text-red-600 animate-pulse"></i>
                        <div class="absolute inset-x-0 -bottom-2 h-0.5 bg-red-600/20 blur-sm"></div>
                    </div>
                    <span class="text-[10px] font-black italic">Awaiting_Remote_Signal...</span>
                </div>
                <div class="hud-scan"></div>
                <div class="absolute top-4 left-6 py-1.5 px-4 bg-white/5 border-l-2 border-white/20 text-[8px] font-black tracking-[0.4em] text-white/40 uppercase">
                    REMOTE_FEED: <%= isTeacher ? "STUDENT_UNIT" : "COMMANDER" %>
                </div>
            </div>
        </div>
    </main>

    <!-- CONTROLS HUD -->
    <div class="relative z-50 p-12 flex justify-center items-center gap-12 bg-black/40 backdrop-blur-sm">
        <button id="toggle-mic" class="control-btn active" title="Toggle Audio Pipeline">
            <i data-lucide="mic" class="w-6 h-6"></i>
        </button>
        <button id="toggle-video" class="control-btn active" title="Toggle Visual Array">
            <i data-lucide="video" class="w-6 h-6"></i>
        </button>
        <button id="disconnect" class="control-btn bg-red-700/80 border-red-600 hover:bg-black transition-all group" 
                onclick="window.location.href='<%= isTeacher ? "teacherDashboard.jsp" : "dashboard.jsp" %>'">
            <i data-lucide="phone-off" class="w-6 h-6 group-hover:scale-110"></i>
        </button>
        
        <button id="start-hardware" class="hidden absolute bottom-24 bg-red-600 text-white px-10 py-4 font-[Orbitron] text-[11px] tracking-[0.4em] font-black uppercase hover:bg-black transition-all shadow-2xl border border-red-600/40">
            Re-Initialize_Comms
        </button>
    </div>

    <!-- SECURITY BYPASS MODAL -->
    <div id="security-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-8 backdrop-blur-2xl bg-black/80 font-[Inter]">
        <div class="glass max-w-xl w-full p-10 border-l-4 border-red-600 shadow-[0_0_100px_rgba(255,51,51,0.15)] relative">
            <h2 class="font-[Orbitron] text-sm tracking-[0.5em] uppercase font-black text-red-500 mb-6 italic">Secure_Origin_Required</h2>
            <p class="text-[10px] text-gray-400 leading-relaxed mb-8 uppercase tracking-widest font-bold">
                Hardware access is <span class="text-red-500 underline">DISABLED</span> for non-secure LAN origins. Execute the following override sequence:
            </p>
            <div class="space-y-6 text-[10px] font-bold text-gray-500">
                <div class="p-4 bg-white/5 border border-white/5">
                    1. Navigate to Flag Core: <br>
                    <code class="text-red-500 font-mono block mt-2 select-all">chrome://flags/#unsafely-treat-insecure-origin-as-secure</code>
                </div>
                <div class="p-4 bg-white/5 border border-white/5">
                    2. Add Node Identity to Permissions: <br>
                    <div class="flex justify-between items-center mt-2">
                        <code id="node-id" class="text-red-500 font-mono">http://<%= request.getServerName() %>:<%= request.getServerPort() %></code>
                        <button onclick="copyNode()" class="bg-red-600 text-white px-4 py-1.5 hover:bg-white hover:text-black transition-all text-[8px] font-black uppercase tracking-widest">Copy</button>
                    </div>
                </div>
                <div class="p-4 bg-white/5 border border-white/5 uppercase">
                    3. Set Protocol to <span class="text-red-500 underline">ENABLED</span> and Relaunch System.
                </div>
            </div>
            <button onclick="document.getElementById('security-modal').classList.add('hidden')" class="w-full mt-10 bg-white/5 border border-white/10 text-white py-5 font-[Orbitron] text-[10px] tracking-[0.6em] uppercase hover:bg-red-600 transition-all font-black">Proceed to Terminal</button>
        </div>
    </div>

    <script>
        lucide.createIcons();
        const meetId = "<%= meetingId %>";
        const isTeacher = <%= isTeacher %>;
        let localStream, peer;

        async function init() {
            if (!window.isSecureContext && window.location.hostname !== "localhost") {
                document.getElementById('security-modal').classList.remove('hidden');
            }
            try {
                localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                document.getElementById('localVideo').srcObject = localStream;
                document.getElementById('security-modal').classList.add('hidden');
                const config = { config: { 'iceServers': [{ url: 'stun:stun.l.google.com:19302' }, { url: 'stun:stun1.l.google.com:19302' }] } };
                if (isTeacher) {
                    peer = new Peer(meetId, config);
                    peer.on('call', (call) => { call.answer(localStream); handle(call); });
                } else {
                    peer = new Peer(undefined, config);
                    peer.on('open', (id) => { const call = peer.call(meetId, localStream); handle(call); });
                }
            } catch (err) {
                console.error(err);
                document.getElementById('start-hardware').classList.remove('hidden');
            }
        }
        function handle(call) {
            call.on('stream', (rs) => {
                const rv = document.getElementById('remoteVideo');
                rv.srcObject = rs;
                document.getElementById('wait-message').style.display = 'none';
            });
        }
        function copyNode() { navigator.clipboard.writeText(document.getElementById('node-id').innerText); }
        document.getElementById('toggle-mic').onclick = function() {
            const t = localStream.getAudioTracks()[0]; t.enabled = !t.enabled;
            this.classList.toggle('active', t.enabled); this.querySelector('i').setAttribute('data-lucide', t.enabled ? 'mic' : 'mic-off'); lucide.createIcons();
        };
        document.getElementById('toggle-video').onclick = function() {
            const t = localStream.getVideoTracks()[0]; t.enabled = !t.enabled;
            this.classList.toggle('active', t.enabled); this.querySelector('i').setAttribute('data-lucide', t.enabled ? 'video' : 'video-off'); lucide.createIcons();
        };
        document.getElementById('start-hardware').onclick = () => init();
        init();
    </script>
</body>
</html>
