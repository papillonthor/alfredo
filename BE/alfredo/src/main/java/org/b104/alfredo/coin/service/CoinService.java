package org.b104.alfredo.coin.service;


import lombok.RequiredArgsConstructor;
import org.b104.alfredo.coin.domain.Coin;
import org.b104.alfredo.coin.repository.CoinRepository;
import org.b104.alfredo.coin.response.CoinDetailDto;
import org.b104.alfredo.user.Domain.User;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CoinService {
    private final CoinRepository coinRepository;

    // 코인 조회
    @Transactional
    public CoinDetailDto detailCoin(User user) {
        Coin coin = coinRepository.findByUserId(user);
        if (coin == null) {
            throw new IllegalArgumentException("Achieve not found for the user");
        }
        return new CoinDetailDto(coin);
    }

    @Transactional
    public void updateTotalCoin(User user, int additionalCoins) {
        Coin coin = coinRepository.findByUserId(user);
        if (coin != null) {
            coin.updateTotalCoin(coin.getTotalCoin() + additionalCoins);
        }
    }

    // 코인 생성
    @Transactional
    public Coin createCoin(User user) {
        // 유저당 코인 기록이 이미 있는지 확인
        Coin existingCoin = coinRepository.findByUserId(user);
        if (existingCoin != null) {
            throw new IllegalArgumentException("이 유저에 대한 코인 기록이 이미 존재합니다.");
        }

        // 새로운 코인 기록 생성
        Coin newCoin = Coin.builder()
                .userId(user)
                .totalCoin(0)
                .todayCoin(0)
                .build();

        return coinRepository.save(newCoin);
    }

    // 매일 자정에 todayCoin을 0으로 초기화하는 작업
    @Scheduled(cron = "0 0 0 * * *")
    @Transactional
    public void resetTodayCoin() {
        List<Coin> coins = coinRepository.findAll();
        for (Coin coin : coins) {
            coin.updateTodayCoin(0);
        }
    }

    // todayCoin과 totalCoin을 5개씩 증가시키는 서비스
    @Transactional
    public void incrementCoins(User user) {
        Coin coin = coinRepository.findByUserId(user);
        // 하루 얻을수 있는 코인 갯수
        if (coin != null && coin.getTodayCoin() < 50) {
            coin.updateTodayCoin(coin.getTodayCoin() + 5);
            coin.updateTotalCoin(coin.getTotalCoin() + 5);
        }
    }

    // todayCoin과 totalCoin을 5개씩 감소시키는 서비스
    @Transactional
    public void decrementCoins(User user) {
        Coin coin = coinRepository.findByUserId(user);
        if (coin != null && coin.getTodayCoin() >= 5 && coin.getTotalCoin() >= 5) {
            coin.updateTodayCoin(coin.getTodayCoin() - 5);
            coin.updateTotalCoin(coin.getTotalCoin() - 5);
        }
    }

    // 특정 값만큼 totalCoin을 감소시키는 서비스
    @Transactional
    public void decrementTotalCoin(User user, int decrementValue) {
        Coin coin = coinRepository.findByUserId(user);
        if (coin != null && coin.getTotalCoin() >= decrementValue) {
            coin.updateTotalCoin(coin.getTotalCoin() - decrementValue);
        } else {
            throw new IllegalArgumentException("Not enough coins to decrement.");
        }
    }
}
