package org.b104.alfredo.schedule.request;

import lombok.Getter;
import lombok.Setter;
import org.b104.alfredo.schedule.domain.Schedule;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
public class ScheduleUpdateDto {

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
