package com.amanhogan.commitment_tracker.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.amanhogan.commitment_tracker.model.BusinessCommitmentOne;
import com.amanhogan.commitment_tracker.model.CommitmentStatus;
import com.amanhogan.commitment_tracker.repository.BusinessCommitmentOneRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BusinessCommitmentOneImpl implements BusinessCommitmentOneService {
    private final BusinessCommitmentOneRepository businessCommitmentOneRepository;

    @Override
    public List<BusinessCommitmentOne> findAll() {
        return businessCommitmentOneRepository.findAll();
    }

    @Override
    public BusinessCommitmentOne create(BusinessCommitmentOne businessCommitmentOne){
        return businessCommitmentOneRepository.save(businessCommitmentOne);
    }

    @Override
    public BusinessCommitmentOne update(String id, BusinessCommitmentOne updated) {
        return businessCommitmentOneRepository.findById(id)
                .map(existing -> {
                    existing.setWorkItem(updated.getWorkItem());
                    existing.setDateStarted(updated.getDateStarted());
                    existing.setDateCompleted(updated.getDateCompleted());
                    existing.setApplicationContext(updated.getApplicationContext());
                    existing.setDescription(updated.getDescription());
                    existing.setProblem(updated.getProblem());
                    existing.setWhoBenefited(updated.getWhoBenefited());
                    existing.setImpact(updated.getImpact());
                    existing.setValueEntryList(updated.getValueEntryList());
                    existing.setAlignment(updated.getAlignment());
                    existing.setStatusNotes(updated.getStatusNotes());
                    existing.setStatus(updated.getStatus());
                    return businessCommitmentOneRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("BusinessCommitmentOne not found: " + id));
    }

    @Override
    public void delete(String id) {
        if (!businessCommitmentOneRepository.existsById(id)) {
            throw new RuntimeException("BusinessCommitmentOne not found: " + id);
        }
        businessCommitmentOneRepository.deleteById(id);
    }

    @Override
    public List<BusinessCommitmentOne> findByStatus(String status) {
        return businessCommitmentOneRepository.findByStatus(CommitmentStatus.valueOf(status)); }


    @Override
    public void deleteAll(){
    List<BusinessCommitmentOne> listOfBusinessCommitments = businessCommitmentOneRepository.findAll();
    for (BusinessCommitmentOne commitment : listOfBusinessCommitments) {
        businessCommitmentOneRepository.deleteById(commitment.getId());
    }}

}
