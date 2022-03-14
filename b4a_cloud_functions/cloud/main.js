// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
var express = require('express');

Parse.Cloud.define("hello", (request) => {
	var client_id = '2790074ebf84432dadf0602fbf2bf8e2';
    var redirect_uri = 'http://localhost:8888';

    var app = express();

    app.get('/login', function(req, res) {
    res.redirect('https://accounts.spotify.com/authorize?' +
        querystring.stringify({
        response_type: 'code',
        client_id: client_id,
        redirect_uri: redirect_uri,
        }));
    });

    return app;
});
