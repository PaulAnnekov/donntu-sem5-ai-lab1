library end;

import "package:authentication_via_handshake/authenticator.dart";
import "package:authentication_via_handshake/peer.dart";

abstract class End {
  factory End(String end, Map<String, String> keys) {
    switch (end) {
      case "authenticator":
        return new Authenticator(keys);
        break;
      case "peer":
        return new Peer(keys);
        break;
    }
  }

  Map onConnect();

  Map onReceive(Map message);
}
