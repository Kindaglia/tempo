# Use Ubuntu as base image
FROM ubuntu:22.04

# Avoid interactive dialog during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Install required packages including OpenJDK
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download and install Android SDK Command-line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm cmdline-tools.zip

# Accept licenses and install required Android SDK packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Grant execute permission to gradlew
RUN chmod +x ./gradlew

# Build the project (skipping lint)
RUN ./gradlew clean assembleDebug -x lint

# Default command (also skipping lint)
CMD ["./gradlew", "assembleDebug", "-x", "lint"] 