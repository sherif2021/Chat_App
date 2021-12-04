import 'dart:io';

class CustomWebSocket {
  final String url;
  final Map<String, dynamic> headers;
  final Function onData;
  Function onOpen;
  Function onSessionExpired;
  Function? onClose;
  WebSocket? _channel;

  bool connected = false;
  bool isForcingClose = false;
  int times = 0;

  CustomWebSocket(
      {required this.url,
      required this.onData,
      required this.headers,
      required this.onSessionExpired,
      required this.onOpen,
      this.onClose});

  Future<void> connect() async {
    print('trying');

    if (!isForcingClose) {
      try {
        if (_channel == null) {
          _channel = await WebSocket.connect(url, headers: headers);
          connected = true;
          times = 0;
          print('connected');
          _channel?.listen(
              (data) {
                if (data == 'close')
                  forcingClose();
                else if (data == 'expired')
                  onSessionExpired();
                else if (data == 'open')
                  onOpen();
                else
                  onData(data);
              },
              cancelOnError: false,
              onDone: connect,
              onError: (e) {
                connect();
              });
        } else {
          await close();
          connect();
        }
      } catch (e) {
        print(e);
        if (times < 20) {
          await Future.delayed(Duration(seconds: 5));
          times++;
          connect();
        }
      }
    }
  }

  void sendData(String value) {
    try {
      if (connected && _channel != null) _channel?.add(value);
    } catch (e) {}
  }

  Future<void> close() async {
    print('close connection');
    connected = false;
    await _channel?.close();
    _channel = null;
  }

  void forcingClose() {
    isForcingClose = true;
    close();
  }

  void forcingConnect() {
    isForcingClose = false;
    times = 0;
    connect();
  }
}
