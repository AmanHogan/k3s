package com.amanhogan.commitment_tracker.repository;

import com.amanhogan.commitment_tracker.model.BusinessCommitmentOne;
import com.amanhogan.commitment_tracker.model.CommitmentStatus;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BusinessCommitmentOneRepository extends MongoRepository<BusinessCommitmentOne, String> {

    List<BusinessCommitmentOne> findByStatus(CommitmentStatus status);

}
