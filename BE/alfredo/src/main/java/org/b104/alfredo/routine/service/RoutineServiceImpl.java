package org.b104.alfredo.routine.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.routine.alarm.FirebaseCloudMessageService;
import org.b104.alfredo.routine.domain.BasicRoutine;
import org.b104.alfredo.routine.domain.Routine;
import org.b104.alfredo.routine.repository.BasicRoutineRepository;
import org.b104.alfredo.routine.repository.RoutineRepository;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

//TODO controller에서 repository하면 안됨.바꾸기
@Slf4j
@Service
@RequiredArgsConstructor
public class RoutineServiceImpl implements RoutineService {
    private final RoutineRepository routineRepository;
    private final BasicRoutineRepository basicRoutineRepository;
    private final UserRepository userRepository;
    private final FirebaseCloudMessageService firebaseCloudMessageService;

    @Override
    public List<Routine> getAllRoutines(Long userId) {
        return routineRepository.findByUserUserIdOrderByStartTimeAsc(userId);
    }

    @Override
    public Routine getRoutine(Long id) {
        Optional<Routine> routine= routineRepository.findById(id);
        return routine.orElse(null);
    }

    //TODO dto사용구조가 아님(리팩토링 하기)
    @Override
    public Routine createRoutine(String uid,String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo, Long basicRoutineId){
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User currentUser = user.get();

        //유저에게 푸시알림 전송 테스트
//        firebaseCloudMessageService.sendMessageTo(currentUser.getFcmToken(),"테스트","태스트");

        Routine routine = new Routine();
        routine.setUser(currentUser);
        routine.setRoutineTitle(routineTitle);
        routine.setStartTime(startTime);
        routine.setDays(days);
        routine.setAlarmSound(alarmSound);
        routine.setMemo(memo);
        if (basicRoutineId != null) {
            BasicRoutine basicRoutine = basicRoutineRepository.findById(basicRoutineId)
                    .orElseThrow(() -> new RuntimeException("BasicRoutine not found"));
            routine.setBasicRoutine(basicRoutine);
        }
        return routineRepository.save(routine);
    }

    @Override
    public void addBasicRoutines(String uid, List<Long> basicRoutineIds) {
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        for (Long basicRoutineId : basicRoutineIds) {
            BasicRoutine basicRoutine = basicRoutineRepository.findById(basicRoutineId).orElseThrow(() -> new RuntimeException("BasicRoutine not found"));

            Routine routineBySurvey = new Routine();
            routineBySurvey.setUser(user.get());
            routineBySurvey.setBasicRoutine(basicRoutine);
            routineBySurvey.setRoutineTitle(basicRoutine.getBasicRoutineTitle());
            routineBySurvey.setStartTime(basicRoutine.getStartTime());
            routineBySurvey.setDays((new HashSet<>(basicRoutine.getDays())));
            routineBySurvey.setAlarmSound(basicRoutine.getAlarmSound());
            routineBySurvey.setMemo(basicRoutine.getMemo());

            routineRepository.save(routineBySurvey);
        }


    }


    @Override
    public void deleteRoutine(Long routineId) {
        routineRepository.deleteById(routineId);
    }

    @Override
    public Routine updateRoutine(Long routineId,String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo) {
        Routine routine = routineRepository.findById(routineId)
                .orElseThrow(() -> new RuntimeException("Routine not found with id: " + routineId));

        if (routineTitle != null) {
            routine.setRoutineTitle(routineTitle);
        }
        if (startTime != null) {
            routine.setStartTime(startTime);
        }
        if (days != null) {
            routine.setDays(days);
        }
        if (alarmSound != null) {
            routine.setAlarmSound(alarmSound);
        }
        if (memo != null) {
            routine.setMemo(memo);
        }

        return routineRepository.save(routine);
        //이건 put
//        routine.setRoutineTitle(routineTitle);
//        routine.setStartTime(startTime);
//        routine.setDays(days);
//        routine.setAlarmSound(alarmSound);
//        routine.setMemo(memo);
//        return routineRepository.save(routine);*/

    }
    @Override
    public List<Routine> getRoutinesToNotify() {
        LocalDateTime now = LocalDateTime.now();
        // 예시 로직입니다, 루틴 구조에 따라 이를 조정해야 할 수 있습니다
        return routineRepository.findAll().stream()
                .filter(routine -> shouldNotify(routine, now))
                .collect(Collectors.toList());
    }

    private boolean shouldNotify(Routine routine, LocalDateTime now) {
//        log.info(String.valueOf(routine.getStartTime()));
//        log.info(now.toLocalTime().truncatedTo(ChronoUnit.MINUTES).toString());
//        log.info(now.getDayOfWeek().toString().substring(0, 3));
        LocalTime nowTime = now.toLocalTime().truncatedTo(ChronoUnit.MINUTES);
        LocalTime routineTime = routine.getStartTime();
        String dayOfWeekShort = now.getDayOfWeek().toString().substring(0, 3);
//        log.info(String.valueOf(routineTime.equals(nowTime)));
        // 'now' 시간에 루틴에 대한 알림을 보내야 하는지 결정하는 예시 로직
        return routine.getDays().contains(dayOfWeekShort) &&
                routineTime.equals(nowTime);
    }

}
