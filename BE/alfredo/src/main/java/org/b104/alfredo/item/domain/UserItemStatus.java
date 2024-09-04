package org.b104.alfredo.item.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "user_item_status")
public class UserItemStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String uid;

    @Column(nullable = false)
    private Integer background = 1;

    @Column(nullable = false)
    private Integer characterType = 1;
}
