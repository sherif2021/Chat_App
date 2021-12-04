import 'package:chat/core/app_cubit.dart';
import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/home/home_bloc.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/message/message_bloc.dart';
import 'package:chat/features/messaging/presentation/widgets/message_widget.dart';
import 'package:chat/features/messaging/presentation/widgets/user_picture_widget.dart';
import 'package:chat/utility/constants.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fcm_config/fcm_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessageScreen extends StatefulWidget {
  final UserModel userModel;

  const MessageScreen(this.userModel);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _textFieldController = TextEditingController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _textFieldController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().isInMessageScreen = true;
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final messageBloc = context.read<MessageBloc>();

    return FCMNotificationClickListener(
      onNotificationClick:
          (RemoteMessage notification, void Function() setState) =>
              _onNotificationClick(notification),
      child: WillPopScope(
        onWillPop: () {
          if (messageBloc.isEmojiShow) messageBloc.add(EmojiEvent(show: false));
          if (_focusNode.hasFocus) _focusNode.unfocus();

          final status = messageBloc.isEmojiShow ||
                  messageBloc.keyboardVisibilityController.isVisible
              ? false
              : true;
          if (status) context.read<HomeBloc>().isInMessageScreen = false;
          return Future.value(status);
        },
        child: MultiBlocListener(
          listeners: [
            BlocListener<HomeBloc, HomeState>(
                listener: (_, state) => homeStateListener(messageBloc, state)),
            BlocListener<MessageBloc, MessageState>(listener: (_, state) {
              if (state is UserInfoChangedState)
                context.read<HomeBloc>().add(UserInfoChangedEvent(state.user));
            })
          ],
          child: Scaffold(
            appBar: AppBar(
              title: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (oldState, newState) =>
                    newState is UpdateUserDataState &&
                    newState.uid == widget.userModel.uid,
                builder: (_, state) => Row(
                  children: [
                    Hero(
                      tag: widget.userModel.hashCode,
                      child: UserPicture(
                        picUrl: widget.userModel.pic,
                        size: 45,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.userModel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                            context, videoCallingScreen,
                                            arguments: {
                                              'uid': widget.userModel.uid,
                                              'name': widget.userModel.name,
                                              'pic': widget.userModel.pic,
                                              'incoming': false
                                            });
                                      },
                                      child: Text('Yes')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No'))
                                ],
                                title: Text(
                                    'Are you sure you want to contact ${widget.userModel.name} by video'),
                              ));
                    },
                    icon: Icon(Icons.video_call)),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<MessageBloc, MessageState>(
                    buildWhen: (oldState, newState) =>
                        newState is MessagesLoadedState,
                    builder: (context, state) {
                      return state is MessagesLoadedState
                          ? ScrollablePositionedList.builder(
                              initialScrollIndex: state.initialScrollIndex,
                              itemScrollController:
                                  messageBloc.itemScrollController,
                              itemPositionsListener:
                                  messageBloc.itemPositionsListener,
                              itemBuilder: (_, index) => MessageWidget(
                                  messageModel: state.messages[index]),
                              itemCount: state.messages.length)
                          : Container();
                    },
                  ),
                ),
                BlocBuilder<MessageBloc, MessageState>(
                  buildWhen: (oldState, newState) =>
                      newState is ChangeImagesSelectedState,
                  builder: (context, state) {
                    return messageBloc.images.isEmpty
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                Text(messageBloc.images.length.toString())
                              ],
                            ),
                          );
                  },
                ),
                _buildMessageInput(
                    context: context,
                    appCubit: appCubit,
                    messageBloc: messageBloc),

                BlocBuilder<MessageBloc, MessageState>(
                  buildWhen: (oldState, newState) =>
                      newState is EmojiChangeState,
                  builder: (context, state) {
                    return state is EmojiChangeState && state.show
                        ? _buildEmojiWidget(context)
                        : SizedBox();
                  },
                )
                //_buildMessageFiled(appCubit: appCubit, messageBloc: messageBloc)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiWidget(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .4,
      child: EmojiPicker(
          onEmojiSelected: (Category category, Emoji emoji) {
            _textFieldController
              ..text += emoji.emoji
              ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _textFieldController.text.length));
          },
          onBackspacePressed: () {},
          config: const Config(
              columns: 7,
              emojiSizeMax: 32.0,
              verticalSpacing: 0,
              horizontalSpacing: 0,
              initCategory: Category.RECENT,
              bgColor: Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              progressIndicatorColor: Colors.blue,
              backspaceColor: Colors.blue,
              showRecentsTab: true,
              recentsLimit: 28,
              noRecentsText: 'No Recent',
              noRecentsStyle: TextStyle(fontSize: 20, color: Colors.black26),
              categoryIcons: CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL)),
    );
  }

  Widget _buildMessageInput(
      {required BuildContext context,
      required AppCubit appCubit,
      required MessageBloc messageBloc}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.blueAccent,
              elevation: 0,
              onPressed: () => _sendMessage(
                  appCubit: appCubit,
                  messageBloc: messageBloc,
                  homeBloc: context.read<HomeBloc>()),
              child: Icon(Icons.send),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: _focusNode,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                        hintText: 'Type a message',
                        contentPadding: EdgeInsets.fromLTRB(70, 6, 16, 6),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                    minLines: 1,
                    maxLines: 5,
                    controller: _textFieldController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) => _sendMessage(
                        appCubit: appCubit,
                        messageBloc: messageBloc,
                        homeBloc: context.read<HomeBloc>()),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            if (!messageBloc.isEmojiShow && _focusNode.hasFocus)
                              _focusNode.unfocus();
                            else if (messageBloc.isEmojiShow &&
                                !_focusNode.hasFocus) _focusNode.requestFocus();

                            await Future.delayed(Duration(milliseconds: 100));
                            messageBloc.add(
                                EmojiEvent(show: !messageBloc.isEmojiShow));
                          },
                          child: BlocBuilder<MessageBloc, MessageState>(
                            buildWhen: (oldState, newState) =>
                                newState is EmojiChangeState,
                            builder: (context, state) {
                              return Icon(
                                  state is EmojiChangeState && state.show
                                      ? Icons.keyboard
                                      : Icons.emoji_emotions);
                            },
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _imagePicker
                                .pickMultiImage(imageQuality: 80)
                                .then((images) {
                              messageBloc.images.clear();
                              if (images != null)
                                messageBloc.images
                                    .addAll(images.map((e) => e.path).toList());
                              messageBloc.add(ChangeImagesSelectedEvent());
                            });
                          },
                          child: Icon(Icons.camera_alt_rounded),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(
      {required AppCubit appCubit,
      required MessageBloc messageBloc,
      required HomeBloc homeBloc}) async {
    if (_textFieldController.text.isNotEmpty || messageBloc.images.isNotEmpty) {
      final message = await messageBloc.sendMessage(
          text: _textFieldController.text,
          receiver: widget.userModel,
          token: appCubit.state.authUserModel.token!);

      _textFieldController.clear();
      homeBloc.add(UpdateLastMessageEvent(message));
    }
  }

  void homeStateListener(MessageBloc messageBloc, HomeState state) {
    if (state is NewMessageState &&
        state.messageModel.uid == widget.userModel.uid)
      messageBloc.addMessage(messageModel: state.messageModel);
    if (state is SendingSeenDoneState)
      messageBloc.removeSendingSeen(
          ids: state.ids, userUID: widget.userModel.uid);
    if (state is UpdateMessageDataStata)
      messageBloc.messageUpdateData(
          index: state.index,
          id: state.id,
          isSent: state.isSent,
          isSeen: state.isSeen,
          time: state.time);
  }

  void _onNotificationClick(RemoteMessage notification) {
    if (notification.data.containsKey('uid')) {
      final uid = notification.data['uid'];
      final homeBloc = context.read<HomeBloc>();

      if (uid != widget.userModel.uid) {
        final user = homeBloc.getUser(uid);

        if (user != null) {
          Navigator.pop(context);
          Navigator.pushNamed(context, messageScreen, arguments: user);
        }
      }
    }
  }
}
