package org.b104.alfredo.user.Dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.b104.alfredo.user.Domain.User;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class AnswerDto {
    private List<Long> answer;

    public static void updateEntity(User user, AnswerDto answerDto) {
        if (answerDto.getAnswer() != null) user.setAnswer(answerDto.getAnswer());
    }
}
