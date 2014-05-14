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

  /**
   * Makes some action after connection is established and returns map of data
   * to send to the opposite end or null.
   */
  Map onConnect();

  /**
   * Makes some action with passed [message] from oppoiste end and returns map of
   * data to send or null.
   */
  Map onReceive(Map message);
}
