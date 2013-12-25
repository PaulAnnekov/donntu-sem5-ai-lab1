module.exports = function () {
    "use strict";

    var jade = require('jade'),
        fileSystem = require('fs'),
        path = require('path'),
        outName = __dirname + '/web/js/templates.js',
        viewsDir = __dirname + '/views/parts',
        files = fileSystem.readdirSync(viewsDir),
        templates = {},
        properties = [],
        key,
        sourceCode;

    files.forEach(function (filename) {
        if (/\.jade$/.test(filename)) {
            var name = path.basename(filename, '.jade'),
                filePath = path.join(viewsDir, filename),
                fileContents;
            console.log('compiling', filePath);
            fileContents = fileSystem.readFileSync(filePath, {encoding: 'utf8'});
            templates[name] = jade.compile(fileContents, {
                debug: false,
                compileDebug: false,
                filename: filePath,
                client: true
            });
        }
    });
    console.log('writing', outName);

    for (key in templates) {
        if (templates.hasOwnProperty(key)) {
            properties.push(JSON.stringify(key) + ':\n  ' + templates[key].toString());
        }
    }

    sourceCode = 'var Templates = {\n' + properties.join(',\n\n') + '\n};';

    fileSystem.writeFile(outName, sourceCode);

    return outName;
};