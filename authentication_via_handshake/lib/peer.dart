library peer;

import "dart:convert";
import "dart:typed_data";

import "package:authentication_via_handshake/end.dart";

import "package:cipher/cipher.dart";
import "package:cipher/impl/server.dart";

class Peer implements End {
  Map<String, String> _keys;
  String _login;

  Peer(Map<String, String> keys) {
    _keys=keys;

    initCipher();
  }

  Map onConnect() {
    print('Connected to authenticator.');

    return null;
  }

  Map onReceive(Map message) {
    if (message['action'] != 'init') {
      print('Unknown action received. Maybe it is not authenticator. '
          'Data: ' + message.toString());
      return null;
    }

    var params = new PaddedBlockCipherParameters(new KeyParameter(UTF8.encode(
        _keys[message['login']])), null);
    var cipher = new PaddedBlockCipher("AES/PKCS7")..init(false, params);
    var random = cipher.process(new Uint8List.fromList(message['cipherText']));
    var randomString = UTF8.decode(random);

    print('Received ID (${message['login']}) and cipher text from random '
        'string $randomString from authenticator.');

    var digest = new Digest('SHA-256');
    var hash = digest.process(random);

    print('Generated hash from random string and sended to authenticator.');

    return {
      'action': 'hash',
      'hash': hash
    };
  }
}