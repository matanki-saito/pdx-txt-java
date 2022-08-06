FROM openjdk:17-jdk-slim

COPY build/libs/rico_console-0.0.1-all.jar /app/rico_console-0.0.1-all.jar
COPY src/main/resources/docker-entrypoint.sh /app/docker-entrypoint.sh

RUN apt update
RUN apt-get -y install wget

ENV REVIEWDOG_VERSION=v0.14.1
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

RUN ["chmod", "+x", "app/docker-entrypoint.sh"]

ENTRYPOINT ["app/docker-entrypoint.sh"]
