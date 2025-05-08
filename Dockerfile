FROM openjdk:24-jdk-bookworm
LABEL maintainer="roland@headease.nl"

# Install native compilation dependencies.
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y gcc g++ make apt-utils iputils-ping

# Install Node from NodeSource.
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Jekyll for Ubuntu/Debian: https://jekyllrb.com/docs/installation/ubuntu/
RUN apt-get install -y ruby-full build-essential zlib1g-dev plantuml
RUN gem install -N jekyll bundler

RUN mkdir /workspace
WORKDIR /workspace

# Install the FHIR Shorthand transfiler:
RUN npm i -g fsh-sushi

## Download the IG publisher.
COPY ./_updatePublisher.sh .
RUN chmod +x ./_updatePublisher.sh
RUN bash ./_updatePublisher.sh -y
RUN chmod +x *.sh *.bat

### Pre-fill the /root/.fhir directory
RUN cd /tmp && \
    git clone https://github.com/openhie/empty-fhir-ig-custom.git && \
    cd ./empty-fhir-ig-custom && \
    bash _updatePublisher.sh -y && \
    bash _genonce.sh || true && \
    cd /tmp && \
    rm -Rf ./empty-fhir-ig-custom

CMD ["bash", "_genonce.sh"]
