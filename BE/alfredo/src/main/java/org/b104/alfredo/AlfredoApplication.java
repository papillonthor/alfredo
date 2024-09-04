package org.b104.alfredo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.reactive.function.client.WebClient;

@EnableScheduling
@SpringBootApplication
public class AlfredoApplication {

    public static void main(String[] args) {
        // DevTools 비활성화
        System.setProperty("spring.devtools.restart.enabled", "false");
        SpringApplication.run(AlfredoApplication.class, args);
    }
    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }

}
