<<<<<<< HEAD
# Bucky - Setup Instructions for Delivery Area Feature in OS (O>

## Setup Instructions

1. **Replace Files**:
   - Copy and paste each file into your project, overwriting `p>
   - Create `lib/widgets/delivery_area_editor.dart` as a new fi>
2. **Install Dependencies**:
   - Run `flutter pub get` to install `flutter_map`, `latlong2`>
3. **Configure Permissions**:
   - In `android/app/src/main/AndroidManifest.xml`, ensure:
     ```xml
     <uses-permission android:name="android.permission.ACCESS_F>
     <uses-permission android:name="android.permission.ACCESS_C>
     ```
   - In `ios/Runner/Info.plist`, add:
     ```xml
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>App needs location for delivery area and tracking<>
     ```
4. **Firebase Setup**:
   - Ensure `lib/firebase_options.dart` exists (from `flutterfi>
   - Verify `main.d