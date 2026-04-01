package com.amanhogan.commitment_tracker.mapper;

import java.util.List;
import java.util.stream.Collectors;

import com.amanhogan.commitment_tracker.io.BusinessCommitmentOneDto;
import com.amanhogan.commitment_tracker.model.BusinessCommitmentOne;
import com.amanhogan.commitment_tracker.model.CommitmentStatus;

public final class BusinessCommitmentOneMapper {
    private BusinessCommitmentOneMapper() {}

    public static BusinessCommitmentOneDto toDto(BusinessCommitmentOne e) {
        if (e == null) return null;
        return new BusinessCommitmentOneDto(
                e.getId(),
                e.getWorkItem(),
                e.getDateStarted(),
                e.getDateCompleted(),
                e.getApplicationContext(),
                e.getDescription(),
                e.getProblem(),
                e.getWhoBenefited(),
                e.getImpact(),
                e.getValueEntryList(),
                e.getAlignment(),
                e.getStatusNotes(),
                e.getStatus() == null ? null : e.getStatus().name(),
                e.getCreatedAt(),
                e.getUpdatedAt()
        );
    }

    public static BusinessCommitmentOne toEntity(BusinessCommitmentOneDto d) {
        if (d == null) return null;
        CommitmentStatus status = d.status() == null ? null : CommitmentStatus.valueOf(d.status());
        return BusinessCommitmentOne.builder()
                .id(d.id())
                .workItem(d.workItem())
                .dateStarted(d.dateStarted())
                .dateCompleted(d.dateCompleted())
                .applicationContext(d.applicationContext())
                .description(d.description())
                .problem(d.problem())
                .whoBenefited(d.whoBenefited())
                .impact(d.impact())
                .valueEntryList(d.valueEntryList())
                .alignment(d.alignment())
                .statusNotes(d.statusNotes())
                .status(status)
                .createdAt(d.createdAt())
                .updatedAt(d.updatedAt())
                .build();
    }

    public static List<BusinessCommitmentOneDto> toDtoList(List<BusinessCommitmentOne> list) {
        return list.stream().map(BusinessCommitmentOneMapper::toDto).collect(Collectors.toList());
    }
}
