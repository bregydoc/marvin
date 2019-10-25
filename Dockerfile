# Auto Generated Dockerfile

FROM openjdk:8-jre-alpine
LABEL maintainer="dev@ballerina.io"

WORKDIR /home/ballerina
COPY main.jar /home/ballerina 

EXPOSE  3300
ENTRYPOINT ["java", "-jar", "main.jar"]
