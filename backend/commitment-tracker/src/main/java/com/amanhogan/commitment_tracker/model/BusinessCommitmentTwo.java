package com.amanhogan.commitment_tracker.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Document(collection = "business_commit_2")
public class BusinessCommitmentTwo {
    @Id
    private String id;

    private String eventName;

    private String type;

    private LocalDate started;

    private LocalDate finished;

    private String description;

    private DoneNotDone isDone;

    private RequiredNotRequired isRequired;

    private List<SubEvent> subEvents;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
