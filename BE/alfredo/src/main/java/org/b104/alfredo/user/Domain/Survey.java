package org.b104.alfredo.user.Domain;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "survey")
public class Survey {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long surveyId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId", referencedColumnName = "userId")
    private User user;

    @Column
    private Integer question1;

    @Column
    private Integer question2;

    @Column
    private Integer question3;

    @Column
    private Integer question4;

    @Column
    private Integer question5;
}
