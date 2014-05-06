import "package:authentication_via_handshake/client.dart";
import "package:authentication_via_handshake/end.dart";

void main() {
  var clients={
    "paul": "123",
    "admin": "321"
  };

  print("Application started");

  var client1 = new Client();
  var client2 = new Client();

  client1.setEnd(new End("authenticator"));
  client2.setEnd(new End("peer"));

  client1.initConnection();
  client2.initConnection();
}
