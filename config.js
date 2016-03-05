module.exports = {
	server: {
		port: process.env.PORT || 8080
	},
	redis: {
		url: process.env.REDIS_URL || 'redis://127.0.0.1:6379'
	}
};