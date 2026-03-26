<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="home.css">


    <link rel="stylesheet" href="https://unicons.iconscout.com/release/v4.0.0/css/line.css">

    <title>Gurukul Home</title>
</head>

<body>
    <nav>
        <div class="logo-name">
            <div class="logo-image">
                <img src="images/logo2.png" alt="">
            </div>

            <span class="logo_name">Gurukul</span>
        </div>

        <div class="menu-items">
            <ul class="nav-links">
                <li><a href="College/college.html">
                        <i class="uil uil-university"></i>
                        <span class="link-name">Colleges</span>
                    </a></li>
                <li><a href="classroom.html">
                        <i class="uil uil-book-reader"></i></i>
                        <span class="link-name">Classroom</span>
                    </a></li>
                <li><a href="quiz/quiz.html">
                        <i class="uil uil-cell"></i>
                        <span class="link-name">Quiz</span>
                    </a></li>
                <li><a href="https://phcascstudentportal.mes.ac.in/">
                        <i class="uil uil-chart"></i>
                        <span class="link-name">Result</span>
                    </a></li>
                <li><a href="points.html">
                        <i class="uil uil-analysis"></i>
                        <span class="link-name">Points</span>
                    </a></li>
                <li><a href="chat.html">
                        <i class="uil uil-comments"></i>
                        <span class="link-name">Chats</span>
                    </a></li>
                <li><a href="share.html">
                        <i class="uil uil-share"></i>
                        <span class="link-name">Share</span>
                    </a></li>
                <li><a href="game/index.html">
                        <i class="uil uil-google-play"></i>
                        <span class="link-name">Game</span>
                    </a></li>
                <li><a href="about.html">
                        <i class="uil uil-user-exclamation"></i>
                        <span class="link-name">About Dev's</span>
                    </a></li>
            </ul>

            <ul class="logout-mode">
                <li><a href="home.html">
                        <i class="uil uil-signout"></i>
                        <span class="link-name">Logout</span>
                    </a></li>

                <li class="mode">
                    <a href="#">
                        <i class="uil uil-moon"></i>
                        <span class="link-name">Dark Mode</span>
                    </a>

                    <div class="mode-toggle">
                        <span class="switch"></span>
                    </div>
                </li>
            </ul>
        </div>
    </nav>

    <section class="dashboard">
        <div class="top">
            <i class="uil uil-bars sidebar-toggle"></i>

            <div class="search-box">
                <i class="uil uil-search"></i>
                <input type="text" placeholder="Search here...">
            </div>

            <img src="images/profile.jpg" alt="profile">
        </div>

        <div class="dash-content">
            <div class="overview">
                <h2>Welcome, <%= session.getAttribute("username") %>!</h2>
                <div class="title">
                    <i class="uil uil-tachometer-fast-alt"></i>
                    <span class="text">Dashboard</span>
                </div>

                <div class="boxes">
                    <div class="box box1">
                        <i class="uil uil-book"></i>
                        <span class="text">Attendence</span>
                        <span class="number">DB Error</span>
                        <a
                            href="https://docs.google.com/spreadsheets/d/16KkRHBr6H4Afn8mMiajtfo8bQO8eTLhu/edit?usp=sharing&ouid=114892388761282598102&rtpof=true&sd=true">View
                            Attendence stylesheet</a>
                    </div>
                    <div class="box box2">
                        <i class="uil uil-notebooks"></i>
                        <span class="text">Assigned Work</span>
                        <span class="number">DB Error</span>
                        <a href="classroom.html">Go To Classroom</a>
                    </div>
                    <div class="box box3">
                        <i class="uil uil-analysis"></i>
                        <span class="text">Points</span>
                        <span class="number">DB Error</span>
                        <a href="classroom.html">View Points</a>
                    </div>
                </div>
            </div>


        </div>
    </section>

    <script src="Home.js"></script>
</body>

</html>