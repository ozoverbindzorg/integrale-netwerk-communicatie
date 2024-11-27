FROM openjdk:24-jdk-bookworm
LABEL maintainer="roland@headease.nl"

# Install native compilation dependencies.
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y gcc g++ make apt-utils iputils-ping curl

# Install Node from NodeSource.
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Jekyll for Ubuntu/Debian: https://jekyllrb.com/docs/installation/ubuntu/
RUN apt-get install -y ruby-full build-essential zlib1g-dev plantuml
RUN gem install -N jekyll bundler

RUN mkdir /app
WORKDIR /app

# Install the FHIR Shorthand transfiler:
RUN npm i -g fsh-sushi

# Download the IG publisher.
RUN wget "https://raw.githubusercontent.com/FHIR/ig-guidance/refs/heads/master/_updatePublisher.sh"  -O _updatePublisher.sh && chmod +x _updatePublisher.sh && bash ./_updatePublisher.sh -y && chmod +x *.sh *.bat

ADD ig.ini .
ADD sushi-config.yaml .

CMD ["bash", "_genonce.sh"]
