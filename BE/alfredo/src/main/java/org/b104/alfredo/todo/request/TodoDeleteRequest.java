package org.b104.alfredo.todo.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class TodoDeleteRequest {
    private String subIndex;
    private LocalDate dueDate;
}
