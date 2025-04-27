const asyncHandler = require('express-async-handler');
const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const registerUser = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;
  if (await User.findOne({ email })) return res.status(400).json({ message: 'User exists' });
  const user = await User.create({ name, email, password });
  res.status(201).json({ _id: user._id, name: user.name, email: user.email, token: generateToken(user._id) });
});
const authUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (user && await user.matchPassword(password)) return res.json({ _id: user._id, name: user.name, email: user.email, token: generateToken(user._id) });
  res.status(401).json({ message: 'Invalid creds' });
});
module.exports = { registerUser, authUser };
