
import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;

class UserPlacesController extends GetxController {
  final places = List<Place>.empty().obs;

  void addPlace(String title, File image, PlaceLocation location) async {
    // copy captured image from camera to application directory
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedFile = await image.copy("$appDir/$filename");

    places.add(Place(title: title, image: copiedFile, location: location));
  }
}