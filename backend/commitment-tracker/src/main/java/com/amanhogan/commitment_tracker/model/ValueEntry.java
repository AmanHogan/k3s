package com.amanhogan.commitment_tracker.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ValueEntry {
    private ValueCategory valueCategory;
    private String reason;
}
