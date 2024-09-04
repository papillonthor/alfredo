package org.b104.alfredo.achieve.repository;

import org.b104.alfredo.achieve.domain.Achieve;
import org.b104.alfredo.user.Domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AchieveRepository extends JpaRepository<Achieve, Long> {
    Achieve findByUser(User user);
}

