# ── Stage 1: Build ────────────────────────────────────────────────────────────
# Sets up Flutter, installs dependencies, runs analyze + tests, and produces
# a release Flutter-web build.
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.19.6
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# System dependencies required by Flutter
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Install the pinned Flutter SDK
RUN curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C /opt

# Disable analytics and pre-cache web artifacts
RUN flutter config --no-analytics \
 && flutter config --enable-web \
 && flutter precache --web

WORKDIR /app

# Restore packages first so the layer is cached when only sources change
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Quality gate: analyze and test before building
RUN flutter analyze
RUN flutter test

# Produce a release web build
RUN flutter build web --release

# ── Stage 2: Serve ────────────────────────────────────────────────────────────
# Copies only the compiled assets into a minimal nginx image.
FROM nginx:1.25-alpine AS runner

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
