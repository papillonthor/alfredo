package org.b104.alfredo.achieve.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import org.b104.alfredo.achieve.domain.Achieve;

import java.util.Date;

@Getter
@NoArgsConstructor
public class AchieveDetailDto {

    private Long achieveId;
    private Boolean achieveOne;
    private Boolean achieveTwo;
    private Boolean achieveThree;
    private Boolean achieveFour;
    private Boolean achieveFive;
    private Boolean achieveSix;
    private Boolean achieveSeven;
    private Boolean achieveEight;
    private Boolean achieveNine;
    private Date finishOne;
    private Date finishTwo;
    private Date finishThree;
    private Date finishFour;
    private Date finishFive;
    private Date finishSix;
    private Date finishSeven;
    private Date finishEight;
    private Date finishNine;

    public AchieveDetailDto(Achieve achieve){
        this.achieveId = achieve.getAchieveId();
        this.achieveOne = achieve.getAchieveOne();
        this.achieveTwo = achieve.getAchieveTwo();
        this.achieveThree = achieve.getAchieveThree();
        this.achieveFour = achieve.getAchieveFour();
        this.achieveFive = achieve.getAchieveFive();
        this.achieveSix = achieve.getAchieveSix();
        this.achieveSeven = achieve.getAchieveSeven();
        this.achieveEight = achieve.getAchieveEight();
        this.achieveNine = achieve.getAchieveNine();
        this.finishOne = achieve.getFinishOne();
        this.finishTwo = achieve.getFinishTwo();
        this.finishThree = achieve.getFinishThree();
        this.finishFour = achieve.getFinishFour();
        this.finishFive = achieve.getFinishFive();
        this.finishSix = achieve.getFinishSix();
        this.finishSeven = achieve.getFinishSeven();
        this.finishEight = achieve.getFinishEight();
        this.finishNine = achieve.getFinishNine();
    }
}
