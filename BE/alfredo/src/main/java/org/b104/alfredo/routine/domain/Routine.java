package org.b104.alfredo.routine.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.b104.alfredo.user.Domain.User;

import java.time.LocalTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "routine")
@Getter @Setter
public class Routine {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="routine_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name="basic_routine_id",nullable = true)
    private BasicRoutine basicRoutine;

    @Column(name="routine_title",nullable = false)
    private String routineTitle;

    @Column(name="start_time")
    private LocalTime startTime;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "routine_days", joinColumns = @JoinColumn(name = "routine_id"))
    @Column(name="days",nullable = false)
    private Set<String> days = new HashSet<>();

    @Column(name="alarm_sound")
    private String alarmSound;

    @Column(nullable = true)
    private String memo;

}
