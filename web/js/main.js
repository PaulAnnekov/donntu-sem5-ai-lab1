/*global $, Kb, Templates*/
/*jslint browser: true*/

$(document).ready(function () {
    'use strict';

    var $container = $('.container'),
        kb = new Kb();

    function getTemplate(name, data) {
        return Templates[name](data);
    }

    function kbTableRerender() {
        if (kb.isIncomplete()) {
            return;
        }

        $('#kb-table').html(getTemplate('kb-table', {
            symptoms: kb.getSymptoms(),
            diagnoses: kb.getDiagnoses(),
            associations: kb.getAssociations()
        }));
    }

    function fillListWithSymptoms($select) {
        $('option', $select).remove();

        var symptoms = kb.getSymptoms();
        $.each(symptoms, function (id, name) {
            $select.append(getTemplate('symptom-list', {
                id: id,
                name: name
            }));
        });
    }

    function fillSymptomsRadioGroup($container) {
        var symptoms = kb.getSymptoms();
        $.each(symptoms, function (id, name) {
            $container.append(getTemplate('symptom-radio', {
                id: id,
                name: name
            }));
        });
    }

    function testInit() {
        var $symptoms = $('#symptoms', $container),
            $message = $('.result', $container);

        fillSymptomsRadioGroup($symptoms);

        $symptoms.change(function () {
            var symptomIds = [],
                diagnosisId;

            $('input[type="checkbox"]', $symptoms).each(function () {
                var $symptom = $(this);
                if ($symptom.prop('checked')) {
                    symptomIds.push($symptom.val());
                }
            });

            $message.removeClass('alert-success alert-info alert-warning');

            if (!symptomIds.length) {
                $message.addClass('alert-info').text('Choose symptoms.');
                return;
            }

            $.each(symptomIds, function (index, value) {
                symptomIds[index] = parseInt(value, 10);
            });

            diagnosisId = kb.searchDiagnosis(symptomIds);

            if (diagnosisId === false) {
                $message.addClass('alert-warning').text('Diagnosis with these symptoms was not found.');
                return;
            }

            $message.addClass('alert-success').text('Diagnosis: ' + kb.getDiagnosisName(diagnosisId));
        });
    }

    function kbInit() {
        var $form = $('#diagnosis-add', $container),
            $symptoms = $('select#symptoms', $form);

        kbTableRerender();
        fillListWithSymptoms($symptoms);

        $('button#add-symptom', $form).click(function () {
            var $symptom = $('input#symptom', $form),
                symptom = $symptom.val();

            if (kb.isSymptomExists(symptom)) {
                $symptom.parent().addClass('has-error');
                return;
            }

            kb.addSymptom(symptom);

            fillListWithSymptoms($symptoms);
            $symptom.val('');

            kbTableRerender();
        });

        $form.submit(function (e) {
            e.preventDefault();

            var $diagnosis = $('input#diagnosis', $form),
                $symptoms = $('select#symptoms', $form),
                diagnosis = $diagnosis.val(),
                diagnosisId,
                symptomIds = $symptoms.val();

            if (!symptomIds) {
                $symptoms.parent().addClass('has-error');
                return;
            }

            $.each(symptomIds, function (index, value) {
                symptomIds[index] = parseInt(value, 10);
            });

            if (kb.isDiagnosisExists(diagnosis)) {
                $diagnosis.parent().addClass('has-error');
                return;
            }

            diagnosisId = kb.addDiagnosis(diagnosis);

            if (!kb.addSymptomsToDiagnosis(symptomIds, diagnosisId)) {
                $symptoms.parent().addClass('has-error');
                return;
            }

            $form.get(0).reset();
            kbTableRerender();
        });
    }

    if (window.location.href.search('/test') >= 0) {
        testInit();
    } else {
        kbInit();
    }
});