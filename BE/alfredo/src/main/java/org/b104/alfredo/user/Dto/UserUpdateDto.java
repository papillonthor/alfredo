package org.b104.alfredo.user.Dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.b104.alfredo.user.Domain.User;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class UserUpdateDto {
    private String nickname;
    private Date birth;
    private List<Long> answer;
    private String googleCalendarUrl;

    public static void updateEntity(User user, UserUpdateDto userUpdateDto) {
        if (userUpdateDto.getNickname() != null) user.setNickname(userUpdateDto.getNickname());
        if (userUpdateDto.getBirth() != null) user.setBirth(userUpdateDto.getBirth());
        if (userUpdateDto.getAnswer() != null) user.setAnswer(userUpdateDto.getAnswer());
        if (userUpdateDto.getGoogleCalendarUrl() != null) user.setGoogleCalendarUrl(userUpdateDto.getGoogleCalendarUrl());
    }
}
