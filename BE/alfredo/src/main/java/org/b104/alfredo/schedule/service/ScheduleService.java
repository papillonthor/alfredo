package org.b104.alfredo.schedule.service;

import lombok.RequiredArgsConstructor;
import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.schedule.repository.ScheduleRepository;
import org.b104.alfredo.schedule.request.ScheduleCreateDto;
import org.b104.alfredo.schedule.request.ScheduleUpdateDto;
import org.b104.alfredo.schedule.response.ScheduleDetailDto;
import org.b104.alfredo.schedule.response.ScheduleListDto;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final UserRepository userRepository;

    // 생성
    @Transactional
    public Schedule create(ScheduleCreateDto scheduleCreateDto, User user){
        Schedule schedule = Schedule.builder()
                .userId(user)
                .scheduleTitle(scheduleCreateDto.getScheduleTitle())
                .startDate(scheduleCreateDto.getStartDate())
                .endDate(scheduleCreateDto.getEndDate())
                .startAlarm(scheduleCreateDto.getStartAlarm())
                .alarmTime(scheduleCreateDto.getAlarmTime())
                .alarmDate(scheduleCreateDto.getAlarmDate())
                .jobUid(scheduleCreateDto.getJobUid())
                .place(scheduleCreateDto.getPlace())
                .startTime(scheduleCreateDto.getStartTime())
                .endTime(scheduleCreateDto.getEndTime())
                .withTime(scheduleCreateDto.getWithTime())
                .build();
        return scheduleRepository.save(schedule);
    }
    // 조회
    @Transactional
    public List<ScheduleListDto> findAllByUser(User user) {
        List<Schedule> schedules = scheduleRepository.findByUserId(user);
        return schedules.stream()
                .map(ScheduleListDto::new)
                .collect(Collectors.toList());
    }
    // 상세조회
    @Transactional
    public ScheduleDetailDto findScheduleById(Long id) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 스케줄이 없습니다. id=" + id));
        return new ScheduleDetailDto(schedule);
    }
    // 삭제
    @Transactional
    public void deleteSchedule(Long id) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 스케줄이 없습니다. id=" + id));
        scheduleRepository.delete(schedule);
    }
    // 수정
    @Transactional
    public void updateSchedule(Long id, ScheduleUpdateDto dto) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Schedule not found for id=" + id));

        if (dto.getScheduleTitle() != null) schedule.updateScheduleTitle(dto.getScheduleTitle());
        if (dto.getStartDate() != null) schedule.updateStartDate(dto.getStartDate());
        if (dto.getEndDate() != null) schedule.updateEndDate(dto.getEndDate());
        if (dto.getStartAlarm() != null) schedule.updateStartAlarm(dto.getStartAlarm());
        if (dto.getAlarmTime() != null) schedule.updateAlarmTime(dto.getAlarmTime());

        if (dto.getAlarmDate() != null) schedule.updateAlarmDate(dto.getAlarmDate());

        if (dto.getJobUid() != null) schedule.updateJobUid(dto.getJobUid());

        if (dto.getPlace() != null) schedule.updatePlace(dto.getPlace());
        if (dto.getStartTime() != null) schedule.updateStartTime(dto.getStartTime());
        if (dto.getEndTime() != null) schedule.updateEndTime(dto.getEndTime());
        if (dto.getWithTime() != null) schedule.updateWithTime(dto.getWithTime());
    }

    @Transactional
    public void updateJobUidForSchedule(User user, String scheduleTitle, String jobUid) {
        List<Schedule> schedules = scheduleRepository.findByUserIdAndScheduleTitle(user, scheduleTitle);
        if (!schedules.isEmpty()) {
            Schedule schedule = schedules.get(0); // 여러 개 있을 경우 첫 번째 일정을 사용
            schedule.updateJobUid(jobUid);
            scheduleRepository.save(schedule);
        } else {
            throw new IllegalArgumentException("No schedule found for the given user and title.");
        }
    }



}
