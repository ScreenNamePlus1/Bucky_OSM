# Bucky - Setup Instructions for Delivery Area Feature in OS (Open Street Maps)

## Setup Instructions

1. **Replace Files**:
   - Copy and paste each file into your project, overwriting `pubspec.yaml`, `lib/models/user.dart`, `lib/services/firestore_service.dart`, and `lib/screens/driver_home.dart`.
   - Create `lib/widgets/delivery_area_editor.dart` as a new file.
2. **Install Dependencies**:
   - Run `flutter pub get` to install `flutter_map`, `latlong2`, and `http`.
3. **Configure Permissions**:
   - In `android/app/src/main/AndroidManifest.xml`, ensure:
     ```xml
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
     ```
   - In `ios/Runner/Info.plist`, add:
     ```xml
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>App needs location for delivery area and tracking</string>
     ```
4. **Firebase Setup**:
   - Ensure `lib/firebase_options.dart` exists (from `flutterfire configure`).
   - Verify `main.dart` initializes Firebase:
     ```dart
     import 'package:firebase_core/firebase_core.dart';
     import 'firebase_options.dart';

     void main() async {
       WidgetsFlutterBinding.ensureInitialized();
       await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
       runApp(const MyApp());
     }
     ```
5. **Test**:
   - Run `flutter run` on a device/emulator with location enabled.
   - The driver home screen should show a map (OSM tiles) where you can tap to define a delivery area, with points snapping to a grid and roads (via Overpass API). The area saves to Firestore.