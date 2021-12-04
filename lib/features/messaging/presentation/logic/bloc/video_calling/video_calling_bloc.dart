import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chat/features/messaging/repository/messaging_repository.dart';
import 'package:chat/utility/webRTC/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meta/meta.dart';

part 'video_calling_event.dart';

part 'video_calling_state.dart';

class VideoCallingBloc extends Bloc<VideoCallingEvent, VideoCallingState> {
  final MessagingRepository messagingRepository;
  final String uid;
  final bool isInComing;

  late Signaling signaling;

  bool isCalling = false;

  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? remoteRenderer;

  VideoCallingBloc(
      {required this.messagingRepository,
      required this.uid,
      required this.isInComing})
      : super(CallingInitialState()) {
    signaling = Signaling(uid);
    if (!isInComing)
      _sendCallingRequest();
    else
      emit(CallingRingingState());
  }

  @override
  Stream<VideoCallingState> mapEventToState(
    VideoCallingEvent event,
  ) async* {
    if (event is CallingCloseEvent) {
      emit(CallingCloseState(event.byRemoteUser));
      if (isCalling && !event.byRemoteUser)
        messagingRepository.sendCloseVideoCalling(uid: uid);
      if (!isCalling && !event.byRemoteUser)
        messagingRepository.sendCancelVideoCalling(uid: uid);
    }

    if (event is CallingCancelEvent) emit(CallingCancelingState());

    if (event is CallingAcceptEvent || event is CallingStartEvent) {
      if (event is CallingAcceptEvent)
        messagingRepository.sendAcceptVideoCalling(uid: uid);

      isCalling = true;
      localRenderer = RTCVideoRenderer();
      remoteRenderer = RTCVideoRenderer();

      await localRenderer?.initialize();
      await remoteRenderer?.initialize();

      signaling.sendServerMessage = (data) {
        messagingRepository.sendVideoCallingData(data: data);
      };

      signaling.onLocalStream = ((stream) {
        localRenderer?.srcObject = stream;
        emit(CallingIsActiveState());
      });

      signaling.onAddRemoteStream = ((stream) {
        remoteRenderer?.srcObject = stream;
        emit(CallingIsActiveState());
      });

      signaling.onRemoveRemoteStream = ((stream) {
        remoteRenderer?.srcObject = null;
      });

      if (isInComing) signaling.connect();
    }

    if (event is CallingDataEvent) {
      signaling.onReceivedData(event.event, event.payload);
    }
  }

  void _sendCallingRequest() async {
    emit(CallingWaitingState());

    final result = await messagingRepository.requestVideoCalling(caller: uid);

    if (result == null || result == 'err')
      emit(CallingErrorState());
    else if (result == 'offline')
      emit(CallingOfflineState());
    else if (result == 'busy')
      emit(CallingBusyState());
    else if (result == 'success') {
      emit(CallingRingingState());
    }
  }

  @override
  Future<void> close() {
    localRenderer?.dispose();
    remoteRenderer?.dispose();
    signaling.disconnect();
    return super.close();
  }
}
