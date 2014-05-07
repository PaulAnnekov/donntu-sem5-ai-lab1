import "package:authentication_via_handshake/client.dart";
import "package:authentication_via_handshake/end.dart";

import 'package:args/args.dart';

void main(List<String> args) {
  var parser = new ArgParser();
  parser.addOption('client', abbr: 'c', defaultsTo: 'authenticator', help:
    '"authenticator" or "peer"');
  parser.addFlag('help', abbr: 'h', defaultsTo: false);
  ArgResults results = parser.parse(args);

  if (results['help']) {
    print(parser.getUsage());
    return;
  }

  var keys={
    "paul": "1234567890123456",
    "admin": "0987654321987654"
  };

  print('Client "${results['client']}" started.');

  var client = new Client();
  client.setEnd(new End(results['client'], keys));
  client.initConnection();
}
