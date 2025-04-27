const r = require('express').Router();
const { getTodos, createTodo, updateTodo, deleteTodo } = require('../controllers/todoController');
const { protect } = require('../middleware/authMiddleware');
r.route('/').get(protect,getTodos).post(protect,createTodo);
r.route('/:id').put(protect,updateTodo).delete(protect,deleteTodo);
module.exports = r;
