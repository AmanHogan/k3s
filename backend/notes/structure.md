## **Configuration**

- **`@Configuration` + `@EnableMongoAuditing`:** Turn on Spring configuration and Mongo auditing. Audited fields annotated with `@CreatedDate` / `@LastModifiedDate` (and `@CreatedBy` / `@LastModifiedBy`) are populated automatically.

- **Mongo properties:** Prefer `spring.data.mongodb.uri=mongodb://host:port/dbname`. It's the most reliable way to set host, port and database in Spring Boot.

## **Controller**

- **`@RestController` + `@RequestMapping`**: Expose REST endpoints. Controllers should be thin—translate HTTP ↔ service calls.
- **Dependency injection:** Use constructor injection. Lombok's `@RequiredArgsConstructor` generates the constructor for `final` fields; Spring injects beans automatically. Avoid field injection (`@Autowired` on fields).
- **Response conventions:** `POST` → `201 Created`, `PUT` → `200 OK` or `204 No Content`, `DELETE` → `204 No Content`.

## **Model (domain / document / entity)**

- **`@Document` / `@Entity`:** Mark persistence classes. For Mongo use `@Document(collection = "...")`.
- **Lombok:** `@Data` generates getters/setters/toString/equals/hashCode. `@Builder` creates a fluent builder API. Keep `@NoArgsConstructor` for frameworks (Jackson, Spring Data); `@AllArgsConstructor` is commonly used by `@Builder`.
- **Builder vs constructors:** `@Builder` creates a nested `Builder` class and static `builder()` method at compile time (Lombok annotation processor). You still often need a no-args constructor so frameworks can instantiate objects via reflection.

## **Repository**

- **Spring Data repositories (e.g. `MongoRepository<T, ID>`):** You define an interface and Spring Data generates a runtime implementation. You get CRUD (`save`, `findById`, `findAll`, `deleteById`) for free.
- **Query derivation:** Methods named like `findByUserIdAndStatus(...)` are parsed by Spring Data and converted into queries automatically.

## **Service**

- **Business layer:** Implement business logic and orchestrate repository calls. Define an interface and implement it (`@Service`) so callers depend on the interface.
- **Updates:** Typical pattern for `PUT /resource/{id}`:
  - Controller: receive `id` in path and updated payload in body.
  - Service: `findById(id)` → map allowed fields from request onto existing entity → `save(existing)` → return saved entity.
  - Rationale: preserves fields clients shouldn't overwrite (e.g., `createdAt`), prevents accidental inserts when the id doesn't exist.

## **Common tooling & concepts**

- **Jackson:** JSON (de)serializer used by Spring MVC to map request/response bodies to Java objects. It relies on constructors/getters/setters by default.
- **JPA:** Java Persistence API — a spec for ORM mapping to relational databases (annotations like `@Entity`, `@Id`). Implementations include Hibernate.
- **Spring Data:** High-level repository abstraction supporting multiple datastores (JPA, MongoDB, Cassandra, etc.). It is not an ORM itself but integrates with ORMs for relational stores.

## **Practical tips**

- **ID field naming:** Use `private String id;` (lowercase) with `@Id`. Inconsistent naming (e.g. `Id`) can break mapping.
- **Auditing:** `@EnableMongoAuditing` + `@CreatedDate`/`@LastModifiedDate` will populate timestamps only when entities are saved through Spring Data (not when inserted directly via `mongosh`).
- **Config precedence:** If properties seem ignored, set `spring.data.mongodb.uri`. For deterministic behavior you can provide a `MongoClient` configuration class by extending `AbstractMongoClientConfiguration`.
- **Error handling:** Return appropriate HTTP status codes. Use `@ControllerAdvice` for centralized exception-to-HTTP mapping rather than throwing raw `RuntimeException` from services.

## **Recommended development order**

1. **Model** — define domain/DTOs.  
2. **Repository** — create interfaces (`extends MongoRepository` / `JpaRepository`).  
3. **Service** — implement business logic and validation.  
4. **Controller** — expose endpoints and map requests to services.

## **Short glossary**

- **ORM:** Object-relational mapping (maps Java objects ↔ relational tables). JPA is a spec; Hibernate is an implementation.  
- **Spring Data:** Repository abstraction and helpers for many datastores; generates repository implementations at runtime.  
- **Jackson:** JSON mapper used by Spring for HTTP bodies.

---


### Spring Data JPA

An alternative to Spring JDBC, and the more antiquated Java JDBC, and maps Java Objects to Tables in a database by *translating* your java code into sql queries. 


### Difference between Spring Data JPA vs. JPA vs. Hibernate vs. JDBC


JDBC is a low level abstraction to execute sql, manage connections, and map rows to objects. Very low level. You could technically do everything manually with this

Java Persistence API  (JPA) - a standard/specification using annotations like `@Entity`. It is the ORM Specification.

Hibernate - A popular implmentation of JPA. It is the ORM itself. 

SPring Data JPA - Spring module on top of JPA and Hibernate that proivides even more abstractions so you write less boiler plate. It uses hibernate under the hood. 


IM techncailly not using sproing jpa:
Spring Data (shared idea: repositories + method parsing)
        ↓
   JPA version                 Mongo version
        ↓                          ↓
JPA → Hibernate (SQL)     MongoDB driver (NoSQL)


Mongo repsitory uses obejtc dodmuent mapping and isnt an orm spec. Spring data mongo talks directkly wiht the database:
Spring Data MongoDB
      ↓
MongoDB Java Driver (no ORM layer)
      ↓
MongoDB