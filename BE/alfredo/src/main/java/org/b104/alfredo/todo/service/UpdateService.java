package org.b104.alfredo.todo.service;

import lombok.RequiredArgsConstructor;
import org.b104.alfredo.todo.domain.OldTodo;
import org.b104.alfredo.todo.domain.Todo;
import org.b104.alfredo.todo.repository.OldTodoRepository;
import org.b104.alfredo.todo.repository.TodoRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@RequiredArgsConstructor
@Service
public class UpdateService {
    private final TodoRepository todoRepository;
    private final OldTodoRepository oldTodoRepository;


    public void transferOldTodos() {
        LocalDate twoMonthsAgo = LocalDate.now().minusMonths(4);
        LocalDateTime now = LocalDateTime.now();
        System.out.println("Current Local Date and Time: " + now);
        // 두 달 이상 된 Todos 가져오기
        List<Todo> oldTodos = todoRepository.findByDueDateBefore(twoMonthsAgo);

        // Todos를 OldTodo로 옮기기
        for (Todo todo : oldTodos) {
            OldTodo oldTodo = new OldTodo(
                    todo.getId(),
                    todo.getSubIndex(),
                    todo.getTodoTitle(),
                    todo.getTodoContent(),
                    todo.getDueDate(),
                    todo.getSpentTime(),
                    todo.getIsCompleted(),
                    todo.getUrl(),
                    todo.getPlace(),
                    todo.getUid()
            );
            oldTodoRepository.save(oldTodo);
        }

        // Todo에서 삭제
        todoRepository.deleteAll(oldTodos);
    }
}
