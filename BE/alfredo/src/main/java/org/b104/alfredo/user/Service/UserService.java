package org.b104.alfredo.user.Service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import org.b104.alfredo.achieve.domain.Achieve;
import org.b104.alfredo.achieve.repository.AchieveRepository;
import org.b104.alfredo.achieve.service.AchieveService;
import org.b104.alfredo.coin.domain.Coin;
import org.b104.alfredo.coin.repository.CoinRepository;
import org.b104.alfredo.item.domain.UserItemInventory;
import org.b104.alfredo.item.domain.UserItemStatus;
import org.b104.alfredo.item.repository.UserItemInventoryRepository;
import org.b104.alfredo.item.repository.UserItemStatusRepository;
import org.b104.alfredo.routine.domain.Routine;
import org.b104.alfredo.routine.response.RoutineDto;
import org.b104.alfredo.user.Domain.Survey;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Dto.*;
import org.b104.alfredo.user.Repository.*;
import org.b104.alfredo.user.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.b104.alfredo.routine.repository.RoutineRepository;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {
    @Autowired
    private RoutineRepository routineRepository;

    private final UserRepository userRepository;
    private final AchieveRepository achieveRepository;
    private final CoinRepository coinRepository;
    private final UserItemInventoryRepository userItemInventoryRepository;
    private final UserItemStatusRepository userItemStatusRepository;

    @Autowired
    private SurveyRepository surveyRepository;

    @Value("${flask.url}")
    private String flaskUrl;


    public User createUser(UserCreateDto userCreateDto) {
        User user = User.builder()
                .email(userCreateDto.getEmail())
                .uid(userCreateDto.getUid())
                .build();

        user = userRepository.save(user);

        Achieve newAchieve = Achieve.builder()
                .user(user)
                .achieveOne(false)
                .finishOne(null)
                .achieveTwo(false)
                .finishTwo(null)
                .achieveThree(false)
                .finishThree(null)
                .achieveFour(false)
                .finishFour(null)
                .achieveFive(false)
                .finishFive(null)
                .achieveSix(false)
                .finishSix(null)
                .achieveSeven(false)
                .finishSeven(null)
                .achieveEight(false)
                .finishEight(null)
                .achieveNine(false)
                .finishNine(null)
                .build();
        newAchieve = achieveRepository.save(newAchieve);

        Coin newCoin = Coin.builder()
                .userId(user)
                .totalCoin(0)
                .todayCoin(0)
                .build();

        newCoin = coinRepository.save(newCoin);

        UserItemInventory newUserItemInventory = new UserItemInventory();
        newUserItemInventory.setUid(userCreateDto.getUid());
        newUserItemInventory.setBackground1(true);
        newUserItemInventory.setBackground2(false);
        newUserItemInventory.setBackground3(false);
        newUserItemInventory.setCharacter1(true);
        newUserItemInventory.setCharacter2(false);
        newUserItemInventory.setCharacter3(false);
        userItemInventoryRepository.save(newUserItemInventory);

        UserItemStatus newUserItemStatus = new UserItemStatus();
        newUserItemStatus.setUid(userCreateDto.getUid());
        newUserItemStatus.setBackground(1);
        newUserItemStatus.setCharacterType(1);
        userItemStatusRepository.save(newUserItemStatus);

        user.setNickname("사용자" + user.getUserId());
        return userRepository.save(user);
    }

    public UserInfoDto getUserInfo(String uid) {
        User user = userRepository.findByUid(uid).orElseThrow(() -> new NoSuchElementException("User not found"));

        return new UserInfoDto(
                user.getEmail(),
                user.getNickname(),
//                user.getUid(),
                user.getBirth(),
                user.getAnswer(),
                user.getGoogleCalendarUrl()
        );
    }

    public User updateUser(String uid, UserUpdateDto userUpdateDto) {
        User user = userRepository.findByUid(uid).orElseThrow(() ->
                new NoSuchElementException("user not found: " + uid));

        UserUpdateDto.updateEntity(user, userUpdateDto);
        return userRepository.save(user);
    }


    public User getUserByUid(String uid) {
        return userRepository.findByUid(uid).orElse(null);
    }

    public User updateUserToken(String uid, String token) {
        User user = userRepository.findByUid(uid).orElseThrow(() -> new NoSuchElementException("No user found with uid: " + uid));
        user.setFcmToken(token);
//        System.out.println("여기 오니");
        return userRepository.saveAndFlush(user);
    }


    //////////////////////////////// 루틴추천서비스 ///////////////////////////
    public Survey saveSurvey(String uid, SurveyDto surveyDto) {
        User user = userRepository.findByUid(uid).orElseThrow(() ->
                new NoSuchElementException("User not found with uid: " + uid));

        Survey survey = surveyDto.toEntity(user);
        return surveyRepository.save(survey);
    }



    public RecommendRoutineDto getSimilarUser(String uid) {
        User user = userRepository.findByUid(uid).orElseThrow(() -> new NoSuchElementException("User not found"));
        Survey survey = surveyRepository.findByUserUserId(user.getUserId())
                .orElseThrow(() -> new NoSuchElementException("Survey not found for user: " + uid));

        List<Integer> answers = Arrays.asList(survey.getQuestion1(), survey.getQuestion2(), survey.getQuestion3(), survey.getQuestion4(), survey.getQuestion5());

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> map = new HashMap<>();
        map.put("question1", answers.get(0));
        map.put("question2", answers.get(1));
        map.put("question3", answers.get(2));
        map.put("question4", answers.get(3));
        map.put("question5", answers.get(4));
        map.put("userId", user.getUserId());
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(map, headers);

        String url = flaskUrl + "/recommend";
        ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);
        Long similarUserId = Long.parseLong(response.getBody());

        List<Routine> routines = routineRepository.findByUserUserIdOrderByStartTimeAsc(similarUserId);
        Set<Long> uniqueBasicRoutineIds = routines.stream()
                .filter(routine -> routine.getBasicRoutine() != null)
                .map(routine -> routine.getBasicRoutine().getId())
                .collect(Collectors.toSet());

        return new RecommendRoutineDto(new ArrayList<>(uniqueBasicRoutineIds));
    }

}