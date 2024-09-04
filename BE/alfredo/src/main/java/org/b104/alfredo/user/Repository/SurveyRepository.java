package org.b104.alfredo.user.Repository;

import org.b104.alfredo.user.Domain.Survey;
import org.b104.alfredo.user.Domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SurveyRepository extends JpaRepository<Survey, Long> {
    Optional<Survey> findByUserUserId(Long userId);
}
