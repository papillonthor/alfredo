package org.b104.alfredo.tts.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "user_requests")
public class UserRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "uid", nullable = false)
    private String uid;
    @Column(name = "request_date", nullable = false)
    private LocalDate requestDate;
    @Column(name = "request_count", nullable = false)
    private int requestCount;

    public UserRequest(String uid, LocalDate requestDate, int requestCount) {
        this.uid = uid;
        this.requestDate = requestDate;
        this.requestCount = requestCount;
    }
}
