-- ============================================================
-- GURUKUL RESULTS MODULE - Database Tables
-- Run this SQL against the 'gurukul' database
-- ============================================================

-- Grading Configurations per Class
CREATE TABLE IF NOT EXISTS result_configs (
    class_id INT PRIMARY KEY,
    theory_max INT DEFAULT 100,
    theory_pass INT DEFAULT 40,
    internal_max INT DEFAULT 50,
    internal_pass INT DEFAULT 20,
    viva_max INT DEFAULT 50,
    viva_pass INT DEFAULT 20,
    grade_a INT DEFAULT 90,
    grade_b INT DEFAULT 75,
    grade_c INT DEFAULT 60,
    grade_d INT DEFAULT 40,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);

-- Student Results per Class
CREATE TABLE IF NOT EXISTS student_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    student_id INT NOT NULL,
    theory_marks INT DEFAULT 0,
    internal_marks INT DEFAULT 0,
    viva_marks INT DEFAULT 0,
    total_marks INT DEFAULT 0,
    grade VARCHAR(5),
    status ENUM('PASS', 'FAIL') DEFAULT 'FAIL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_student_result (class_id, student_id)
);
