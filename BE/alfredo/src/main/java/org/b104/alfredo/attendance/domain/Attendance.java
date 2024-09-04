package org.b104.alfredo.attendance.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.b104.alfredo.user.Domain.User;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Getter @Setter
public class Attendance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private LocalDateTime loginTime;
}
