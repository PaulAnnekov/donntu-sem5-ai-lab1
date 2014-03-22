library selection;

import "dart:math";

abstract class SelectionAlgorithm {
  factory SelectionAlgorithm() {
    return new TournamentSelection();
  }

  List<int> select(List<int> fitnesses, int number, [bool is_max = true]);
}

class RouletteWheelSelection implements SelectionAlgorithm {
  Random random = new Random();

  List<int> select(List<int> fitnesses, int number,  [bool is_max = true]) {
    if (!is_max) {
      throw new Exception(
          "Selection by the lower fitness has not been implemented yet.");
    }

    var probabilities = [],
        totalFitness = 0,
        selected = [];

    fitnesses.forEach((fitness) => totalFitness += fitness);
    fitnesses.forEach((fitness) =>
        probabilities.add(fitness / totalFitness));

    for (var i = 0; i < number; i++) {
      var test = random.nextDouble(),
          current = 0;
      for (var j = 0; j < probabilities.length; j++) {
        if (test < current + probabilities[j]) {
          selected.add(j);
          break;
        }

        current += probabilities[j];
      }
    }

    return selected;
  }
}

class TournamentSelection implements SelectionAlgorithm {
  Random random = new Random();

  List<int> select(List<int> fitnesses, int number, [bool is_max = true]) {
    var selected = [];

    for (var i = 0; i < number; i++) {
      // Set subset size from 2 to population size chromosomes.
      var size = random.nextInt(fitnesses.length - 1) + 2,
          chosen,
          subset = [];

      while (size > 0) {
        subset.add(random.nextInt(fitnesses.length));
        size--;
      }
      chosen = subset.first;
      subset.forEach((index) {
        if (is_max && fitnesses[index] > fitnesses[chosen] ||
            !is_max && fitnesses[index] < fitnesses[chosen]) {
          chosen = index;
        }
      });
      selected.add(chosen);
    }

    return selected;
  }
}