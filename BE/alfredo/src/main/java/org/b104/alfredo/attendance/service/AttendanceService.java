package org.b104.alfredo.attendance.service;

import org.b104.alfredo.attendance.domain.Attendance;
import org.b104.alfredo.attendance.repository.AttendanceRepository;
import org.b104.alfredo.attendance.response.AttendanceDateDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface AttendanceService {
    public void checkAttendance(String uid);

    public List<AttendanceDateDto> getAttendanceForCurrentWeek(String uid);

    public int getTotalAttendanceDaysForWeek(String uid);

    public int getConsecutiveAttendanceDaysForWeek(String uid);


    public int getTotalAttendanceDays(String uid);
}
