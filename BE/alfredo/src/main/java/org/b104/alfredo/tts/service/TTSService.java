package org.b104.alfredo.tts.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.schedule.domain.Schedule;
import org.b104.alfredo.schedule.repository.ScheduleRepository;
import org.b104.alfredo.todo.domain.Todo;
import org.b104.alfredo.todo.repository.TodoRepository;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.b104.alfredo.tts.component.OpenAICredentials;
import org.b104.alfredo.tts.domain.UserRequest;
import org.b104.alfredo.tts.repository.UserRequestRepository;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@Service
@Slf4j
public class TTSService {

    private final TodoRepository todoRepository;
    private final UserRepository userRepository;
    private final ScheduleRepository scheduleRepository;
    private final UserRequestRepository userRequestRepository;
    private final WebClient webClient;
    private final OpenAICredentials openAICredentials;

    public TTSService(TodoRepository todoRepository, UserRepository userRepository, ScheduleRepository scheduleRepository, UserRequestRepository userRequestRepository, WebClient.Builder webClientBuilder, OpenAICredentials openAICredentials) {
        this.todoRepository = todoRepository;
        this.userRepository = userRepository;
        this.scheduleRepository = scheduleRepository;
        this.userRequestRepository = userRequestRepository;
        this.webClient = webClientBuilder.baseUrl(openAICredentials.getApiUrl()).build();
        this.openAICredentials = openAICredentials;
    }

    public boolean checkLimit(String authHeader) throws FirebaseAuthException{
        LocalDate today = LocalDate.now();
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        log.info(uid);
        User user = userRepository.findByUid(uid).orElse(null);
        UserRequest userRequest = userRequestRepository.findByUidAndRequestDate(user.getUid(), today)
                .orElse(new UserRequest(user.getUid(), today, 0));

        if (userRequest.getRequestCount() >= 20) {
            return false;
        } else {
            userRequest.setRequestCount(userRequest.getRequestCount() + 1);
            userRequestRepository.save(userRequest);
            return true;
        }
    }

    public String getTodayList(String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        log.info(uid);
        User user = userRepository.findByUid(uid).orElse(null);
        LocalDate today = LocalDate.now();
        log.info(today.toString());
        List<Todo> todoList = todoRepository.findAllByUidAndDueDate(uid, today);
        List<Schedule> scheduleList = scheduleRepository.findAllByIdAndDate(user, today);
        log.info(String.valueOf(scheduleList.size()));
        StringBuilder sb = new StringBuilder();
        sb.append("오늘의 할 일은 ");
        if (!todoList.isEmpty()) {
            for (int i = 0; i < todoList.size(); i++) {
                Todo t = todoList.get(i);
                sb.append(t.getTodoTitle());
                if (i < todoList.size() - 1) {
                    sb.append(", ");
                }
            }
        } else {
            sb.append("없습니다. ");
        }
        sb.append("오늘의 일정은 ");
        if (!scheduleList.isEmpty()) {
            for (int i = 0; i < scheduleList.size(); i++) {
                Schedule t = scheduleList.get(i);
                sb.append(t.getScheduleTitle());
                if (i < scheduleList.size() - 1) {
                    sb.append(", ");
                }
            }
            sb.append("입니다.");
        } else {
            sb.append("없습니다. ");
        }
        return sb.toString();
    }

    public Mono<byte[]> convertTextToSpeech(
            String authHeader
    ) throws FirebaseAuthException {
        String text = getTodayList(authHeader);
//        String text = "알프레도 서비스 스트리밍 테스트입니다. 이건 오픈 에에피아이를 통해 진행됩니다. 오픈에이피아이 문제일까요?";
        WebClient client = WebClient.create("https://api.openai.com/v1/audio/speech");

        String requestBody = String.format("{\"model\": \"tts-1-hd\", \"input\": \"%s\", \"voice\": \"onyx\", \"format\": \"opus\"}", text);

        return client.post()
                .uri(uriBuilder -> uriBuilder.path("").build())
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + openAICredentials.getApiKey())
                .body(BodyInserters.fromValue(requestBody))
                .retrieve()
                .bodyToFlux(DataBuffer.class)
                .collectList()  // Collect all DataBuffers into a list
                .map(dataBuffers -> {
                    // Join all DataBuffers into one byte array
                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                    dataBuffers.forEach(dataBuffer -> {
                        byte[] bytes = new byte[dataBuffer.readableByteCount()];
                        dataBuffer.read(bytes);
                        try {
                            outputStream.write(bytes);
                        } catch (IOException e) {
                            throw new RuntimeException("Error writing data buffer to output stream", e);
                        } finally {
                            DataBufferUtils.release(dataBuffer); // Release each buffer right after use
                        }
                    });
                    return outputStream.toByteArray();
                });
    }
}