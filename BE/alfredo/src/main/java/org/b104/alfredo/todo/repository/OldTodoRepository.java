package org.b104.alfredo.todo.repository;

import org.b104.alfredo.todo.domain.OldTodo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OldTodoRepository extends JpaRepository<OldTodo, Long> {}
