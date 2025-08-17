# Bucky_OSM

Bucky_OSM is a peer-to-peer delivery app built with Flutter, integrating OpenStreetMap (OSM) for map visualization, geocoding, and routing. It allows drivers to set delivery areas and customers to request deliveries, leveraging OSM's open-source geospatial data for cost-effective mapping.

## Features
- **Driver Features**: Set custom delivery areas on an OSM map, accept/reject delivery requests, track locations.
- **Customer Features**: Request deliveries, view driver locations, track delivery status.
- **OSM Integration**: Uses `flutter_osm_plugin` for map rendering and `osm_api` for geocoding/routing.
- **Firebase Backend**: Stores user data, delivery requests, and map polygons via Firestore and GeoFire.

## Prerequisites
- Flutter SDK (v3.0.0+)
- Dart (v2.17.0+)
- Firebase account (for authentication and Firestore)
- OSM account (optional, for contributing to map data)
- Android Studio or VS Code for development

## Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ScreenNamePlus1/Bucky_OSM.git
   cd Bucky_OSM

~/bucky_osm/
├── lib/
│   ├── app_state.dart
│   ├── auth_user.dart
│   ├── maps_user.dart
│   ├── providers.dart
│   ├── main.dart
│   ├── models/
│   │   ├── bid.dart
│   │   ├── request.dart
│   │   ├── user.dart
│   ├── screens/
│   │   ├── bid_form.dart
│   │   ├── bid_selection.dart
│   │   ├── customer_home.dart
│   │   ├── delivery_area_editor.dart
│   │   ├── driver_home.dart
│   │   ├── login.dart
│   │   ├── request_form.dart
│   │   ├── tracking.dart
│   ├── services/
│   │   ├── Auth_service.dart
│   │   ├── firestore_services.dart
│   │   ├── location_service.dart
│   │   ├── osm_service.dart
├── test/
│   ├── bid_test.dart
├── firebase.json
├── pubspec.yaml


# Getting Started with a Flutter Project from GitHub

This guide will walk you through the process of cloning a Flutter project from GitHub and preparing it for compilation. You do not need to manually create any XML files; these are automatically handled by the Flutter framework.

## Prerequisites

Before you begin, ensure that you have the Flutter SDK installed and configured on your machine. You can verify your setup by running:

```bash
flutter doctor

This command will check for all necessary dependencies and tools required for development.
Step 1: Clone the Project
The first step is to get the project files from the GitHub repository onto your local machine.
 * Open your terminal or command prompt.
 * Navigate to the directory where you want to store the project.
 * Use the git clone command with the repository URL. You can find this URL by clicking the "Code" button on the GitHub page.
   git clone [your-github-repo-url]

   Example:
   git clone [https://github.com/your-username/your-flutter-app.git](https://github.com/your-username/your-flutter-app.git)

Step 2: Navigate to the Project Directory
Once the cloning process is complete, a new folder will be created. Change your current directory to this new project folder.
cd your-flutter-app

Step 3: Get the Dependencies
Flutter projects rely on various packages and libraries. These are listed in the pubspec.yaml file. You must download these dependencies before you can run or build the application.
Run the following command inside your project directory:
flutter pub get

Step 4: Run or Build the App
After the dependencies are installed, you can launch the app on a connected device or an emulator, or you can compile it for a specific platform.
 * To run the app on a connected device or emulator:
   flutter run

 * To build a release version for Android:
   flutter build apk --release

 * To build a release version for iOS (requires macOS and Xcode):
   flutter build ipa

 * To build for the web:
   flutter build web

After the build process, the compiled files will be located in the build directory of your project.

