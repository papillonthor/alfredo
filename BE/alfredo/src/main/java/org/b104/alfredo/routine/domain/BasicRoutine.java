package org.b104.alfredo.routine.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalTime;
import java.util.HashSet;
import java.util.Set;
//TODO memo는 없어도 될듯
@Entity
@Table(name = "basic_routine")
@Getter
@Setter
public class BasicRoutine {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="basic_routine_id")
    private Long id;

    private String basicRoutineTitle;
    private LocalTime startTime;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "basic_routine_days", joinColumns = @JoinColumn(name = "basic_routine_id"))
    private Set<String> days = new HashSet<>();

    private String alarmSound;

    @Column(nullable = true)
    private String memo;
}
