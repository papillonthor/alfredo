package org.b104.alfredo.schedule.repository;

import org.b104.alfredo.schedule.domain.OldSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OldScheduleRepository extends JpaRepository<OldSchedule, Long> {

}
