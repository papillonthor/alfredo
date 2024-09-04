package org.b104.alfredo.schedule.repository;

import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.user.Domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByUserId(User user);

    List<Schedule> findByUserIdAndScheduleTitle(User user, String scheduleTitle);

    @Query("SELECT s FROM Schedule s WHERE s.userId = :user AND :today >= s.startDate AND :today <= s.endDate")
    List<Schedule> findAllByIdAndDate(@Param("user")User user, @Param("today") LocalDate today);

    Schedule findByScheduleId(Long id);
    List<Schedule> findByEndDateBefore(LocalDate date);

    long countByUserId(User user);
}
