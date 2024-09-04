package org.b104.alfredo.todo.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.b104.alfredo.achieve.service.AchieveService;
import org.b104.alfredo.todo.domain.Day;
import org.b104.alfredo.todo.domain.Todo;
import org.b104.alfredo.todo.request.TodoCreateDto;
import org.b104.alfredo.todo.request.TodoDeleteRequest;
import org.b104.alfredo.todo.request.TodoUpdateDto;
import org.b104.alfredo.todo.request.TodoUpdateSubDto;
import org.b104.alfredo.todo.response.TodoDetailDto;
import org.b104.alfredo.todo.response.TodoListDto;
import org.b104.alfredo.todo.service.DayService;
import org.b104.alfredo.todo.service.TodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.time.LocalDate;
import java.util.*;


@CrossOrigin(origins = "*", allowedHeaders = "*")

@RestController
@RequestMapping("/api/todo")
public class TodoController {
    private static final Logger log = LoggerFactory.getLogger(TodoController.class);
    @Autowired
    private final TodoService todoService;
    private final DayService dayService;
    private final AchieveService achieveService;

    @Autowired
    public TodoController(TodoService todoService, DayService dayService, AchieveService achieveService) {
        this.todoService = todoService;
        this.dayService = dayService;
        this.achieveService = achieveService;
    }


    @GetMapping
    public ResponseEntity<?> getTodosByUser(@RequestHeader(value = "Authorization") String authHeader) {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            List<TodoListDto> todos = todoService.findAllTodosByUid(uid);
            if (todos != null) {
                return ResponseEntity.ok(todos);
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No todos found for this user");
            }
        } catch (Exception e) {
            log.error("Error verifying token: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
        }
    }

    //날짜별 조회
    @PostMapping("/bydate")
    public ResponseEntity<List<TodoListDto>> getTodosByDate(@RequestBody Map<String, String> requestBody, @RequestHeader(value = "Authorization") String authHeader) {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            String date = requestBody.get("date");
            LocalDate parsedDate = LocalDate.parse(date); // 문자열을 LocalDate로 변환
            List<TodoListDto> todos = todoService.findAllTodosByUidAndDate(uid, parsedDate);

            return ResponseEntity.ok(todos);
        } catch (Exception e) {
            log.error("Error verifying token: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Collections.emptyList()); // 빈 목록 반환
        }
    }




    @PostMapping
    public ResponseEntity<?> createTodos(@RequestHeader(value = "Authorization") String authHeader,
                                         @RequestBody List<TodoCreateDto> todoCreateDtos) {
        // 토큰에서 UID 추출
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            if (uid != null) {
                // 각 TodoCreateDto를 순회하며 이를 Todo로 변환하고 저장
                for (TodoCreateDto todoCreateDto : todoCreateDtos) {
                    todoService.createTodo(todoCreateDto, uid);
                }

                return ResponseEntity.ok("Todos created successfully");
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            }
        } catch (Exception e) {
            log.error("Token verification failed: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
        }
    }


    @GetMapping("/{id}")
    public ResponseEntity<TodoDetailDto> getTodoById(@PathVariable Long id) {
        TodoDetailDto todoDetailDto = todoService.findTodoById(id);
        if (todoDetailDto != null) {
            return ResponseEntity.ok(todoDetailDto);
        }
        return ResponseEntity.notFound().build();
    }


    @PatchMapping("/{id}")
    public ResponseEntity<String> updateTodo(@PathVariable Long id, @RequestBody TodoUpdateDto todoUpdateDto) {
        try {
            // Todo 업데이트
            todoService.updateTodo(id, todoUpdateDto);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            // Todo를 찾지 못한 경우
            log.error("Todo not found: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Todo not found");
        } catch (Exception e) {
            // 그 외의 예외 발생 시
            log.error("Error updating todo: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Internal server error");
        }
    }



    @GetMapping("/dayresult")
    public ResponseEntity<Map<Integer, Integer>> getDayCounts(@RequestHeader(value = "Authorization") String authHeader) {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        try {
            // Firebase 토큰 검증
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            // 해당 사용자의 모든 요일에 대한 값을 조회
            Map<Integer, Integer> dayCounts = new HashMap<>();
            for (int i = 0; i < 7; i++) {
                Optional<Day> dayOptional = dayService.findByUidAndDayIndex(uid, i);
                int count = dayOptional.map(Day::getCount).orElse(0);
                dayCounts.put(i, count);

                // 토요일인 경우 3번째 업적 체크 메서드 호출
                if (i == 6) {
                    achieveService.checkWeekendTodo(uid);
                }
            }

            // 만약 해당 uid에 대한 요일 데이터가 전혀 없는 경우, 일괄적으로 0으로 초기화
            if (dayCounts.isEmpty()) {
                for (int i = 0; i < 7; i++) {
                    dayCounts.put(i, 0);
                }
            }

            return ResponseEntity.ok(dayCounts);
        } catch (FirebaseAuthException e) {
            log.error("Firebase Auth error: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
        } catch (Exception e) {
            log.error("Error retrieving day counts: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTodo(@PathVariable Long id) {
        todoService.deleteTodo(id);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/updateBySubIndex")
    public ResponseEntity<Void> updateTodosBySubIndexAndDueDate(@RequestBody TodoUpdateSubDto updateDto) {
        try {
            todoService.updateTodosBySubIndexAndDate(updateDto); // 서비스에 `updateDto` 전달

            return ResponseEntity.noContent().build(); // 성공 시 No Content 응답 반환
        } catch (Exception e) {
            log.error("Error updating todos with subIndex and date: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // 실패 시 오류 응답 반환
        }
    }

    @DeleteMapping("/deleteBySubIndex")
    public ResponseEntity<Void> deleteTodosBySubIndexAndDueDate(
            @RequestParam("subIndex") String subIndex,
            @RequestParam("dueDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dueDate) {
        try {
            todoService.deleteTodosBySubIndexAndDueDate(subIndex, dueDate);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            log.error("Error deleting todos with subIndex '{}' and dueDate '{}': {}", subIndex, dueDate, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

}
