# Use the official Flutter Docker image with the correct version
FROM ghcr.io/cirruslabs/flutter:3.16.3

# Avoid running as root; create a user for the container
RUN useradd -m flutteruser
USER flutteruser

# Set working directory
WORKDIR /app

# Copy only the pubspec files to optimize caching
COPY pubspec.yaml pubspec.lock /app/

# Fix "dubious ownership" issue by configuring git for the flutter directory
RUN git config --global --add safe.directory /sdks/flutter

# Install Flutter dependencies (use `flutter pub get` instead of `dart pub get`)
RUN flutter pub get

# Copy the rest of the application code
COPY . /app

# Ensure Flutter is properly configured
RUN flutter doctor -v

# Build the Flutter app (adjust according to your target platform, e.g., web, android)
RUN flutter build apk --release

# Define the command to run the app (adjust if needed)
CMD ["flutter", "run"]
