package org.b104.alfredo.schedule.component;

import lombok.RequiredArgsConstructor;
import org.b104.alfredo.schedule.service.TransferScheduleService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TransferScheduleComponent {
    private final TransferScheduleService transferScheduleService;

    @Scheduled(cron = "0 0 5 1 * *")
    void migration(){
        transferScheduleService.TransferSchedule();
    }
}
