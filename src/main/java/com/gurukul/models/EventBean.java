package com.gurukul.models;

import java.io.Serializable;
import java.sql.Date;

public class EventBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String eventName;
    private Date eventDate;
    private String description;

    public EventBean() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }

    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
