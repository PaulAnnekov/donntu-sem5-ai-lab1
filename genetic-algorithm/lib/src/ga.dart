library ga;

import "dart:math";
import "package:genetic_algorithm/src/selection.dart";

/**
 * Implements genetic algorithm that finds the minimum of `(x – 10) ^ 2 + 20`
 * function.
 */
class GA {
  List<int> _population = [];

  static const xBits = 16;

  static const maxX = 1 << xBits;

  final random = new Random();

  int _currentStep = 0;

  SelectionAlgorithm selectionAlgorothm;

  /**
   * Initializes population of [number] chromosomes.
   */
  _initPopulation(int number) {
    for (var i = 0; i < number; i++) {
      _population.add(random.nextInt(maxX));
    }
  }

  /**
   * Calculates function result from passed [x] and returns it.
   */
  _f(num x) {
    return pow((x - 10), 2) + 20;
  }

  /**
   * Selects the most fit [number] chromosomes from [population] and returns
   * them.
   */
  List<int> _selection(List<int> population, int number) {
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
  _crossover(List<int> population) {
    var updatedPopulation = [];

    for (var i = 0; i < population.length; i+=2) {
      var chromosomeBinary1 = population[i].toRadixString(2),
          chromosomeBinary2 = population[i + 1].toRadixString(2);

      var point;
      if (chromosomeBinary1.length < chromosomeBinary2.length) {
        point = random.nextInt(chromosomeBinary1.length);
      } else {
        point = random.nextInt(chromosomeBinary2.length);
      }

      var chromosome1 = chromosomeBinary1.substring(0, point + 1) +
              chromosomeBinary2.substring(point + 1),
          chromosome2 = chromosomeBinary2.substring(0, point + 1) +
              chromosomeBinary1.substring(point + 1);

      updatedPopulation.add(int.parse(chromosome1, radix: 2));
      updatedPopulation.add(int.parse(chromosome2, radix: 2));
    }

    return updatedPopulation;
  }

  /**
   * Makes random mutation of random bit of each chromosome with random
   * probability in [population] and returns updated.
   */
  _mutation(List<int> population) {
    var updatedPopulation = [];

    for (var i = 0; i < population.length; i++) {
      if (random.nextInt(2) == 0) {
        updatedPopulation.add(population[i]);
        continue;
      }

      var chromosomeBinary = population[i].toRadixString(2),
          position = random.nextInt(chromosomeBinary.length);
      // I haven't found easier way to replace single character in string :(.
      chromosomeBinary = chromosomeBinary.substring(0,position) +
          (chromosomeBinary[position].compareTo("0") == 0 ? "1" : "0") +
              chromosomeBinary.substring(position + 1);

      updatedPopulation.add(int.parse(chromosomeBinary, radix: 2));
    }

    return updatedPopulation;
  }

  _logPopulation(String description, List<int> population) {
    print(description);
    population.forEach((chromosome) {
      print(chromosome.toString() + ' (' + chromosome.toRadixString(2) + ')');
    });
    print('');
  }

  _logStep() {
    print('Current step: $_currentStep');
  }

  GA.start([int chromosomes = 4, int steps = 20]) {
    if (!chromosomes.isEven)
      throw new Exception("Number of chromosomes must be even");

    var tempPopulation = [];

    selectionAlgorothm = new SelectionAlgorithm();

    _initPopulation(chromosomes);

    while (_currentStep < steps) {
      _currentStep++;

      _logStep();
      _logPopulation("Initial population", tempPopulation);

      tempPopulation = _selection(_population, _population.length);
      _logPopulation("Selection", tempPopulation);

      tempPopulation = _crossover(tempPopulation);
      _logPopulation("Crossover", tempPopulation);

      tempPopulation = _mutation(tempPopulation);
      _logPopulation("Mutation", tempPopulation);

      tempPopulation.addAll(_population);
      _population = _selection(tempPopulation, _population.length);
    }

    _logPopulation("Result", tempPopulation);
  }
}