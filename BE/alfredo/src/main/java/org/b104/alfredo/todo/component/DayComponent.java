package org.b104.alfredo.todo.component;

import lombok.RequiredArgsConstructor;
import org.b104.alfredo.todo.service.DayService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DayComponent {
    private final DayService dayService;

    @Scheduled(cron = "0 1 0 * * SUN")  // 매주 일요일 자정 1분에 실행
    public void weeklyDeletion() {

        dayService.deleteAllDays();  // 모든 'day' 데이터를 삭제
    }
}

