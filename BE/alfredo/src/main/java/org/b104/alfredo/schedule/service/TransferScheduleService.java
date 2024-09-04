package org.b104.alfredo.schedule.service;

import jakarta.persistence.Column;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.RequiredArgsConstructor;
import org.b104.alfredo.schedule.domain.OldSchedule;
import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.schedule.repository.OldScheduleRepository;
import org.b104.alfredo.schedule.repository.ScheduleRepository;
import org.b104.alfredo.user.Domain.User;
import org.hibernate.annotations.ColumnDefault;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@RequiredArgsConstructor
@Service
public class TransferScheduleService {
    private final ScheduleRepository scheduleRepository;
    private final OldScheduleRepository oldScheduleRepository;

    public void TransferSchedule() {
        LocalDate twoMonthsAgo = LocalDate.now().minusMonths(4);
        LocalDateTime now = LocalDateTime.now();
        System.out.println("Current Local Date and Time: " + now);
        // 4 달 이상 된 Schedule 이동하기
        List<Schedule> oldSchedules = scheduleRepository.findByEndDateBefore(twoMonthsAgo);

        for (Schedule schedule : oldSchedules) {
            OldSchedule oldSchedule = new OldSchedule(
                    schedule.getUserId(),
                    schedule.getScheduleTitle(),
                    schedule.getStartDate(),
                    schedule.getEndDate(),
                    schedule.getStartAlarm(),
                    schedule.getAlarmTime(),
                    schedule.getAlarmDate(),
                    schedule.getPlace(),
                    schedule.getStartTime(),
                    schedule.getEndTime(),
                    schedule.getWithTime(),
                    schedule.getJobUid()
            );
            oldScheduleRepository.save(oldSchedule);
        }
        scheduleRepository.deleteAll(oldSchedules);
    }
}
