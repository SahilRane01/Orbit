package com.gurukul.models;

public class QuizAnswer {
    private int id;
    private int submissionId;
    private int questionId;
    private String selectedOption; // 'A', 'B', 'C', 'D'

    public QuizAnswer() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSubmissionId() { return submissionId; }
    public void setSubmissionId(int submissionId) { this.submissionId = submissionId; }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public String getSelectedOption() { return selectedOption; }
    public void setSelectedOption(String selectedOption) { this.selectedOption = selectedOption; }
}
