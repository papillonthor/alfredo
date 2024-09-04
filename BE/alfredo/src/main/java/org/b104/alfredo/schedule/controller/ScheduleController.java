package org.b104.alfredo.schedule.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.schedule.request.ScheduleCreateDto;
import org.b104.alfredo.schedule.request.ScheduleUpdateDto;
import org.b104.alfredo.schedule.response.ScheduleDetailDto;
import org.b104.alfredo.schedule.response.ScheduleListDto;
import org.b104.alfredo.schedule.service.ScheduleService;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/schedule")
public class ScheduleController {

    private final ScheduleService scheduleService;
    private final UserService userService;

    // 저장
    @PostMapping("/save")
    public ResponseEntity<Schedule> createSchedule(@RequestHeader(value = "Authorization") String authHeader,
                                                   @RequestBody ScheduleCreateDto scheduleCreateDto) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            User user = userService.getUserByUid(uid);
            Schedule createdSchedule = scheduleService.create(scheduleCreateDto, user);
            return new ResponseEntity<>(createdSchedule, HttpStatus.CREATED);
        } catch (Exception e) {
            log.error("Failed to create schedule", e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    // 전체 조회
    @GetMapping("/list")
    public ResponseEntity<List<ScheduleListDto>> findAllSchedules(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            List<ScheduleListDto> schedules = scheduleService.findAllByUser(user);
            return new ResponseEntity<>(schedules, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Failed to read schedule list", e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    // 상세 조회
    @GetMapping("/detail/{id}")
    public ScheduleDetailDto getScheduleById(@PathVariable Long id) {
        return scheduleService.findScheduleById(id);
    }

    // 수정
    @PatchMapping("/detail/{id}")
    public ResponseEntity<Void> update(@PathVariable Long id, @RequestBody ScheduleUpdateDto scheduleUpdateDto) {
        scheduleService.updateSchedule(id, scheduleUpdateDto);
        return ResponseEntity.ok().build();
    }

    // 삭제
    @DeleteMapping("/detail/{id}")
    public Long deleteScheduleById(@PathVariable Long id) {
        scheduleService.deleteSchedule(id);
        return id;
    }

}
