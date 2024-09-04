package org.b104.alfredo.tts.repository;

import org.b104.alfredo.tts.domain.UserRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface UserRequestRepository extends JpaRepository<UserRequest, Long> {
    Optional<UserRequest> findByUidAndRequestDate(String uid, LocalDate today);
}
