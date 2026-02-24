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
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Java 17 OpenJDK
# -----------------------------
RUN apt-get update && apt-get install -y openjdk-17-jdk unzip wget curl git \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Microsoft package repo
# -----------------------------
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb

# -----------------------------
# Install .NET 10 SDK with script
# -----------------------------
RUN wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet \
    && rm /tmp/dotnet-install.sh

# Make dotnet available globally
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="$DOTNET_ROOT:$PATH"

# Verify installation
RUN dotnet --info

# -----------------------------
# Install Android SDK 36 command-line tools
# -----------------------------
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && cd $ANDROID_SDK_ROOT/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip \
    && rm cmdline-tools.zip \
    && mv cmdline-tools latest

# Accept licenses
RUN yes | sdkmanager --licenses

# Install correct SDK
RUN sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# Apply write permissions for runner user
RUN chown -R runner:runner /opt/android-sdk

# -----------------------------
# GitHub Actions runner
# -----------------------------
RUN mkdir -p /home/runner/actions-runner \
    && cd /home/runner/actions-runner \
    && curl -L -o actions-runner.tar.gz \
       https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar -xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R runner:runner /home/runner

# -----------------------------
# Entrypoints
# -----------------------------
COPY entrypoint.sh /entrypoint.sh
COPY entrypoint-runner.sh /home/runner/entrypoint-runner.sh
RUN chmod +x /entrypoint.sh /home/runner/entrypoint-runner.sh

# -----------------------------
# Environment
# -----------------------------
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:/usr/share/dotnet:/home/runner/.dotnet/tools"

WORKDIR /home/runner
USER root

ENTRYPOINT ["/entrypoint.sh"]
