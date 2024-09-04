package org.b104.alfredo.achieve.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.achieve.domain.Achieve;
import org.b104.alfredo.achieve.response.AchieveDetailDto;
import org.b104.alfredo.achieve.service.AchieveService;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/achieve")
public class AchieveController {
    private final AchieveService achieveService;
    private final UserService userService;

    // 사용자 ID를 기반으로 업적 생성
    @PostMapping("/create")
    public ResponseEntity<Object> createAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            AchieveDetailDto existingAchieve = achieveService.getAchieveDetail(user);

            if (existingAchieve != null) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Achieve already exists for this user.");
            }

            Achieve newAchieve = achieveService.createAchieve(user);
            return ResponseEntity.ok(new AchieveDetailDto(newAchieve));
        } catch (Exception e) {
            log.error("Failed to create achieve", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 조회
    @GetMapping("/detail")
    public ResponseEntity<AchieveDetailDto> findAchieveDetail(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            AchieveDetailDto achieveDetail = achieveService.getAchieveDetail(user);

            return new ResponseEntity<>(achieveDetail, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error fetching achieve details", e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
    // 첫번째 업적 - 총 수행시간
    @PostMapping("/one")
    public ResponseEntity<String> checkTimeAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            boolean isUpdated = achieveService.checkTimeTodo(uid);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    // 두번째 업적 - 첫 ical 등록
    @PostMapping("/two")
    public ResponseEntity<String> checkFirstIcal(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            User user = userService.getUserByUid(uid);

            boolean isUpdated = achieveService.checkFirstIcal(user);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    // 3번째 업적 - day 풀 참가
    @PostMapping("/three")
    public ResponseEntity<String> checkWeekendAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            boolean isUpdated = achieveService.checkWeekendTodo(uid);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    // 4번째 업적 - 총 루틴의 갯수
    @PostMapping("/four")
    public ResponseEntity<String> checkRoutineAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            User user = userService.getUserByUid(uid);

            boolean isUpdated = achieveService.checkTotalRoutine(user);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 5번째 업적 - 총 투두 갯수
    @PostMapping("/five")
    public ResponseEntity<String> checkTodoAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            boolean isUpdated = achieveService.checkTotalTodo(uid);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 6번째 업적 - 총 일정의 갯수
    @PostMapping("/six")
    public ResponseEntity<String> checkSchedulesAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);

            boolean isUpdated = achieveService.checkTotalSchedule(user);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 7번째 업적 - 1주일에 6일 연속 출석
    @PostMapping("/seven")
    public ResponseEntity<String> checkChainAtt(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);

            boolean isUpdated = achieveService.checkChainAttendance(user);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 8번째 업적 - 총 출석 일수 6일
    @PostMapping("/eight")
    public ResponseEntity<String> checkTotalAtt(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);

            boolean isUpdated = achieveService.checkTotalAttendance(user);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 9번째 업적 - 생일인 경우
    @PostMapping("/nine")
    public ResponseEntity<String> checkBirthAchieve(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);

            boolean isUpdated = achieveService.checkBirth(user);
            if (isUpdated) {
                return ResponseEntity.ok("Achievement status updated successfully.");
            } else {
                return ResponseEntity.ok("Achievement not updated.");
            }
        } catch (Exception e) {
            log.error("Failed to update achievement status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


}