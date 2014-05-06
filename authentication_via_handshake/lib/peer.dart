library peer;

import "dart:convert";
import "dart:math";

import "package:authentication_via_handshake/end.dart";

import "package:cipher/cipher.dart";
import "package:cipher/impl/server.dart";

class Peer implements End {
  Map<String, String> keys;

  Peer(keys);

  Map onConnect() {
    Random random = new Random();
    var login = keys.keys.elementAt(random.nextInt(keys.keys.length));
    var randomString = _randomString();

    initCipher();
    var digest = new Digest('SHA-256');
    var hash = digest.process(UTF8.encode(randomString));

    return {
      "action": "init",
      "login": login,
      "cipherText": hash
    };
  }

  Map onReceive(Map message) {
    //print(message);

    return null;//{"Peer": "123"};
  }

  /**
   * Gets random string.
   */
  String _randomString() {
    return "random :)";
  }
}