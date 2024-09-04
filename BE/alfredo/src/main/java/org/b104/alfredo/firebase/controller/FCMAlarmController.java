package org.b104.alfredo.firebase.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.firebase.request.FCMAlarmDto;
import org.b104.alfredo.firebase.service.FCMAlarmService;
import org.b104.alfredo.schedule.request.ScheduleUpdateDto;
import org.quartz.SchedulerException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/alarm")
public class FCMAlarmController {

    private final FCMAlarmService fcmAlarmService;

    // POST 요청을 통해 FCM 메시지를 스케줄링합니다.
    @PostMapping("/send")
    public ResponseEntity<String> pushMessage(@RequestBody FCMAlarmDto requestDTO) {
        try {
            // FCMAlarmService의 scheduleMessage 메소드를 호출하여 메시지 스케줄링
            fcmAlarmService.scheduleMessage(
                    requestDTO.getTargetToken(),
                    requestDTO.getTitle(),
                    requestDTO.getBody()
            );
            System.out.println("send Alarm");
            return ResponseEntity.ok("Message scheduled successfully");
        } catch (Exception e) {
            log.error("Failed to schedule message", e);
            return ResponseEntity.internalServerError().body("Failed to schedule message: " + e.getMessage());
        }
    }
    // 알림 수정 - 수정시 알림 삭제후 재 생성
    @PostMapping("update/{id}")
    public ResponseEntity<?> updateAlarm(@PathVariable Long id, @RequestBody FCMAlarmDto requestDTO) {
        try {
            fcmAlarmService.deleteAlarm(id);

            fcmAlarmService.upscheduleMessage(
                    requestDTO.getTargetToken(),
                    requestDTO.getTitle(),
                    requestDTO.getBody(),
                    id
            );
            System.out.println("update Alarm");
            return ResponseEntity.ok().build();
        } catch (SchedulerException e) {
            return ResponseEntity.internalServerError().body("Scheduler error: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Invalid request: " + e.getMessage());
        }
    }

    // 알림 삭제
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteAlarm(@PathVariable Long id) {
        try {
            fcmAlarmService.deleteAlarm(id);
            System.out.println("delete Alarm");
            return ResponseEntity.ok().build();
        } catch (SchedulerException e) {
            return ResponseEntity.internalServerError().body("Scheduler error: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Invalid request: " + e.getMessage());
        }
    }


}

