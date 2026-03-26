FROM ubuntu:22.04

ARG RUNNER_VERSION=2.328.0
ENV RUNNER_VERSION=${RUNNER_VERSION}

# Prevent tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Create runner user
# -----------------------------
RUN useradd -m -s /bin/bash runner

# -----------------------------
# Base dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    git \
    wget \
    ca-certificates \
    bash \
    zip \
    jq \
    docker.io \
    gosu \
    libfontconfig1 \
    libfreetype6 \
    libx11-6 \
    libxrender1 \
    libxext6 \
    libgdiplus \
    libicu70 \
    libxml2 \
    zlib1g \
    sudo \
    python3 \
    build-essential \
    npm \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Java 17 OpenJDK
# -----------------------------
RUN apt-get update && apt-get install -y openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# -----------------------------
# Install Microsoft package repo
# -----------------------------
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb

# -----------------------------
# Install .NET 10 SDK into user directory
# -----------------------------
USER runner
RUN mkdir -p /home/runner/.dotnet
ENV DOTNET_ROOT=/home/runner/.dotnet
ENV PATH="$DOTNET_ROOT:$PATH:$DOTNET_ROOT/tools"

RUN wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir $DOTNET_ROOT \
    && rm /tmp/dotnet-install.sh

# Make .NET globally visible for SonarScanner & other tools
USER root
RUN ln -s /home/runner/.dotnet /usr/share/dotnet
USER runner

# Verify installation
RUN dotnet --info

# -----------------------------
# Install Android SDK command-line tools
# -----------------------------
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

USER root
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && cd $ANDROID_SDK_ROOT/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O tools.zip \
    && unzip tools.zip \
    && rm tools.zip \
    && mv cmdline-tools latest \
    && chown -R runner:runner /opt/android-sdk

USER runner
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.1.0"

# -----------------------------
# Install Node.js 20 LTS
# -----------------------------
USER root
RUN apt-get update \
    && apt-get remove -y nodejs npm libnode-dev \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v

# -----------------------------
# Install Emscripten & Node dependencies for Browser/WASM
# -----------------------------
USER runner
ENV EMSDK_DIR=/home/runner/emsdk
RUN git clone https://github.com/emscripten-core/emsdk.git $EMSDK_DIR \
    && cd $EMSDK_DIR \
    && ./emsdk install latest \
    && ./emsdk activate latest \
    && echo "source $EMSDK_DIR/emsdk_env.sh" >> /home/runner/.bashrc

ENV PATH="$EMSDK_DIR/upstream/emscripten:$PATH"

# -----------------------------
# GitHub Actions runner
# -----------------------------
USER root
RUN mkdir -p /home/runner/actions-runner \
    && cd /home/runner/actions-runner \
    && curl -L -o actions-runner.tar.gz \
       https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar -xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R runner:runner /home/runner

# -----------------------------
# Add runner to docker group at build time
# -----------------------------
RUN groupadd -g 999 docker || true \
    && usermod -aG docker runner    

# -----------------------------
# Entrypoints
# -----------------------------
COPY entrypoint.sh /entrypoint.sh
COPY entrypoint-runner.sh /home/runner/entrypoint-runner.sh
RUN chmod +x /entrypoint.sh /home/runner/entrypoint-runner.sh

# -----------------------------
# Environment
# -----------------------------
ENV PATH="${PATH}:/home/runner/.dotnet/tools"
WORKDIR /home/runner
USER runner

ENTRYPOINT ["/entrypoint.sh"]