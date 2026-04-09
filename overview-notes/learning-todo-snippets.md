# Snippets

## Config

```java
@Configuration
@EnableJpaAuditing
public class JpaConfig {
}

```

## Controller

```java
@RestController
@RequestMapping("/api/bcomm1")
@RequiredArgsConstructor
public class BusinessCommitmentOneController {

    private final BusinessCommitmentOneService businessCommitmentOneService;

    @GetMapping
    public ResponseEntity<List<BusinessCommitmentOneDto>> getAll() {
        List<BusinessCommitmentOne> entities = businessCommitmentOneService.findAll();
        return ResponseEntity.ok(BusinessCommitmentOneMapper.toDtoList(entities));
    }

    @PostMapping
    public ResponseEntity<BusinessCommitmentOneDto> create(@RequestBody BusinessCommitmentOneDto dto) {
        BusinessCommitmentOne entity = BusinessCommitmentOneMapper.toEntity(dto);
        BusinessCommitmentOne saved = businessCommitmentOneService.create(entity);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(BusinessCommitmentOneMapper.toDto(saved));
    }

    @PutMapping("/{id}")
    public ResponseEntity<BusinessCommitmentOneDto> update(@PathVariable Integer id,
            @RequestBody BusinessCommitmentOneDto dto) {
        BusinessCommitmentOne entity = BusinessCommitmentOneMapper.toEntity(dto);
        BusinessCommitmentOne updated = businessCommitmentOneService.update(id, entity);
        return ResponseEntity.ok(BusinessCommitmentOneMapper.toDto(updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        businessCommitmentOneService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteAll() {
        businessCommitmentOneService.deleteAll();
        return ResponseEntity.noContent().build();
    }
}

```

## Io/DTO

```java

public record BusinessCommitmentOneDto(
        Integer id,
        String workItem,
        LocalDate started,
        LocalDate dateCompleted,
        String applicationContext,
        String description,
        String problemOpportunity,
        String whoBenefited,
        String impact,
        String[] valueCategories,
        Boolean improvedOutcomes,
        String improvedOutcomesText,
        Boolean increasedEfficiency,
        String increasedEfficiencyText,
        Boolean reducedRiskCost,
        String reducedRiskCostText,
        Boolean enhancedCustomerExperience,
        String enhancedCustomerExperienceText,
        Boolean enhancedEmployeeExperience,
        String enhancedEmployeeExperienceText,
        String alignment,
        String statusNotes,
        Instant createdAt) {
}

```

## MApper

```java
public final class BusinessCommitmentOneMapper {
    private BusinessCommitmentOneMapper() {
    }

    public static BusinessCommitmentOneDto toDto(BusinessCommitmentOne e) {
        if (e == null)
            return null;
        return new BusinessCommitmentOneDto(
                e.getId(),
                e.getWorkItem(),
                e.getStarted(),
                e.getDateCompleted(),
                e.getApplicationContext(),
                e.getDescription(),
                e.getProblemOpportunity(),
                e.getWhoBenefited(),
                e.getImpact(),
                e.getValueCategories(),
                e.getImprovedOutcomes(),
                e.getImprovedOutcomesText(),
                e.getIncreasedEfficiency(),
                e.getIncreasedEfficiencyText(),
                e.getReducedRiskCost(),
                e.getReducedRiskCostText(),
                e.getEnhancedCustomerExperience(),
                e.getEnhancedCustomerExperienceText(),
                e.getEnhancedEmployeeExperience(),
                e.getEnhancedEmployeeExperienceText(),
                e.getAlignment(),
                e.getStatusNotes(),
                e.getCreatedAt());
    }

    public static BusinessCommitmentOne toEntity(BusinessCommitmentOneDto d) {
        if (d == null)
            return null;
        return BusinessCommitmentOne.builder()
                .id(d.id())
                .workItem(d.workItem())
                .started(d.started())
                .dateCompleted(d.dateCompleted())
                .applicationContext(d.applicationContext())
                .description(d.description())
                .problemOpportunity(d.problemOpportunity())
                .whoBenefited(d.whoBenefited())
                .impact(d.impact())
                .valueCategories(d.valueCategories())
                .improvedOutcomes(d.improvedOutcomes())
                .improvedOutcomesText(d.improvedOutcomesText())
                .increasedEfficiency(d.increasedEfficiency())
                .increasedEfficiencyText(d.increasedEfficiencyText())
                .reducedRiskCost(d.reducedRiskCost())
                .reducedRiskCostText(d.reducedRiskCostText())
                .enhancedCustomerExperience(d.enhancedCustomerExperience())
                .enhancedCustomerExperienceText(d.enhancedCustomerExperienceText())
                .enhancedEmployeeExperience(d.enhancedEmployeeExperience())
                .enhancedEmployeeExperienceText(d.enhancedEmployeeExperienceText())
                .alignment(d.alignment())
                .statusNotes(d.statusNotes())
                .createdAt(d.createdAt())
                .build();
    }

    public static List<BusinessCommitmentOneDto> toDtoList(List<BusinessCommitmentOne> list) {
        return list.stream().map(BusinessCommitmentOneMapper::toDto).collect(Collectors.toList());
    }
}

```

