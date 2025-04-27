const r= require('express').Router();
const { registerUser, authUser } = require('../controllers/authController');
r.post('/register', registerUser);
r.post('/login', authUser);
module.exports = r;
