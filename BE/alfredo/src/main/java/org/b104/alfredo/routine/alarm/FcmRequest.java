package org.b104.alfredo.routine.alarm;

public class FcmRequest {
    private String targetToken;
    private String title;
    private String body;

    // getters and setters
    public String getTargetToken() {
        return targetToken;
    }

    public void setTargetToken(String targetToken) {
        this.targetToken = targetToken;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }
}
