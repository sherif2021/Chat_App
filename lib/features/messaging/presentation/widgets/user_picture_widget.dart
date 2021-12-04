import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserPicture extends StatelessWidget {
  final String? picUrl;
  final double size;

  const UserPicture({this.picUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: picUrl == null || picUrl!.isEmpty
          ? ColoredBox(
              color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0),
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
                print(error);
                return CircularProgressIndicator();
              },
              fit: BoxFit.cover,
            ),
    );
  }
}
