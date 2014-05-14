library client;

import "dart:convert";
import "dart:io";

import "package:authentication_via_handshake/end.dart";

class Client {
  String _ip;
  int _port;
  End _end;

  Client([String ip = '127.0.0.1', int port = 4041]) {
    _ip = ip;
    _port = port;
  }

  /**
   * Initiates connection to another client.
   */
  void initConnection() {
    serverConnect((message) {
      // I hope that there will be no errors on second try :).
      clientConnect(null);
    });
  }

  /**
   * Makes some actions after connection is esteblished with [socket].
   */
  void _onConnect(Socket socket) {
    var toSend = _end.onConnect();
    if (toSend != null) {
      socket.write(JSON.encode(toSend));
    }

    socket.transform(UTF8.decoder).listen((message) {
      var toSend = _end.onReceive(JSON.decode(message));
      if (toSend != null) {
        socket.write(JSON.encode(toSend));
      }
    });
  }

  /**
   * Tries to listen for incoming connections as server. Calls [onError] if
   * error occurred.
   */
  void serverConnect(Function onError) {
    ServerSocket.bind(_ip, _port).then((serverSocket) {
      serverSocket.listen((socket) {
        _onConnect(socket);
      });
    }, onError: onError);
  }

  /**
   * Tries to connect to server. Calls [onError] if error occurred.
   */
  void clientConnect(Function onError) {
    Socket.connect(_ip, _port).then((socket) {
      _onConnect(socket);
    }, onError: onError);
  }

  /**
   * Sets the end which processes the data from the other end.
   */
  void setEnd(End end) {
    _end = end;
  }
}