## Model

```java
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "business_commitments")
@EntityListeners(AuditingEntityListener.class)
public class BusinessCommitmentOne {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String workItem;

    private LocalDate started;

    private LocalDate dateCompleted;

    private String applicationContext;

    private String description;

    private String problemOpportunity;

    private String whoBenefited;

    private String impact;

    private String[] valueCategories;

    private Boolean improvedOutcomes;
    private String improvedOutcomesText;

    private Boolean increasedEfficiency;
    private String increasedEfficiencyText;

    private Boolean reducedRiskCost;
    private String reducedRiskCostText;

    private Boolean enhancedCustomerExperience;
    private String enhancedCustomerExperienceText;

    private Boolean enhancedEmployeeExperience;
    private String enhancedEmployeeExperienceText;

    private String alignment;

    private String statusNotes;

    @CreatedDate
    @Column(updatable = false)
    private Instant createdAt;
}

```

## Repository

```java
@Repository
public interface BusinessCommitmentOneRepository extends JpaRepository<BusinessCommitmentOne, Integer> {
}

```

## Service

```java

public interface BusinessCommitmentOneService {

    List<BusinessCommitmentOne> findAll();

    BusinessCommitmentOne create(BusinessCommitmentOne businessCommitmentOne);

    BusinessCommitmentOne update(Integer id, BusinessCommitmentOne businessCommitmentOne);

    void delete(Integer id);

    void deleteAll();
}

```

## ServiceImpl

```java
@Service
@RequiredArgsConstructor
public class BusinessCommitmentOneImpl implements BusinessCommitmentOneService {
    private final BusinessCommitmentOneRepository businessCommitmentOneRepository;

    @Override
    public List<BusinessCommitmentOne> findAll() {
        return businessCommitmentOneRepository.findAll();
    }

    @Override
    public BusinessCommitmentOne create(BusinessCommitmentOne businessCommitmentOne) {
        return businessCommitmentOneRepository.save(businessCommitmentOne);
    }

    @Override
    public BusinessCommitmentOne update(Integer id, BusinessCommitmentOne updated) {
        return businessCommitmentOneRepository.findById(id)
                .map(existing -> {
                    existing.setWorkItem(updated.getWorkItem());
                    existing.setStarted(updated.getStarted());
                    existing.setDateCompleted(updated.getDateCompleted());
                    existing.setApplicationContext(updated.getApplicationContext());
                    existing.setDescription(updated.getDescription());
                    existing.setProblemOpportunity(updated.getProblemOpportunity());
                    existing.setWhoBenefited(updated.getWhoBenefited());
                    existing.setImpact(updated.getImpact());
                    existing.setValueCategories(updated.getValueCategories());
                    existing.setImprovedOutcomes(updated.getImprovedOutcomes());
                    existing.setImprovedOutcomesText(updated.getImprovedOutcomesText());
                    existing.setIncreasedEfficiency(updated.getIncreasedEfficiency());
                    existing.setIncreasedEfficiencyText(updated.getIncreasedEfficiencyText());
                    existing.setReducedRiskCost(updated.getReducedRiskCost());
                    existing.setReducedRiskCostText(updated.getReducedRiskCostText());
                    existing.setEnhancedCustomerExperience(updated.getEnhancedCustomerExperience());
                    existing.setEnhancedCustomerExperienceText(updated.getEnhancedCustomerExperienceText());
                    existing.setEnhancedEmployeeExperience(updated.getEnhancedEmployeeExperience());
                    existing.setEnhancedEmployeeExperienceText(updated.getEnhancedEmployeeExperienceText());
                    existing.setAlignment(updated.getAlignment());
                    existing.setStatusNotes(updated.getStatusNotes());
                    return businessCommitmentOneRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("BusinessCommitmentOne not found: " + id));
    }

    @Override
    public void delete(Integer id) {
        if (!businessCommitmentOneRepository.existsById(id)) {
            throw new RuntimeException("BusinessCommitmentOne not found: " + id);
        }
        businessCommitmentOneRepository.deleteById(id);
    }

    @Override
    public void deleteAll() {
        businessCommitmentOneRepository.deleteAll();
    }
}
```
