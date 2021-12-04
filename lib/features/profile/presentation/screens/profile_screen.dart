import 'dart:io';

import 'package:chat/core/app_cubit.dart';
import 'package:chat/features/messaging/presentation/widgets/user_picture_widget.dart';
import 'package:chat/features/profile/presentation/logic/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final profileCubit = context.read<ProfileCubit>();

    if (profileCubit.state is ProfileInitialState)
      profileCubit.getProfileData(uid: appCubit.state.authUserModel.uid!);

    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (_, state) {
          if (state is ProfileChangedDataState && state.status)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Data has Updated'),
              duration: Duration(seconds: 1),
            ));
        },
        buildWhen: (oldState, newState) =>
            oldState.runtimeType != newState.runtimeType,
        builder: (context, state) {
          return state is ProfileLoadingState
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : state is ProfileFieldToFetchState
                  ? Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.error,
                          size: 40,
                          color: Colors.red,
                        ),
                        onPressed: () => profileCubit.getProfileData(
                            uid: appCubit.state.authUserModel.uid!),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30.h,
                          ),
                          Stack(
                            children: [
                              BlocBuilder<ProfileCubit, ProfileState>(
                                buildWhen: (oldState, newState) =>
                                    newState is ProfileFetchedState ||
                                    (newState is ProfileChangedDataState &&
                                        newState.status &&
                                        newState.picUrl != null),
                                builder: (_, state) => ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: StreamBuilder<Object>(
                                      stream: null,
                                      builder: (context, snapshot) {
                                        return UserPicture(
                                          picUrl: profileCubit.profile.picUrl,
                                          size: 100,
                                        );
                                      }),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: IconButton(
                                    onPressed: () => _openImagePicker(
                                        appCubit, profileCubit),
                                    icon: Image.asset(
                                      'assets/images/camera_ic.png',
                                      height: 30,
                                      width: 30,
                                    )),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.go,
                              onFieldSubmitted: (v) {
                                if (v.length > 3)
                                  profileCubit.changeValue(
                                      name: v,
                                      uid: appCubit.state.authUserModel.uid!,
                                      token:
                                          appCubit.state.authUserModel.token!);
                              },
                              initialValue: profileCubit.profile.name,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          BlocBuilder<AppCubit, AppState>(
                            builder: (_, state) => SwitchListTile(
                                title: Text('Dark Mode :'),
                                value: state.darkModeEnable,
                                onChanged: (v) => appCubit.toggleDarkMode()),
                          ),
                          BlocBuilder<ProfileCubit, ProfileState>(
                            buildWhen: (oldState, newState) =>
                                newState is ProfileFetchedState ||
                                (newState is ProfileChangedDataState &&
                                    newState.status &&
                                    newState.notification != null),
                            builder: (_, state) {
                              return SwitchListTile(
                                title: Text('Notification :'),
                                value: profileCubit.profile.notificationEnable,
                                onChanged: (v) => profileCubit.changeValue(
                                    notificationEnable: v,
                                    uid: appCubit.state.authUserModel.uid!,
                                    token: appCubit.state.authUserModel.token!),
                              );
                            },
                          ),
                          BlocBuilder<ProfileCubit, ProfileState>(
                            buildWhen: (oldState, newState) =>
                                newState is ProfileFetchedState ||
                                (newState is ProfileChangedDataState &&
                                    newState.status &&
                                    newState.online != null),
                            builder: (_, state) {
                              return SwitchListTile(
                                title: Text('Online :'),
                                value: profileCubit.profile.onlineEnable,
                                onChanged: (v) => profileCubit.changeValue(
                                    onlineEnable: v,
                                    uid: appCubit.state.authUserModel.uid!,
                                    token: appCubit.state.authUserModel.token!),
                              );
                            },
                          ),
                        ],
                      ),
                    );
        },
      ),
    );
  }

  void _openImagePicker(AppCubit appCubit, ProfileCubit profileCubit) {
    _imagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null)
        profileCubit.changeProfilePic(
            filePath: value.path,
            uid: appCubit.state.authUserModel.uid!,
            token: appCubit.state.authUserModel.token!);
    });
  }
}
