import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/features/messaging/data/model/attachment_model.dart';
import 'package:chat/features/messaging/data/model/message_model.dart';
import 'package:chat/utility/bubble_painter.dart';
import 'package:chat/utility/constants.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel messageModel;

  const MessageWidget({required this.messageModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          messageModel.me ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: 30,
                minWidth: 100,
                maxWidth: MediaQuery.of(context).size.width / 1.3,
                maxHeight: messageModel.textOverFlow ? double.infinity : 500),
            child: CustomPaint(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(messageModel.text),
                  ),
                  if (messageModel.attachments.isNotEmpty)
                    _buildImages(context, messageModel),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 7, bottom: 5, right: 5, left: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text("${messageModel.time.hour}.${messageModel.time.minute}"),
                        if (messageModel.me)
                          Icon(
                            messageModel.seen! || messageModel.sent
                                ? Icons.done_all
                                : messageModel.id != null &&
                                        messageModel.id!.isNotEmpty
                                    ? Icons.done
                                    : Icons.watch_later_outlined,
                            color:
                                messageModel.seen! ? Colors.green : Colors.grey,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              painter: BubblePainter(
                  me: messageModel.me,
                  background: Theme.of(context)
                      .primaryColor
                      .withRed(messageModel.me ? 9 : 230)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildImages(BuildContext context, MessageModel messageModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Wrap(
        runSpacing: 3,
        spacing: 3,
        children: messageModel.attachments
            .getRange(
                0,
                messageModel.attachments.length > 4
                    ? 4
                    : messageModel.attachments.length)
            .map(
              (e) => InkWell(
                onTap: () => Navigator.of(context)
                    .pushNamed(imagesGalleryScreen, arguments: [
                  messageModel.attachments,
                  messageModel.attachments.indexOf(e)
                ]),
                child: messageModel.attachments.indexOf(e) == 3
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildOneImage(context, e),
                          Text("${messageModel.attachments.length} +")
                        ],
                      )
                    : _buildOneImage(context, e),
              ),
            )
            .toList(),
      ),
    );
  }

  static Widget _buildOneImage(
      BuildContext context, AttachmentModel attachment) {
    return Hero(
      tag: attachment.hashCode,
      child: attachment.path.isNotEmpty
          ? Image.file(
              File(attachment.path),
              height: 180,
              width: MediaQuery.of(context).size.width * .33,
              fit: BoxFit.fill,
              gaplessPlayback: true,
            )
          : CachedNetworkImage(
              imageUrl: attachment.url!,
              height: 180,
              width: MediaQuery.of(context).size.width * .33,
              fit: BoxFit.fill),
    );
  }
}
