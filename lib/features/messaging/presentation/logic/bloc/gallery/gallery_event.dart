import 'package:flutter/cupertino.dart';

@immutable
abstract class GalleryEvent {}

class GalleryChangeCurrentImageEvent extends GalleryEvent {
  final int index;

  GalleryChangeCurrentImageEvent(this.index);
}
