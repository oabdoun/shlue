# shlue [![Build Status](https://snap-ci.com/oabdoun/shlue/branch/master/build_image)](https://snap-ci.com/oabdoun/shlue/branch/master)
URL shortener PoC

The service has 2 endpoints:
- shorten, that returns a short URL for a URL passed as a parameter
- resolve, that redirects a short URL to the mapped URL

Implementation relies on:
- redis as a key/value store for mapped URLs and as a distributed sequence generator
- hashids as a key shortener

You can test the service deployed on Heroku:

```
$ curl -d 'url=https://en.wikipedia.org/wiki/URL_shortening' -X POST https://shlue.herokuapp.com/
```
