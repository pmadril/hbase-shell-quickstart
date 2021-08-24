FROM openjdk:8-jdk-alpine

LABEL Pablo Madril <pmadril@gmail.com>

RUN apk update && \
    apk upgrade


RUN apk --update add git less openssh && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/* && \
    apk add --no-cache curl tar bash procps

# Downloading and installing Maven
ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Checking download hash" \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  \
  && echo "Unziping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
  && curl -fsSL -o /tmp/btexamples.zip https://github.com/GoogleCloudPlatform/cloud-bigtable-examples/archive/refs/heads/master.zip \
  && mkdir -p /home/btexamples \
  && unzip -d /home/btexamples /tmp/btexamples.zip \
  && cd /home/btexamples/cloud-bigtable-examples-master/quickstart/ \
  && mvn clean install -DskipTests \
  && mvn -Dexec.skip=true exec:java

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV EMULATOR_PORT 8086
ENV PROJECT dev
ENV INSTANCE dev
ENV USE_EMULATOR 'true'
ENV EMULATOR_HOST 'local'

ARG CREDENTIALS=/app/sa_bigtable.json
WORKDIR /home/btexamples/cloud-bigtable-examples-master/quickstart/
COPY hbase-site.xml src/main/resources/hbase-site.xml

# Run HBase-shell
VOLUME ["/app/sa_bigtable.json"]
CMD if [[ $USE_EMULATOR == 'true' ]];  then if [[ $EMULATOR_HOST == 'local' ]]; then export BIGTABLE_EMULATOR_HOST=$(ip -4 route show default | cut -d' ' -f3)":"$EMULATOR_PORT; export CREDENTIALS=''; echo "USING EMULATOR ON: "$BIGTABLE_EMULATOR_HOST;  else export BIGTABLE_EMULATOR_HOST=$EMULATOR_HOST":"$EMULATOR_PORT; export CREDENTIALS=''; echo "USING EMULATOR ON: "$BIGTABLE_EMULATOR_HOST; fi else echo "NO EMULATOR - USING CREDENTIALS IN: "$CREDENTIALS; echo "YOU MUST SET PROJECT AND INSTANCE - ACTUAL VALUES PROJECT: "$PROJECT" - INSTANCE: "$INSTANCE; export GOOGLE_APPLICATION_CREDENTIALS=$CREDENTIALS; export BIGTABLE_EMULATOR_HOST=""; fi && mvn clean package exec:java -Dbigtable.projectID=$PROJECT -Dbigtable.instanceID=$INSTANCE -Dquickstart.emulatorhost=$BIGTABLE_EMULATOR_HOST -Dquickstart.credentials=$CREDENTIALS
