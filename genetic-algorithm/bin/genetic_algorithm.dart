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
  List<num> _population = [];

  _initPopulation(int chromosomes) {
    var random = new Random();
    for (var i = 0; i < chromosomes; i++) {
      _population.add(random.nextInt(1 << 32));
      print(_population.last);
    }
  }

  GA.start([int chromosomes = 4]) {
    _initPopulation(chromosomes);
  }
}

void main() {
  var ga = new GA.start();
}
