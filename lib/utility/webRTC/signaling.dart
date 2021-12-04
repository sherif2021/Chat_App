import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const CLIENT_ID_EVENT = 'client-id-event';
const OFFER_EVENT = 'offer-event';
const ANSWER_EVENT = 'answer-event';
const ICE_CANDIDATE_EVENT = 'ice-candidate-event';

typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef dynamic OnServerMessageCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef void DataChannelCallback(RTCDataChannel dc);

class Signaling {
  final String userUID;
  RTCPeerConnection? peerConnection;
  RTCDataChannel? dataChannel;
  var _remoteCandidates = [];

  MediaStream? _localStream;
  List<MediaStream>? _remoteStreams;
  StreamStateCallback? onLocalStream;
  StreamStateCallback? onAddRemoteStream;
  StreamStateCallback? onRemoveRemoteStream;
  DataChannelMessageCallback? onDataChannelMessage;
  DataChannelCallback? onDataChannel;
  OtherEventCallback? sendServerMessage;

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
       */
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  Signaling(this.userUID);

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks().first);
    }
  }

  void connect({String media = 'video', isScreenSharing = false}) {
    /*if (_turnCredential == null) {
      try {
        _turnCredential = await getTurnCredential(_host, _port);
        /*{
            "username": "1584195784:mbzrxpgjys",
            "password": "isyl6FF6nqMTB9/ig5MrMRUXqZg",
            "ttl": 86400,
            "uris": ["turn:127.0.0.1:19302?transport=udp"]
          }
        */
        _iceServers = {
          'iceServers': [
            {
              'url': _turnCredential['uris'][0],
              'username': _turnCredential['username'],
              'credential': _turnCredential['password']
            },
          ]
        };
      } catch (e) {
      }
    }*/
    _createPeerConnection(media, isScreenSharing).then((pc) {
      peerConnection = pc;
      if (media == 'data') {
        _createDataChannel(pc);
      }
      _createOffer(pc, media);
    });
  }

  void disconnect() {
    _localStream?.dispose();

    _remoteStreams?.clear();

    _localStream = null;

    dataChannel?.close();

    peerConnection?.close();

    _remoteCandidates.clear();
  }

  void onReceivedData(event, payload) async {
    switch (event) {
      case OFFER_EVENT:
        var media = 'call';

        var pc = await _createPeerConnection(media, false);
        peerConnection = pc;
        await pc.setRemoteDescription(
            RTCSessionDescription(payload['sdp'], payload['type']));
        _createAnswer(pc, media);
        if (this._remoteCandidates.length > 0) {
          _remoteCandidates.forEach((candidate) async {
            await pc.addCandidate(candidate);
          });
          _remoteCandidates.clear();
        }

        break;
      case ANSWER_EVENT:
        var pc = peerConnection;
        if (pc != null) {
          await pc.setRemoteDescription(
              RTCSessionDescription(payload['sdp'], payload['type']));
        }

        break;
      case ICE_CANDIDATE_EVENT:
        if (payload != null) {
          var pc = peerConnection;
          RTCIceCandidate candidate = RTCIceCandidate(payload['candidate'],
              payload['sdpMid'], payload['sdpMLineIndex']);
          if (pc != null) {
            await pc.addCandidate(candidate);
          } else {
            _remoteCandidates.add(candidate);
          }
        }

        break;
    }
  }

  Future<MediaStream> createStream(media, userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = userScreen
        ? await navigator.mediaDevices.getDisplayMedia(mediaConstraints)
        : await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (this.onLocalStream != null) {
      this.onLocalStream!(stream);
    }
    return stream;
  }

  Future<RTCPeerConnection> _createPeerConnection(media, userScreen) async {
    if (media != 'data') _localStream = await createStream(media, userScreen);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (media != 'data') pc.addStream(_localStream!);
    pc.onIceCandidate = (candidate) {
      final iceCandidate = {
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      };
      _emitIceCandidateEvent(iceCandidate);
    };

    _localStream!.getAudioTracks()[0].enableSpeakerphone(true);

    pc.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        disconnect();
      }
    };

    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream!(stream);
      //_remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream!(stream);
      _remoteStreams!.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(channel);
    };

    return pc;
  }

  void _addDataChannel(RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage!(channel, data);
    };
    dataChannel = channel;

    if (this.onDataChannel != null) this.onDataChannel!(channel);
  }

  void _createDataChannel(RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(channel);
  }

  void _createOffer(RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s =
          await pc.createOffer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);

      final description = {'sdp': s.sdp, 'type': s.type};
      _emitOfferEvent(description);
    } catch (e) {}
  }

  void _createAnswer(RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);

      final description = {'sdp': s.sdp, 'type': s.type};
      _emitAnswerEvent(description);
    } catch (e) {}
  }

  void _send(event, data) {
    if (sendServerMessage != null)
      sendServerMessage!({'uid': userUID, 'event': event, 'payload': data});
  }

  void _emitOfferEvent(description) {
    _send(OFFER_EVENT, description);
  }

  void _emitAnswerEvent(description) {
    _send(ANSWER_EVENT, description);
  }

  void _emitIceCandidateEvent(candidate) {
    _send(ICE_CANDIDATE_EVENT, candidate);
  }
}
