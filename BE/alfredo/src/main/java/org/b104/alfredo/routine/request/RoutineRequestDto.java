package org.b104.alfredo.routine.request;

import lombok.*;

import java.time.LocalTime;
import java.util.Set;
@Getter
@Setter
@NoArgsConstructor
@ToString
public class RoutineRequestDto {
    private String routineTitle;
    private LocalTime startTime;
    private Set<String> days;
    private String alarmSound;
    private String memo;
    private Long basicRoutineId;

    @Builder
    public RoutineRequestDto(String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo, Long basicRoutineId){
        this.routineTitle = routineTitle;
        this.startTime = startTime;
        this.days = days;
        this.alarmSound = alarmSound;
        this.memo = memo;
        this.basicRoutineId = basicRoutineId;
    }
}
