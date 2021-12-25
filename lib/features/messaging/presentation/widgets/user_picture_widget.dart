import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserPicture extends StatelessWidget {
  final String? picUrl;
  final String? name;
  final double size;

  const UserPicture({this.picUrl, this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: picUrl == null || picUrl!.isEmpty
          ? ColoredBox(
              color: getColorByName(),
              child: SizedBox(
                height: size,
                width: size,
              ),
            )
          : CachedNetworkImage(
              imageUrl: picUrl!,
              height: size,
              width: size,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) {
                return CircularProgressIndicator();
              },
              fit: BoxFit.cover,
            ),
    );
  }

  Color getColorByName() {
    return name != null && name!.length > 0
        ? Color(name!.codeUnitAt(0) * 0xFFFFFF).withOpacity(1.0)
        : Colors.black;
  }
}
