package org.b104.alfredo.todo.repository;

import org.b104.alfredo.todo.domain.Todo;
import org.b104.alfredo.todo.request.TodoCreateDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface TodoRepository extends JpaRepository<Todo, Long> {
    List<Todo> findAllByUid(String uid); // uid로 할 일 목록 조회

    List<Todo> findByDueDateBefore(LocalDate date);

    @Query("SELECT t FROM Todo t WHERE t.uid = :uid AND t.dueDate = :date")
    List<Todo> findAllByUidAndDueDate(@Param("uid") String uid, @Param("date") LocalDate date);

    List<Todo> findBySubIndex(String subIndex);

    @Query("SELECT t FROM Todo t WHERE t.subIndex = :subIndex AND t.dueDate >= :date")
    List<Todo> findBySubIndexAndDueDateAfterOrEqual(@Param("subIndex") String subIndex, @Param("date") LocalDate date);

//    @Query("SELECT t FROM Todo t WHERE t.subIndex = :subIndex AND t.dueDate >= :date")
//    List<Todo> findBySubIndexAndDueDateAfterOrEqual(@Param("subIndex") String subIndex, @Param("date") LocalDate date);

    boolean existsByUidAndDueDateAndIsCompletedFalse(String uid, LocalDate dueDate);
    long countByUid(String uid);

}

