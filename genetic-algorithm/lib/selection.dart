library selection;

import "dart:math";
import "dart:collection";

abstract class SelectionAlgorithm {
  factory SelectionAlgorithm() {
    return new RangingSelection();
  }

  /**
   * Selects the most fit [number] chromosomes from using [fitnesses] and
   * returns a list with fitness keys.
   */
  List<double> select(List<double> fitnesses, int number, [bool is_max = true]);
}

class RouletteWheelSelection implements SelectionAlgorithm {
  Random random = new Random();

  List<double> select(List<double> fitnesses, int number,  [bool is_max = true]) {
    var probabilities = [],
        totalFitness = 0,
        selected = [];

    fitnesses.forEach((fitness) => totalFitness += fitness);
    fitnesses.forEach((fitness) {
      var probability = fitness / totalFitness;
      print(probability);
      if (is_max) {
        probabilities.add(probability);
      } else {
        probabilities.add(1 / fitnesses.length - probability);
      }
    });

    print(probabilities);

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

  List<double> select(List<double> fitnesses, int number, [bool is_max = true]) {
    var selected = [];

    print('selection input: ' + fitnesses.toString());
    for (var i = 0; i < number; i++) {
      // Set subset size from 2 to population size chromosomes.
      var size = 2,//random.nextInt(fitnesses.length - 1) + 2,
          chosen,
          chromosome,
          subset = [];

      while (size > 0) {
        chromosome = random.nextInt(fitnesses.length);
        if (!subset.contains(chromosome)) {
          subset.add(chromosome);
          size--;
        }
      }
      print('tournament between: ' + subset.toString());
      chosen = subset.first;
      subset.forEach((index) {
        if (is_max && fitnesses[index] > fitnesses[chosen] ||
            !is_max && fitnesses[index] < fitnesses[chosen]) {
          chosen = index;
        }
      });
      print('chosen: ' + chosen.toString());
      selected.add(chosen);
    }

    return selected;
  }
}

class RangingSelection implements SelectionAlgorithm {
  Random random = new Random();

  List<double> select(List<double> fitnesses, int number, [bool is_max = true]) {
    if (is_max) {
      throw new Exception(
          "Selection by the higher fitness has not been implemented yet.");
    }

    SplayTreeMap<int, double> map = new SplayTreeMap.from(fitnesses.asMap(), (key1, key2) {
      return fitnesses[key1] < fitnesses[key2] ? 1 : -1;
    });
    var probabilities = {},
        i = 0,
        selected = [];

    map.forEach((index, fitness) {
      var a = random.nextDouble() + 1;
      probabilities[index] = 1 / fitnesses.length * (a - (a - 2 + a) * ((i - 1) / (fitnesses.length - 1)));
      i++;
    });

    for (var i = 0; i < number; i++) {
      var test = random.nextDouble(),
          current = 0,
          chromosome = -1;

      map.forEach((index, fitness) {
        if (chromosome == -1 && test < current + probabilities[index]) {
          chromosome = index;
        } else {
          current += probabilities[index];
        }
      });

      selected.add(chromosome);
    }

    return selected;
  }
}