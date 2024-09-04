package org.b104.alfredo.item.repository;

import org.b104.alfredo.item.domain.UserItemInventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserItemInventoryRepository extends JpaRepository<UserItemInventory, Long> {
    UserItemInventory findByUid(String uid);
}
