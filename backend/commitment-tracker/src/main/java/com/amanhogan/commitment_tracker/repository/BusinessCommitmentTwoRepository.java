package com.amanhogan.commitment_tracker.repository;

import com.amanhogan.commitment_tracker.model.BusinessCommitmentTwo;
import com.amanhogan.commitment_tracker.model.DoneNotDone;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BusinessCommitmentTwoRepository extends MongoRepository<BusinessCommitmentTwo, String> {

    List<BusinessCommitmentTwo> findByIsDone(DoneNotDone isDone);
}

