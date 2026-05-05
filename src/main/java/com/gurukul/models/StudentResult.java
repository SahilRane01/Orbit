package com.gurukul.models;

public class StudentResult {
    private int id;
    private int classId;
    private int studentId;
    private String studentName;
    private int theoryMarks;
    private int internalMarks;
    private int vivaMarks;
    private int totalMarks;
    private String grade;
    private String status;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public int getTheoryMarks() { return theoryMarks; }
    public void setTheoryMarks(int theoryMarks) { this.theoryMarks = theoryMarks; }

    public int getInternalMarks() { return internalMarks; }
    public void setInternalMarks(int internalMarks) { this.internalMarks = internalMarks; }

    public int getVivaMarks() { return vivaMarks; }
    public void setVivaMarks(int vivaMarks) { this.vivaMarks = vivaMarks; }

    public int getTotalMarks() { return totalMarks; }
    public void setTotalMarks(int totalMarks) { this.totalMarks = totalMarks; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
