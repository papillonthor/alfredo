package org.b104.alfredo.user.Dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class RecommendRoutineDto {
    private List<Long> basicRoutineId;
}
