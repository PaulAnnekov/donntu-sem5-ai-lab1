"use strict";

var express = require('express'),
    piler = require('piler'),
    jadeCompiler = require('./compile-jade'),
    clientJs = piler.createJSManager(),
    clientCss = piler.createCSSManager(),
    app = express();

app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.logger('dev'));

app.configure(function () {
    clientJs.bind(app);
    clientCss.bind(app);

    clientCss.addFile(__dirname + "/vendor/bootstrap/dist/css/bootstrap.css");
    clientCss.addFile(__dirname + "/vendor/alertify.js/themes/alertify.core.css");
    clientCss.addFile(__dirname + "/web/css/alertify.js/bootstrap.css");
    clientCss.addFile(__dirname + "/web/css/main.css");
    clientJs.addFile(__dirname + "/node_modules/jade/runtime.js");
    clientJs.addFile(jadeCompiler());
    clientJs.addFile(__dirname + "/vendor/jquery/dist/jquery.js");
    clientJs.addFile(__dirname + "/vendor/alertify.js/lib/alertify.js");
    clientJs.addFile(__dirname + "/vendor/bootstrap/dist/js/bootstrap.js");
    clientJs.addFile(__dirname + "/web/js/knowledge-base.js");
    clientJs.addFile(__dirname + "/web/js/main.js");
});

app.get('/', function (req, res) {
    res.render(
        'knowledge-base',
        {
            title: 'Knowledge base',
            page: 'kb',
            js: clientJs.renderTags(),
            css: clientCss.renderTags()
        }
    );
});

app.get('/test', function (req, res) {
    res.render(
        'test',
        {
            title: 'Test',
            page: 'test',
            js: clientJs.renderTags(),
            css: clientCss.renderTags()
        }
    );
});

app.listen(8080);