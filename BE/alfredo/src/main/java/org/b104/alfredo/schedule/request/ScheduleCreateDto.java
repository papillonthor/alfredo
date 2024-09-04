package org.b104.alfredo.schedule.request;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.user.Domain.User;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@NoArgsConstructor
public class ScheduleCreateDto {

    private Long userId;
    private String scheduleTitle;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean startAlarm;
    private LocalTime alarmTime;
    private LocalDate alarmDate;
    private String place;
    private LocalTime startTime;
    private LocalTime endTime;
    private Boolean withTime;
    private String jobUid;

}
