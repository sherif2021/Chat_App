import 'package:chat/core/app_cubit.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/home/home_bloc.dart';
import 'package:chat/features/messaging/presentation/widgets/user_widget.dart';
import 'package:chat/utility/constants.dart';
import 'package:fcm_config/fcm_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, FCMNotificationClickMixin {
  late HomeBloc _homeBloc;
  late AppCubit _appCubit;

  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is RequestVideoCallingState) {
          Navigator.pushNamed(context, videoCallingScreen, arguments: {
            'uid': state.uid,
            'name': state.name,
            'pic': state.pic,
            'incoming': true
          });
        }
        if (state is SessionExpiredState) {
          _appCubit.clearAuth();
          Navigator.pushNamedAndRemoveUntil(
              context, loginScreen, (route) => false);
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (_homeBloc.isSearching) {
            _homeBloc.isSearching = false;
            _homeBloc.add(SearchingStatusEvent());
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              BlocBuilder<HomeBloc, HomeState>(
                builder: (_, state) {
                  if (_homeBloc.isSearching)
                    return Expanded(
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                _homeBloc.isSearching = false;
                                _homeBloc.add(SearchingStatusEvent());
                              },
                              icon: Icon(Icons.arrow_back)),
                          Expanded(
                              child: TextField(
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v) {
                              if (v.length > 0)
                                _homeBloc.add(SearchEvent(value: v, currentUserUID: _appCubit.state.authUserModel.uid!));
                            },
                          )),
                        ],
                      ),
                    );
                  else
                    return Row(
                      children: [
                        IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, profileScreen),
                            icon: Icon(Icons.person)),
                        IconButton(
                            onPressed: () {
                              if (_homeBloc.isSearching) {
                                _homeBloc.isSearching = false;
                                _homeBloc.add(SearchingStatusEvent());
                              } else {
                                _homeBloc.isSearching = true;
                                _homeBloc.add(SearchingStatusEvent());
                              }
                            },
                            icon: Icon(Icons.search))
                      ],
                    );
                },
                buildWhen: (oldState, newState) =>
                    newState is SearchingStatusState,
              )
            ],
          ),
          body: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (oldState, newState) => newState is LoadUsersState || newState is SearchResultState,
            builder: (_, state) {
              if (state is LoadUsersState || state is SearchResultState)
                return ListView.builder(
                  itemBuilder: (_, index) => UserWidget(
                      userModel: state is LoadUsersState
                          ? state.users[index]
                          : (state as SearchResultState).result[index]),
                  itemCount: state is LoadUsersState
                      ? state.users.length
                      : (state as SearchResultState).result.length,
                );
              else
                return Center(
                  child: CircularProgressIndicator(),
                );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    _appCubit = context.read<AppCubit>();

    WidgetsBinding.instance!.addObserver(this);

    _homeBloc.add(ConnectWithWebServerEvent(
        uid: _appCubit.state.authUserModel.uid!,
        token: _appCubit.state.authUserModel.token!));

    _homeBloc.add(LoadUsersEvent());

    FCMConfig.instance.getInitialMessage().then((initNotification) {
      if (initNotification != null)
        handleNotificationClick(initNotification.data['uid']);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused)
      _homeBloc.add(DisConnectWithWebServerEvent());
    else if (state == AppLifecycleState.resumed)
      _homeBloc.add(ConnectWithWebServerEvent(
          uid: _appCubit.state.authUserModel.uid!,
          token: _appCubit.state.authUserModel.token!));
  }

  @override
  void onClick(RemoteMessage notification) {
    handleNotificationClick(notification.data['uid']);
  }

  void handleNotificationClick(String? uid) async {

    if (uid != null && !_homeBloc.isInMessageScreen) {
      final user = _homeBloc.getUser(uid);

      if (user != null) {
        Navigator.pushNamed(context, messageScreen, arguments: user);
      } else {
        final userInfo = await _homeBloc.loadUserInfo(uid);
        if (userInfo != null)
          Navigator.pushNamed(context, messageScreen, arguments: userInfo);
      }
    }
  }
}
