# Adapted from https://github.com/Phyremaster/papermc-docker

# Java 17 base
FROM eclipse-temurin:17

RUN apt-get update \
    && apt-get install -y wget \
    && apt-get install -y jq \
    && apt-get install -y p7zip-full \
    && apt-get install -y nano \
    && apt-get install -y xxd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /paper \
    && mkdir /paper/Worlds \
    && mkdir /backups \
    && mkdir /scripts

ADD ./scripts /scripts/

RUN chmod -R +x /scripts/

# Create a named pipe for input into the server console
RUN mkfifo /tmp/consolepipe
RUN chown :1000 /tmp/consolepipe
RUN chmod g=rw /tmp/consolepipe

# Define volumes
VOLUME /paper
VOLUME /backups

# Create the filesystem group to allow access to volume data
RUN groupadd -g 1000 minecraft

# Create the local user
RUN useradd --shell /bin/bash minecraft -g minecraft -m -d /paper

# Switch to the local user
USER minecraft

# Run setup script
CMD ["bash", "./scripts/entry.sh"]

# Container ports
EXPOSE 25565/tcp
EXPOSE 25575/tcp
