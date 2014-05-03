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

  Db([String file]) {
    if (file != null) {
      this._path = file;
    }
  }

  /**
   * Initiates connection to DB with [masterPassword] and returns [true] if
   * connection was successful.
   */
  bool init(String masterPassword) {
    initCipher();

    _key=_genKey(masterPassword);

    _initDb();

    return _db != null;
  }

  /**
   * Generates DB key from password.
   */
  _genKey(String password) {
    var salt = new Uint8List.fromList(_salt);
    var params = new Pbkdf2Parameters(salt, 100, 16);
    var keyDerivator = new KeyDerivator("SHA-1/HMAC/PBKDF2")
      ..init(params);

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

    var params = new PaddedBlockCipherParameters(new KeyParameter(_key), null);
    var cipher = new PaddedBlockCipher("AES/PKCS7")..init(false, params);

    try {
      var dbBytes = cipher.process(file.readAsBytesSync());
      _db=JSON.decode(UTF8.decode(dbBytes));
    } catch (e) {
      print('Malformed data in DB file. Maybe key is invalid. Exception: "$e"');
    }

    return _db;
  }

  /**
   * Encodes data and writes it to database file.
   */
  _saveDb() {
    var file = new File(_path);

    var params = new PaddedBlockCipherParameters(new KeyParameter(_key), null);
    var cipher = new PaddedBlockCipher("AES/PKCS7")..init(true, params);
    var dbBytes = UTF8.encode(JSON.encode(_db));

    var cipherText = cipher.process(dbBytes);

    file.writeAsBytesSync(cipherText);
  }

  /**
   * Adds new user with [login] and [password] to DB.
   */
  void addUser(String login, String password) {
    var digest = new Digest('SHA-256');
    var hash = digest.process(UTF8.encode(password));

    _db[login]=UTF8.decode(hash, allowMalformed: true);
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

    return _db[login];
  }

  /**
   * Gets all users and hashed passwords from DB as formatted string.
   */
  String getLoginData() {
    return _db.toString();
  }
}
