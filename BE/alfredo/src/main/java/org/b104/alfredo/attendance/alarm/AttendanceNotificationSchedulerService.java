package org.b104.alfredo.attendance.alarm;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.routine.alarm.FirebaseCloudMessageService;
import org.b104.alfredo.todo.repository.TodoRepository;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Slf4j
@Service @RequiredArgsConstructor
public class AttendanceNotificationSchedulerService {
    private final UserRepository userRepository;
    private final TodoRepository todoRepository;
    private final FirebaseCloudMessageService firebaseCloudMessageService;

    @Scheduled(cron = "0 0 12 * * ?")
    public void sendNoonReminder() throws IOException {
        log.info("12시 알림 작동함");
        sendReminder("lunch");
    }

    @Scheduled(cron = "0 0 18 * * ?")
    public void sendEveningReminder() throws IOException {
        log.info("저녁 알림 수행");
        sendReminder("dinner");
    }

    @Scheduled(cron = "0 0 23 * * ?")
    public void sendNightReminder() throws IOException {
        log.info("밤 알림 수행");
        sendReminder("night");
    }


    //사용자의 최근 접속시간이 오늘 특정시간 이전이고 당일의 아직 완료하지 않은 todo가 있는 경우 알림
    private void sendReminder(String alarmTitle) throws IOException {
        LocalDate today = LocalDate.now();
        List<User> users = userRepository.findAll();

        for (User user : users) {
            LocalDateTime lastLoginTime = user.getLastLoginTime();
            boolean hasIncompleteTodos = todoRepository.existsByUidAndDueDateAndIsCompletedFalse(user.getUid(), today);

            switch (alarmTitle) {
                case "lunch" -> {
                    if ((lastLoginTime == null || lastLoginTime.isBefore(LocalDateTime.of(today, LocalTime.of(11, 00))) && hasIncompleteTodos)) {
                        sendNoonPushNotification(user);
                    }
                }
                case "dinner" -> {
                    if ((lastLoginTime == null || lastLoginTime.isBefore(LocalDateTime.of(today, LocalTime.of(17, 00))) && hasIncompleteTodos)) {
                        sendDinnerPushNotification(user);
                    }
                }
                case "night" -> {
                    if ((lastLoginTime == null || lastLoginTime.isBefore(LocalDateTime.of(today, LocalTime.of(22, 00))) && hasIncompleteTodos)) {
                        sendNightPushNotification(user);
                    }
                }
            }
        }
    }

    private void sendNoonPushNotification(User user) throws IOException {
        firebaseCloudMessageService.sendMessageTo(
                user.getFcmToken(),
                "주인님, 맛있는 점심 드실 시간입니다!",
                "오늘의 할 일이 등록되어 있습니다. 잊지 말고 확인해 주세요."
        );
    }

    private void sendDinnerPushNotification(User user) throws IOException {
        firebaseCloudMessageService.sendMessageTo(
                user.getFcmToken(),
                "주인님, 좋은 저녁 시간 보내세요!",
                "오늘의 할 일을 마치셨다면 체크 표시를 해주세요."
        );
    }

    private void sendNightPushNotification(User user) throws IOException {
        firebaseCloudMessageService.sendMessageTo(
                user.getFcmToken(),
                "주인님, 저를 잊으신 건 아니시겠죠?",
                "아직 완료하지 않으신 오늘의 할 일이 있습니다."
        );
    }


}

