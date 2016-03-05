var express = require('express');
var Hashids = require('hashids');
var bodyParser = require('body-parser');
var validate = require('url-validator');
var redis = require('redis');

var shlue = express();
shlue.use(bodyParser.urlencoded({ extended: false }));
module.exports = shlue;

var hashids = new Hashids('salt');

var config = require('./config');
var store = redis.createClient(config.redis);

/**
 * Shortens a URL.
 * POST params:
 *  - url: the URL to be shorten
 * returns the shorten URL (as a JSON string), 400 if url is not a valid URL.
 */
shlue.route('/')
.post(function (req, res) {
	// validate url
	var url = validate(req.body.url);
	if (!url) {
		res.status(400).json('Invalid URL ' + req.body.url);
		return;
	}

	// assign id to URL
	store.incr('shlue:sequence', function (err, id) {
		// calculate shorten url
		var code = hashids.encode(id);
		var short = req.protocol + '://' + req.get('host') + '/' + code;

		// store shorten url
		store.set('shlue:url:' + code, url);

		// respond
		res.status(200).json(short);
	});
});

shlue.route('/:code')
.get(function (req, res) {
	// load mapped url
	store.get('shlue:url:' + req.params['code'], function (err, url) {
		// url not found
		if (err || !url)  res.status(404).end();
		// redirect to url
		else res.redirect(url);
	});
});