import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: "",
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? "Pick your location" : "Your location",
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(onPressed: () {
              Navigator.of(context).pop(_pickedLocation);
            }, icon: Icon(Icons.save)),
        ],
      ),
      body: GoogleMap(
        onTap: widget.isSelecting ? (position) {
          setState(() {
            _pickedLocation = position;
          });
        } : null,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.location.latitude, widget.location.longitude),
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("m1"),
            position: LatLng(
              _pickedLocation?.latitude ?? widget.location.latitude,
              _pickedLocation?.longitude ?? widget.location.longitude,
            ),
          ),
        },
      ),
    );
  }
}
