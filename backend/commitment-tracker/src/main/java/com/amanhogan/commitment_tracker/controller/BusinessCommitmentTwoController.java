package com.amanhogan.commitment_tracker.controller;

import com.amanhogan.commitment_tracker.model.BusinessCommitmentTwo;
import com.amanhogan.commitment_tracker.service.BusinessCommitmentTwoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/commitments-two")
@RequiredArgsConstructor
public class BusinessCommitmentTwoController {

    private final BusinessCommitmentTwoService businessCommitmentTwoService;

    @GetMapping
    public ResponseEntity<List<BusinessCommitmentTwo>> getAll() {
        return ResponseEntity.ok(businessCommitmentTwoService.findAll());
    }

    @GetMapping("/getByStatus/{status}")
    public ResponseEntity<List<BusinessCommitmentTwo>> getByStatus(@PathVariable String status) {
        return ResponseEntity.ok(businessCommitmentTwoService.findByStatus(status));
    }

    @PostMapping
    public ResponseEntity<BusinessCommitmentTwo> create(@RequestBody BusinessCommitmentTwo businessCommitmentTwo) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(businessCommitmentTwoService.create(businessCommitmentTwo));
    }

    @PutMapping("/{id}")
    public ResponseEntity<BusinessCommitmentTwo> update(@PathVariable String id,
            @RequestBody BusinessCommitmentTwo businessCommitmentTwo) {
        return ResponseEntity.ok(businessCommitmentTwoService.update(id, businessCommitmentTwo));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        businessCommitmentTwoService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteAll() {
        businessCommitmentTwoService.deleteAll();
        return ResponseEntity.noContent().build();
    }
}
