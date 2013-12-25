/*global $, Kb, Templates, alertify*/
/*jslint browser: true*/

$(document).ready(function () {
    'use strict';

    var $container = $('.container'),
        kb = new Kb();

    function getTemplate(name, data) {
        return Templates[name](data);
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
            $symptoms = $('select#symptoms', $form),
            $kbTable = $('#kb-table');

        function fillListWithSymptoms() {
            $('option', $symptoms).remove();

            var symptoms = kb.getSymptoms();
            $.each(symptoms, function (id, name) {
                $symptoms.append(getTemplate('symptom-list', {
                    id: id,
                    name: name
                }));
            });
        }

        function kbTableRerender() {
            if (kb.isIncomplete()) {
                $kbTable.html('');
                return;
            }

            $kbTable.html(getTemplate('kb-table', {
                symptoms: kb.getSymptoms(),
                diagnoses: kb.getDiagnoses(),
                associations: kb.getAssociations()
            }));

            // Modify list of diagnosis' symptoms.
            $('input[type="checkbox"]', $kbTable).change(function () {
                var $checkbox = $(this),
                    diagnosisId = parseInt($checkbox.attr('data-diagnosis-id'), 10),
                    symptomId = parseInt($checkbox.attr('data-symptom-id'), 10),
                    success;

                if ($checkbox.prop('checked')) {
                    success = kb.addSymptomsToDiagnosis([symptomId], diagnosisId);
                } else {
                    success = kb.removeSymptomsFromDiagnosis([symptomId], diagnosisId);
                }

                if (!success) {
                    alertify.error('A new set of symptoms is a subset of the symptoms of another diagnosis, or vice versa.');
                    $checkbox.prop('checked', !$checkbox.prop('checked'));
                } else {
                    alertify.success('Symptoms list updated.');
                }
            });

            // Remove diagnosis.
            $('thead .header button', $kbTable).click(function () {
                var $column = $(this).closest('th'),
                    diagnosisId = parseInt($column.attr('data-diagnosis-id'), 10);

                alertify.confirm("Do you really want to remove this diagnosis?", function (e) {
                    if (e) {
                        kb.removeDiagnosis(diagnosisId);
                        kbTableRerender();
                    }
                });
            });

            // Remove symptom.
            $('tbody .header button', $kbTable).click(function () {
                var $row = $(this).closest('tr'),
                    symptomId = parseInt($row.attr('data-symptom-id'), 10);

                alertify.confirm("Do you really want to remove this symptom?", function (e) {
                    if (e) {
                        kb.removeSymptom(symptomId);
                        fillListWithSymptoms();
                        kbTableRerender();
                    }
                });
            });
        }

        kbTableRerender();
        fillListWithSymptoms();

        $('button#add-symptom', $form).click(function () {
            var $symptom = $('input#symptom', $form),
                symptom = $symptom.val();

            if (!symptom) {
                return;
            }

            if (kb.isSymptomExists(symptom)) {
                $symptom.parent().addClass('has-error');
                return;
            }

            kb.addSymptom(symptom);

            fillListWithSymptoms();
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
                alertify.error('You must select at least one symptom.');
                return;
            }

            $.each(symptomIds, function (index, value) {
                symptomIds[index] = parseInt(value, 10);
            });

            if (kb.isDiagnosisExists(diagnosis)) {
                alertify.error('Diagnosis with such name is already exists.');
                return;
            }

            diagnosisId = kb.addDiagnosis(diagnosis);
            kbTableRerender();

            if (!kb.addSymptomsToDiagnosis(symptomIds, diagnosisId)) {
                alertify.error('Symptoms set is a subset of symptoms from another diagnosis.');
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