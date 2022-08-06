FROM openjdk:17-jdk-slim

COPY src/rico_console-all.jar /opt/
COPY src/rico_console-all.jar app/
COPY src/docker-entrypoint.sh /opt/
COPY src/docker-entrypoint.sh app/

RUN apt update

RUN apt-get -y install wget
RUN apt-get -y install git

#ENV REVIEWDOG_VERSION=v0.14.1
#RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

RUN ["chmod", "+x", "opt/docker-entrypoint.sh"]
# RUN ["chmod", "+x", "opt/rico_console-all.jar"]

# ☢Caution!!☢ ☢Caution!!☢ ☢Caution!!☢
#
#  Path must start with a slash! Otherwise you will get the following error on github actions!
# | docker: Error response from daemon: failed to create shim:
# | OCI runtime create failed: container_linux.go:380: starting container process caused: exec:
# | "docker-entrypoint.sh": executable file not found in $PATH: unknown.
#
#  x : ["app/docker-entrypoint.sh"]
#  o : ["/app/docker-entrypoint.sh"]
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
