package org.b104.alfredo.todo.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.*;

/**
 * Represents a daily count of completed tasks for a given user.
 */
@Entity
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Day {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String uid;
    private int dayIndex;  // Day of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
    private int count;  // Count of tasks completed on the specific day
}

