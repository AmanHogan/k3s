# Stage 1: build the fat JAR using the Maven wrapper bundled in the project
FROM eclipse-temurin:25-jdk AS build
WORKDIR /app
# Install maven (mvnw needs mvn in PATH on some images; use wrapper with -Dmaven.wrapper.skip=false)
# Copy wrapper first so dependency layer is cached
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B
COPY src ./src
RUN ./mvnw package -DskipTests

# Stage 2: minimal JRE runtime
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
