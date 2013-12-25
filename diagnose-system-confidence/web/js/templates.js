var Templates = {
"kb-table":
  function anonymous(locals) {
var buf = [];
var locals_ = (locals || {}),diagnoses = locals_.diagnoses,symptoms = locals_.symptoms,associations = locals_.associations;buf.push("<table class=\"table table-striped\"><thead><th></th>");
// iterate diagnoses
;(function(){
  var $$obj = diagnoses;
  if ('number' == typeof $$obj.length) {

    for (var diagnosisId = 0, $$l = $$obj.length; diagnosisId < $$l; diagnosisId++) {
      var diagnosis = $$obj[diagnosisId];

buf.push("<th" + (jade.attrs({ 'data-diagnosis-id':("" + (diagnosisId) + "") }, {"data-diagnosis-id":true})) + "><div class=\"header\">" + (jade.escape(null == (jade.interp = diagnosis) ? "" : jade.interp)) + "<button type=\"button\" aria-hidden=\"true\" title=\"Remove\" class=\"close\">&times;</button></div></th>");
    }

  } else {
    var $$l = 0;
    for (var diagnosisId in $$obj) {
      $$l++;      var diagnosis = $$obj[diagnosisId];

buf.push("<th" + (jade.attrs({ 'data-diagnosis-id':("" + (diagnosisId) + "") }, {"data-diagnosis-id":true})) + "><div class=\"header\">" + (jade.escape(null == (jade.interp = diagnosis) ? "" : jade.interp)) + "<button type=\"button\" aria-hidden=\"true\" title=\"Remove\" class=\"close\">&times;</button></div></th>");
    }

  }
}).call(this);

buf.push("</thead><tbody>");
// iterate symptoms
;(function(){
  var $$obj = symptoms;
  if ('number' == typeof $$obj.length) {

    for (var symptomId = 0, $$l = $$obj.length; symptomId < $$l; symptomId++) {
      var symptom = $$obj[symptomId];

buf.push("<tr" + (jade.attrs({ 'data-symptom-id':("" + (symptomId) + "") }, {"data-symptom-id":true})) + "><td><div class=\"header\">" + (jade.escape(null == (jade.interp = symptom) ? "" : jade.interp)) + "<button type=\"button\" aria-hidden=\"true\" title=\"Remove\" class=\"close\">&times;</button></div></td>");
// iterate diagnoses
;(function(){
  var $$obj = diagnoses;
  if ('number' == typeof $$obj.length) {

    for (var diagnosisId = 0, $$l = $$obj.length; diagnosisId < $$l; diagnosisId++) {
      var diagnosis = $$obj[diagnosisId];

buf.push("<td><input" + (jade.attrs({ 'type':("checkbox"), 'data-symptom-id':("" + (symptomId) + ""), 'data-diagnosis-id':("" + (diagnosisId) + ""), 'checked':(associations[diagnosisId].indexOf(parseInt(symptomId)) >= 0) }, {"type":true,"data-symptom-id":true,"data-diagnosis-id":true,"checked":true})) + "/></td>");
    }

  } else {
    var $$l = 0;
    for (var diagnosisId in $$obj) {
      $$l++;      var diagnosis = $$obj[diagnosisId];

buf.push("<td><input" + (jade.attrs({ 'type':("checkbox"), 'data-symptom-id':("" + (symptomId) + ""), 'data-diagnosis-id':("" + (diagnosisId) + ""), 'checked':(associations[diagnosisId].indexOf(parseInt(symptomId)) >= 0) }, {"type":true,"data-symptom-id":true,"data-diagnosis-id":true,"checked":true})) + "/></td>");
    }

  }
}).call(this);

buf.push("</tr>");
    }

  } else {
    var $$l = 0;
    for (var symptomId in $$obj) {
      $$l++;      var symptom = $$obj[symptomId];

buf.push("<tr" + (jade.attrs({ 'data-symptom-id':("" + (symptomId) + "") }, {"data-symptom-id":true})) + "><td><div class=\"header\">" + (jade.escape(null == (jade.interp = symptom) ? "" : jade.interp)) + "<button type=\"button\" aria-hidden=\"true\" title=\"Remove\" class=\"close\">&times;</button></div></td>");
// iterate diagnoses
;(function(){
  var $$obj = diagnoses;
  if ('number' == typeof $$obj.length) {

    for (var diagnosisId = 0, $$l = $$obj.length; diagnosisId < $$l; diagnosisId++) {
      var diagnosis = $$obj[diagnosisId];

buf.push("<td><input" + (jade.attrs({ 'type':("checkbox"), 'data-symptom-id':("" + (symptomId) + ""), 'data-diagnosis-id':("" + (diagnosisId) + ""), 'checked':(associations[diagnosisId].indexOf(parseInt(symptomId)) >= 0) }, {"type":true,"data-symptom-id":true,"data-diagnosis-id":true,"checked":true})) + "/></td>");
    }

  } else {
    var $$l = 0;
    for (var diagnosisId in $$obj) {
      $$l++;      var diagnosis = $$obj[diagnosisId];

buf.push("<td><input" + (jade.attrs({ 'type':("checkbox"), 'data-symptom-id':("" + (symptomId) + ""), 'data-diagnosis-id':("" + (diagnosisId) + ""), 'checked':(associations[diagnosisId].indexOf(parseInt(symptomId)) >= 0) }, {"type":true,"data-symptom-id":true,"data-diagnosis-id":true,"checked":true})) + "/></td>");
    }

  }
}).call(this);

buf.push("</tr>");
    }

  }
}).call(this);

buf.push("</tbody></table>");;return buf.join("");
},

"symptom-list":
  function anonymous(locals) {
var buf = [];
var locals_ = (locals || {}),id = locals_.id,name = locals_.name;buf.push("<option" + (jade.attrs({ 'value':("" + (id) + "") }, {"value":true})) + ">" + (jade.escape(null == (jade.interp = name) ? "" : jade.interp)) + "</option>");;return buf.join("");
},

"symptom-radio":
  function anonymous(locals) {
var buf = [];
var locals_ = (locals || {}),name = locals_.name,id = locals_.id;buf.push("<div class=\"checkbox\"><label>" + (jade.escape(null == (jade.interp = name) ? "" : jade.interp)) + "<input" + (jade.attrs({ 'type':("checkbox"), 'value':("" + (id) + "") }, {"type":true,"value":true})) + "/></label></div>");;return buf.join("");
}
};