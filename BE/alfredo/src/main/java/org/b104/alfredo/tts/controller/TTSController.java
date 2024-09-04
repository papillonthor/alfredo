package org.b104.alfredo.tts.controller;

import com.google.firebase.auth.FirebaseAuthException;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.tts.service.TTSService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.IOException;



@RestController
@RequestMapping("/api/tts")
@Slf4j
public class TTSController {

    private final TTSService ttsService;

    public TTSController(TTSService ttsService) {
        this.ttsService = ttsService;
    }

    @GetMapping("/listen")
    public ResponseEntity<String> getTodaySummary(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String data = ttsService.getTodayList(authHeader);
        return ResponseEntity.ok(data);
    }
    @GetMapping("/check")
    public ResponseEntity<?> checkRequestLimit(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            boolean isAllowed = ttsService.checkLimit(authHeader);
            if (isAllowed) {
                return ResponseEntity.ok().body("You can proceed with your request.");
            } else {
                return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body("You have reached your request limit for today.");
            }
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authentication failed: " + e.getMessage());
        }
    }

    @GetMapping("/stream")
    public ResponseEntity<StreamingResponseBody> streamAudio(
            @RequestHeader(value = "Authorization") String authHeader
    ) {
        Logger logger = LoggerFactory.getLogger(this.getClass()); // Logger instance

        StreamingResponseBody stream = outputStream -> {
            try {
                logger.info("Starting to stream audio content for auth: {}", authHeader); // Logging start
                byte[] audioData = ttsService.convertTextToSpeech(
                        authHeader
                ).block(); // Blocking to wait for the complete audio file

                if (audioData != null) {
                    outputStream.write(audioData); // Write the complete audio data to the outputStream
                    outputStream.flush(); // Ensure all data is written out before closing
                }
                logger.info("Audio stream completed successfully."); // Log successful streaming
            } catch (Exception e) {
                logger.error("Exception caught during streaming setup", e); // Log exception during setup
                try {
                    outputStream.write(("Error streaming TTS: " + e.getMessage()).getBytes()); // Provide error message to client
                } catch (IOException ioException) {
                    logger.error("Failed to write error message to outputStream", ioException); // Log failure to write error message
                } finally {
                    try {
                        outputStream.close(); // Close stream in all cases
                    } catch (IOException ioException) {
                        logger.error("Failed to close outputStream", ioException);
                    }
                }
            }
        };

        return ResponseEntity.ok()
                .contentType(MediaType.valueOf("audio/ogg"))
                .body(stream);
    }
}
