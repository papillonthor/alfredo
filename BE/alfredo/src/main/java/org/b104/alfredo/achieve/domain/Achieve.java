package org.b104.alfredo.achieve.domain;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.b104.alfredo.user.Domain.User;
import org.hibernate.annotations.ColumnDefault;

import java.util.Date;

@Entity
@Getter
@NoArgsConstructor
public class Achieve {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long achieveId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ColumnDefault("false")
    private Boolean achieveOne;

    @Column
    private Date finishOne;  // Achieve One 달성일

    @ColumnDefault("false")
    private Boolean achieveTwo;

    @Column
    private Date finishTwo;  // Achieve Two 달성일

    @ColumnDefault("false")
    private Boolean achieveThree;

    @Column
    private Date finishThree;  // Achieve Three 달성일

    @ColumnDefault("false")
    private Boolean achieveFour;

    @Column
    private Date finishFour;  // Achieve Four 달성일

    @ColumnDefault("false")
    private Boolean achieveFive;

    @Column
    private Date finishFive;  // Achieve Five 달성일

    @ColumnDefault("false")
    private Boolean achieveSix;

    @Column
    private Date finishSix;  // Achieve Six 달성일

    @ColumnDefault("false")
    private Boolean achieveSeven;

    @Column
    private Date finishSeven;  // Achieve Seven 달성일

    @ColumnDefault("false")
    private Boolean achieveEight;

    @Column
    private Date finishEight;  // Achieve Eight 달성일

    @ColumnDefault("false")
    private Boolean achieveNine;

    @Column
    private Date finishNine;  // Achieve Nine 달성일

    @Builder
    public Achieve(User user, Boolean achieveOne, Date finishOne, Boolean achieveTwo, Date finishTwo, Boolean achieveThree, Date finishThree, Boolean achieveFour, Date finishFour, Boolean achieveFive, Date finishFive, Boolean achieveSix, Date finishSix, Boolean achieveSeven, Date finishSeven, Boolean achieveEight, Date finishEight, Boolean achieveNine, Date finishNine) {
        this.user = user;
        this.achieveOne = achieveOne;
        this.finishOne = finishOne;
        this.achieveTwo = achieveTwo;
        this.finishTwo = finishTwo;
        this.achieveThree = achieveThree;
        this.finishThree = finishThree;
        this.achieveFour = achieveFour;
        this.finishFour = finishFour;
        this.achieveFive = achieveFive;
        this.finishFive = finishFive;
        this.achieveSix = achieveSix;
        this.finishSix = finishSix;
        this.achieveSeven = achieveSeven;
        this.finishSeven = finishSeven;
        this.achieveEight = achieveEight;
        this.finishEight = finishEight;
        this.achieveNine = achieveNine;
        this.finishNine = finishNine;
    }

    public void updateAchieveOne(Boolean achieveOne, Date finishOne) {
        this.achieveOne = achieveOne;
        this.finishOne = finishOne;
    }

    public void updateAchieveTwo(Boolean achieveTwo, Date finishTwo) {
        this.achieveTwo = achieveTwo;
        this.finishTwo = finishTwo;
    }

    public void updateAchieveThree(Boolean achieveThree, Date finishThree) {
        this.achieveThree = achieveThree;
        this.finishThree = finishThree;
    }

    public void updateAchieveFour(Boolean achieveFour, Date finishFour) {
        this.achieveFour = achieveFour;
        this.finishFour = finishFour;
    }

    public void updateAchieveFive(Boolean achieveFive, Date finishFive) {
        this.achieveFive = achieveFive;
        this.finishFive = finishFive;
    }

    public void updateAchieveSix(Boolean achieveSix, Date finishSix) {
        this.achieveSix = achieveSix;
        this.finishSix = finishSix;
    }

    public void updateAchieveSeven(Boolean achieveSeven, Date finishSeven) {
        this.achieveSeven = achieveSeven;
        this.finishSeven = finishSeven;
    }

    public void updateAchieveEight(Boolean achieveEight, Date finishEight) {
        this.achieveEight = achieveEight;
        this.finishEight = finishEight;
    }

    public void updateAchieveNine(Boolean achieveNine, Date finishNine) {
        this.achieveNine = achieveNine;
        this.finishNine = finishNine;
    }
}
