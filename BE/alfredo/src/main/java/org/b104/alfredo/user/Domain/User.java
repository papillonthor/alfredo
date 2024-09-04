package org.b104.alfredo.user.Domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.b104.alfredo.todo.domain.Todo;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column
    private String nickname;

    @Column(nullable = false)
    private String uid;

    @Column
    private Date birth;

    @Column
    private List<Long> answer;

    @Column
    private String googleCalendarUrl;

    @Column(nullable = false, unique = true)
    private LocalDateTime registeredAt;

    @Column(nullable = true)
    private String fcmToken;

    @JsonIgnore
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private Survey survey;

    //sj 추가 시작
    private LocalDateTime lastLoginTime;
    //sj 추가 끝

    @PrePersist
    protected void onRegister() {
        this.registeredAt = LocalDateTime.now();
    }

}
