<%@ page import="com.gurukul.userProfileBean" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    userProfileBean user = (userProfileBean) session.getAttribute("user");
    String meetingId = request.getParameter("id");
    String roomName = request.getParameter("room");
    boolean isTeacher = "Teacher".equalsIgnoreCase(user.getRole());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tactical Briefing Room - <%= roomName %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js"></script>
    <style type="text/tailwindcss">
        .grid-bg { background-image: linear-gradient(to right, rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 1px, transparent 1px); background-size: 30px 30px; }
        .glass { background: rgba(10, 10, 10, 0.8); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); }
        .video-box { @apply relative bg-black aspect-video overflow-hidden border border-white/10 shadow-2xl; }
        .hud-scan { @apply absolute inset-0 pointer-events-none bg-gradient-to-b from-transparent via-red-500/5 to-transparent h-20 w-full animate-[scan_5s_linear_infinite] opacity-30; }
        @keyframes scan { 0% { transform: translateY(-100%); } 100% { transform: translateY(400%); } }
        .control-btn { @apply w-12 h-12 rounded-full border border-white/10 bg-white/5 hover:bg-white/20 flex items-center justify-center transition-all; }
        .control-btn.active { @apply bg-red-500 border-red-500 text-white shadow-[0_0_20px_rgba(255,51,51,0.4)]; }
    </style>
