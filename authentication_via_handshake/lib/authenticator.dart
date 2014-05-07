library authenticator;

import "dart:convert";
import "dart:math";

import "package:authentication_via_handshake/end.dart";

import "package:cipher/cipher.dart";
import "package:cipher/impl/server.dart";

import 'package:collection/equality.dart';

class Authenticator implements End {
  Map<String, String> _keys;
  String _randomString;
  Random _random;

  Authenticator(Map<String, String> keys) {
    _keys=keys;

    _random = new Random();
    initCipher();
  }

  Map onConnect() {
    print('Connected to peer.');

    var login = _keys.keys.elementAt(_random.nextInt(_keys.keys.length));
    _randomString = _getRandomString();

    var params = new PaddedBlockCipherParameters(new KeyParameter(UTF8.encode(
        _keys[login])), null);
    var cipher = new PaddedBlockCipher("AES/PKCS7")..init(true, params);
    var cipherText = cipher.process(UTF8.encode(_randomString));

    print('Sended ID ($login) and cipher text from random string '
        '"$_randomString" to peer.');

    return {
      "action": "init",
      "login": login,
      "cipherText": cipherText
    };
  }

  Map onReceive(Map message) {
    if (message['action'] != 'hash') {
      print('Unknown action received. Maybe it is not peer. '
          'Data: ' + message.toString());
      return null;
    }

    print('Received hash from random string from peer.');

    var digest = new Digest('SHA-256');
    var hash = digest.process(UTF8.encode(_randomString));

    var listEquality = new ListEquality();
    if (listEquality.equals(hash, message['hash'])) {
      print('The end was successfully authenticated');
    } else {
      print('Unknown end');
    }

    return null;
  }

  /**
   * Gets random string.
   */
  String _getRandomString() {
    var randomString = '';
    for (var i = 0; i < 32; i++) {
      // Char codes generated from 32 to 126 (main Latin part of Unicode).
      randomString += new String.fromCharCode(_random.nextInt(94)+32);
    }

    return randomString;
  }
}
