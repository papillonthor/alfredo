package org.b104.alfredo.routine.request;

import java.util.List;

public class RoutineIdsRequest {
    private List<Long> basicRoutineIds;

    public List<Long> getBasicRoutineIds() {
        return basicRoutineIds;
    }

    public void setBasicRoutineIds(List<Long> basicRoutineIds) {
        this.basicRoutineIds = basicRoutineIds;
    }
}
