/*jslint browser: true*/

(function () {
    'use strict';

    function Db() {
        var db = {},
            symptoms = ['Общее недомагание', 'Сухость, першение'],
            diagnoses = ['Ларингит острый'];

        this.addSymptom = function (name) {
            if (symptoms.indexOf(name) < 0) {
                return false;
            }

            symptoms.push(name);
            return true;
        };

        this.addDiagnosis = function (name) {
            if (diagnoses.indexOf(name) < 0) {
                return false;
            }

            diagnoses.push(name);
            return true;
        };

        this.addSymptomsToDiagnosis = function (symptomIds, diagnosisId) {


            if (!db.hasOwnProperty(diagnosisId)) {
                db[diagnosisId] = [];
            }
            db[diagnosisId].push(symptomIds);
        };

        function init() {

        }

        init();
    }

    window.Db = Db;
}());