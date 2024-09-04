package org.b104.alfredo.firebase.service;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.b104.alfredo.firebase.domain.FcmMessage;
import org.b104.alfredo.jobs.FcmJob;
import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.schedule.repository.ScheduleRepository;
import org.b104.alfredo.schedule.request.ScheduleUpdateDto;
import org.b104.alfredo.schedule.service.ScheduleService;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.quartz.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.core.io.FileSystemResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.Date;

@Service
public class FCMAlarmService {

    @Value("${firebase.api.url}")
    private String API_URL;
    private final ObjectMapper objectMapper;

    private final UserRepository userRepository;
    private final ScheduleService scheduleService;
    private final ScheduleRepository scheduleRepository;
    private final Scheduler scheduler;

    @Autowired
    private ApplicationContext applicationContext; // ApplicationContext 주입

    @Value("${firebase.sdk}")
    private String firebaseConfigPath;

    @Autowired
    public FCMAlarmService(ObjectMapper objectMapper, UserRepository userRepository, ScheduleService scheduleService, ScheduleRepository scheduleRepository, Scheduler scheduler) {
        this.objectMapper = objectMapper;
        this.userRepository = userRepository;
        this.scheduleService = scheduleService;
        this.scheduleRepository = scheduleRepository;
        this.scheduler = scheduler;
    }

    // 메시지를 스케줄링하는 메소드
    public void scheduleMessage(String targetToken, String title, String body) throws SchedulerException {
        User user = userRepository.findByFcmToken(targetToken);

        String uniqueIdentifier = targetToken + "-" + System.currentTimeMillis(); // 고유 식별자 생성

        JobDetail jobDetail = JobBuilder.newJob(FcmJob.class)
                .withIdentity(uniqueIdentifier, "FCM-Messages") // 고유 식별자 사용
                .usingJobData("targetToken", targetToken)
                .usingJobData("title", title)
                .usingJobData("body", body)
                .build();

        scheduleService.updateJobUidForSchedule(user, title, uniqueIdentifier);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        LocalDateTime scheduleTime = LocalDateTime.parse(body, formatter);
        Date startAt = Date.from(scheduleTime.atZone(ZoneId.systemDefault()).toInstant());

        Trigger trigger = TriggerBuilder.newTrigger()
                .withIdentity("trigger-" + uniqueIdentifier, "FCM-Messages")
                .startAt(startAt)
                .build();

        scheduler.scheduleJob(jobDetail, trigger);
    }

    // 메시지를 스케줄링하는 메소드
    public void upscheduleMessage(String targetToken, String title, String body, Long scheduleId) throws SchedulerException {
        Schedule schedule = scheduleRepository.findByScheduleId(scheduleId);

        if (!schedule.getStartAlarm()) {
            // 알람 설정이 비활성화되어 있으면 작업을 수행하지 않습니다.
            return;
        }
        // 고유 식별자 생성
        String uniqueIdentifier = targetToken + "-" + System.currentTimeMillis();

        // 새 JobDetail 생성
        JobDetail jobDetail = JobBuilder.newJob(FcmJob.class)
                .withIdentity(uniqueIdentifier, "FCM-Messages")
                .usingJobData("targetToken", targetToken)
                .usingJobData("title", title)
                .usingJobData("body", body)
                .build();

        if (schedule != null) {
            // schedule의 jobUid 업데이트
            schedule.updateJobUid(uniqueIdentifier);
            scheduleRepository.save(schedule); // 변경사항 저장
        } else {
            throw new SchedulerException("Schedule not found with id: " + scheduleId);
        }

        // 시간 파싱을 위한 포매터
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        LocalDateTime scheduleTime = LocalDateTime.parse(body, formatter); // LocalDateTime으로 파싱 (예외 처리 필요)
        Date startAt = Date.from(scheduleTime.atZone(ZoneId.systemDefault()).toInstant());

        // Trigger 생성 및 스케쥴링
        Trigger trigger = TriggerBuilder.newTrigger()
                .withIdentity("trigger-" + uniqueIdentifier, "FCM-Messages")
                .startAt(startAt)
                .build();

        // 스케쥴러에 Job과 Trigger 등록
        scheduler.scheduleJob(jobDetail, trigger);
    }

