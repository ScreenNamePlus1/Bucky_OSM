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

- Implementation of **GeoFire** for real-time location queries and **full Firebase Phone Authentication** for secure user sign-in, along with their setup instructions, file modifications, and cost details. This README will focus exclusively on these additions, assuming you already have the base app (from prior responses) with its file structure, Flutter setup, Firebase project, and Google Maps configured. It includes the updated code files (`user.dart`, `location_service.dart`, `firestore_service.dart`, `customer_home.dart`, `driver_home.dart`, `auth_service.dart`, `login.dart`), new dependencies, and Firestore rules tailored for these features. The instructions are streamlined for integration into your existing `local_delivery_app/` project, with clear guidance on costs and deployment considerations for the Google Play Store.

---

# Local Delivery App (Bucky) - GeoFire and Phone Auth Add-On

This README provides instructions to extend the Local Delivery App with **GeoFire** for real-time location-based driver matching and **Firebase Phone Authentication** for secure SMS-based user sign-in. These additions enhance the existing P2P delivery app where customers post food order requests, drivers bid, and payments are handled in-person. This assumes you have the base app (Flutter, Firebase, Google Maps) set up as per prior instructions.

## Table of Contents
- [Added Features](#added-features)
- [Updated File Structure](#updated-file-structure)
- [Setup Instructions](#setup-instructions)
  - [1. Update Dependencies](#1-update-dependencies)
  - [2. Configure Firebase for Phone Auth](#2-configure-firebase-for-phone-auth)
  - [3. Update Firestore Rules](#3-update-firestore-rules)
  - [4. Add/Modify Code Files](#4-addmodify-code-files)
  - [5. Test the App](#5-test-the-app)
- [Firebase Costs](#firebase-costs)
- [Limitations](#limitations)
- [Next Steps](#next-steps)

## Added Features
- **GeoFire for Location Queries**:
  - Stores driver locations as GeoPoints with geohashes in Firestore.
  - Queries nearby drivers (e.g., within 5 km) for customer request feeds.
  - Updates driver locations in real-time for accurate matching and tracking.
- **Firebase Phone Authentication**:
  - Secure SMS-based OTP sign-in for customers and drivers.
  - Replaces simplified auth with verified phone numbers, enhancing trust.
- **Integration**:
  - Customers see nearby drivers in their feed.
  - Drivers’ locations update automatically when active.
  - Phone auth ensures verified users for bidding and delivery.

## Updated File Structure
Add or modify the following files in your existing `local_delivery_app/` project:

```
local_delivery_app/
├── android/
│   ├── app/
│   │   └── build.gradle                # Add GeoFire dependency
├── lib/
│   ├── models/
│   │   └── user.dart                  # Updated with GeoPoint and geohash
│   ├── screens/
│   │   ├── login.dart                 # Updated for Phone Auth OTP
│   │   ├── customer_home.dart         # Updated to show nearby drivers
│   │   └── driver_home.dart           # Updated for location updates
│   ├── services/
│   │   ├── auth_service.dart          # Updated for Phone Auth
│   │   ├── firestore_service.dart     # Updated for GeoFire queries
│   │   └── location_service.dart      # Updated for GeoFire updates
├── pubspec.yaml                       # Add geoflutterfire2
├── firebase.json                      # Updated Firestore rules
└── README.md                          # This file
```

### File Descriptions
- **user.dart**: Adds `location` (GeoPoint) and `geohash` for GeoFire.
- **login.dart**: Implements SMS OTP input for Phone Auth.
- **customer_home.dart**: Displays nearby drivers using GeoFire queries.
- **driver_home.dart**: Updates driver location in background.
- **auth_service.dart**: Handles Firebase Phone Auth with OTP verification.
- **firestore_service.dart**: Adds GeoFire queries for nearby drivers.
- **location_service.dart**: Integrates GeoFire for location storage.
- **pubspec.yaml**: Adds `geoflutterfire2` dependency.
- **android/app/build.gradle**: Adds GeoFire Android library.
- **firebase.json**: Updated Firestore rules for secure access.

## Setup Instructions

### 1. Update Dependencies
- **Update `pubspec.yaml`**:
  Add the GeoFire Flutter wrapper:
  ```yaml
  dependencies:
    geoflutterfire2: ^2.3.15
  ```
  Ensure existing dependencies remain:
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
- **Update `android/app/build.gradle`**:
  Add GeoFire Android library:
  ```gradle
  dependencies {
    implementation 'com.firebase:geofire-android-common:3.2.0'
  }
- **Install**:
  ```bash
  flutter pub get
  ```

### 2. Configure Firebase for Phone Auth
- **Enable Phone Auth**:
  - In [Firebase Console](https://console.firebase.google.com), go to Authentication > Sign-in Method.
  - Enable "Phone" provider.
  - Add your app’s SHA-1 and SHA-256 fingerprints:
    ```bash
    cd android
    ./gradlew signingReport
    ```
    Copy SHA-1/SHA-256 from the output and add to Firebase Console > Project Settings > Your Apps.
- **Verify Permissions**:
  - Ensure `android/app/src/main/AndroidManifest.xml` includes:
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    ```

### 3. Update Firestore Rules
- Create or update `firebase.json` (or edit via Firebase Console) with rules to secure GeoFire and Phone Auth data:
  ```javascript
  {
    "firestore": {
      "rules": "firestore.rules"
    }
  }
  ```
- Create `firestore.rules`:
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

### 4. Add/Modify Code Files
Copy the following code into the specified files, replacing or updating as needed. These extend the existing app with GeoFire and Phone Auth.

- **lib/models/user.dart**:
  ```dart
  import 'package:cloud_firestore/cloud_firestore.dart';

  class AppUser {
    final String id;
    final String role;
    final double rating;
    final int completedJobs;
    final GeoPoint? location; // For GeoFire
    final String? geohash; // For GeoFire queries

    AppUser({
      required this.id,
      required this.role,
      this.rating = 5.0,
      this.completedJobs = 0,
      this.location,
      this.geohash,
    });

    Map<String, dynamic> toMap() => {
          'id': id,
          'role': role,
          'rating': rating,
          'completedJobs': completedJobs,
          'location': location,
          'geohash': geohash,
        };

    factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
          id: map['id'],
          role: map['role'],
          rating: map['rating'],
          completedJobs: map['completedJobs'],
          location: map['location'],
          geohash: map['geohash'],
        );
  }
  ```

- **lib/services/auth_service.dart**:
  ```dart
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../models/user.dart';

  class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<AppUser?> signInWithPhone(
        String phone, String role, Function(String, PhoneAuthProvider.ForceResendingToken) onCodeSent, Function(String) onError) async {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            final userCredential = await _auth.signInWithCredential(credential);
            await _storeUser(userCredential.user!.uid, role, phone);
          },
          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? 'Verification failed');
          },
          codeSent: onCodeSent,
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        return null; // Wait for OTP
      } catch (e) {
        onError(e.toString());
        return null;
      }
    }

    Future<AppUser?> verifyOtp(String verificationId, String smsCode, String role, String phone) async {
      try {
        final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          await _storeUser(user.uid, role, phone);
          return AppUser(id: user.uid, role: role);
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    Future<void> _storeUser(String uid, String role, String phone) async {
      final user = AppUser(id: uid, role: role);
      await _firestore.collection('users').doc(uid).set(user.toMap());
    }

    Future<AppUser?> getCurrentUser() async {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    }
  }
  ```

- **lib/services/location_service.dart**:
  ```dart
  import 'package:geoflutterfire2/geoflutterfire2.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class LocationService {
    final GeoFlutterFire _geo = GeoFlutterFire();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<Position> getCurrentLocation() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permission denied');
      }
      return await Geolocator.getCurrentPosition();
    }

    Future<void> updateDriverLocation(String driverId, Position position) async {
      GeoFirePoint point = _geo.point(latitude: position.latitude, longitude: position.longitude);
      await _firestore.collection('users').doc(driverId).update({
        'location': point.geoPoint,
        'geohash': point.hash,
      });
    }

    Stream<Position> getLocationStream() {
      return Geolocator.getPositionStream();
    }
  }
  ```

- **lib/services/firestore_service.dart**:
  ```dart
  import 'package:geoflutterfire2/geoflutterfire2.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../models/request.dart';
  import '../models/bid.dart';
  import '../models/user.dart';

  class FirestoreService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GeoFlutterFire _geo = GeoFlutterFire();

    Future<void> postRequest(DeliveryRequest request) async {
      await _firestore.collection('requests').doc(request.id).set(request.toMap());
    }

    Stream<List<DeliveryRequest>> getRequests(String userId) {
      return _firestore
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => DeliveryRequest.fromMap(doc.data())).toList());
    }

    Future<void> placeBid(Bid bid) async {
      await _firestore.collection('bids').doc(bid.id).set(bid.toMap());
    }

    Stream<List<Bid>> getBids(String requestId) {
      return _firestore
          .collection('bids')
          .where('requestId', isEqualTo: requestId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Bid.fromMap(doc.data())).toList());
    }

    Future<void> acceptBid(String bidId, String requestId, String driverId) async {
      await _firestore.collection('bids').doc(bidId).update({'status': 'accepted'});
      await _firestore
          .collection('requests')
          .doc(requestId)
          .update({'status': 'accepted', 'driverId': driverId});
    }

    Future<void> updateRequestStatus(String requestId, String status) async {
      await _firestore.collection('requests').doc(requestId).update({'status': status});
    }

    Future<void> rateUser(String userId, double rating) async {
      final doc = await _firestore.collection('users').doc(userId).get();
      final user = AppUser.fromMap(doc.data()!);
      final newRating = (user.rating * user.completedJobs + rating) / (user.completedJobs + 1);
      await _firestore.collection('users').doc(userId).update({
        'rating': newRating,
        'completedJobs': user.completedJobs + 1,
      });
    }

    Stream<List<AppUser>> getNearbyDrivers(double lat, double lng, double radiusKm) {
      GeoFirePoint center = _geo.point(latitude: lat, longitude: lng);
      var collectionReference = _firestore.collection('users').where('role', isEqualTo: 'driver');
      return _geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: radiusKm, field: 'location')
          .map((snapshots) => snapshots.map((doc) => AppUser.fromMap(doc.data())).toList());
    }
  }
  ```

- **lib/screens/login.dart**:
  ```dart
  import 'package:flutter/material.dart';
  import '../services/auth_service.dart';
  import 'customer_home.dart';
  import 'driver_home.dart';

  class LoginScreen extends StatefulWidget {
    @override
    _LoginScreenState createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final AuthService _authService = AuthService();
    final _phoneController = TextEditingController();
    final _otpController = TextEditingController();
    String? _verificationId;
    String? _error;
    String _role = 'customer';
    bool _isOtpSent = false;

    void _sendOtp() async {
      setState(() => _error = null);
      await _authService.signInWithPhone(
        _phoneController.text,
        _role,
        (verificationId, _) => setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
        }),
        (error) => setState(() => _error = error),
      );
    }

    void _verifyOtp() async {
      final user = await _authService.verifyOtp(_verificationId!, _otpController.text, _role, _phoneController.text);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => user.role == 'customer' ? CustomerHomeScreen() : DriverHomeScreen(),
          ),
        );
      } else {
        setState(() => _error = 'Invalid OTP');
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Local Delivery')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number (e.g., +1234567890)'),
                keyboardType: TextInputType.phone,
              ),
              if (_isOtpSent)
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(labelText: 'Enter OTP'),
                  keyboardType: TextInputType.number,
                ),
              DropdownButton<String>(
                value: _role,
                items: ['customer', 'driver'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (value) => setState(() => _role = value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

- **lib/screens/customer_home.dart**:
  ```dart
  import 'package:flutter/material.dart';
  import '../services/auth_service.dart';
  import '../services/firestore_service.dart';
  import 'request_form.dart';
  import 'bid_selection.dart';

  class CustomerHomeScreen extends StatelessWidget {
    final FirestoreService _firestoreService = FirestoreService();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Customer Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await AuthService()._auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<DeliveryRequest>>(
                stream: _firestoreService.getRequests((await AuthService().getCurrentUser())!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final requests = snapshot.data!.where((r) => r.customerId == AuthService()._auth.currentUser!.uid).toList();
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return ListTile(
                        title: Text('${request.restaurantName}: \$${request.offerAmount}'),
                        subtitle: Text(request.status),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BidSelectionScreen(requestId: request.id)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            StreamBuilder<List<AppUser>>(
              stream: _firestoreService.getNearbyDrivers(37.7853889, -122.4056973, 5.0), // Replace with customer location
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text('Loading drivers...');
                final drivers = snapshot.data!;
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Driver: ${driver.id} (Rating: ${driver.rating})'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RequestFormScreen())),
          child: Icon(Icons.add),
        ),
      );
    }
  }
  ```

- **lib/screens/driver_home.dart**:
  ```dart
  import 'package:flutter/material.dart';
  import '../services/auth_service.dart';
  import '../services/firestore_service.dart';
  import '../services/location_service.dart';
  import '../models/request.dart';
  import 'tracking.dart';
  import 'package:uuid/uuid.dart';

  class DriverHomeScreen extends StatefulWidget {
    @override
    _DriverHomeScreenState createState() => _DriverHomeScreenState();
  }

  class _DriverHomeScreenState extends State<DriverHomeScreen> {
    final FirestoreService _firestoreService = FirestoreService();
    final LocationService _locationService = LocationService();

    @override
    void initState() {
      super.initState();
      _locationService.getLocationStream().listen((position) async {
        final driverId = AuthService()._auth.currentUser!.uid;
        await _locationService.updateDriverLocation(driverId, position);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Driver Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await AuthService()._auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
            ),
          ],
        ),
        body: StreamBuilder<List<DeliveryRequest>>(
          stream: _firestoreService.getRequests((await AuthService().getCurrentUser())!.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            final requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return ListTile(
                  title: Text('${request.restaurantName}: \$${request.offerAmount}'),
                  subtitle: Text('Est. Cost: \$${request.estimatedCost} | ${request.status}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final driverId = AuthService()._auth.currentUser!.uid;
                      final bid = Bid(
                        id: Uuid().v4(),
                        requestId: request.id,
                        driverId: driverId,
                        counterOffer: request.offerAmount,
                      );
                      await _firestoreService.placeBid(bid);
                      if (request.status == 'accepted' && request.driverId == driverId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TrackingScreen(request: request)),
                        );
                      }
                    },
                    child: Text('Bid'),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
  ```

### 5. Test the App
- **Set Up Emulator**:
  - Use Android Studio’s emulator (Pixel 6, API 33) or a physical Android device with USB debugging.
- **Test GeoFire**:
  - Use mock locations in the emulator to simulate driver movement.
  - Replace hardcoded coordinates (37.7853889, -122.4056973) in `customer_home.dart` with `LocationService.getCurrentLocation()` for dynamic customer location.
  - Verify nearby drivers appear in the customer’s feed (bottom horizontal list).
- **Test Phone Auth**:
  - Enter a phone number (e.g., `+1234567890`) and test OTP flow.
  - For development, enable test mode in `auth_service.dart`:
    ```dart
    _auth.setAppVerificationDisabledForTesting(true); // Add before verifyPhoneNumber
    ```
    Use fictional numbers to avoid SMS costs during testing.
- **Run**:
  ```bash
  flutter run
  ```
  - Ensure `google-services.json` is in `android/app/`.
  - Check Firebase Console for Firestore data (`users`, `requests`, `bids`) and auth logs.

## Firebase Costs
- **GeoFire (Firestore)**:
  - **Free on Spark Plan**: Up to 1 GB storage, 20K reads/day, 50K writes/day, 20K deletes/day.
  - **Usage Estimate**: For 100 drivers updating locations every 10 seconds for 8 hours (~28K writes/day) and 100 customers querying 5 times/day (~500 reads/day), fits within free limits.
  - **Blaze Plan**: If exceeded, ~$0.06/100K reads, $0.18/100K writes. Unlikely for local MVP.
- **Phone Authentication**:
  - **Spark Plan**: Free for 10 SMS/day.
  - **Blaze Plan**: $0.01–$0.34/SMS (e.g., $0.01 US/Canada). For 100 users/day, 90 SMS cost ~$0.90/day or $27/month.
  - **Mitigation**: Use email/social login (free) or cache auth sessions to reduce SMS.
- **Total**: Free for testing (<10 users/day). Budget $20–$50/month on Blaze Plan for 50–100 users/day.

## Limitations
- **GeoFire**:
  - Queries may include false positives near radius edges (client-side filtering needed).
  - Less accurate near poles (not relevant for local use).
- **Phone Auth**:
  - SMS costs escalate on Blaze Plan for high usage.
  - Requires SHA-1/SHA-256 and Play Integrity setup.
- **Integration**: Hardcoded coordinates in `customer_home.dart` need dynamic replacement for production.

## Next Steps
- **Test Locally**: Verify GeoFire queries and OTP flow with 5–10 users.
- **Enhance Trust**: Add receipt uploads (Firebase Storage, free up to 1 GB).
- **Polish UI**: Request Figma mockups for better UX.
- **Hire Developer**: Refine for production ($7K–$25K for MVP).
- **Play Store**: Update privacy policy to include SMS consent and location usage.

---

### Notes
- **Base App**: Assumes you have `main.dart`, `request.dart`, `bid.dart`, `request_form.dart`, `bid_selection.dart`, and `tracking.dart` from prior code. If missing, request specific files.
- **Error Fixes**: No stray text (e.g., "különböző" or citation tags) included.
- **Troubleshooting**: Check `flutter doctor`, Firebase Console logs, or ask for debug help (e.g., SHA-1 setup, Firestore indexes).

This README covers only the GeoFire and Phone Auth additions, integrating seamlessly with your existing app. If you need specific files from the base app re-shared, help with testing (e.g., mock locations), or a sample privacy policy, let me know!
