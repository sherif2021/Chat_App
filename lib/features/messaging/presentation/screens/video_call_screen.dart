import 'package:chat/features/messaging/presentation/logic/bloc/home/home_bloc.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/video_calling/video_calling_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallingScreen extends StatelessWidget {
  final String uid;
  final String name;
  final String pic;
  final bool isInComing;

  const VideoCallingScreen(
      {required this.uid,
      required this.pic,
      required this.name,
      required this.isInComing});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(listener: (_, state) {
          final videoCallingBloc = context.read<VideoCallingBloc>();

          if (state is AcceptingVideoCallingState && state.uid == uid)
            videoCallingBloc.add(CallingStartEvent());

          if (state is OnVideoCallingDataState && state.uid == uid)
            videoCallingBloc.add(
                CallingDataEvent(event: state.event, payload: state.payload));

          if (state is CloseVideoCallingState && state.uid == uid) {
            Navigator.pop(context);
          }
          if (state is CancelVideoCallingState && state.uid == uid) {
            videoCallingBloc.add(CallingCancelEvent());
          }
        }),
        BlocListener<VideoCallingBloc, VideoCallingState>(listener: (_, state) {
          if (state is CallingCloseState) Navigator.pop(context);

          if (state is CallingErrorState ||
              state is CallingOfflineState ||
              state is CallingCancelingState ||
              state is CallingBusyState)
            Future.delayed(Duration(seconds: 5)).then((v) {
              try {
                if (Navigator.canPop(context)) Navigator.pop(context);
              } catch (e) {}
            });
        })
      ],
      child: WillPopScope(
        onWillPop: () {
          context.read<VideoCallingBloc>().add(CallingCloseEvent(false));
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: BlocBuilder<VideoCallingBloc, VideoCallingState>(
            buildWhen: (oldState, newState) => newState is CallingIsActiveState,
            builder: (context, state) {
              return state is CallingIsActiveState
                  ? OrientationBuilder(builder: (context, orientation) {
                      return Container(
                        child: Stack(children: <Widget>[
                          Positioned(
                              left: 0.0,
                              right: 0.0,
                              top: 0.0,
                              bottom: 0.0,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: RTCVideoView(context
                                    .read<VideoCallingBloc>()
                                    .remoteRenderer!),
                                decoration:
                                    BoxDecoration(color: Colors.black54),
                              )),
                          Positioned(
                            left: 20.0,
                            top: 20.0,
                            child: Container(
                              width: orientation == Orientation.portrait
                                  ? 90.0
                                  : 120.0,
                              height: orientation == Orientation.portrait
                                  ? 120.0
                                  : 90.0,
                              child: RTCVideoView(context
                                  .read<VideoCallingBloc>()
                                  .localRenderer!),
                              decoration: BoxDecoration(color: Colors.black54),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FloatingActionButton(
                                    heroTag: null,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.call_end),
                                    onPressed: () => context
                                        .read<VideoCallingBloc>()
                                        .add(CallingCloseEvent(false)),
                                  ),
                                  FloatingActionButton(
                                    heroTag: null,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.switch_camera),
                                    onPressed: context
                                        .read<VideoCallingBloc>()
                                        .signaling
                                        .switchCamera,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]),
                      );
                    })
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 80.h,
                          ),
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(pic),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          SizedBox(
                            height: 50.h,
                          ),
                          BlocBuilder<VideoCallingBloc, VideoCallingState>(
                            buildWhen: (oldState, newState) =>
                                newState is CallingWaitingState ||
                                newState is CallingRingingState ||
                                newState is CallingErrorState ||
                                newState is CallingOfflineState ||
                                newState is CallingCancelingState,
                            builder: (context, state) {
                              return Text(
                                state is CallingWaitingState
                                    ? 'Waiting...'
                                    : state is CallingRingingState
                                        ? 'Ringing...'
                                        : state is CallingErrorState
                                            ? 'Error...'
                                            : state is CallingBusyState
                                                ? 'Busy...'
                                                : state is CallingOfflineState
                                                    ? 'The User is Offline....'
                                                    : state is CallingCancelingState
                                                        ? 'The User is Canceling Calling....'
                                                        : state is CallingCloseState
                                                            ? 'The User is Closing Calling....'
                                                            : '',
                                style: Theme.of(context).textTheme.bodyText1,
                              );
                            },
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (isInComing)
                                FloatingActionButton(
                                  onPressed: () => context
                                          .read<VideoCallingBloc>()
                                          .state is CallingRingingState
                                      ? context
                                          .read<VideoCallingBloc>()
                                          .add(CallingAcceptEvent())
                                      : null,
                                  heroTag: null,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.call),
                                ),
                              FloatingActionButton(
                                onPressed: () => context
                                    .read<VideoCallingBloc>()
                                    .add(CallingCloseEvent(false)),
                                heroTag: null,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.call_end),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50.h,
                          ),
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
