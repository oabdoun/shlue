var express = require('express');
var Hashids = require('hashids');
var bodyParser = require('body-parser');
var validate = require('url-validator');

var shlue = express();
shlue.use(bodyParser.urlencoded({ extended: false }));
module.exports = shlue;

var store = require('./store');

var config = require('./config');
var hashids = new Hashids(config.shlue.salt);

var log = require('./log');

/**
 * Shortens a URL.
 * POST params:
 *  - url: the URL to be shorten
 * returns the shorten URL (as a JSON string), 400 if url is not a valid URL
 * and 500 if store fails.
 */
shlue.route('/')
.post(function (req, res, next) {
	// validate url
	var url = validate(req.body.url);
	if (!url) {
		res.status(400).json('Invalid URL ' + req.body.url);
		log.warn({ mapped: req.body.url }, 'invalid url');
		next();
		return;
	}

	// assign id to URL
	store.incr('shlue:sequence', function (err, id) {
		if (err) {
			res.status(500).end();
			log.error(err, 'redis incr error');
			next();
			return;
		}

		// calculate shorten url
		var code = hashids.encode(id);
		var short = req.protocol + '://' + req.get('host') + '/' + code;

		// store shorten url
		store.set('shlue:url:' + code, url, function (err, reply) {
			if (err) log.error(err, 'redis set error');
		});

		// respond
		res.status(200).json(short);
		log.info({ mapped: url , short: short }, 'url shorten');
		next();
	});
});

/**
 * Resolves a URL from shorten code
 * GET with path as shorten code
 * returns 302 + Location = original URL, 404 if no mapping found or error
 */
shlue.route('/:code')
.get(function (req, res, next) {
	// load mapped url
	store.get('shlue:url:' + req.params.code, function (err, url) {
		// url not found
		if (err || !url)  {
			res.status(404).end('URL not found');
			if (err)
				log.error(err, 'redis get error');
			else
				log.warn({ short: req.params.code }, 'url not found');
		}
		// redirect to url
		else {
			res.redirect(url);
			log.info({ mapped: url, short: req.params.code }, 'url resolved');
		}
		next();
	});
});
