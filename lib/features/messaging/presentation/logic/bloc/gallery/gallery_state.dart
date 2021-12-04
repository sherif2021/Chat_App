import 'package:flutter/cupertino.dart';

@immutable
abstract class GalleryState {}

class GalleryInitState extends GalleryState {}

class GalleryChangeImageState extends GalleryState {
  final int index;

  GalleryChangeImageState(this.index);
}
