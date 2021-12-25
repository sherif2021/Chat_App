import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/home/home_bloc.dart';
import 'package:chat/features/messaging/presentation/widgets/user_picture_widget.dart';
import 'package:chat/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserWidget extends StatelessWidget {
  final UserModel userModel;

  const UserWidget({required this.userModel});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (oldState, newState) => newState is UpdateUserDataState && newState.uid == userModel.uid,
      builder: (context, state) {
        return ListTile(
          leading: Hero(
            tag: userModel.hashCode,
            child: UserPicture(
              picUrl: userModel.pic,
              name : userModel.name,
              size: 50,
            ),
          ),
          title: Text(
            userModel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            userModel.lastMessage != null ? userModel.lastMessage!.text : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.pushNamed(context, messageScreen, arguments: userModel),
        );
      },
    );
  }
}
