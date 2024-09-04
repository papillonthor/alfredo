package org.b104.alfredo.item.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import lombok.AllArgsConstructor;
import org.b104.alfredo.item.domain.UserItemInventory;
import org.b104.alfredo.item.domain.UserItemStatus;
import org.b104.alfredo.item.repository.UserItemInventoryRepository;
import org.b104.alfredo.item.repository.UserItemStatusRepository;
import org.b104.alfredo.item.request.SelectDto;
import org.b104.alfredo.item.response.ItemDto;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class ItemService {

    private final UserItemInventoryRepository userItemInventoryRepository;
    private final UserItemStatusRepository userItemStatusRepository;

    public ItemDto callList(String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        UserItemInventory userItemInventory = userItemInventoryRepository.findByUid(uid);

        if (userItemInventory == null) {
            throw new IllegalArgumentException("UserItemInventory not found");
        }

        ItemDto itemDto = new ItemDto();
        itemDto.setBackground1(userItemInventory.isBackground1());
        itemDto.setBackground2(userItemInventory.isBackground2());
        itemDto.setBackground3(userItemInventory.isBackground3());
        itemDto.setCharacter1(userItemInventory.isCharacter1());
        itemDto.setCharacter2(userItemInventory.isCharacter2());
        itemDto.setCharacter3(userItemInventory.isCharacter3());
        return itemDto;
    }

    public SelectDto callStatus(String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        UserItemStatus userItemStatus = userItemStatusRepository.findByUid(uid);

        if (userItemStatus == null) {
            throw new IllegalArgumentException("UserItemStatus not found");
        }

        SelectDto selectDto = new SelectDto();
        selectDto.setBackground(userItemStatus.getBackground());
        selectDto.setCharacterType(userItemStatus.getCharacterType());
        return selectDto;
    }

    public void selectItem(String authHeader, SelectDto selectDto) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        UserItemStatus userItemStatus = userItemStatusRepository.findByUid(uid);

        if (userItemStatus == null) {
            throw new IllegalArgumentException("UserItemStatus not found");
        }

        if (selectDto.getBackground() != null) {
            userItemStatus.setBackground(selectDto.getBackground());
        }
        if (selectDto.getCharacterType() != null) {
            userItemStatus.setCharacterType(selectDto.getCharacterType());
        }

        userItemStatusRepository.save(userItemStatus);
        System.out.println("확인");

    }


    public void buyItem(String authHeader, SelectDto selectDto) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        UserItemInventory userItemInventory = userItemInventoryRepository.findByUid(uid);

        if (userItemInventory == null) {
            throw new IllegalArgumentException("UserItemInventory not found");
        }

        if (selectDto.getBackground() != null) {
            if (selectDto.getBackground() == 2) {
                userItemInventory.setBackground2(true);
            } else if (selectDto.getBackground() == 3) {
                userItemInventory.setBackground3(true);
            }
        }

        if (selectDto.getCharacterType() != null) {
            if (selectDto.getCharacterType() == 2) {
                userItemInventory.setCharacter2(true);
            } else if (selectDto.getCharacterType() == 3) {
                userItemInventory.setCharacter3(true);
            }
        }

        userItemInventoryRepository.save(userItemInventory);
    }
}
