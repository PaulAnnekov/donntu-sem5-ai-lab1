import "package:genetic_algorithm/ga.dart";
import 'package:args/args.dart';

void main(List<String> args) {
  var parser = new ArgParser();
  parser.addOption('chromosomes', abbr: 'c', defaultsTo: '10'); // Chromosomes count.
  parser.addOption('steps', abbr: 's', defaultsTo: '40'); // Number of steps.
  parser.addOption('mutation', abbr: 'm', defaultsTo: '0.5'); // Mutation chance.
  //parser.addOption('crossover', abbr: 'r', defaultsTo: '0.6'); // Crossover chance.
  //parser.addFlag('binary-tournament', abbr: 'b', defaultsTo: true); // Is binary tournament selection.
  parser.addFlag('help', abbr: 'h', defaultsTo: false);
  ArgResults results = parser.parse(args);

  Map<String, dynamic> inputArgs = {};
  inputArgs['chromosomes'] = int.parse(results['chromosomes'], radix: 10);
  inputArgs['steps'] = int.parse(results['steps'], radix: 10);
  inputArgs['mutation'] = double.parse(results['mutation']);
  //inputArgs['crossover'] = double.parse(results['crossover']);

  if (results['help']) {
    print(parser.getUsage());
  } else {
    var ga = new GA.start(inputArgs);
  }
}