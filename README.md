# Bucky

![](https://raw.githubusercontent.com/ScreenNamePlus1/Bucky/main/1755008421060.jpg)



Flutter Prototype Code for P2P Delivery App

A peer-to-peer delivery app for Android written in Flutter, where customers post food order requests with delivery offers, drivers bid to accept or counter-offer, and mutual selection matches them. Drivers front the cost at restaurants and get reimbursed in-person by customers (including delivery fee/tip). Features include request posting, bidding, real-time tracking, ratings for trust, GeoFire for location-based driver matching, and Firebase Phone Authentication for secure sign-in. Built with Flutter, Firebase, and Google Maps.

## Table of Contents
- [Features](#features)
- [File Structure](#file-structure)
- [Setup Instructions](#setup-instructions)
  - [1. Install Flutter](#1-install-flutter)
  - [2. Set Up Firebase](#2-set-up-firebase)
  - [3. Configure Google Maps](#3-configure-google-maps)
  - [4. Configure GeoFire and Phone Auth](#4-configure-geofire-and-phone-auth)
  - [5. Install Dependencies](#5-install-dependencies)
  - [6. Run the App](#6-run-the-app)
  - [7. Deploy to Google Play Store](#7-deploy-to-google-play-store)
- [Firebase Costs](#firebase-costs)
- [Limitations](#limitations)
- [Next Steps](#next-steps)
- [Contributing](#contributing)

## Features
- **Customer Features**:
  - Post delivery requests with restaurant details, order, estimated cost, and offer (delivery fee + tip).
  - View nearby drivers (within 5 km) using GeoFire for location-based matching.
  - Select drivers from bids based on ratings and counter-offers.
  - Track driver location in real-time.
  - Confirm delivery and rate drivers.
- **Driver Features**:
  - Browse requests, filter by offer or cost, and bid (accept or counter).
  - Automatically update location in real-time for customer visibility.
  - Navigate to restaurant/customer, update status (e.g., "En Route," "Delivered").
  - Log deliveries and view ratings.
- **Trust Mechanisms**:
  - Mutual ratings after delivery.
  - Profile data (completed jobs, rating) for transparency.
  - Verified phone numbers via Firebase Phone Authentication.
- **Tech**:
  - Flutter for Android UI.
  - Firebase for backend (Firestore, Authentication, Cloud Messaging).
  - Google Maps for location and tracking.
  - GeoFire for real-time location queries.

## File Structure
The project follows this structure in the `local_delivery_app/` directory:

```
local_delivery_app/
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── AndroidManifest.xml  # Add Google Maps API key, permissions
│   │   │   │   └── res/
│   │   └── build.gradle                # Android config with GeoFire
├── lib/
│   ├── main.dart                       # App entry point
│   ├── providers/                      # State management
│   │   └── app_state.dart             # Manages user role and ID
│   ├── models/                        # Data models
│   │   ├── request.dart               # DeliveryRequest model
│   │   ├── bid.dart                   # Bid model
│   │   └── user.dart                  # AppUser model with GeoPoint, geohash
│ | ├── screens/                       # UI screens
│   │   ├── login.dart                 # Phone-based login with OTP
│   │   ├── customer_home.dart         # Customer request feed with nearby drivers
│   │   ├── driver_home.dart           # Driver request feed with location updates
│   │   ├── request_form.dart          # Form to post requests
│   │   ├── bid_form.dart              # Form for drivers to place bids
│   │   ├── bid_selection.dart         # Customer selects driver bids
│   │   └── tracking.dart              # Real-time tracking
│   ├── services/                      # Backend logic
│   │   ├── auth_service.dart          # Firebase Authentication with Phone Auth
│   │   ├── firestore_service.dart     # Firestore CRUD with GeoFire queries
│   │   └── location_service.dart      # Geolocator and GeoFire for tracking
├── pubspec.yaml                       # Dependencies and config
├── firebase.json                      # Firebase configuration
└── README.md                          # This file
```

### File Descriptions
- **main.dart**: Initializes Firebase, Provider, and starts with the login screen.
- **providers/app_state.dart**: Manages user role (customer/driver) and ID.
- **models/**: Defines data structures for requests, bids, and users (with GeoPoint/geohash for GeoFire).
- **screens/**: UI for login (OTP-based), customer/driver home, request posting, bid submission, bid selection, and tracking.
- **services/**: Handles Firebase auth (Phone Auth), Firestore operations (GeoFire queries), and location updates.
- **pubspec.yaml**: Lists Flutter dependencies, including `geoflutterfire2`.
- **android/app/src/main/AndroidManifest.xml**: Configures Android permissions, Google Maps, and internet access.
- **android/app/build.gradle**: Includes GeoFire Android library.
- **firebase.json**: Configures Firestore rules for secure access.

## Setup Instructions

### 1. Install Flutter
- **Download Flutter**: Install from [flutter.dev](https://flutter.dev/docs/get-started/install).
- **Set Up Environment**:
  - Install Flutter SDK and add to PATH.
  - Install Android Studio with Android SDK (API 33+ recommended).
  - Run `flutter doctor` to verify setup (ensure Android toolchain and emulator are ready).
- **Clone Repository**:
  ```bash
  git clone https://github.com/ScreenNamePlus1/Bucky.git
  cd local_delivery_app
  ```

### 2. Set Up Firebase
- **Create Firebase Project**:
  - Go to [Firebase Console](https://console.firebase.google.com).
  - Create a project (e.g., "Bucky").
  - Enable Firestore, Authentication (Phone provider), and Cloud Messaging.
- **Add Android App**:
  - Add an Android app with package name `com.example.local_delivery_app` (or customize in `android/app/build.gradle`).
  - Download `google-services.json` and place in `android/app/`.
- **Configure Firestore Rules**:
  - See [Configure GeoFire and Phone Auth](#4-configure-geofire-and-phone-auth) for updated rules.

### 3. Configure Google Maps
- **Get API Key**:
  - In [Google Cloud Console](https://console.cloud.google.com), create or use a project.
  - Enable Maps SDK for Android and Places API.
  - Generate an API key (restrict to Android apps with your package name).
- **Update AndroidManifest**:
  - Edit `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <manifest ...>
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
      <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
      <uses-permission android:name="android.permission.INTERNET"/>
      <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY"/>
      </application>
    </manifest>
    ```

### 4. Configure GeoFire and Phone Auth
- **GeoFire Setup**:
  - Add GeoFire dependency in `android/app/build.gradle`:
    ```gradle
    dependencies {
      implementation 'com.firebase:geofire-android-common:3.2.0'
    }
    ```
  - Ensure `geoflutterfire2` is in `pubspec.yaml` (see below).
- **Phone Auth Setup**:
  - In Firebase Console > Authentication > Sign-in Method, enable "Phone" provider.
  - Add SHA-1 and SHA-256 fingerprints:
    ```bash
    cd android
    ./gradlew signingReport
    ```
    Copy SHA-1/SHA-256 from output and add to Firebase Console > Project Settings > Your Apps.
- **Firestore Rules**:
  - Create `firestore.rules` in project root (or edit via Firebase Console):
    ```javascript
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        match /requests/{requestId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && (request.auth.uid == resource.data.customerId || resource.data.driverId == request.auth.uid);
        }
        match /bids/{bidId} {
          allow read, write: if request.auth != null;
        }
      }
    }
    ```
  - Deploy rules (requires Firebase CLI: `npm install -g firebase-tools`):
    ```bash
    firebase deploy --only firestore:rules
    ```

### 5. Install Dependencies
- Update `pubspec.yaml` with:
  ```yaml
  name: local_delivery_app
  description: A peer-to-peer delivery app prototype
  version: 1.0.0

  environment:
    sdk: '>=3.0.0 <4.0.0'

  dependencies:
    flutter:
      sdk: flutter
    firebase_core: ^3.6.0
    cloud_firestore: ^5.4.4
    firebase_auth: ^5.3.1
    firebase_messaging: ^15.1.3
    google_maps_flutter: ^2.9.0
    geolocator: ^13.0.1
    geoflutterfire2: ^2.3.15
    provider: ^6.1.2
    uuid: ^4.5.1
    cupertino_icons: ^1.0.8

  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^4.0.0

  flutter:
    uses-material-design: true
  ```
- Run:
  ```bash
  flutter pub get
  ```

### 6. Run the App
- **Set Up Emulator**:
  - In Android Studio, configure an Android emulator (Pixel 6, API 33) or connect a physical Android device (USB debugging enabled).
- **Copy Code**:
  - Ensure all files from prior instructions are in place (`main.dart`, `app_state.dart`, `request.dart`, `bid.dart`, `user.dart`, `auth_service.dart`, `firestore_service.dart`, `location_service.dart`, `login.dart`, `customer_home.dart`, `driver_home.dart`, `request_form.dart`, `bid_form.dart`, `bid_selection.dart`, `tracking.dart`).
  - Update files with GeoFire and Phone Auth code as provided.
- **Run**:
  ```bash
  flutter run
  ```
  - Test Phone Auth with a fictional number (enable test mode in `auth_service.dart` for development):
    ```dart
    _auth.setAppVerificationDisabledForTesting(true); // Before verifyPhoneNumber
    ```
  - Test GeoFire by setting mock locations in emulator for driver movement.
- **Test Flows**:
  - **Customer**: Log in with phone OTP, post request, view nearby drivers, select bid, track delivery.
  - **Driver**: Log in, browse requests, bid, verify location updates in Firestore (`users` collection).

### 7. Deploy to Google Play Store
- **Build Release**:
  ```bash
  flutter build appbundle --release
  ```
  - Outputs `build/app/outputs/bundle/release/app-release.aab`.
- **Google Play Console**:
  - Create account ($25 one-time fee).
  - Upload AAB, add app details (name, description, screenshots).
  - Update privacy policy to include SMS consent and location usage (e.g., hosted on Google Sites).
  - Submit for review (1-7 days).
- **Tips**:
  - Use Android Studio’s emulator screenshot tool for high-quality screenshots.
  - Optimize listing with keywords: "local delivery," "food pickup," "P2P delivery."

## Firebase Costs
- **Firestore (including GeoFire)**:
  - **Spark Plan**: Free up to 1 GB storage, 20K reads/day, 50K writes/day, 20K deletes/day.
  - **Usage Estimate**: 100 drivers updating locations every 10 seconds for 8 hours (~28K writes/day) and 100 customers querying 5 times/day (~500 reads/day) fits within free limits.
  - **Blaze Plan**: If exceeded, ~$0.06/100K reads, $0.18/100K writes. Unlikely for local MVP.
- **Phone Authentication**:
  - **Spark Plan**: Free for 10 SMS/day.
  - **Blaze Plan**: $0.01–$0.34/SMS (e.g., $0.01 US/Canada). For 100 users/day, 90 SMS cost ~$0.90/day or $27/month.
  - **Mitigation**: Cache auth sessions or add email login (free).
- **Total**: Free for testing (<10 users/day). Budget $20–$50/month on Blaze Plan for 50–100 users/day.

## Limitations
- **GeoFire**:
  - Queries may include false positives near radius edges (requires client-side filtering).
  - Less accurate near poles (not relevant for local use).
- **Phone Auth**:
  - SMS costs escalate on Blaze Plan for high usage.
  - Requires SHA-1/SHA-256 and Play Integrity setup.
- **Authentication**: Current Phone Auth implementation is simplified for testing. Full SMS flow required for production.
- **Location**: Basic tracking with Geolocator and GeoFire. Optimize for battery efficiency in production.
- **Bidding**: One-round bids. Add in-app messaging for negotiations if needed.
- **Scalability**: Handles small user base. Optimize Firestore indexes for larger scale.

## Next Steps
- **Test Locally**: Verify GeoFire queries (nearby drivers in `customer_home.dart`) and Phone Auth OTP flow with 5–10 users.
- **Enhance UI**: Request Figma mockups for polished designs.
- **Add Features**: Implement receipt uploads (Firebase Storage, free up to 1 GB), negotiation chat, or driver verification.
- **Hire Developer**: For production, engage a Flutter dev to refine and test ($7K–$25K for MVP).
- **Local Marketing**: Promote via local social media, flyers, or word-of-mouth.

## Contributing
Contribute to ScreenNamePlus1/Bucky development by creating an account on GitHub. To contribute:
1. Create a GitHub account if you don’t have one.
2. Fork the repository.
3. Create a new branch (`git checkout -b feature/your-feature`).
4. Make changes and commit (`git commit -m "Add your feature"`).
5. Push to your fork (`git push origin feature/your-feature`).
6. Open a pull request.
Please ensure code follows Flutter best practices and includes tests where applicable.

### Additional Notes
- **Missing Files**: The original `README.md` references `request.dart`, `bid.dart`, `bid_selection.dart`, and `tracking.dart`, which weren’t updated in the latest request.
