CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    role VARCHAR(20),
    course VARCHAR(100),
    batch VARCHAR(50),
    specialization VARCHAR(100),
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE noticeboard (
    id INT AUTO_INCREMENT PRIMARY KEY,
    heading VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    whom VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE meetings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    teacher_name VARCHAR(100),
    meeting_id VARCHAR(100) NOT NULL,
    course VARCHAR(100),
    heading VARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    scheduled_time DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);