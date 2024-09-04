package org.b104.alfredo.item.controller;


import com.google.firebase.auth.FirebaseAuthException;
import lombok.AllArgsConstructor;
import org.b104.alfredo.item.request.SelectDto;
import org.b104.alfredo.item.response.ItemDto;
import org.b104.alfredo.item.service.ItemService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/item")
@AllArgsConstructor
public class ItemController {

    private final ItemService itemService;

    // 상점 페이지 조회
    @GetMapping("/shoplist")
    public ResponseEntity<?> calllist(@RequestHeader(value = "Authorization") String authHeader){
        try {
            ItemDto itemDto = itemService.callList(authHeader);
            return ResponseEntity.ok(itemDto);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Firebase token");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
        }
    }

    // 사용자 설정 아이템 상태 조회
    @GetMapping("/status")
    public ResponseEntity<?> status(@RequestHeader(value = "Authorization") String authHeader){
        try {
            SelectDto selectDto = itemService.callStatus(authHeader);
            return ResponseEntity.ok(selectDto);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Firebase token");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
        }
    }
    
    @PostMapping("/select")
    public ResponseEntity<?> select(@RequestHeader(value = "Authorization") String authHeader,
                                    @RequestBody SelectDto selectDto){
        try {
            itemService.selectItem(authHeader, selectDto);
            return ResponseEntity.ok("Item changed successfully");
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Firebase token");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
        }
    }

    @PostMapping("/buy")
    public ResponseEntity<?> buy(@RequestHeader(value = "Authorization") String authHeader,
                                 @RequestBody SelectDto selectDto){
        try {
            itemService.buyItem(authHeader, selectDto);
            return ResponseEntity.ok("Purchase successfully");
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Firebase token");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
        }
    }






}
