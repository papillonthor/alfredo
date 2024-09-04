package org.b104.alfredo.schedule.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import org.b104.alfredo.schedule.domain.Schedule;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@NoArgsConstructor
public class ScheduleDetailDto {
    private Long scheduleId;
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

    public ScheduleDetailDto(Schedule schedule){
        this.scheduleId = schedule.getScheduleId();
        this.scheduleTitle = schedule.getScheduleTitle();
        this.startDate = schedule.getStartDate();
        this.endDate = schedule.getEndDate();
        this.startAlarm = schedule.getStartAlarm();
        this.alarmTime = schedule.getAlarmTime();
        this.alarmDate = schedule.getAlarmDate();
        this.place = schedule.getPlace();
        this.startTime = schedule.getStartTime();
        this.endTime = schedule.getEndTime();
        this.withTime = schedule.getWithTime();
        this.jobUid = schedule.getJobUid();

    }
}
