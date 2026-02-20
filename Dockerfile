FROM ubuntu:22.04

ARG RUNNER_VERSION=2.328.0
ENV RUNNER_VERSION=${RUNNER_VERSION}

# Prevent tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive

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
    libfontconfig1 \
    libfreetype6 \
    libx11-6 \
    libxrender1 \
    libxext6 \
    libgdiplus \
    libicu70 \
    libxml2 \
    zlib1g \
    docker.io \
    gosu \
    jq \
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
# Create runner user
# -----------------------------
RUN useradd -m -s /bin/bash runner

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
# Create runner user
# -----------------------------
RUN useradd -m -s /bin/bash runner
