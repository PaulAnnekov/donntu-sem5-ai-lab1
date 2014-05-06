library authenticator;

import "package:authentication_via_handshake/end.dart";

class Authenticator implements End {
  String onConnect() {
    return "hi, peer";
  }

  String onReceive(String message) {
    //print(message);

    return "Authenticator";
  }
}