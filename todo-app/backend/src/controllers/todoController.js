const asyncHandler = require('express-async-handler');
const Todo = require('../models/Todo');
const getTodos = asyncHandler(async (req, res) => res.json(await Todo.find({ user: req.user._id })));
const createTodo = asyncHandler(async (req, res) => res.status(201).json(await Todo.create({ text: req.body.text, completed: false, user: req.user._id })));
const updateTodo = asyncHandler(async (req, res) => {
  const todo = await Todo.findById(req.params.id);
  if (!todo || todo.user.toString()!==req.user._id.toString()) return res.status(401).json({});
  Object.assign(todo, req.body);
  res.json(await todo.save());
});
const deleteTodo = asyncHandler(async (req, res) => { await Todo.findByIdAndDelete(req.params.id); res.json({ message: 'deleted' }); });
module.exports = { getTodos, createTodo, updateTodo, deleteTodo };
