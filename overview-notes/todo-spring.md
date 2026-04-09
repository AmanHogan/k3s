# Spring Learning Todo

## Core Spring Concepts

- [ ] Review the 3 dependency injection styles: constructor (recommended), field, setter
- [ ] Know when @Autowired is required vs. implicit (single constructor → no annotation needed)
- [ ] Understand @Primary vs @Qualifier for resolving multiple bean implementations
- [ ] Understand @RequiredArgsConstructor (Lombok) as shorthand for constructor injection on final fields
- [ ] Review @ComponentScan, @SpringBootApplication, and how beans are discovered

## Spring Data JPA / Hibernate Stack

- [ ] Solidify the stack: Spring Data JPA → JPA spec → Hibernate → JDBC → DB
- [ ] Know when to use Spring Data JPA vs Spring Data MongoDB (different stores, same pattern)
- [ ] Understand ddl-auto modes: validate, update, create, create-drop — and why validate + manual SQL is production-safe
- [ ] Review @Entity, @Table, @Id, @GeneratedValue(strategy = GenerationType.IDENTITY)
- [ ] Review @Column attributes: nullable, updatable, unique, length
- [ ] Understand @OneToMany / @ManyToOne: mappedBy, @JoinColumn, cascade, fetch type
- [ ] Understand lazy vs eager loading and why lazy can cause issues during JSON serialization
- [ ] Know the @JsonIgnore fix for lazy-loaded collections (and the trade-off)
- [ ] Review @EntityListeners(AuditingEntityListener.class) + @CreatedDate + @LastModifiedDate
- [ ] Know what @EnableJpaAuditing does and where to put it

## Lombok

- [ ] Know @Data, @Getter, @Setter, @Builder, @NoArgsConstructor, @AllArgsConstructor
- [ ] Understand why @Data can be risky on JPA entities (equals/hashCode on lazy collections)
- [ ] Know @Builder requires @AllArgsConstructor to work properly alongside @NoArgsConstructor

## REST Layer (Controller)

- [ ] Review @RestController vs @Controller
- [ ] Review @RequestMapping, @GetMapping, @PostMapping, @PutMapping, @DeleteMapping
- [ ] Know correct HTTP status codes: POST→201, PUT→200, DELETE→204
- [ ] Understand ResponseEntity<T> and how to set status + body
- [ ] Review @PathVariable, @RequestBody, @RequestParam

## Service Layer

- [ ] Understand the interface + impl pattern (@Service on impl, inject by interface)
- [ ] Review the standard update pattern: findById → map → setters → save → orElseThrow
- [ ] Review the delete pattern: existsById check → deleteById → throw if missing
- [ ] Know why you prefer saving the fetched existing entity vs. saving the incoming request entity directly

## Spring Data MongoDB (from structure.md / notes)

- [ ] Review @Document(collection="...") vs @Entity/@Table
- [ ] Understand @EnableMongoAuditing and how it differs from @EnableJpaAuditing
- [ ] Review MongoRepository<T, ID> and derived query methods (findByX, findByXAndY)
- [ ] Know the difference: Spring Data MongoDB does not use Hibernate (no SQL)

## Spring AI / MCP (k3s-mcp project)

- [ ] Review Spring AI @Tool annotation and how it auto-registers tools to an MCP server
- [ ] Understand SSE (WebFlux) vs STDIO transport modes
- [ ] Review spring-ai-mcp-server-webflux-spring-boot-starter and what it auto-configures

## Error Handling & Best Practices

- [ ] Understand @ControllerAdvice for centralized exception→HTTP mapping
- [ ] Know why raw RuntimeException from service is a shortcut (good for now; revisit for production)
- [ ] Review Jackson and how it serializes/deserializes — relies on getters, constructors, or @JsonProperty

## Project-Specific Patterns (commitment-tracker)

- [ ] Review the full entity→repository→service→controller build order
- [ ] Review io/ package (DTOs as Java records) — understand why records are good for DTOs
- [ ] Review mapper/ package pattern (static methods for entity↔DTO conversion)
- [ ] Review application.properties: datasource, ddl-auto, JPA dialect settings
- [ ] Review @EnableJpaAuditing placement in JpaConfig.java
