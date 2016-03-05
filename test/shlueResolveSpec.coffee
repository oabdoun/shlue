request = require 'supertest'
url = require 'url'

shlue = require '../shlue'

describe 'shlue resolve', ->
	r = request shlue
	short = null
	beforeEach (done) ->
		r.post '/'
		.type 'form'
		.send url:'https://foo.com/bar/baz?biz=2&buz=boz'
		.end (err, res) ->
			short = res.body
			done()
	it 'gets the URL from shorten', (done) ->
		r.get url.parse(short).pathname
		.expect 302
		.expect 'Location', 'https://foo.com/bar/baz?biz=2&buz=boz'
		.end done
	it 'rejects invalid short urls', (done) ->
		r.get '/fubar'
		.expect 404
		.end done
