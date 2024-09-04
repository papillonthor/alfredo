package org.b104.alfredo.coin.repository;

import org.b104.alfredo.coin.domain.Coin;
import org.b104.alfredo.user.Domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CoinRepository extends JpaRepository<Coin, Long> {

    Coin findByUserId(User userId);
}
