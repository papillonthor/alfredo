package org.b104.alfredo.todo.component;

import lombok.RequiredArgsConstructor;
import org.b104.alfredo.todo.service.UpdateService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class RefreshComponent {
    private final UpdateService updateService;

    @Scheduled(cron = "0 0 5 1 * *")
    void migration(){
        updateService.transferOldTodos();
    }
}


