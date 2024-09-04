package org.b104.alfredo.firebase.request;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class FCMAlarmDto {

    private String targetToken;
    private String title;
    private String body;

}

