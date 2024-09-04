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
public class RecommendUserDto {
    private List<Long> answer;
    private Long userId;


    public User toEntity() {
        return User.builder()
                .answer(this.answer)
                .userId(this.userId)
                .build();
    }
}