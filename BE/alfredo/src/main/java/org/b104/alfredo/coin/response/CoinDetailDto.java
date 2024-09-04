package org.b104.alfredo.coin.response;

import jakarta.persistence.Column;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.b104.alfredo.coin.domain.Coin;
import org.b104.alfredo.user.Domain.User;
@Getter
@NoArgsConstructor
public class CoinDetailDto {

    private Long coinId;
    private Integer totalCoin; // 총 코인 갯수
    private Integer todayCoin; // 오늘 얻은 코인 갯수

    @Builder
    public CoinDetailDto(Coin coin) {
        this.coinId = coin.getCoinId();
        this.totalCoin = coin.getTotalCoin();
        this.todayCoin = coin.getTodayCoin();
    }
}
