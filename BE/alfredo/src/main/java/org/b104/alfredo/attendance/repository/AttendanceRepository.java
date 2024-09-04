package org.b104.alfredo.attendance.repository;

import org.b104.alfredo.attendance.domain.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance,Long> {
    List<Attendance> findByUserUserIdAndDateBetween(Long userId, LocalDate startDate, LocalDate endDate);
    Optional<Attendance> findByUserUserIdAndDate(Long userId, LocalDate date);
    int countByUserUserId(Long userId);
}
