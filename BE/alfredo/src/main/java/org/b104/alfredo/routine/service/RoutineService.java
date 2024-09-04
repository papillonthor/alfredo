package org.b104.alfredo.routine.service;

import org.b104.alfredo.routine.domain.Routine;
import org.springframework.web.bind.annotation.RequestHeader;

import java.time.LocalTime;
import java.util.List;
import java.util.Set;

public interface RoutineService {

    List<Routine> getAllRoutines(Long userId);
    Routine getRoutine(Long id);

    Routine createRoutine(String uid,String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo, Long basicRoutineId);

    void deleteRoutine(Long routineId);

    Routine updateRoutine(Long routineId,String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo);

    void addBasicRoutines(String uid, List<Long> basicRoutineIds);

    List<Routine> getRoutinesToNotify();
}
