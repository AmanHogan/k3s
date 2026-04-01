package com.amanhogan.commitment_tracker.service;


import com.amanhogan.commitment_tracker.model.BusinessCommitmentTwo;

import java.util.List;

public interface BusinessCommitmentTwoService {

    List<BusinessCommitmentTwo> findAll();

    BusinessCommitmentTwo create(BusinessCommitmentTwo businessCommitmentTwo);

    BusinessCommitmentTwo update(String id, BusinessCommitmentTwo businessCommitmentTwo);

    void delete(String id);

    List<BusinessCommitmentTwo> findByStatus(String status);

    void deleteAll();
}
