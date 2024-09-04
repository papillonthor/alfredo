package org.b104.alfredo.item.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Column;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "user_item_inventory")
public class UserItemInventory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @Column(nullable = false, unique = true)
    private String uid;

    @Column(nullable = false)
    private boolean background1 = true;

    @Column(nullable = false)
    private boolean background2 = false;

    @Column(nullable = false)
    private boolean background3 = false;

    @Column(nullable = false)
    private boolean character1 = true;

    @Column(nullable = false)
    private boolean character2 = false;

    @Column(nullable = false)
    private boolean character3 = false;
}
