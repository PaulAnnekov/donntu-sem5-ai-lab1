import 'dart:io';
import 'dart:math';

List<String> symptoms = [];
Map objects = {};

/**
 * Ask questions and returns a list of symptoms.
 */
List<int> askQuestions() {
  var acceptedSymptoms=[];
  List symptomsCopy = new List.from(symptoms);
  Random random = new Random();

  while(symptomsCopy.isNotEmpty && acceptedSymptoms.length < 2) {
    var index = (symptomsCopy.length > 1) ? random.nextInt(symptomsCopy.length-1) : 0;
    print('Does this object has "${symptomsCopy[index]}" symptom (y/n)?');
    if (stdin.readLineSync() == 'y') {
      acceptedSymptoms.add(index);
    }
    symptomsCopy.removeAt(index);
  }

  return acceptedSymptoms;
}

/**
 * Checks symptoms list.
 */
checkSymptoms(List<int> chosenSymptoms) {
  var isPromtObject=true;
  print('$chosenSymptoms $symptoms $objects');
  if (chosenSymptoms.length < 2) {
    print('Not enough symptoms to determine object. Add missing symptoms and name the object.');
    while(chosenSymptoms.length < 2) {
      print('Enter one more symptom to describe this object:');
      symptoms.add(stdin.readLineSync());
      chosenSymptoms.add(symptoms.length);
    }
  } else {
    String objectName;
    for (var key in objects.keys) {
      if (objects[key].every((v) => chosenSymptoms.contains(v))) {
        objectName=key;
        break;
      }
    }

    if (objectName != null) {
      print('The object is "$objectName"');
      isPromtObject=false;
    } else {
      print('Object with such symptoms is not found');
    }
  }

  if (isPromtObject) {
    print('Enter object name to associate with these symptoms:');
    objects[stdin.readLineSync()] = chosenSymptoms;
  }
}

/**
 * Program flow control function.
 */
main() {
  print('Hello');

  var is_continue=true;
  while(is_continue) {
    List<int> acceptedSymptoms = askQuestions();
    checkSymptoms(acceptedSymptoms);

    print('Do you want to continue (y/n)?');
    if (stdin.readLineSync() != 'y') {
      is_continue=false;
    }
  }

  print('Bye');
}