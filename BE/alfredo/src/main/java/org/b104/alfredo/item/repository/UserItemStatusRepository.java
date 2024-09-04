package org.b104.alfredo.item.repository;

import org.b104.alfredo.item.domain.UserItemStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserItemStatusRepository extends JpaRepository<UserItemStatus, Long> {
    UserItemStatus findByUid(String uid);

}
