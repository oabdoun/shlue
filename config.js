module.exports = {
	server: {
		port: process.env.PORT || 8080
	},
	redis: {
		url: process.env.REDIS_URL || 'redis://127.0.0.1:6379'
	},
	shlue: {
		salt: process.env.SHLUE_SALT || 'aco8aihea4Ciarae2ax2iH9voh3phaselohGhaighoofilooN2oobio4oidit4ub'
	}
};