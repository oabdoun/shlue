var config = require('./config');
var redis = require('redis');
module.exports = redis.createClient(config.redis);