    // 실제 FCM 메시지를 구성하고 전송하는 메소드
    public void sendMessageTo(String targetToken, String title, String body) throws IOException {
        String message = makeMessage(targetToken, title, body);

        OkHttpClient client = new OkHttpClient();
        MediaType mediaType = MediaType.get("application/json; charset=utf-8");
        RequestBody requestBody = RequestBody.create(message, mediaType);

        Request request = new Request.Builder()
                .url(API_URL)
                .post(requestBody)
                .addHeader("Authorization", "Bearer " + getAccessToken())
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();

        try (Response response = client.newCall(request).execute()) {
            System.out.println(response.isSuccessful() ? response.body().string() : "Failed with status: " + response.code());
        }
    }

    // FCM 메시지 형식을 생성하는 메소드
    private String makeMessage(String targetToken, String title, String body) throws JsonParseException, IOException {
        FcmMessage fcmMessage = FcmMessage.builder()
                .message(FcmMessage.Message.builder()
                        .token(targetToken)
                        .notification(FcmMessage.Notification.builder()
                                .title("주인님, " + title + " 일정이 있습니다")
                                .body("좋은 시간 보내세요!")
                                .image(null)
                                .build())
                        .build())
                .validateOnly(false)
                .build();

        return objectMapper.writeValueAsString(fcmMessage);
    }

    // 실제 FCM 메시지를 구성하고 전송하는 메소드
    public void sendMessageToAchieve(String targetToken, String title, String body) throws IOException {
        String message = makeMessageAchieve(targetToken, title, body);

        OkHttpClient client = new OkHttpClient();
        MediaType mediaType = MediaType.get("application/json; charset=utf-8");
        RequestBody requestBody = RequestBody.create(message, mediaType);

        Request request = new Request.Builder()
                .url(API_URL)
                .post(requestBody)
                .addHeader("Authorization", "Bearer " + getAccessToken())
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();

        try (Response response = client.newCall(request).execute()) {
            System.out.println(response.isSuccessful() ? response.body().string() : "Failed with status: " + response.code());
        }
    }

    // FCM 메시지 형식을 생성하는 메소드
    private String makeMessageAchieve(String targetToken, String title, String body) throws JsonParseException, IOException {
        FcmMessage fcmMessage = FcmMessage.builder()
                .message(FcmMessage.Message.builder()
                        .token(targetToken)
                        .notification(FcmMessage.Notification.builder()
                                .title(body + " 업적을 달성하셨습니다!")
                                .body("축하드려요, 다른 업적도 도전해보세요!")
                                .image(null)
                                .build())
                        .build())
                .validateOnly(false)
                .build();

        return objectMapper.writeValueAsString(fcmMessage);
    }

    // Google API 토큰을 얻는 메소드
    private String getAccessToken() throws IOException {
        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new FileSystemResource(firebaseConfigPath).getInputStream())
                .createScoped(Collections.singletonList("https://www.googleapis.com/auth/cloud-platform"));

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    // 알림 삭제 서비스
    @Transactional
    public void deleteAlarm(Long id) throws SchedulerException {
        // id로 일정 찾기
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 스케줄이 없습니다. id=" + id));

        // jobUid가 null이거나 빈 문자열인지 확인
        if (schedule.getJobUid() == null || schedule.getJobUid().isEmpty()) {
            System.out.println("No jobUid found for schedule with id: " + id);
            return; // jobUid가 없으면 함수 종료
        }

        // 일정의 JobUid로 job의 고유 식별자 찾기
        JobKey jobKey = new JobKey(schedule.getJobUid(), "FCM-Messages");
        if (scheduler.checkExists(jobKey)) {
            scheduler.deleteJob(jobKey);
            System.out.println("in service alarm delete");
        } else {
            System.out.println("Job does not exist or already deleted: " + jobKey);
        }
    }
}
