package org.b104.alfredo.routine.response;

import jakarta.persistence.Column;
import lombok.*;


import java.time.LocalTime;
import java.util.Set;


//TODO routine list에서는 alarmSound,memo불필요
@Getter @Setter
@NoArgsConstructor
@ToString
public class RoutineDto {
    private Long id;
    private String routineTitle;
    private LocalTime startTime;
    private Set<String> days;
    private String alarmSound;
    private String memo;

    @Builder
    public RoutineDto(Long id,String routineTitle,LocalTime startTime,Set<String> days,String alarmSound,String memo){
        this.id= id;
        this.routineTitle = routineTitle;
        this.startTime = startTime;
        this.days = days;
        this.alarmSound = alarmSound;
        this.memo = memo;
    }
}
