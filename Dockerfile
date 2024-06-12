# Install dependencies and build the app in a build environment
FROM debian:latest AS build-env

# Install flutter dependencies
RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 sed
RUN apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git -b 3.22.2 --single-branch /usr/local/flutter

# Set flutter path
ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

# Download Dart SDK
RUN flutter doctor

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Run pre-build commands
RUN flutter pub get
RUN flutter gen-l10n

# Build the app
RUN flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://npm.elemecdn.com/canvaskit-wasm@0.37.1/bin/ --base-href "/"

# Copy assets to build/web
RUN cp -r assets build/web/assets/

# Copy tree-shaked icons
# RUN cp assets/fonts/MaterialIcons-Regular.otf build/web/assets/fonts/MaterialIcons-Regular.otf

# Built web root is at /app/build/web
# Create the run-time image
FROM nginx:1.23.3-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html/

# Copy nginx config
COPY --from=build-env /app/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
