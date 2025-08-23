FROM mcr.microsoft.com/devcontainers/java:17

# Install additional development tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    tree \
    htop \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (Docker-in-Docker feature will handle the daemon)
RUN curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz -o docker.tgz \
    && tar -xzf docker.tgz \
    && mv docker/docker /usr/local/bin/ \
    && rm -rf docker docker.tgz

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Set up Maven wrapper
RUN mvn -N wrapper:wrapper

# Create development scripts directory
RUN mkdir -p /workspaces/scripts

# Set environment variables
ENV JAVA_HOME=/usr/local/openjdk-17
ENV MAVEN_HOME=/usr/local/share/maven
ENV PATH=$PATH:$MAVEN_HOME/bin:$JAVA_HOME/bin

# Create a convenient alias for Maven
RUN echo 'alias mvnw="./mvnw"' >> /home/vscode/.bashrc

# Set working directory
WORKDIR /workspaces

# Switch to vscode user
USER vscode
