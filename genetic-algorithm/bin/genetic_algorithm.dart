import "dart:math";

/**
 * Implements genetic algorithm that finds the minimum of `(x – 10) ^ 2 + 20`
 * function.
 *
 * Initialization:
 *
 * 1. Generate initial population (0 to infinity) of chromosome of user defined size.
 * 2. Get fitness of all chromosomes and theirs probability for next gen.
 *
 * Selection:
 * Randomly select chromosomes for new population based on probability.
 *
 * Crossover:
 *
 * 1. Break into pairs in the order of selection.
 * 2. Make crossover.
 *
 * Mutation:
 * Randomly invert one bit in each chromosome.
 *
 * Repeat algorithm until some maximum iterations number.
 */
class GA {
  List<int> _population = [];

  static const xBits = 16;

  static const maxX = 1 << xBits;

  final random = new Random();

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
   * Randomly selects chromosomes and updates population.
   */
  _selection() {
    var fitnesses = [],
        probabilities = [],
        totalFitness = 0,
        newPopulation = [];

    _population.forEach((chromosome) => fitnesses.add(_f(chromosome)));
    fitnesses.forEach((fitness) => totalFitness += fitness);
    fitnesses.forEach((fitness) => probabilities.add(fitness / totalFitness));

    for (var i = 0; i < _population.length; i++) {
      var test = random.nextDouble(),
          current = 0;
      for (var j = 0; j < probabilities.length; j++) {
        if (test < current + probabilities[j]) {
          newPopulation.add(_population[j]);
          break;
        }

        current += probabilities[j];
      }
    }

    _population = newPopulation;
  }

  /**
   * Makes crossover and updates population.
   */
  _crossover() {
    for (var i = 0; i < _population.length; i+=2) {
      var point = random.nextInt(xBits),
          chromosomeBinary1 = _population[i].toRadixString(2),
          chromosomeBinary2 = _population[i + 1].toRadixString(2),
          chromosome1 = chromosomeBinary1.substring(0, point + 1) +
              chromosomeBinary2.substring(point + 1),
          chromosome2 = chromosomeBinary2.substring(0, point + 1) +
              chromosomeBinary1.substring(point + 1);

      _population[i] = int.parse(chromosome1, radix: 2);
      _population[i+1] = int.parse(chromosome2, radix: 2);
    }
  }

  /**
   * Makes random mutation of random bit of each chromosome with random
   * probability.
   */
  _mutation() {
    for (var i = 0; i < _population.length; i++) {
      if (random.nextInt(2) == 0) {
        continue;
      }

      var chromosomeBinary = _population[i].toRadixString(2),
          position = random.nextInt(chromosomeBinary.length);
      chromosomeBinary = chromosomeBinary.substring(0,position) +
          (chromosomeBinary[position].compareTo("0") == 0 ? "1" : "0") +
              chromosomeBinary.substring(position + 1);

      _population[i]=int.parse(chromosomeBinary, radix: 2);
    }
  }

  GA.start([int chromosomes = 4, int steps = 20]) {
    _initPopulation(chromosomes);

    var stepsLeft = steps;
    while (steps > 0) {
      _selection();
      _crossover();
      _mutation();

      steps--;
    }
  }
}

void main() {
  var ga = new GA.start();
}
