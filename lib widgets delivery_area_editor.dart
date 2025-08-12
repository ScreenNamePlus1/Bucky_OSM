import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';  // Assuming your state provider
import '../services/firestore_service.dart';

class DeliveryAreaEditor extends StatefulWidget {
  final String apiKey;  // Google Maps API key
  final List<LatLng>? initialArea;  // Existing area to load

  const DeliveryAreaEditor({required this.apiKey, this.initialArea, super.key});

  @override
  _DeliveryAreaEditorState createState() => _DeliveryAreaEditorState();
}

class _DeliveryAreaEditorState extends State<DeliveryAreaEditor> {
  GoogleMapController? _mapController;
  List<LatLng> _polygonPoints = [];
  Set<Polygon> _polygons = {};
  bool _drawingMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialArea != null) {
      _polygonPoints = widget.initialArea!;
      _updatePolygon();
    }
  }

  void _toggleDrawingMode() {
    setState(() {
      _drawingMode = !_drawingMode;
      if (!_drawingMode) _polygonPoints.clear();  // Reset if canceling
    });
  }

  Future<LatLng> _snapToGrid(LatLng point, double gridSize = 0.0009) async {  // ~100m grid
    double lat = (point.latitude / gridSize).round() * gridSize;
    double lng = (point.longitude / gridSize).round() * gridSize;
    return LatLng(lat, lng);
  }

  Future<List<LatLng>> _snapToRoads(List<LatLng> points) async {
    if (points.isEmpty) return points;
    
    final path = points.map((p) => '${p.latitude},${p.longitude}').join('|');
    final url = 'https://roads.googleapis.com/v1/snapToRoads?path=$path&interpolate=true&key=${widget.apiKey}';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['snappedPoints'].map<LatLng>((sp) => LatLng(
        sp['location']['latitude'],
        sp['location']['longitude'],
      )).toList();
    } else {
      print('Snap to roads failed: ${response.body}');
      return points;  // Fallback
    }
  }

  void _onMapTap(LatLng point) async {
    if (!_drawingMode) return;
    
    LatLng gridSnapped = await _snapToGrid(point);
    
    setState(() {
      _polygonPoints.add(gridSnapped);
      _updatePolygon();
    });
  }

  void _finalizeArea() async {
    List<LatLng> snappedPoints = await _snapToRoads(_polygonPoints);
    
    if (snappedPoints.isNotEmpty && snappedPoints.first != snappedPoints.last) {
      List<LatLng> closingSegment = await _snapToRoads([snappedPoints.last, snappedPoints.first]);
      snappedPoints.addAll(closingSegment.skip(1));
    }
    
    setState(() {
      _polygonPoints = snappedPoints;
      _updatePolygon();
      _drawingMode = false;
    });
    
    final appState = Provider.of<AppState>(context, listen: false);
    final firestore = FirestoreService();
    await firestore.updateDriverDeliveryArea(appState.currentUser!.id, _polygonPoints);
  }

  void _updatePolygon() {
    _polygons = {
      Polygon(
        polygonId: const PolygonId('delivery_area'),
        points: _polygonPoints,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.3),
      ),
    };
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
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),  // Customize to user's location
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            polygons: _polygons,
          ),
        ),
      ],
    );
  }
}