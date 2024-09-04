package org.b104.alfredo.attendance.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import org.b104.alfredo.attendance.domain.Attendance;
import org.b104.alfredo.attendance.response.AttendanceDateDto;
import org.b104.alfredo.attendance.service.AttendanceService;
import org.b104.alfredo.routine.controller.RoutineController;
import org.b104.alfredo.routine.repository.BasicRoutineRepository;
import org.b104.alfredo.user.Domain.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;
    private final Logger log = LoggerFactory.getLogger(RoutineController.class);
    @PostMapping("/check")
    public ResponseEntity<Void> checkAttendance(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        attendanceService.checkAttendance(uid);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/week/history")
    public ResponseEntity<List<AttendanceDateDto>> getAttendanceForCurrentWeek(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        List<AttendanceDateDto> attendances = attendanceService.getAttendanceForCurrentWeek(uid);
        return ResponseEntity.ok(attendances);
    }

    @GetMapping("/week/count")
    public ResponseEntity<Integer> getTotalAttendanceDaysForWeek(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();

        int totalDays = attendanceService.getTotalAttendanceDaysForWeek(uid);
        return ResponseEntity.ok(totalDays);
    }

    @GetMapping("/week/consecutive")
    public ResponseEntity<Integer> getConsecutiveAttendanceDays(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        int streak = attendanceService.getConsecutiveAttendanceDaysForWeek(uid);
        return ResponseEntity.ok(streak);
    }
    @GetMapping("total/count")
    public ResponseEntity<Integer> getTotalAttendanceDays(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        int totalDays = attendanceService.getTotalAttendanceDays(uid);
        return ResponseEntity.ok(totalDays);
    }

}
