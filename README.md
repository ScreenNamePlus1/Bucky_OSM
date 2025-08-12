# Bucky
Flutter Prototype Code for P2P Delivery App

A peer-to-peer delivery app for Android written in Flutter (mostly) where customers post food order requests with delivery offers, drivers bid to accept or counter-offer, and mutual selection matches them. Drivers front the cost at restaurants and get reimbursed in-person by customers (including delivery fee/tip). Features include request posting, bidding, real-time tracking, and ratings for trust. Built with Flutter, Firebase, and Google Maps.

## Table of Contents
- [Features](#features)
- [File Structure](#file-structure)
- [Setup Instructions](#setup-instructions)
  - [1. Install Flutter](#1-install-flutter)
  - [2. Set Up Firebase](#2-set-up-firebase)
  - [3. Configure Google Maps](#3-configure-google-maps)
  - [4. Install Dependencies](#4-install-dependencies)
  - [5. Run the App](#5-run-the-app)
  - [6. Deploy to Google Play Store](#6-deploy-to-google-play-store)
- [Limitations](#limitations)
- [Next Steps](#next-steps)

## Features
- **Customer Features**:
  - Post delivery requests with restaurant details, order, estimated cost, and offer (delivery fee + tip).
  - Select drivers from bids based on ratings and counter-offers.
  - Track driver location in real-time.
  - Confirm delivery and rate drivers.
- **Driver Features**:
  - Browse requests, filter by offer or cost, and bid (accept or counter).
  - Navigate to restaurant/customer, update status (e.g., "En Route," "Delivered").
  - Log deliveries and view ratings.
- **Trust Mechanisms**:
  - Mutual ratings after delivery.
  - Profile data (completed jobs, rating) for transparency.
- **Tech**:
  - Flutter for Android UI.
  - Firebase for backend (Firestore, Authentication, Cloud Messaging).
  - Google Maps for location and tracking.

## File Structure
Create the following structure in your Flutter project directory (e.g., `local_delivery_app/`):

```
local_delivery_app/
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── AndroidManifest.xml  # Add Google Maps API key
│   │   │   │   └── res/
│   │   └── build.gradle                # Android config
├── lib/
│   ├── main.dart                       # App entry point
│   ├── models/                        # Data models
│   │   ├── request.dart               # DeliveryRequest model
│   │   ├── bid.dart                   # Bid model
│   │   └── user.dart                  # AppUser model
│   ├── screens/                       # UI screens
│   │   ├── login.dart                 # Phone-based login
│   │   ├── customer_home.dart         # Customer request feed
│   │   ├── driver_home.dart           # Driver request feed
│   │   ├── request_form.dart          # Form to post requests
│   │   ├── bid_selection.dart         # Customer selects driver bids
│   │   └── tracking.dart              # Real-time tracking
│   ├── services/                      # Backend logic
│   │   ├── auth_service.dart          # Firebase Authentication
│   │   ├── firestore_service.dart     # Firestore CRUD operations
│   │   └── location_service.dart      # Geolocator for tracking
├── pubspec.yaml                       # Dependencies and config
├── firebase.json                      # Firebase rules (optional)
└── README.md                          # This file
```

### File Descriptions
- **main.dart**: Initializes Firebase and starts the app with the login screen.
- **models/**: Defines data structures for requests, bids, and users.
- **screens/**: UI for login, customer/driver home, request posting, bid selection, and tracking.
- **services/**: Handles Firebase auth, Firestore operations, and location updates.
- **pubspec.yaml**: Lists Flutter dependencies.
- **android/app/src/main/AndroidManifest.xml**: Configures Android permissions and Google Maps.

## Setup Instructions

### 1. Install Flutter
- **Download Flutter**: Install from [flutter.dev](https://flutter.dev/docs/get-started/install).
- **Set Up Environment**:
  - Install Flutter SDK and add to PATH.
  - Install Android Studio with Android SDK (API 33+ recommended).
  - Run `flutter doctor` to verify setup (ensure Android toolchain and emulator are ready).
- **Create Project**:
  ```bash
  flutter create local_delivery_app
  cd local_delivery_app
  ```

### 2. Set Up Firebase
- **Create Firebase Project**:
  - Go to [console.firebase.google.com](https://console.firebase.google.com).
  - Create a new project (e.g., "Local Delivery").
  - Enable Firestore, Authentication (Phone provider), and Cloud Messaging.
- **Add Android App**:
  - In Firebase Console, add an Android app.
  - Use package name: `com.example.local_delivery_app` (or customize in `android/app/build.gradle`).
  - Download `google-services.json` and place it in `android/app/`.
- **Configure Firestore Rules**:
  - Create `firestore.rules` in the project root (or edit via Firebase Console):
    ```javascript
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read: if request.auth != null;
          allow write: if request.auth.uid == userId;
        }
        match /requests/{requestId} {
          allow read: if request.auth != null;
          allow write: if request.auth.uid == resource.data.customerId || resource.data.driverId == request.auth.uid;
        }
        match /bids/{bidId} {
          allow read, write: if request.auth != null;
        }
      }
    }
    ```
  - Deploy rules:
    ```bash
    firebase deploy --only firestore:rules
    ```
    (Requires Firebase CLI: `npm install -g firebase-tools`).

### 3. Configure Google Maps
- **Get API Key**:
  - Go to [Google Cloud Console](https://console.cloud.google.com).
  - Create a project or use existing.
  - Enable Maps SDK for Android and Places API.
  - Generate an API key (restrict to Android apps with your package name).
- **Update AndroidManifest**:
  - Edit `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <manifest ...>
      <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY"/>
      </application>
      <!-- Add permissions -->
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
      <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    </manifest>
    ```
  - Add at the top:
    ```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    ```

### 4. Install Dependencies
- Update `pubspec.yaml` with:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    firebase_core: ^3.6.0
    cloud_firestore: ^5.4.4
    firebase_auth: ^5.3.1
    firebase_messaging: ^15.1.3
    google_maps_flutter: ^2.9.0
    geolocator: ^13.0.1
    uuid: ^4.5.1
  ```
- Run the following command in the project directory to fetch dependencies
  ```bash
  flutter pub get
  ```

### 5. Run the App
- **Set Up Emulator**:
  - In Android Studio, configure an Android emulator (Pixel 6, API 33) or connect a physical Android device (USB debugging enabled).
- **Copy Code**:
  - Create the files listed in [File Structure](#file-structure) and paste the provided code (from previous response).
  - Ensure all files are in the correct `lib/` subdirectories.
- **Run**:
  ```bash
  flutter run
  ```
  - Select emulator/device.
  - App will launch with a login screen (phone-based, simplified for demo).
  - Test as customer (post request, select bid) or driver (bid, track).

### 6. Deploy to Google Play Store
- **Build Release**:
  ```bash
  flutter build appbundle --release
  ```
  - Outputs `build/app/outputs/bundle/release/app-release.aab`.
- **Google Play Console**:
  - Create account ($25 one-time fee).
  - Upload AAB, add app details (name, description, screenshots).
  - Include a privacy policy URL (e.g., hosted on a free site like Google Sites) stating no in-app payments and data usage (location, phone).
  - Submit for review (1-7 days).
- **Tips**:
  - Use high-quality screenshots (use Android Studio’s emulator screenshot tool).
  - Optimize listing with keywords like "local delivery," "food pickup."

## Limitations
- **Authentication**: Uses simplified phone auth (no SMS flow). For production, implement full Firebase Phone Auth.
- **Location**: Basic tracking with Geolocator. Add GeoFire for scalable geolocation queries.
- **Bidding**: One-round bids. Add in-app messaging for negotiations if needed.
- **Trust Features**: Basic ratings. Expand with receipt uploads or ID verification.
- **Scalability**: Handles small user base. Optimize Firestore for larger scale.

## Next Steps
- **Test Locally**: Use emulator to verify request posting, bidding, and tracking.
- **Enhance UI**: Add polished designs (Figma mockups available on request).
- **Add Features**: Receipt uploads, negotiation chat, or driver verification.
- **Hire Developer**: For production, engage a Flutter dev to refine and test ($7K-$25K for MVP).
- **Local Marketing**: Promote via local social media, flyers, or word-of-mouth.

---

### Notes
- **Code Source**: Assumes you have the code from the prior response (files like `main.dart`, `request.dart`, etc.). If missing, request specific files.
- **Environment**: Tested with Flutter 3.24.x, Firebase SDKs as listed, and Android Studio 2023.x.
- **Support**: For issues, check `flutter doctor`, Firebase Console logs, or ask for specific debugging steps.

This README provides a clear path to set up and run the prototype. Create each file as listed, follow the setup steps, and you’ll have a working app to test locally. If you need help with a specific step (e.g., Firebase rules, Maps API setup, or generating screenshots), let me know, and I can provide detailed guidance or additional resources!
