FROM openjdk:17-jdk-slim

COPY src/rico_console-all.jar /app/rico_console-all.jar
COPY src/docker-entrypoint.sh /app/docker-entrypoint.sh

RUN apt update
RUN apt-get -y install wget

ENV REVIEWDOG_VERSION=v0.14.1
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

RUN ["chmod", "+x", "app/docker-entrypoint.sh"]

ENTRYPOINT ["app/docker-entrypoint.sh"]
