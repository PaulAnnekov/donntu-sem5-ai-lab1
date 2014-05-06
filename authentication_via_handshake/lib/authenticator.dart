library authenticator;

import "package:authentication_via_handshake/end.dart";

class Authenticator implements End {
  Map<String, String> keys;

  Authenticator(keys);

  Map onConnect() {
    return {
      "hi, peer": "123"
    };
  }

  Map onReceive(Map message) {
    switch (message['action']) {
      case 'init':
        break;
    }

    return {
      "Authenticator": "123"
    };
  }
}