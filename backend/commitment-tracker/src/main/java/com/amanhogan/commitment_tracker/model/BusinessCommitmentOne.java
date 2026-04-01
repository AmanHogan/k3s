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
@Document(collection="business_commit_1")
public class BusinessCommitmentOne {

    @Id
    private String id;

    private String workItem;

    private LocalDate dateStarted;

    private LocalDate dateCompleted;

    private String applicationContext;

    private String description;

    private String problem;

    private String whoBenefited;

    private String impact;

    private List<ValueEntry> valueEntryList;

    private String alignment;

    private String statusNotes;

    private CommitmentStatus status;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;


}
