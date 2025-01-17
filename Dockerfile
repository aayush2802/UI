# Use the latest Dart SDK (Change this if a newer version is available)
FROM dart:3.5.4 AS build

# Set working directory
WORKDIR /app

# Copy the pubspec files first to optimize caching
COPY pubspec.yaml /app/
COPY pubspec.lock /app/

# Get dependencies
RUN dart pub get

# Copy the rest of the application
COPY . /app

# Build the app (Modify this if using Flutter Web)
RUN dart compile exe bin/main.dart -o app

# Use a minimal runtime image
FROM debian:buster-slim
WORKDIR /app
COPY --from=build /app/app .
CMD ["./app"]
