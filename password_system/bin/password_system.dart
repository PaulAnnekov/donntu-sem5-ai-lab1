import "../lib/db.dart";
import "dart:io";

Db db;

void main() {
  db = new Db("key");

  stdout.writeln("Hi");

  var is_exit=false;
  while (!is_exit) {
    stdout.writeln("Write actions");

    var action = stdin.readLineSync();
    var parts = action.split(' ');

    switch(parts[0]) {
      case 'add':
        db.addUser(parts[1], parts[2]);
        stdout.writeln('User "${parts[1]}" was added');
        break;
      case 'get':
        stdout.writeln(db.getPassword(parts[1]));
        break;
      case 'get_all':
        stdout.writeln(db.getLoginData());
        break;
      case 'exit':
        is_exit=true;
        break;
    }
  }

  stdout.writeln("GL HF");
}