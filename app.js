"use strict";

var express = require('express'),
    piler = require("piler"),
    clientJs = piler.createJSManager(),
    clientCss = piler.createCSSManager(),
    app = express(),
    srv = require('http').createServer(app);

app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.logger('dev'));
//app.use('', express.static(__dirname + '/web'));
//app.use(express.static(__dirname + '/web'));

app.configure(function () {
    clientJs.bind(app, srv);
    clientCss.bind(app, srv);

    clientCss.addFile(__dirname + "/vendor/bootstrap/dist/css/bootstrap.css");
    clientCss.addFile(__dirname + "/web/css/main.css");
    clientJs.addFile(__dirname + "/vendor/jquery/jquery.js");
    clientJs.addFile(__dirname + "/vendor/bootstrap/dist/js/bootstrap.js");
    clientJs.addFile(__dirname + "/web/js/db.js");
    clientJs.addFile(__dirname + "/web/js/main.js");
});

app.get('/', function (req, res) {
    res.render(
        'index',
        {
            title: 'Home',
            js: clientJs.renderTags(),
            css: clientCss.renderTags()
        }
    );
});

srv.listen(8080);