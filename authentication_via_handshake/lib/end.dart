library end;

import "package:authentication_via_handshake/authenticator.dart";
import "package:authentication_via_handshake/peer.dart";

abstract class End {
  factory End(String end) {
    switch (end) {
      case "authenticator":
        return new Authenticator();
        break;
      case "peer":
        return new Peer();
        break;
    }
  }

  String onConnect();

  String onReceive(String message);
}
