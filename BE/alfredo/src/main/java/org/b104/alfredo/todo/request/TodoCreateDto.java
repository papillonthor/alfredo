package org.b104.alfredo.todo.request;

import com.google.firebase.database.annotations.NotNull;
import lombok.*;
import java.time.LocalDate;


@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TodoCreateDto {
    private String subIndex;
    @NotNull
    private String todoTitle;
    private String todoContent;
    @NotNull
    private LocalDate dueDate;
    private Integer spentTime;
    private Boolean isCompleted;
    private String url;
    private String place;
    private String uid; // 사용자의 UID만 참조
}
