Here is the updated checklist with **Maven** and **SQL connection setup** added at the end.

---

# 0. Foundations (Beans, DI, Annotations)

- [ ] What an annotation is (metadata, reflection)
- [ ] What a Spring bean is
- [ ] What the Application Context is
- [ ] Component scanning

### Dependency Injection

- [ ] Constructor injection
- [ ] Field injection
- [ ] Differences and tradeoffs
- [ ] How `@RequiredArgsConstructor` works

### Core Annotations

- [ ] `@Component`
- [ ] `@Service`
- [ ] `@Repository`
- [ ] `@RestController`
- [ ] `@Configuration`

---

# 1. Controller Layer

- [ ] Purpose of a controller
- [ ] `@RequestMapping`
- [ ] `@GetMapping`
- [ ] `@PostMapping`
- [ ] `@PutMapping`
- [ ] `@DeleteMapping`
- [ ] `@RequestBody`
- [ ] `@PathVariable`
- [ ] `ResponseEntity`
- [ ] HTTP status codes (200, 201, 204)

### Flow

- [ ] JSON → DTO
- [ ] DTO → Entity
- [ ] Entity → DTO → JSON

---

# 2. DTO and Serialization

- [ ] What a DTO is
- [ ] Why DTOs are used
- [ ] Java `record` basics
- [ ] Jackson JSON mapping (serialize and deserialize)
- [ ] Immutability vs mutability

---

# 3. Mapper Layer

- [ ] Purpose of a mapper
- [ ] Entity → DTO mapping
- [ ] DTO → Entity mapping
- [ ] Static mapper methods
- [ ] Mapping lists with streams

---

# 4. Entity (JPA Model)

### Core JPA Annotations

- [ ] `@Entity`
- [ ] `@Table`
- [ ] `@Id`
- [ ] `@GeneratedValue`
- [ ] `@Column`

### Field Types

- [ ] Wrapper vs primitive types
- [ ] `LocalDate` vs `Instant`
- [ ] Arrays (`String[]`) and how JPA handles them

### Lifecycle and Auditing

- [ ] `@CreatedDate`
- [ ] `@EntityListeners`
- [ ] `@EnableJpaAuditing`

---

# 5. Lombok

- [ ] `@Data`
- [ ] `@Builder`
- [ ] `@AllArgsConstructor`
- [ ] `@NoArgsConstructor`
- [ ] What code each annotation generates

---

# 6. Repository Layer

- [ ] What `JpaRepository` is
- [ ] How Spring generates implementations
- [ ] `findAll()`
- [ ] `findById()`
- [ ] `save()`
- [ ] `deleteById()`
- [ ] `existsById()`

---

# 7. Service Layer

- [ ] Purpose of service layer
- [ ] Interface vs implementation
- [ ] Dependency injection into service
- [ ] CRUD operations flow

### Update Logic

- [ ] `findById()` + modify + `save()`
- [ ] Use of `Optional`
- [ ] `map()` vs imperative style

---

# 8. JPA and Hibernate Behavior

- [ ] What JPA is (specification)
- [ ] What Hibernate is (implementation)
- [ ] Persistence context
- [ ] Entity lifecycle (transient, managed, detached)
- [ ] Dirty checking
- [ ] When `save()` does insert vs update

---

# 9. Full Request Flow

- [ ] Request enters controller
- [ ] Controller calls service
- [ ] Service calls repository
- [ ] Repository interacts with JPA/Hibernate
- [ ] Database interaction
- [ ] Response returned

---

# 10. Maven (Build System)

- [ ] What Maven is (dependency management + build tool)
- [ ] Project structure (`src/main/java`, `resources`, etc.)
- [ ] `pom.xml` structure

### Key Concepts

- [ ] Dependencies
- [ ] Plugins
- [ ] GroupId, ArtifactId, Version

### Spring Boot Dependencies

- [ ] `spring-boot-starter-web`
- [ ] `spring-boot-starter-data-jpa`
- [ ] Database driver (e.g., MySQL, PostgreSQL)

### Commands

- [ ] `mvn clean install`
- [ ] `mvn spring-boot:run`

---

# 11. Database Connection (SQL Setup)

### Configuration File (`application.properties` or `.yml`)

- [ ] `spring.datasource.url`
- [ ] `spring.datasource.username`
- [ ] `spring.datasource.password`
- [ ] `spring.datasource.driver-class-name`

### JPA Configuration

- [ ] `spring.jpa.hibernate.ddl-auto` (create, update, validate)
- [ ] `spring.jpa.show-sql`
- [ ] Dialect (optional)

### Connection Flow

- [ ] Spring Boot auto-configures DataSource
- [ ] Hibernate uses DataSource
- [ ] Repository uses Hibernate

---

# 12. Reconstruction Exercises

- [ ] Rewrite one class without Lombok
- [ ] Write constructor manually for injection
- [ ] Recreate repository interface from memory
- [ ] Recreate entity with annotations from memory
- [ ] Recreate full CRUD flow on paper
- [ ] Trace one endpoint end-to-end without looking

---

If you want to tighten this further, the next useful step would be turning this into a strict time-blocked schedule for today.
