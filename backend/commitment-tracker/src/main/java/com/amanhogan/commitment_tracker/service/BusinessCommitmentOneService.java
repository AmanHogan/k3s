package com.amanhogan.commitment_tracker.service;

import java.util.List;

import com.amanhogan.commitment_tracker.model.BusinessCommitmentOne;

public interface BusinessCommitmentOneService {

    List<BusinessCommitmentOne> findAll();

    BusinessCommitmentOne create(BusinessCommitmentOne businessCommitmentOne);

    BusinessCommitmentOne update(String id, BusinessCommitmentOne businessCommitmentOne);

    void delete(String id);

    List<BusinessCommitmentOne> findByStatus(String status);

    void deleteAll();
}
