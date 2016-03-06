request = require 'supertest'
url = require 'url'

shlue = require '../shlue'

log = require '../log'
log.level 'fatal'

isShortUrl = (url) -> /^http:\/\/127\.0\.0\.1:\d+\/[a-zA-Z0-9]+$/.test url

describe 'shlue shorten', ->
	r = request shlue
	it 'rejects no params request', (done) ->
		r.post '/'
		.expect 400, done
	it 'rejects invalid url param', (done) ->
		r.post '/'
		.type 'form'
		.send url:'fubar'
		.expect 400, done
	it 'sortens a valid url param', (done) ->
		r.post '/'
		.type 'form'
		.send url:'https://fu.bar/baz?biz=2'
		.expect 200
		.expect (res) ->
			throw new Error(res.body) unless isShortUrl res.body
		.end done
	it 'gives different short URLs for different urls', (done) ->
		r.post '/'
		.type 'form'
		.send url:'https://fu.bar/baz?biz=2'
		.expect 200
		.end (err, res) ->
			throw new Error(res.body) unless isShortUrl res.body
			r.post '/'
			.type 'form'
			.send url:'http://foo.org/buz'
			.expect 200
			.expect (res2) ->
				throw new Error(res2.body) unless isShortUrl res2.body
				throw new Error(res2.body + ' - ' + res.body) if res.body is res2.body
				u1 = url.parse res.body
				u2 = url.parse res2.body
				throw new Error(u2.pathname + ' - ' + u1.pathname) if u1.pathname is u2.pathname
			.end done
	it 'gives different short URLs for same urls', (done) ->
		r.post '/'
		.type 'form'
		.send url:'https://fu.bar/baz?biz=2'
		.end (err, res) ->
			throw new Error(res.body) unless isShortUrl res.body
			r.post '/'
			.type 'form'
			.send url:'https://fu.bar/baz?biz=2'
			.expect (res2) ->
				throw new Error(res2.body + ' - ' + res.body) if res.body is res2.body
				u1 = url.parse res.body
				u2 = url.parse res2.body
				throw new Error(u2.pathname + ' - ' + u1.pathname) if u1.pathname is u2.pathname
			.end done