</head>
<body class="bg-[#050505] text-white font-[Inter] h-screen overflow-hidden flex flex-col">
    <div class="fixed inset-0 grid-bg opacity-20 pointer-events-none"></div>

    <!-- TOP HUD -->
    <div class="relative z-50 border-b border-white/5 px-8 py-4 flex justify-between items-center bg-black/50 backdrop-blur-md">
        <div class="flex items-center gap-6">
            <div class="w-10 h-10 bg-red-500 flex items-center justify-center font-[Orbitron] text-xs font-bold text-white shadow-[0_0_20px_rgba(255,51,51,0.3)]">GKL</div>
            <div>
                <h1 class="font-[Orbitron] text-xs tracking-[0.3em] font-black uppercase text-red-500">Tactical_Briefing: <%= roomName %></h1>
                <p class="text-[8px] text-gray-500 tracking-[0.4em] font-bold mt-1 uppercase">Relay_ID: <%= meetingId %> / Enc_Status: NOMINAL</p>
            </div>
        </div>
        <div class="flex items-center gap-8">
            <div class="hidden md:flex flex-col items-end">
                <span class="text-[7px] text-gray-500 font-bold tracking-widest">SIGNAL_STRENGTH</span>
                <div class="flex gap-1 mt-1">
                    <div class="w-4 h-1 bg-red-500"></div>
                    <div class="w-4 h-1 bg-red-500"></div>
                    <div class="w-4 h-1 bg-red-500"></div>
                    <div class="w-4 h-1 bg-gray-800 animate-pulse"></div>
                </div>
            </div>
            <% if (isTeacher) { %>
            <form action="meetingAction" method="post">
                <input type="hidden" name="action" value="END_MEETING">
                <input type="hidden" name="meetingId" value="<%= meetingId %>">
                <button type="submit" class="bg-red-500 text-white px-6 py-2 font-[Orbitron] text-[10px] tracking-widest font-black uppercase hover:bg-black hover:border-red-500 border border-transparent transition-all shadow-xl">
                    Terminate_Briefing
                </button>
            </form>
            <% } else { %>
            <a href="dashboard.jsp" class="bg-white/5 text-gray-400 px-6 py-2 font-[Orbitron] text-[10px] tracking-widest font-black uppercase hover:bg-white/10 transition-all border border-white/10">
                Disconnect
            </a>
            <% } %>
        </div>
    </div>

    <!-- VIDEO GRID -->
    <main class="flex-grow relative z-10 p-8 flex items-center justify-center bg-transparent">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 w-full max-w-6xl h-full max-h-[600px]">
            <!-- LOCAL VIDEO -->
            <div class="video-box group">
                <video id="localVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
                <div class="hud-scan"></div>
                <!-- HUD OVERLAY -->
                <div class="absolute top-4 left-6 py-1 px-3 bg-red-500/[0.1] border-l-2 border-red-500 text-[8px] font-bold tracking-[0.3em] text-red-500 uppercase">
                    USER_FEED: <%= user.getFullName().toUpperCase() %>
                </div>
                <div class="absolute bottom-4 right-6 text-[7px] font-mono text-white/20">CAM_SOURCE_01</div>
            </div>

            <!-- REMOTE VIDEO -->
            <div class="video-box group">
                <video id="remoteVideo" class="w-full h-full object-cover" autoplay playsinline></video>
                <div id="wait-message" class="absolute inset-0 flex flex-col items-center justify-center text-gray-500 gap-4 uppercase tracking-[0.2em]">
                    <i data-lucide="radio" class="w-10 h-10 animate-pulse"></i>
                    <span class="text-[10px] font-black">Awaiting_Incoming_Signal...</span>
                </div>
                <div class="hud-scan"></div>
                <div class="absolute top-4 left-6 py-1 px-3 bg-blue-500/[0.1] border-l-2 border-blue-500 text-[8px] font-bold tracking-[0.3em] text-blue-500 uppercase">
                    REMOTE_FEED: <%= isTeacher ? "STUDENT_TERMINAL" : "COMMANDER" %>
                </div>
            </div>
        </div>
    </main>

    <!-- CONTROLS HUD -->
    <div class="relative z-50 p-10 flex justify-center items-center gap-10">
        <button id="toggle-mic" class="control-btn active shadow-[0_0_20px_rgba(255,255,255,0.1)]">
            <i data-lucide="mic" class="w-5 h-5"></i>
        </button>
        <button id="toggle-video" class="control-btn active">
            <i data-lucide="video" class="w-5 h-5"></i>
        </button>
        <button id="disconnect" class="control-btn bg-red-600 border-red-600 hover:bg-black transition-colors" 
                onclick="window.location.href='<%= isTeacher ? "teacherDashboard.jsp" : "dashboard.jsp" %>'">
            <i data-lucide="phone-off" class="w-5 h-5"></i>
        </button>
        
        <!-- HARDWARE FALLBACK BUTTON -->
        <button id="start-hardware" class="hidden absolute -bottom-20 bg-red-500 text-white px-8 py-3 font-[Orbitron] text-[10px] tracking-widest uppercase hover:bg-black transition-all shadow-2xl border border-red-500/50">
            Re-Initialize_Protocol
        </button>
    </div>

    <!-- LAN BYPASS MODAL -->
    <div id="lan-bypass-modal" class="fixed inset-0 z-[100] hidden flex items-center justify-center p-6 backdrop-blur-xl bg-black/60 font-[Inter]">
        <div class="glass max-w-lg w-full p-8 border-l-4 border-red-500 shadow-2xl relative">
            <h2 class="font-[Orbitron] text-xs tracking-[0.4em] uppercase font-black text-gray-900 mb-4">Tactical_LAN_Bypass</h2>
            <p class="text-[10px] text-gray-500 leading-relaxed mb-6 uppercase tracking-wider">
                Video hardware is currently <span class="text-red-500 font-bold">LOCKED</span> due to browser security restrictions on LAN IP addresses. Follow this protocol to unlock:
            </p>
            <div class="space-y-4 text-[9px] font-bold text-gray-600">
                <div class="p-3 bg-black/5 border border-black/5">
                    1. Open Chrome/Edge Flag: <br>
                    <span class="text-red-500 font-mono">chrome://flags/#unsafely-treat-insecure-origin-as-secure</span>
                </div>
                <div class="p-3 bg-black/5 border border-black/5 flex justify-between items-center">
                    <div>
                        2. Add this IP to the list: <br>
                        <span id="bypass-url" class="text-red-500 font-mono">http://<%= request.getServerName() %>:<%= request.getServerPort() %></span>
                    </div>
                    <button onclick="copyBypassURL()" class="bg-black text-white px-3 py-1 hover:bg-red-500 transition-colors uppercase">Copy</button>
                </div>
                <div class="p-3 bg-black/5 border border-black/5">
                    3. Set to <span class="text-red-500 underline">ENABLED</span> and Relaunch.
                </div>
            </div>
            <button onclick="document.getElementById('lan-bypass-modal').classList.add('hidden')" class="w-full mt-8 bg-red-500 text-white py-4 font-[Orbitron] text-[9px] tracking-[0.5em] uppercase hover:bg-black transition-all">Proceed_to_Manual_Command</button>
        </div>
    </div>

    <script>
        lucide.createIcons();

        const sessionMeetingId = "<%= meetingId %>";
        const sessionTeacherId = "<%= meetingId %>";
        const sessionIsTeacher = <%= isTeacher %>;
        
        let localStream;
        let peer;

        async function init() {
            // Check for Secure Context (Required for WebRTC)
            if (!window.isSecureContext && window.location.hostname !== "localhost") {
                document.getElementById('lan-bypass-modal').classList.remove('hidden');
            }

            try {
                localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                document.getElementById('localVideo').srcObject = localStream;
                document.getElementById('start-hardware').classList.add('hidden');
                document.getElementById('lan-bypass-modal').classList.add('hidden');

                const peerConfig = {
                    config: {
                        'iceServers': [
                            { url: 'stun:stun.l.google.com:19302' },
                            { url: 'stun:stun1.l.google.com:19302' }
                        ]
                    }
                };

                if (sessionIsTeacher) {
                    peer = new Peer(sessionTeacherId, peerConfig);
                    peer.on('open', (id) => console.log('Teacher Terminal Active at:', id));
                    peer.on('call', (call) => {
                        console.log('Incoming Student Signal...');
                        call.answer(localStream);
                        handleStream(call);
                    });
                } else {
                    peer = new Peer(undefined, peerConfig);
                    peer.on('open', (id) => {
                        console.log('Student Terminal Syncing...', id);
                        const call = peer.call(sessionTeacherId, localStream);
                        handleStream(call);
                    });
                }

                peer.on('error', (err) => {
                    console.error('Signal Failure:', err);
                    if(!sessionIsTeacher) alert("Connection Failed: Commander is currently offline.");
                });

            } catch (err) {
                console.error('Hardware Failure:', err);
                document.getElementById('start-hardware').classList.remove('hidden');
            }
        }

        function copyBypassURL() {
            const url = document.getElementById('bypass-url').innerText;
            navigator.clipboard.writeText(url);
            alert("URL Copied to Clipboard. Paste into Chrome Flag settings.");
        }

        document.getElementById('start-hardware').addEventListener('click', () => init());

        function handleStream(call) {
            call.on('stream', (remoteStream) => {
                const remoteVideo = document.getElementById('remoteVideo');
                const waitMsg = document.getElementById('wait-message');
                remoteVideo.srcObject = remoteStream;
                if(waitMsg) waitMsg.style.display = 'none';
            });
        }

        // Toggles
        document.getElementById('toggle-mic').addEventListener('click', function() {
            const audioTrack = localStream.getAudioTracks()[0];
            audioTrack.enabled = !audioTrack.enabled;
            this.classList.toggle('active', audioTrack.enabled);
            this.querySelector('i').setAttribute('data-lucide', audioTrack.enabled ? 'mic' : 'mic-off');
            lucide.createIcons();
        });

        document.getElementById('toggle-video').addEventListener('click', function() {
            const videoTrack = localStream.getVideoTracks()[0];
            videoTrack.enabled = !videoTrack.enabled;
            this.classList.toggle('active', videoTrack.enabled);
            this.querySelector('i').setAttribute('data-lucide', videoTrack.enabled ? 'video' : 'video-off');
            lucide.createIcons();
        });

        init();
    </script>
</body>
</html>
