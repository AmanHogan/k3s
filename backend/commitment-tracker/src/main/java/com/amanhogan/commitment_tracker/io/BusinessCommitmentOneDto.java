package com.amanhogan.commitment_tracker.io;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

import com.amanhogan.commitment_tracker.model.ValueEntry;

public record BusinessCommitmentOneDto(
        String id,
        String workItem,
        LocalDate dateStarted,
        LocalDate dateCompleted,
        String applicationContext,
        String description,
        String problem,
        String whoBenefited,
        String impact,
        List<ValueEntry> valueEntryList,
        String alignment,
        String statusNotes,
        String status,
        Instant createdAt,
        Instant updatedAt
) {
}
