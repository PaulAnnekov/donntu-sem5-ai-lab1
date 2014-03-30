library ga;

import "dart:math";
import "dart:io";
import "package:genetic_algorithm/selection.dart";

/**
 * Implements genetic algorithm that finds the minimum of `(x – 10) ^ 2 + 20`
 * function.
 */
class GA {
  List<double> _population = [];

  /**
   * Maximum number of fractional digits for each chromosome.
   */
  static const accuracyDec = 2;

  static const accuracyBin = 7;

  /**
   * Number of places in double type.
   */
  static const doublePlaces = 19;

  static const maxInt = 16;

  final random = new Random();

  int _currentStep = 0;

  SelectionAlgorithm selectionAlgorothm;

  Map<String, dynamic> args;

  /**
   * Initializes population of [number] chromosomes.
   */
  _initPopulation(int number) {
    for (var i = 0; i < number; i++) {
      _population.add(random.nextInt(1 << maxInt) +
          random.nextInt(pow(10, accuracyDec)) / pow(10, accuracyDec));
    }
  }

  /**
   * Calculates function result from passed [x] and returns it.
   */
  double _f(double x) {
    return pow((x - 10), 2) + 20;
  }

  /**
   * Selects the most fit [number] chromosomes from [population] and returns
   * them.
   */
  List<double> _selection(List<double> population, int number) {
    var fitnesses = [],
        newPopulation = [];

    population.forEach((chromosome) => fitnesses.add(_f(chromosome)));
    selectionAlgorothm.select(fitnesses, number, false).forEach((index) =>
        newPopulation.add(population[index]));

    return newPopulation;
  }

  /**
   * Makes crossover on [population] and returns updated.
   */
  _crossover(List<double> population) {
    var updatedPopulation = [];

    for (var i = 0; i < population.length; i+=2) {
      /*if (random.nextDouble() > args['crossover']) {
        print('no crossover between ' + i.toString() + ' and ' + (i + 1).toString());
        updatedPopulation.add(population[i]);
        updatedPopulation.add(population[i + 1]);
        continue;
      }*/

      var chromosomeBinary1 = _doubleToBinary(population[i]),
          chromosomeBinary2 = _doubleToBinary(population[i + 1]);

      print("crossover of " + population[i].toString() + " and " + population[i + 1].toString());

      if (chromosomeBinary1.length < chromosomeBinary2.length) {
        chromosomeBinary1 = _padZeros(chromosomeBinary1, chromosomeBinary2.length);
      } else if (chromosomeBinary1.length > chromosomeBinary2.length) {
        chromosomeBinary2 = _padZeros(chromosomeBinary2, chromosomeBinary1.length);
      }

      var point = random.nextInt(chromosomeBinary1.length);

      print("point: " + point.toString());

      var chromosome1 = chromosomeBinary1.substring(0, point + 1) +
              chromosomeBinary2.substring(point + 1),
          chromosome2 = chromosomeBinary2.substring(0, point + 1) +
              chromosomeBinary1.substring(point + 1);

      updatedPopulation.add(_binaryToDouble(chromosome1));
      updatedPopulation.add(_binaryToDouble(chromosome2));
    }

    return updatedPopulation;
  }

  /**
   * Makes random mutation of random bit of each chromosome with random
   * probability in [population] and returns updated.
   */
  _mutation(List<double> population) {
    var updatedPopulation = [];

    for (var i = 0; i < population.length; i++) {
      var c = random.nextDouble();
      if (c > args['mutation']) {
        updatedPopulation.add(population[i]);
        continue;
      }

      var chromosomeBinary = _doubleToBinary(population[i]),
          position = random.nextInt(chromosomeBinary.length);
      // I haven't found easier way to replace single character in string :(.
      chromosomeBinary = chromosomeBinary.substring(0,position) +
          (chromosomeBinary[position].compareTo("0") == 0 ? "1" : "0") +
              chromosomeBinary.substring(position + 1);

      updatedPopulation.add(_binaryToDouble(chromosomeBinary));
    }

    return updatedPopulation;
  }

  String _padZeros(String input, int length) {
    var output = input;

    while (output.length < length) {
      output = "0" + output;
    }

    return output;
  }

  String _doubleToBinary(double chromosome) {
    int integral = chromosome.truncate();
    var fractional = (chromosome - integral) * pow(10, accuracyDec);
    var fractionalBinary = fractional.round().toRadixString(2);
    fractionalBinary = _padZeros(fractionalBinary, accuracyBin);

    return integral.toRadixString(2) + fractionalBinary;
  }

  double _binaryToDouble(String binary) {
    var integral = binary.substring(0, binary.length - accuracyBin);
    var fractional = binary.substring(binary.length - accuracyBin);


    return int.parse(integral, radix: 2) +
        int.parse(fractional, radix: 2) / pow(10, accuracyDec);
  }

  _logPopulation(String description, List<double> population) {
    print(description);
    population.forEach((chromosome) {
      print('c: ' + chromosome.toString() + ' (' + _doubleToBinary(chromosome) +
          '), f: ' + _f(chromosome).toString());
    });
    print('');
  }

  _logStep() {
    print('Current step: $_currentStep');
  }

  _log(String text) {
    print(text);
  }

  double _getBestChromosome() {
    var best = _population.first;

    _population.forEach((chromosome) {
      if (_f(chromosome) < _f(best)) {
        best = chromosome;
      }
    });

    return best;
  }

  _setOptions() {

  }



  GA.start(Map<String, dynamic> args) {
    this.args = args;

    if (!args['chromosomes'].isEven)
      throw new Exception("Number of chromosomes must be even");

    var tempPopulation = [];

    selectionAlgorothm = new SelectionAlgorithm();

    _initPopulation(args['chromosomes']);
    _logPopulation("Initial population", _population);

    var bestChromosomeEver = _population.first;

    while (_currentStep < args['steps']) {
      _currentStep++;

      _logStep();

      tempPopulation = _selection(_population, _population.length);
      _logPopulation("Selection", tempPopulation);

      tempPopulation = _crossover(tempPopulation);
      _logPopulation("Crossover", tempPopulation);

      tempPopulation = _mutation(tempPopulation);
      _logPopulation("Step result (Mutation completed)", tempPopulation);

     // tempPopulation.addAll(_population);
      //_population = _selection(tempPopulation, _population.length);
      _population = tempPopulation;

      var bestChromosome = _getBestChromosome();
      if (_f(bestChromosome) < _f(bestChromosomeEver)) {
        bestChromosomeEver = bestChromosome;
      }

      _log("Best chromosome in this step: " + bestChromosome.toString());
      _log("Best chromosome ever: " + bestChromosomeEver.toString());

      stdin.readLineSync();
    }
  }
}