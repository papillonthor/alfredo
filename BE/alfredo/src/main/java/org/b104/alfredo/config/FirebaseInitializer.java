package org.b104.alfredo.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;

@Component
public class FirebaseInitializer {

    @Value("${firebase.sdk}")
    private String sdkKey;

    @PostConstruct
    public void initialize() {
        try (FileInputStream serviceAccount = new FileInputStream(sdkKey)) { // FileInputStream으로 파일 열기
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount)) // FileInputStream 객체 사용
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String getFirebaseServerToken() throws IOException {
        // GoogleCredentials 객체를 얻어와야 합니다.
        FileInputStream serviceAccount = new FileInputStream(sdkKey);
        GoogleCredentials googleCredentials = GoogleCredentials.fromStream(serviceAccount)
                .createScoped("https://www.googleapis.com/auth/firebase.messaging");
        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();  // 토큰 값 반환
    }

}
