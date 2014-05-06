library peer;

import "package:authentication_via_handshake/end.dart";

class Peer implements End {
  String onConnect() {
    return "hi, authenticator";
  }

  String onReceive(String message) {
    //print(message);

    return "Peer";
  }
}