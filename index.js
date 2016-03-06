var shlue = require('./shlue');

// config http logs
var morgan = require('morgan');
shlue.use(morgan('combined'));

// config app logs
var log = require('./log');
log.level('info');

// start server
var config = require('./config');
shlue.listen(config.server.port);
