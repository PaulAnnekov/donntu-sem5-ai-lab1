import "dart:typed_data";
import "dart:io";
import "dart:convert";

import "package:cipher/cipher.dart";
import "package:cipher/impl/server.dart";

class Db {
  List<int> _key;
  String _path = "./db.data";
  List<int> _salt = [];
  Map<String, String> _db = null;

  Db(String masterPassword, [String file]) {
    initCipher();

    _key=_genKey(masterPassword);

    if (file != null) {
      this._path = file;
    }

    _initDb();
  }

  /**
   * Generates DB key from password.
   */
  _genKey(String password) {
    var salt = new Uint8List.fromList(_salt);
    var params = new Pbkdf2Parameters(salt, 100, 16);
    var keyDerivator = new KeyDerivator("SHA-1/HMAC/PBKDF2")
      ..init(params)
    ;

    return keyDerivator.process(UTF8.encode(password));
  }

  /**
   * Gets database from file.
   */
  Object _initDb() {
    var file = new File(_path);

    if (!file.existsSync()) {
      _db = {};
      return _db;
    }

    var params = new KeyParameter(_key);
    var cipher = new BlockCipher("AES")..init(false, params);

    var cipherText = cipher.process(file.readAsBytesSync());

    _db=JSON.decode(UTF8.decode(cipherText));

    return _db;
  }

  /**
   * Encodes data and writes it to database file.
   */
  _saveDb() {
    var file = new File(_path);

    var params = new KeyParameter(_key);
    var cipher = new BlockCipher("AES")..init(true, params);

    var cipherText = cipher.process(UTF8.encode(JSON.encode(_db)));

    file.writeAsBytesSync(cipherText);
  }

  /**
   * Adds new user with [login] and [password] to DB.
   */
  void addUser(String login, String password) {
    var digest = new Digest('SHA-256');
    var hash = digest.process(UTF8.encode(password));

    _db[login]=hash;
    _saveDb();
  }

  /**
   * Gets user's hashed password by [login].
   * Returns null if the passed login does not exist.
   */
  String getPassword(String login) {
    if (!_db.containsKey(login)) {
      return null;
    }

    return _db["login"];
  }

  /**
   * Gets all users and hashed passwords from DB as formatted string.
   */
  String getLoginData() {
    return _db.toString();
  }
}
