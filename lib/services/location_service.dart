import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable location services in your device settings.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      for (int i = 0; i < 2; i++) {
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.deniedForever) {
            throw Exception('Location permissions are permanently denied. Please enable them in settings.');
          }
        }
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied after multiple attempts.');
      }
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  Stream<Position> getLocationStream() async* {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable location services in your device settings.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied. Please enable them in settings.');
        }
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      yield* Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      throw Exception('Failed to stream location: $e');
    }
  }
}