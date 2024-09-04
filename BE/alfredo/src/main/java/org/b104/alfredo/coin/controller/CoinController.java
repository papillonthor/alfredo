package org.b104.alfredo.coin.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.coin.domain.Coin;
import org.b104.alfredo.coin.request.CoinDecrementRequestDto;
import org.b104.alfredo.coin.response.CoinDetailDto;
import org.b104.alfredo.coin.service.CoinService;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/coin")
public class CoinController {
    private final UserService userService;
    private final CoinService coinService;

    // 조회
    @GetMapping("/detail")
    public ResponseEntity<CoinDetailDto> findCoinDetail(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            CoinDetailDto coinDetail = coinService.detailCoin(user);

            return new ResponseEntity<>(coinDetail, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error fetching achieve details", e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    // 코인 생성
    @PostMapping("/create")
    public ResponseEntity<Object> createCoin(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);

            Coin newCoin = coinService.createCoin(user);
            return ResponseEntity.ok(new CoinDetailDto(newCoin));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        } catch (Exception e) {
            log.error("Failed to create coin", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // todayCoin과 totalCoin을 5개씩 증가
    @PostMapping("/increment")
    public ResponseEntity<Object> incrementCoins(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            coinService.incrementCoins(user);

            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Failed to increment coins", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // todayCoin과 totalCoin을 5개씩 감소
    @PostMapping("/decrement")
    public ResponseEntity<Object> decrementCoins(@RequestHeader(value = "Authorization") String authHeader) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            coinService.decrementCoins(user);

            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Failed to decrement coins", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 특정 값만큼 totalCoin을 감소
    @PostMapping("/decrementTotal")
    public ResponseEntity<Object> decrementTotalCoins(@RequestHeader(value = "Authorization") String authHeader,
                                                      @RequestBody CoinDecrementRequestDto request) {
        try {
            String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();

            User user = userService.getUserByUid(uid);
            coinService.decrementTotalCoin(user, request.getDecrementValue());

            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            log.error("Failed to decrement total coins", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
