package org.b104.alfredo.todo.request;

import lombok.Getter;
import lombok.Setter;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

/**
 * Day 엔티티를 업데이트하기 위한 요청 데이터 전송 객체.
 * 사용자의 UID, 요일 인덱스, 그리고 카운트 변경량을 포함합니다.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DayUpdateRequestDto {

    private String uid; // 사용자 고유 ID

    private int dayIndex; // 요일을 나타내는 숫자 (0=일요일, 1=월요일, ..., 6=토요일)

    private int change; // 해당 요일에 대한 카운트 변경량 (+1 또는 -1)
}

