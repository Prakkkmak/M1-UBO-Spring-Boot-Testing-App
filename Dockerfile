# Stage 1 : Build
FROM eclipse-temurin:17-jdk AS build

WORKDIR /app

# Copier les fichiers Gradle wrapper et de config en premier (cache des layers)
COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle ./

# Télécharger les dépendances (layer cachée tant que build.gradle ne change pas)
RUN ./gradlew dependencies --no-daemon

# Copier le code source
COPY src/ src/

# Build du JAR sans exécuter les tests (ils nécessitent la DB)
RUN ./gradlew bootJar --no-daemon

# Stage 2 : Runtime
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copier le JAR depuis le stage de build
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
