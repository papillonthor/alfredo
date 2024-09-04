package org.b104.alfredo.firebase.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.b104.alfredo.firebase.request.FCMAlarmDto;

@Builder
@AllArgsConstructor
@Getter
public class FcmMessage {
    private boolean validateOnly;
    private Message message;

    @Builder
    @AllArgsConstructor
    @Getter
    public static class Message {
        private Notification notification;
        private String token;
    }

    @Builder
    @AllArgsConstructor
    @Getter
    public static class Notification {
        private String title;
        private String body;
        private String image;
    }
}
