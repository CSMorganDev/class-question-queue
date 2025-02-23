# class question queue flutter app

This is mobile app that works in tandem with an ESP32 IoT device.
It adds to a queue on the device keeps in-sync using MQTT feeds which both subscribe too.

## Getting Started

### Prerequisites
Ensure you have the following installed on your system:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Android Studio or Visual Studio Code (with Flutter extension)
- Xcode (for iOS development)

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/CSMorganDev/class-question-queue.git
   ```
2. Navigate to the project directory:
   ```sh
   cd class_question_queue
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Run the application:
   ```sh
   flutter run
   ```

## Build Release APK/iOS
To generate a release build for Android:
```sh
flutter build apk
```
For iOS:
```sh
flutter build ios
```

