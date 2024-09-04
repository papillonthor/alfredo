package org.b104.alfredo.todo.response;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.b104.alfredo.todo.domain.Todo;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TodoListDto {
    private Long id;
    private String subIndex; // 추가 인덱스, 필요에 따라 제외 가능
    private String todoTitle; // 할 일 제목
    private String todoContent; // 할 일 내용
    private LocalDate dueDate; // 마감일
    private Integer spentTime; // 소요 시간, 분 단위
    private Boolean isCompleted; // 완료 여부
    private String url; // 관련 URL, 필요에 따라 제외 가능
    private String place; // 할 일 장소, 필요에 따라 제외 가능
    private String uid; // 할 일 소유자 uid

    public TodoListDto(Todo todo) {
        this.id = todo.getId();
        this.subIndex = todo.getSubIndex();
        this.todoTitle = todo.getTodoTitle();
        this.todoContent = todo.getTodoContent();
        this.dueDate = todo.getDueDate();
        this.spentTime = todo.getSpentTime();
        this.isCompleted = todo.getIsCompleted();
        this.url = todo.getUrl();
        this.place = todo.getPlace();
        this.uid = todo.getUid();
    }
}
