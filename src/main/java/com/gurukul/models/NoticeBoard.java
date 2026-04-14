package com.gurukul.models;

import java.io.Serializable;
import java.sql.Timestamp;

public class NoticeBoard implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String heading;
    private String body;
    private Timestamp createdAt;
    private String whom;

    public NoticeBoard() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getHeading() { return heading; }
    public void setHeading(String heading) { this.heading = heading; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getWhom() { return whom; }
    public void setWhom(String whom) { this.whom = whom; }
}
