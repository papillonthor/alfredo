package org.b104.alfredo.tts.component;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class OpenAICredentials {

    @Value("${openai.api.key}")
    private String apiKey;
    @Value("${openai.api.url}")
    private String apiUrl;

    public String getApiKey() {
        return apiKey;
    }
    public String getApiUrl() {
        return apiUrl;
    }
}
