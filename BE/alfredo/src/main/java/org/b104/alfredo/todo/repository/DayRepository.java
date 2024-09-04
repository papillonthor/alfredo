package org.b104.alfredo.todo.repository;

import org.b104.alfredo.todo.domain.Day;
import org.b104.alfredo.todo.domain.Todo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DayRepository extends JpaRepository<Day, Long> {
    Optional<Day> findByUidAndDayIndex(String uid, int dayIndex);

    List<Day> findAllByUid(String uid);

    long countByUid(String uid);
}
