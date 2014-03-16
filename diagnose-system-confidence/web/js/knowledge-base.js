/*global $*/
/*jslint browser: true*/

/**
 * Represents a Knowledge Base with symptoms and diagnoses.
 *
 * @constructor
 */
function Kb() {
    'use strict';

    var associations = {},
        symptoms = {
            nextId: 1,
            values: {}
        },
        diagnoses = {
            nextId: 1,
            values: {}
        };

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
            index,
            firstSetCopy,
            secondSetCopy;

        // Make a copy to prevent modify of original objects.
        firstSetCopy = firstSet.slice();
        secondSetCopy = secondSet.slice();

        for (key in firstSet) {
            if (firstSet.hasOwnProperty(key)) {
                index = secondSetCopy.indexOf(firstSet[key]);
                if (index >= 0) {
                    firstSetCopy.splice(firstSetCopy.indexOf(firstSet[key]), 1);
                    secondSetCopy.splice(index, 1);
                }
            }
        }

        if (!isEqual && (!firstSetCopy.length || !secondSetCopy.length)) {
            return true;
        }

        return isEqual && !firstSetCopy.length && !secondSetCopy.length;
    }

    this.addSymptom = function (name) {
        var symptomId = symptoms.nextId;

        if (this.isSymptomExists(name)) {
            return false;
        }

        symptoms.values[symptomId] = name;
        symptoms.nextId++;
        saveToStorage();

        return symptomId;
    };

    this.addDiagnosis = function (name) {
        var diagnosisId = diagnoses.nextId;

        if (this.isDiagnosisExists(name)) {
            return false;
        }

        diagnoses.values[diagnosisId] = name;
        diagnoses.nextId++;
        associations[diagnosisId] = {};
        saveToStorage();

        return diagnosisId;
    };

    /**
     * Adds symptoms to diagnosis.
     *
     * @param {Object} symptoms Symptoms in the following format: <code>symptomId: {cm: 0.02, mm: 0.01}</code>.
     * @param {Number} diagnosisId Diagnosis ID.
     * @returns {Boolean} <tt>true</tt> on success, <tt>false</tt> on error.
     */
    this.addSymptomsToDiagnosis = function (symptoms, diagnosisId) {
        var allSymptoms = $.extend({}, associations[diagnosisId], symptoms);

        return this.setSymptomsToDiagnosis(allSymptoms, diagnosisId);
    };

    /**
     * Removes passed symptoms from diagnosis.
     *
     * @param {Array} symptomIds List of symptoms IDs.
     * @param {Number} diagnosisId Diagnosis ID.
     * @returns {boolean} <tt>true</tt> on success remove, <tt>false</tt> otherwise.
     */
    this.removeSymptomsFromDiagnosis = function (symptomIds, diagnosisId) {
        if ($.isEmptyObject(associations[diagnosisId])) {
            return false;
        }

        var diagnosisSymptoms = {};
        $.extend(diagnosisSymptoms, associations[diagnosisId]);
        symptomIds.forEach(function (symptomId) {
            delete diagnosisSymptoms[symptomId];
        });

        return this.setSymptomsToDiagnosis(diagnosisSymptoms, diagnosisId);
    };

    /**
     * Removes diagnosis.
     *
     * @param {Number} diagnosisId Diagnosis ID.
     * @returns {Boolean} <tt>true</tt> on success, <tt>false</tt> otherwise.
     */
    this.removeDiagnosis = function (diagnosisId) {
        if (!diagnoses.values.hasOwnProperty(diagnosisId)) {
            return false;
        }

        delete associations[diagnosisId];
        delete diagnoses.values[diagnosisId];
        saveToStorage();

        return true;
    };

    /**
     * Removes symptom.
     *
     * @param {Number} symptomId Symptom ID.
     * @returns {Boolean} <tt>true</tt> on success, <tt>false</tt> otherwise.
     */
    this.removeSymptom = function (symptomId) {
        var diagnosisId;
        symptomId = parseInt(symptomId, 10);

        if (!symptoms.values.hasOwnProperty(symptomId)) {
            return false;
        }

        for (diagnosisId in associations) {
            if (associations.hasOwnProperty(diagnosisId)) {
                if (associations[diagnosisId].hasOwnProperty(symptomId)) {
                    // TODO: Check all associations set before symptom remove.
                    delete associations[diagnosisId][symptomId];
                }
            }
        }

        delete symptoms.values[symptomId];
        saveToStorage();

        return true;
    };

    this.setSymptomCm = function (diagnosisId, symptomId, cm) {
        associations[diagnosisId][symptomId].cm = cm;
        saveToStorage();
    };

    this.setSymptomMm = function (diagnosisId, symptomId, mm) {
        associations[diagnosisId][symptomId].mm = mm;
        saveToStorage();
    };

    this.calculateConfidenceCoefficients = function (symptomIds) {
        var diagnosisId,
            report = {},
            symptomId,
            symptomsCount = Object.getOwnPropertyNames(symptoms.values).length;

        for (diagnosisId in associations) {
            if (!associations.hasOwnProperty(diagnosisId)) {
                continue;
            }

            report[diagnosisId] = {
                cm: 0,
                mm: 0,
                cc: 0
            };

            for (symptomId in associations[diagnosisId]) {
                if (!associations[diagnosisId].hasOwnProperty(symptomId)) {
                    continue;
                }

                symptomId = parseInt(symptomId, 10);
                if (symptomIds.indexOf(symptomId) >= 0) {
                    report[diagnosisId].cm += associations[diagnosisId][symptomId].cm;
                    report[diagnosisId].mm += associations[diagnosisId][symptomId].mm;
                }
            }

            report[diagnosisId].cm /= symptomsCount;
            report[diagnosisId].mm /= symptomsCount;
            report[diagnosisId].cc = report[diagnosisId].cm - report[diagnosisId].mm;
        }

        return report;
    };

    /**
     * Search diagnosis by symptoms IDs.
     *
     * @param {Array} symptomIds Symptoms IDs.
     * @returns {Number|Boolean} Diagnosis ID or <tt>false</tt> if nothing found.
     */
    this.searchDiagnosis = function (symptomIds) {
        var diagnosisId,
            diagnosisSymptomIds;

        for (diagnosisId in diagnoses.values) {
            if (diagnoses.values.hasOwnProperty(diagnosisId)) {
                diagnosisSymptomIds = Object.getOwnPropertyNames(associations[diagnosisId]).map(function (x) {
                    return parseInt(x, 10);
                });
                if (checkSubset(symptomIds, diagnosisSymptomIds, true)) {
                    return diagnosisId;
                }
            }
        }

        return false;
    };

    this.getDiagnosisName = function (id) {
        return diagnoses.values[id];
    };

    this.getSymptoms = function () {
        return symptoms.values;
    };

    this.getDiagnoses = function () {
        return diagnoses.values;
    };

    this.getAssociations = function () {
        return associations;
    };

    this.setSymptomsToDiagnosis = function (symptoms, diagnosisId) {
        var key,
            value;

        if (!$.isEmptyObject(symptoms)) {
            // Check symptoms set entry.
            for (key in associations) {
                if (associations.hasOwnProperty(key)) {
                    value = associations[key];
                    key = parseInt(key, 10);

                    // Do not check diagnosis which symptoms we will replace and diagnoses without symptoms.
                    if (key !== diagnosisId && !$.isEmptyObject(value)) {
                        if (checkSubset(Object.getOwnPropertyNames(value), Object.getOwnPropertyNames(symptoms))) {
                            return false;
                        }
                    }
                }
            }
        }

        associations[diagnosisId] = symptoms;
        saveToStorage();

        return true;
    };

    this.isSymptomExists = function (name) {
        var symptomId;

        for (symptomId in symptoms) {
            if (symptoms.hasOwnProperty(symptomId) && symptoms[symptomId] === name) {
                return true;
            }
        }

        return false;
    };

    this.isDiagnosisExists = function (name) {
        var diagnosisId;

        for (diagnosisId in diagnoses) {
            if (diagnoses.hasOwnProperty(diagnosisId) && diagnoses[diagnosisId] === name) {
                return true;
            }
        }

        return false;
    };

    this.isIncomplete = function () {
        return !Object.getOwnPropertyNames(symptoms.values).length && !Object.getOwnPropertyNames(diagnoses.values).length;
    };

    function init() {
        loadFromStorage();
    }

    init();
}