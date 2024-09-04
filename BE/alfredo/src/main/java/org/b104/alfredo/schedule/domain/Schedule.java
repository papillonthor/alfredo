package org.b104.alfredo.schedule.domain;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.b104.alfredo.user.Domain.User;
import org.hibernate.annotations.ColumnDefault;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Getter
@NoArgsConstructor
public class Schedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long scheduleId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id" )
    private User userId;    // 유저 아이디

    @Column(nullable = false)
    private String scheduleTitle;   // 일정 제목
    @Column(nullable = false)
    private LocalDate startDate;    // 일정 시작일
    @Column(nullable = false)
    private LocalDate endDate;      // 일정 종료일
    // false가 기본
    @ColumnDefault("false")
    private Boolean startAlarm;     // 알람 유무
    @Column
    private LocalTime alarmTime;  // 추가된 알람 시간 필드
    @Column
    private LocalDate alarmDate; // 알림 날짜
    @Column
    private String place;           // 장소
    @Column
    private LocalTime startTime;    // 일정 시작 시간
    @Column
    private LocalTime endTime;      // 일정 종료 시간
    // true가 기본
    @ColumnDefault("true")
    private Boolean withTime;       // 시간 유무(하루종일)
    @Column
    private String jobUid;        // 작업 고유 식별자

    @Builder
    public Schedule(User userId, String scheduleTitle, LocalDate startDate, LocalDate endDate, Boolean startAlarm, LocalTime alarmTime, LocalDate alarmDate, String place, LocalTime startTime, LocalTime endTime, Boolean withTime, String jobUid) {
        this.userId = userId;
        this.scheduleTitle = scheduleTitle;
        this.startDate = startDate;
        this.endDate = endDate;
        this.startAlarm = startAlarm != null ? startAlarm : Boolean.FALSE;
        this.alarmTime = alarmTime;
        this.alarmDate = alarmDate;
        this.place = place;
        this.startTime = startTime;
        this.endTime = endTime;
        this.withTime = withTime != null ? withTime : Boolean.TRUE;
        this.jobUid = jobUid;
    }

    public void updateScheduleTitle(String scheduleTitle) {
        this.scheduleTitle = scheduleTitle;
    }
    public void updateStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    public void updateEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }
    public void updateStartAlarm(Boolean startAlarm) {
        this.startAlarm = startAlarm;
    }
    public void updateAlarmTime(LocalTime alarmTime) {
        this.alarmTime = alarmTime;
    }
    public void updateAlarmDate(LocalDate alarmDate) {
        this.alarmDate = alarmDate;
    }
    public void updatePlace(String place) {
        this.place = place;
    }
    public void updateStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }
    public void updateEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }
    public void updateWithTime(Boolean withTime) {
        this.withTime = withTime;
    }
    public void updateJobUid(String jobUid) {
        this.jobUid = jobUid;
    }

}
