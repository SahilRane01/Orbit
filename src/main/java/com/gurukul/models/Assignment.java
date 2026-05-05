package com.gurukul.models;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class Assignment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int classId;
    private String title;
    private String description;
    private Date dueDate;
    private int maxMarks;
    private Timestamp createdAt;
    private int submissionCount;

    public Assignment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public int getMaxMarks() { return maxMarks; }
    public void setMaxMarks(int maxMarks) { this.maxMarks = maxMarks; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getSubmissionCount() { return submissionCount; }
    public void setSubmissionCount(int submissionCount) { this.submissionCount = submissionCount; }
}
