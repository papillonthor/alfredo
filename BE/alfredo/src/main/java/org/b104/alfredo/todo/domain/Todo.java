package org.b104.alfredo.todo.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Todo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String subIndex;
    @Column(nullable = false, length = 255)
    private String todoTitle;
    private String todoContent;
    private LocalDate dueDate;
    private Integer spentTime;
    private Boolean isCompleted;
    private String url;
    private String place;
    @Column(nullable = false)
    private String uid; // 직접 UID 저장

    @Builder
    public Todo(String subIndex, String todoTitle, String todoContent, LocalDate dueDate, Integer spentTime, Boolean isCompleted, String url, String place, String uid) {
        this.subIndex = subIndex;
        this.todoTitle = todoTitle;
        this.todoContent = todoContent;
        this.dueDate = dueDate != null ? dueDate : LocalDate.now();
        this.spentTime = spentTime;
        this.isCompleted = isCompleted;
        this.url = url;
        this.place = place;
        this.uid = uid;
    }
}
