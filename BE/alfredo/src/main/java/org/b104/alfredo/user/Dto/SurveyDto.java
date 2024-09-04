package org.b104.alfredo.user.Dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.b104.alfredo.user.Domain.Survey;
import org.b104.alfredo.user.Domain.User;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SurveyDto {
    private Integer question1;
    private Integer question2;
    private Integer question3;
    private Integer question4;
    private Integer question5;

    public Survey toEntity(User user) {
        Survey survey = new Survey();
        survey.setUser(user);
        survey.setQuestion1(this.question1);
        survey.setQuestion2(this.question2);
        survey.setQuestion3(this.question3);
        survey.setQuestion4(this.question4);
        survey.setQuestion5(this.question5);
        return survey;
    }
}
