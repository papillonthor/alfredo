package org.b104.alfredo.routine.repository;

import org.b104.alfredo.routine.domain.BasicRoutine;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BasicRoutineRepository extends JpaRepository<BasicRoutine,Long> {
    Optional<BasicRoutine> findByBasicRoutineTitle(String basicRoutineTitle);
}
