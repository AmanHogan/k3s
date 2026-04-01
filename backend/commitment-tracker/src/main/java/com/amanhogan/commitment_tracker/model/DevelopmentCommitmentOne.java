package com.amanhogan.commitment_tracker.model;



import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;

@Builder
@Data
// @AllArgsConstructor
@NoArgsConstructor
@Document(collection = "develop_commit_1")
public class DevelopmentCommitmentOne {
}
