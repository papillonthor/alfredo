package org.b104.alfredo.attendance.response;

import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
public class AttendanceDateDto {
    private LocalDate date;
    public AttendanceDateDto(LocalDate date) {
        this.date = date;
    }
}
