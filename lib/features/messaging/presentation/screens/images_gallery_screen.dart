import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/features/messaging/data/model/attachment_model.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/gallery/gallery_bloc.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/gallery/gallery_event.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/gallery/gallery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImagesGalleryScreen extends StatelessWidget {
  final List<AttachmentModel> attachments;
  final int selectedImage;

  ImagesGalleryScreen(
      {required this.attachments, required this.selectedImage}) {
    pageController = PageController(initialPage: selectedImage);
  }

  late final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (_, state) {
            return Text(
                "${state is GalleryChangeImageState ? state.index + 1 : selectedImage + 1} / ${attachments.length}");
          },
        ),
      ),
      body: PageView.builder(
          onPageChanged: (index) => context
              .read<GalleryBloc>()
              .add(GalleryChangeCurrentImageEvent(index)),
          controller: pageController,
          itemCount: attachments.length,
          itemBuilder: (_, index) => _buildPageViewItem(attachments[index])),
    );
  }

  Widget _buildPageViewItem(AttachmentModel attachment) {
    return attachments.indexOf(attachment) == selectedImage
        ? Hero(
            tag: attachment.hashCode,
            child: _buildOneImage(attachment.path, attachment.url),
          )
        : _buildOneImage(attachment.path, attachment.url);
  }

  Widget _buildOneImage(String path, String? url) {
    return path.isNotEmpty
        ? Image.file(
            File(path),
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          )
        : CachedNetworkImage(
            imageUrl: url!,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          );
  }
}
