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