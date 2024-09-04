package org.b104.alfredo.todo.request;


import lombok.*;
import org.b104.alfredo.todo.domain.Todo;
import java.time.LocalDate;
import java.util.Optional;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TodoUpdateSubDto {
    private Long id;
    private String subIndex; // 추가 인덱스, 필요에 따라 제외 가능
    private String todoTitle; // 할 일 제목
    private String todoContent; // 할 일 내용
    private LocalDate dueDate;
    private Integer spentTime; // 소요 시간, 분 단위
    private String url; // 관련 URL, 필요에 따라 제외 가능
    private String place; // 할 일 장소, 필요에 따라 제외 가능
}