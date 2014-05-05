import 'package:password_system/db.dart';
import 'dart:io';

void main() {
  var key;
  Db db = new Db();

  stdout.writeln("Simple password system (login data storage).\n");

  do {
    stdout.writeln("Enter DB key:");
    key = stdin.readLineSync();
  } while (!db.init(key));

  var is_exit = false;
  while (!is_exit) {
    stdout.writeln(
        "Write actions (add [user] [password], get [user], get_all, exit):");

    var action = stdin.readLineSync();
    var parts = action.split(' ');

    switch (parts[0]) {
      case 'add':
        db.addUser(parts[1], parts[2]);
        stdout.writeln('User "${parts[1]}" was added');
        break;
      case 'get':
        var digest = db.getPassword(parts[1]);
        if (digest == null) {
          stdout.writeln('User "${parts[1]}" does not exist in DB');
        } else {
          stdout.writeln("${parts[1]}'s SHA-256 hashed password: " + digest);
        }
        break;
      case 'get_all':
        stdout.writeln(db.getLoginData());
        break;
      case 'exit':
        is_exit = true;
        break;
    }
  }

  stdout.writeln("GL HF");
}
