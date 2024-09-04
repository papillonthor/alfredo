package org.b104.alfredo.todo.service;

import org.b104.alfredo.todo.domain.Day;
import org.b104.alfredo.todo.repository.DayRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

// DayService.java
@Service
public class DayService {
    private final DayRepository dayRepository;

    public DayService(DayRepository dayRepository) {
        this.dayRepository = dayRepository;
    }

    public Optional<Day> findByUidAndDayIndex(String uid, int dayIndex) {
        return dayRepository.findByUidAndDayIndex(uid, dayIndex);
    }

    // 매주 일요일 자정 1분에 실행되는 메소드
    @Transactional
    public void deleteAllDays() {
        dayRepository.deleteAll();  // 모든 데이터를 삭제
    }
}

