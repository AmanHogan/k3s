package com.amanhogan.commitment_tracker.service;

import com.amanhogan.commitment_tracker.model.BusinessCommitmentTwo;
import com.amanhogan.commitment_tracker.model.DoneNotDone;
import com.amanhogan.commitment_tracker.repository.BusinessCommitmentTwoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BusinessCommitmentTwoImpl implements BusinessCommitmentTwoService {
    private final BusinessCommitmentTwoRepository businessCommitmentTwoRepository;

    @Override
    public List<BusinessCommitmentTwo> findAll() {
        return businessCommitmentTwoRepository.findAll();
    }

    @Override
    public BusinessCommitmentTwo create(BusinessCommitmentTwo businessCommitmentTwo) {
        return businessCommitmentTwoRepository.save(businessCommitmentTwo);
    }

    @Override
    public BusinessCommitmentTwo update(String id, BusinessCommitmentTwo updated) {
        return businessCommitmentTwoRepository.findById(id)
                .map(existing -> {
                    existing.setEventName(updated.getEventName());
                    existing.setType(updated.getType());
                    existing.setStarted(updated.getStarted());
                    existing.setFinished(updated.getFinished());
                    existing.setDescription(updated.getDescription());
                    existing.setIsDone(updated.getIsDone());
                    existing.setIsRequired(updated.getIsRequired());
                    existing.setSubEvents(updated.getSubEvents());
                    return businessCommitmentTwoRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("BusinessCommitmentTwo not found: " + id));
    }

    @Override
    public void delete(String id) {
        if (!businessCommitmentTwoRepository.existsById(id)) {
            throw new RuntimeException("BusinessCommitmentTwo not found: " + id);
        }
        businessCommitmentTwoRepository.deleteById(id);
    }

    @Override
    public List<BusinessCommitmentTwo> findByStatus(String status) {
        return businessCommitmentTwoRepository.findByIsDone(DoneNotDone.valueOf(status));
    }

    @Override
    public void deleteAll() {
        businessCommitmentTwoRepository.deleteAll();
    }
}

