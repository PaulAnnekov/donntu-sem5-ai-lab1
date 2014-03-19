import "dart:math";

// TODO: Update README.md.

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
  List<num> _population = [];

  static const maxX = 1 << 16;

  /**
   * Initializes population of [number] chromosomes.
   */
  _initPopulation(int number) {
    var random = new Random();
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
      var random = new Random().nextDouble(),
          current = 0;
      for (var j = 0; j < probabilities.length; j++) {
        if (random < current + probabilities[j]) {
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

  }

  GA.start([int chromosomes = 4, int steps = 20]) {
    _initPopulation(chromosomes);

    var stepsLeft = steps;
    while (steps > 0) {
      _selection();


      steps--;
    }

  }
}

void main() {
  var ga = new GA.start();
}
