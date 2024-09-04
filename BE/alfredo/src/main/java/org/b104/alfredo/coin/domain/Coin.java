package org.b104.alfredo.coin.domain;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.b104.alfredo.user.Domain.User;

@Entity
@Getter
@NoArgsConstructor
public class Coin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long coinId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User userId;    // 유저 아이디

    @Column
    private Integer totalCoin; // 총 코인 갯수

    @Column
    private Integer todayCoin; // 오늘 얻은 코인 갯수

    @Builder
    public Coin(User userId, Integer totalCoin, Integer todayCoin) {
        this.userId = userId;
        this.totalCoin = totalCoin;
        this.todayCoin = todayCoin;
    }

    public void updateTotalCoin(Integer totalCoin) {
        this.totalCoin = totalCoin;
    }

    public void updateTodayCoin(Integer todayCoin) {
        this.todayCoin = todayCoin;
    }


}
