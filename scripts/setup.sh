#!/bin/bash

# Adapted from https://github.com/Phyremaster/papermc-docker

cd paper

# Load server config
typeset -A config
config=( # defaults
  [world_name]="world"
  [max_backups]="5"
  [backup_time_min]="30"
  [backup_logging]="true"
  [minecraft_version]="latest"
  [paper_build]="latest"
  [java_home]="/opt/java/openjdk"
  [java_opts]="-Xms4G -Xmx4G"
  [jar_override]=""
)
CONFIG_FILE=paper-docker.conf
if test -f "$CONFIG_FILE"; then
  echo "Config file found, loading config"
  echo "If configuration is not loading correctly, make sure option names are correct and the file has unix line endings"
  while IFS= read -r line; do
    if printf '%s' "$line" | grep -F = &>/dev/null
    then
      varname=$(printf '%s' "$line" | cut -d '=' -f 1)
      config[$varname]=$(printf '%s' "$line" | cut -d '=' -f 2-)
    fi
  done < ${CONFIG_FILE}
fi

MC_VERSION=${config[minecraft_version]}
PAPER_BUILD=${config[paper_build]}

export JAVA_HOME=${config[java_home]}
JAVA_VERSION=$("${JAVA_HOME}/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
echo "Using Java ${JAVA_VERSION} @ ${JAVA_HOME}"

JAR_OVERRIDE="${config[jar_override]}"
if [ "${JAR_OVERRIDE}" = "" ]
then
  # Get version information and build download URL and jar name
  URL=https://papermc.io/api/v2/projects/paper
  if [ "${MC_VERSION}" = "latest" ]
  then
    # Get the latest MC version
    MC_VERSION=$(wget -qO - $URL | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
  fi
  URL=${URL}/versions/${MC_VERSION}
  if [ "${PAPER_BUILD}" = "latest" ]
  then
    # Get the latest build
    PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
  fi

  JAR_NAME=paper-${MC_VERSION}-${PAPER_BUILD}.jar
  URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

  # Update if necessary
  if [ ! -e ${JAR_NAME} ]
  then
    # Remove old server jar(s)
    rm -f *.jar

    # Download new server jar
    wget ${URL} -O ${JAR_NAME}

    # If this is the first run, accept the EULA
    if [ ! -e eula.txt ]
    then
      # Run the server once to generate eula.txt
      ${JAVA_HOME}/bin/java -jar ${JAR_NAME}
      # Edit eula.txt to accept the EULA
      sed -i 's/false/true/g' eula.txt
    fi
  fi
fi

# Start server
exec /scripts/start.sh "${config[world_name]}" "${JAR_NAME}" "${JAR_OVERRIDE}" "${config[java_opts]}" "${config[max_backups]}" "${config[backup_time_min]}" "${config[backup_logging]}"
#todo:  users
