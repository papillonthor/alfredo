package org.b104.alfredo.todo.repository;

import org.b104.alfredo.todo.domain.Time;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TimeRepository extends JpaRepository<Time, Long> {
    Time findByUid(String uid);
}
