package org.b104.alfredo.attendance.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.achieve.service.AchieveService;
import org.b104.alfredo.attendance.domain.Attendance;
import org.b104.alfredo.attendance.repository.AttendanceRepository;
import org.b104.alfredo.attendance.response.AttendanceDateDto;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttendanceServiceImpl implements AttendanceService {
    private final AttendanceRepository attendanceRepository;
    private final UserRepository userRepository;
    private final AchieveService achieveService;
    @Override
    public void checkAttendance(String uid) {
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User currentUser = user.get();
        Long userId = currentUser.getUserId();

        // 마지막 로그인 시간 업데이트
        currentUser.setLastLoginTime(now);
        userRepository.save(currentUser);

        // 오늘 날짜의 출석체크 확인
        attendanceRepository.findByUserUserIdAndDate(userId,today).ifPresentOrElse(
                attendance -> {
                    //당일 출석체크 완료된 경우 실행할 것
                    log.info("이미 출석 됨");
                },
                ()->{
                    //당일 출석체크가 없는 경우 실행될 것
                    log.info("출석체크 하는 중");
                    Attendance attendance = new Attendance();
                    attendance.setUser(currentUser);
                    attendance.setDate(today);
                    attendance.setLoginTime(now);
                    attendanceRepository.save(attendance);
                }
        );
        // 9번째 업적 - 생일 업데이트 하고, 로그인한 오늘이 생일인 경우
        achieveService.checkBirth(currentUser);

    }


    @Override
    public List<AttendanceDateDto> getAttendanceForCurrentWeek(String uid) {
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User currentUser = user.get();
        Long userId = currentUser.getUserId();
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
        LocalDate endOfWeek = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SATURDAY));
        log.info("해당 주 일요일"+startOfWeek);
        log.info("해당 주 토요일"+endOfWeek);

        List<Attendance> attendances = attendanceRepository.findByUserUserIdAndDateBetween(userId, startOfWeek, endOfWeek);
        return attendances.stream()
                .map(attendance -> new AttendanceDateDto(attendance.getDate()))
                .collect(Collectors.toList());
    }
    @Override
    public int getTotalAttendanceDaysForWeek(String uid) {
        List<AttendanceDateDto> attendances = getAttendanceForCurrentWeek(uid);
        return attendances.size();
    }

    @Override
    public int getConsecutiveAttendanceDaysForWeek(String uid) {
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User currentUser = user.get();
        Long userId = currentUser.getUserId();

        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
        LocalDate endOfWeek = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SATURDAY));

        List<Attendance> attendances = attendanceRepository.findByUserUserIdAndDateBetween(userId, startOfWeek, endOfWeek);
        attendances.sort(Comparator.comparing(Attendance::getDate));

        int maxStreak = 0;
        int currentStreak = 0;
        LocalDate lastDate = null;

        for (Attendance attendance : attendances) {
            if (lastDate == null || lastDate.plusDays(1).equals(attendance.getDate())) {
                currentStreak++;
            } else {
                currentStreak = 1;
            }
            maxStreak = Math.max(maxStreak, currentStreak);
            lastDate = attendance.getDate();
        }
        // 연속 6일이면 업적 달성
        if (maxStreak > 5){
            achieveService.checkChainAttendance(currentUser);
        }
        return maxStreak;
    }

    @Override
    public int getTotalAttendanceDays(String uid) {
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User currentUser = user.get();
        Long userId = currentUser.getUserId();
        int countAttendance = attendanceRepository.countByUserUserId(userId);

        // 8번째 업적 - 3일 이상 출석
        if (countAttendance> 2){
            achieveService.checkTotalAttendance(currentUser);
        }

        return countAttendance;
    }
}
