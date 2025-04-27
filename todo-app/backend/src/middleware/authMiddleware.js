const jwt = require('jsonwebtoken');
const asyncHandler = require('express-async-handler');
const User = require('../models/User');
const protect = asyncHandler(async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'No token' });
  const { id } = jwt.verify(token, process.env.JWT_SECRET);
  req.user = await User.findById(id).select('-password');
  next();
});
module.exports = { protect };
