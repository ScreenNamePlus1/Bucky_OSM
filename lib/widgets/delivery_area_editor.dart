import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

class DeliveryAreaEditor extends StatefulWidget {
  const DeliveryAreaEditor({super.key});

  @override
  _DeliveryAreaEditorState createState() => _DeliveryAreaEditorState();
}

class _DeliveryAreaEditorState extends State<DeliveryAreaEditor> {
  final MapController _mapController = MapController();
  LatLng _initialCenter = const LatLng(37.7749, -122.4194); // Fallback
  List<LatLng> _polygonPoints = [];
  List<Polygon> _polygons = [];
  bool _drawingMode = false;

  @override
  void initState() {
    super.initState();
    _setInitialCenter();
    _loadInitialArea();
  }

  Future<void> _setInitialCenter() async {
    try {
      final position = await LocationService().getCurrentLocation();
      setState(() {
        _initialCenter = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error setting initial center: $e');
    }
  }

  Future<void> _loadInitialArea() async {
    final appState = context.read(appStateProvider);
    final firestore = FirestoreService();
    final area = await firestore.getDriverDeliveryArea(appState.state['userId'] ?? '');
    if (area != null) {
      setState(() {
        _polygonPoints = area;
        _updatePolygon();
      });
    }
  }

  void _toggleDrawingMode() {
    setState(() {
      _drawingMode = !_drawingMode;
      if (!_drawingMode) _polygonPoints.clear();
      _updatePolygon();
    });
  }

  LatLng _snapToGrid(LatLng point, {double gridSize = 0.0009}) {
    double lat = (point.latitude / gridSize).round() * gridSize;
    double lng = (point.longitude / gridSize).round() * gridSize;
    return LatLng(lat, lng);
  }

  Future<List<LatLng>> _snapToRoads(List<LatLng> points) async {
    if (points.isEmpty) return points;

    List<LatLng> snappedPoints = [];
    const overpassUrl = 'http://overpass-api.de/api/interpreter';

    for (var point in points) {
      final query = '''
        [out:json];
        way["highway"](around:50,${point.latitude},${point.longitude});
        out center;
      ''';
      try {
        final response = await http.post(
          Uri.parse(overpassUrl),
          headers: {'User-Agent': 'Bucky_OSM/1.0'},
          body: query,
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final elements = data['elements'] as List<dynamic>;
          if (elements.isNotEmpty) {
            final closestRoad = elements.first;
            snappedPoints.add(LatLng(
              closestRoad['center']['lat'],
              closestRoad['center']['lon'],
            ));
          } else {
            snappedPoints.add(point);
          }
        } else {
          snappedPoints.add(point);
          print('Overpass API error: ${response.body}');
        }
      } catch (e) {
        snappedPoints.add(point);
        print('Error snapping to road: $e');
      }
    }

    return snappedPoints;
  }

  void _onMapTap(TapPosition position, LatLng point) async {
    if (!_drawingMode) return;

    LatLng gridSnapped = _snapToGrid(point);
    setState(() {
      _polygonPoints.add(gridSnapped);
      _updatePolygon();
    });
  }

  bool _linesIntersect(LatLng p1, LatLng p2, LatLng p3, LatLng p4) {
    double det = (p2.longitude - p1.longitude) * (p4.latitude - p3.latitude) -
        (p4.longitude - p3.longitude) * (p2.latitude - p1.latitude);
    if (det == 0) return false; // Parallel lines
    double t = ((p3.longitude - p1.longitude) * (p4.latitude - p3.latitude) -
            (p3.latitude - p1.latitude) * (p4.longitude - p3.longitude)) / det;
    double u = -((p2.longitude - p1.longitude) * (p3.latitude - p1.latitude) -
            (p2.latitude - p1.latitude) * (p3.longitude - p1.longitude)) / det;
    return t >= 0 && t <= 1 && u >= 0 && u <= 1;
  }

  Future<void> _finalizeArea() async {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('At least 3 points required')),
      );
      return;
    }
    // Check for self-intersection
    bool hasIntersection = false;
    for (int i = 0; i < _polygonPoints.length - 1; i++) {
      for (int j = i + 2; j < _polygonPoints.length - 1; j++) {
        if (_linesIntersect(_polygonPoints[i], _polygonPoints[i + 1], _polygonPoints[j], _polygonPoints[j + 1])) {
          hasIntersection = true;
          break;
        }
      }
    }
    if (hasIntersection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Polygon cannot self-intersect')),
      );
      return;
    }
    List<LatLng> snappedPoints = await _snapToRoads(_polygonPoints);

    if (snappedPoints.isNotEmpty && snappedPoints.first != snappedPoints.last) {
      snappedPoints.add(snappedPoints.first); // Close polygon
    }

    setState(() {
      _polygonPoints = snappedPoints;
      _updatePolygon();
      _drawingMode = false;
    });

    final appState = context.read(appStateProvider);
    final firestore = FirestoreService();
    await firestore.updateDriverDeliveryArea(appState.state['userId'] ?? '', _polygonPoints);
  }

  void _updatePolygon() {
    _polygons = [
      if (_polygonPoints.isNotEmpty)
        Polygon(
          points: _polygonPoints,
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleDrawingMode,
              child: Text(_drawingMode ? 'Cancel Drawing' : 'Define Delivery Area'),
            ),
            if (_drawingMode && _polygonPoints.length > 2)
              ElevatedButton(
                onPressed: _finalizeArea,
                child: const Text('Save Area'),
              ),
          ],
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              PolygonLayer(polygons: _polygons),
            ],
          ),
        ),
      ],
    );
  }
}