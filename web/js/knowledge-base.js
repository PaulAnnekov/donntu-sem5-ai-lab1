/*jslint browser: true*/

function Kb() {
    'use strict';

    var associations = {},
        symptoms = [],
        diagnoses = [];

    function loadFromStorage() {
        var kbJson = localStorage.getItem('kb'),
            kb;
        if (!kbJson) {
            return;
        }

        kb = JSON.parse(kbJson);

        associations = kb.associations;
        symptoms = kb.symptoms;
        diagnoses = kb.diagnoses;
    }

    function saveToStorage() {
        var kb = {
            associations: associations,
            symptoms: symptoms,
            diagnoses: diagnoses
        };

        localStorage.setItem('kb', JSON.stringify(kb));
    }

    /**
     * Checks whether one of the sets is a subset of another.
     *
     * @param {Object} firstSet First set.
     * @param {Object} secondSet Second set.
     * @param {boolean} [isEqual=false] Set to <tt>true</tt> to check if sets are identical.
     * @returns {boolean} <tt>true</tt> if one set is a subset of another, <tt>false</tt> otherwise.
     */
    function checkSubset(firstSet, secondSet, isEqual) {
        var key,
            index;

        for (key in firstSet) {
            if (firstSet.hasOwnProperty(key)) {
                index = secondSet.indexOf(firstSet[key]);
                if (index >= 0) {
                    firstSet.splice(index, 1);
                    secondSet.splice(index, 1);
                }
            }
        }

        if (!isEqual && (!firstSet.length || !secondSet.length)) {
            return true;
        }

        return isEqual && !firstSet.length && !secondSet.length;
    }

    this.addSymptom = function (name) {
        if (this.isSymptomExists(name)) {
            return false;
        }

        symptoms.push(name);
        saveToStorage();

        return symptoms.length - 1;
    };

    this.addDiagnosis = function (name) {
        if (this.isDiagnosisExists(name)) {
            return false;
        }

        var diagnosisId = diagnoses.push(name) - 1;
        associations[diagnosisId] = [];
        saveToStorage();

        return diagnosisId;
    };

    this.addSymptomsToDiagnosis = function (symptomIds, diagnosisId) {
        var allSymptomIds = symptomIds.concat(associations[diagnosisId]);

        return this.setSymptomsToDiagnosis(allSymptomIds, diagnosisId);
    };

    /**
     *
     *
     * @param symptomIds
     * @param diagnosisId
     * @returns {*}
     */
    this.removeSymptomsFromDiagnosis = function (symptomIds, diagnosisId) {
        if (!associations[diagnosisId].length) {
            return false;
        }

        var diagnosisSymptomIds = associations[diagnosisId];

        diagnosisSymptomIds.filter(function (symptomId) {
            return symptomIds.indexOf(symptomId) < 0;
        });

        return this.setSymptomsToDiagnosis(diagnosisSymptomIds, diagnosisId);
    };

    this.searchDiagnosis = function (symptomIds) {
        var diagnosisId;

        for (diagnosisId in diagnoses) {
            if (diagnoses.hasOwnProperty(diagnosisId)) {
                if (checkSubset(symptomIds, associations[diagnosisId], true)) {
                    return diagnosisId;
                }
            }
        }

        return false;
    };

    this.getDiagnosisName = function (id) {
        return diagnoses[id];
    };

    this.getSymptoms = function () {
        return symptoms;
    };

    this.getDiagnoses = function () {
        return diagnoses;
    };

    this.getAssociations = function () {
        return associations;
    };

    this.setSymptomsToDiagnosis = function (symptomIds, diagnosisId) {
        var key,
            value,
            symptomIdsCopy;

        // Check symptoms set entry.
        for (key in associations) {
            if (associations.hasOwnProperty(key)) {
                value = associations[key];

                // Do not check diagnosis which symptoms we will replace and diagnoses without symptoms.
                if (key !== diagnosisId && value.length) {
                    symptomIdsCopy = symptomIds.slice();

                    if (checkSubset(value, symptomIdsCopy)) {
                        return false;
                    }
                }
            }
        }

        associations[diagnosisId] = symptomIds;
        saveToStorage();

        return true;
    };

    this.isSymptomExists = function (name) {
        return symptoms.indexOf(name) >= 0;
    };

    this.isDiagnosisExists = function (name) {
        return diagnoses.indexOf(name) >= 0;
    };

    this.isIncomplete = function () {
        return !symptoms.length || !diagnoses.length;
    };

    function init() {
        loadFromStorage();
    }

    init();
}