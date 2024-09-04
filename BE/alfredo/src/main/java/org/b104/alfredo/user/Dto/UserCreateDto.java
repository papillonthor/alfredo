package org.b104.alfredo.user.Dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.b104.alfredo.user.Domain.User;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserCreateDto {
    private String email;
    private String nickname;
    private String uid;
    private Date birth;
    private List<Long> answer;
    private String googleCalendarUrl;

    public User toEntity() {
        return User.builder()
                .email(this.email)
                .nickname(this.nickname)
                .uid(this.uid)
                .answer(this.answer)
                .googleCalendarUrl(this.googleCalendarUrl)
                .build();
    }
}
