package com.amanhogan.commitment_tracker.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class SubEvent {

    private String subEventName;

    private String description;

    private LocalDate dateStarted;

    private LocalDate dateCompleted;

    private DoneNotDone done;

}
