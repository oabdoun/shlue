request = require 'supertest'
url = require 'url'

shlue = require '../shlue'

log = require '../log'
log.level 'fatal'

store = require '../store'
sinon = require 'sinon'

isShortUrl = (url) -> /^http:\/\/127\.0\.0\.1:\d+\/[a-zA-Z0-9]+$/.test url

describe 'shlue', ->
	r = request shlue
	describe 'shorten', ->
		it 'fails if sequence fails', (done) ->
			stub = sinon.stub store, 'incr'
			stub.yields 'ERR'
			r.post '/'
			.type 'form'
			.send url:'https://fu.bar/baz?biz=2'
			.expect 500
			.end (err, res) ->
				stub.restore()
				done err
		it 'returns short url even if set store fails', (done) ->
			stub = sinon.stub store, 'set'
			stub.yields 'ERR'
			r.post '/'
			.type 'form'
			.send url:'https://fu.bar/baz?biz=2'
			.expect 200
			.expect (res) ->
				throw new Error(res.body) unless isShortUrl res.body
			.end (err, res) ->
				stub.restore()
				done err
	describe 'resolve', ->
		short = null
		beforeEach (done) ->
			r.post '/'
			.type 'form'
			.send url:'https://foo.com/bar/baz?biz=2&buz=boz'
			.end (err, res) ->
				short = res.body
				done()
		it 'returns not found if store fails', (done) ->
			stub = sinon.stub store, 'get'
			stub.yields 'ERR'
			r.get url.parse(short).pathname
			.expect 404
			.end (err, res) ->
				stub.restore()
				done err
