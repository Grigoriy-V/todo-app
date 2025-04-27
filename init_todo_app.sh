#!/usr/bin/env bash
# Скрипт для создания проекта To-Do List с авторизацией
set -e
# Отключаем history expansion, чтобы избежать ошибок с '!' в коде
set +H

# Корневая папка проекта
ROOT_DIR="todo-app"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

# Создаём базовую структуру папок
mkdir -p \
  "$BACKEND_DIR/src/controllers" \
  "$BACKEND_DIR/src/models" \
  "$BACKEND_DIR/src/routes" \
  "$BACKEND_DIR/src/middleware" \
  "$BACKEND_DIR/src/utils" \
  "$FRONTEND_DIR/public" \
  "$FRONTEND_DIR/src/components" \
  "$FRONTEND_DIR/src/pages" \
  "$FRONTEND_DIR/src/services" \
  "$FRONTEND_DIR/src/hooks"

# --- Backend ---
# .env.example
cat > "$BACKEND_DIR/.env.example" << 'EOF'
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
PORT=5000
EOF

# .gitignore
cat > "$BACKEND_DIR/.gitignore" << 'EOF'
node_modules/
.env
EOF

# package.json
cat > "$BACKEND_DIR/package.json" << 'EOF'
{
  "name": "todo-backend",
  "version": "1.0.0",
  "main": "src/server.js",
  "scripts": { "dev": "nodemon src/server.js" },
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "express": "^4.18.1",
    "express-async-handler": "^1.2.0",
    "jsonwebtoken": "^8.5.1",
    "mongoose": "^6.3.1"
  },
  "devDependencies": { "nodemon": "^2.0.19" }
}
EOF

# src/config.js
cat > "$BACKEND_DIR/src/config.js" << 'EOF'
const mongoose = require('mongoose');
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};
module.exports = connectDB;
EOF

# src/utils/generateToken.js
cat > "$BACKEND_DIR/src/utils/generateToken.js" << 'EOF'
const jwt = require('jsonwebtoken');
const generateToken = id => jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
module.exports = generateToken;
EOF

# src/models/User.js
cat > "$BACKEND_DIR/src/models/User.js" << 'EOF'
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const userSchema = new mongoose.Schema({ name: String, email: String, password: String }, { timestamps: true });
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});
userSchema.methods.matchPassword = function(entered) { return bcrypt.compare(entered, this.password); };
module.exports = mongoose.model('User', userSchema);
EOF

# src/models/Todo.js
cat > "$BACKEND_DIR/src/models/Todo.js" << 'EOF'
const mongoose = require('mongoose');
const todoSchema = new mongoose.Schema({ text: String, completed: Boolean, user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' } }, { timestamps: true });
module.exports = mongoose.model('Todo', todoSchema);
EOF

# src/controllers/authController.js
cat > "$BACKEND_DIR/src/controllers/authController.js" << 'EOF'
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
EOF

# src/controllers/todoController.js
cat > "$BACKEND_DIR/src/controllers/todoController.js" << 'EOF'
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
EOF

# src/middleware/authMiddleware.js
cat > "$BACKEND_DIR/src/middleware/authMiddleware.js" << 'EOF'
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
EOF

# src/routes/authRoutes.js
cat > "$BACKEND_DIR/src/routes/authRoutes.js" << 'EOF'
const r= require('express').Router();
const { registerUser, authUser } = require('../controllers/authController');
r.post('/register', registerUser);
r.post('/login', authUser);
module.exports = r;
EOF

# src/routes/todoRoutes.js
cat > "$BACKEND_DIR/src/routes/todoRoutes.js" << 'EOF'
const r = require('express').Router();
const { getTodos, createTodo, updateTodo, deleteTodo } = require('../controllers/todoController');
const { protect } = require('../middleware/authMiddleware');
r.route('/').get(protect,getTodos).post(protect,createTodo);
r.route('/:id').put(protect,updateTodo).delete(protect,deleteTodo);
module.exports = r;
EOF

# src/server.js
cat > "$BACKEND_DIR/src/server.js" << 'EOF'
require('dotenv').config();
const express=require('express');
const cors=require('cors');
const connectDB=require('./config');
connectDB();
const app=express();app.use(cors(),express.json());
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/todos', require('./routes/todoRoutes'));
app.use((e,req,res)=>res.status(res.statusCode===200?500:res.statusCode).json({message:e.message}));
app.listen(process.env.PORT||5000,()=>console.log('Server started')); 
EOF

# --- Frontend ---
# .gitignore
cat > "$FRONTEND_DIR/.gitignore" << 'EOF'
node_modules/
.env.local
EOF

# package.json
cat > "$FRONTEND_DIR/package.json" << 'EOF'
{
  "name": "todo-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "axios": "^1.1.2",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-router-dom": "^6.3.0"
  },
  "scripts": { "start": "react-scripts start", "build": "react-scripts build" }
}
EOF

# public/index.html
cat > "$FRONTEND_DIR/public/index.html" << 'EOF'
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/><title>Todo App</title></head><body><div id="root"></div></body></html>
EOF

# src/index.jsx
cat > "$FRONTEND_DIR/src/index.jsx" << 'EOF'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
const root=createRoot(document.getElementById('root'));
root.render(<App/>);
EOF

# src/App.jsx
cat > "$FRONTEND_DIR/src/App.jsx" << 'EOF'
import React from 'react';
import { BrowserRouter,Routes,Route } from 'react-router-dom';
import { AuthProvider } from './hooks/useAuth';
import Header from './components/Header';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
export default function App(){return(<AuthProvider><BrowserRouter><Header/><Routes><Route path="/login" element={<Login/>}/><Route path="/register" element={<Register/>}/><Route path="/" element={<ProtectedRoute><Dashboard/></ProtectedRoute>}/></Routes></BrowserRouter></AuthProvider>);}
EOF

# src/hooks/useAuth.js
cat > "$FRONTEND_DIR/src/hooks/useAuth.js" << 'EOF'
import React,{createContext,useContext,useState} from 'react';
import * as authService from '../services/authService';
const C=createContext();
export function AuthProvider({children}){const[u,nU]=useState(null);
const login=async(e,p)=>{const d=await authService.login({email:e,password:p});nU({name:d.name});localStorage.setItem('token',d.token);};
const register=async(n,e,p)=>{const d=await authService.register({name:n,email:e,password:p});nU({name:d.name});localStorage.setItem('token',d.token);};
const logout=()=>{authService.logout();nU(null);};
return <C.Provider value={{user:u,login,register,logout}}>{children}</C.Provider>;}
export function useAuth(){return useContext(C);} 
EOF

# src/services/authService.js
cat > "$FRONTEND_DIR/src/services/authService.js" << 'EOF'
import axios from 'axios';
const URL='http://localhost:5000/api/auth';
export const register=data=>axios.post(`${URL}/register`,data).then(r=>r.data);
export const login=data=>axios.post(`${URL}/login`,data).then(r=>r.data);
export const logout=()=>localStorage.removeItem('token');
EOF

# src/services/todoService.js
cat > "$FRONTEND_DIR/src/services/todoService.js" << 'EOF'
import axios from 'axios';
const URL='http://localhost:5000/api/todos';
const auth=()=>({headers:{Authorization:`Bearer ${localStorage.getItem('token')}`}});
export const getTodos=()=>axios.get(URL,auth()).then(r=>r.data);
export const createTodo=text=>axios.post(URL,{text},auth()).then(r=>r.data);
export const updateTodo=(id,data)=>axios.put(`${URL}/${id}`,data,auth()).then(r=>r.data);
export const deleteTodo=id=>axios.delete(`${URL}/${id}`,auth()).then(r=>r.data);
EOF

# src/components/ProtectedRoute.jsx
cat > "$FRONTEND_DIR/src/components/ProtectedRoute.jsx" << 'EOF'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
export default ({children})=>useAuth().user?children:<Navigate to="/login"/>;
EOF

# src/components/Header.jsx
cat > "$FRONTEND_DIR/src/components/Header.jsx" << 'EOF'
import React from 'react';
import { Link,useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
export default()=>{const{user,logout}=useAuth();const nav=useNavigate();
return(<nav>{user?(<><span>{user.name}</span><button onClick={()=>{logout();nav('/login');}}>Logout</button></>):(<><Link to="/login">Login</Link><Link to="/register">Register</Link></>)}</nav>);
}
EOF

# src/components/TodoItem.jsx
cat > "$FRONTEND_DIR/src/components/TodoItem.jsx" << 'EOF'
import React from 'react';
export default({todo,onToggle,onDelete})=>(<li><input type="checkbox" checked={todo.completed} onChange={onToggle}/><span style={{textDecoration:todo.completed?'line-through':''}}>{todo.text}</span><button onClick={onDelete}>Delete</button></li>);
EOF

# src/pages/Login.jsx
cat > "$FRONTEND_DIR/src/pages/Login.jsx" << 'EOF'
import React,{useState} from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
export default()=>{const[e,sE]=useState('');const[p,sP]=useState('');const{login}=useAuth();const nav=useNavigate();return(<form onSubmit={async e=>{e.preventDefault();try{await login(e.target.email.value,e.target.password.value);nav('/');}catch{alert('Failed')}}}><input name="email" value={e} onChange={e2=>sE(e2.target.value)} placeholder="Email"/><input name="password" type="password" value={p} onChange={e2=>sP(e2.target.value)} placeholder="Password"/><button>Login</button></form>);
}
EOF

# src/pages/Register.jsx
cat > "$FRONTEND_DIR/src/pages/Register.jsx" << 'EOF'
import React,{useState} from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
export default()=>{const[n, sN]=useState('');const[e,sE]=useState('');const[p,sP]=useState('');const{register}=useAuth();const nav=useNavigate();return(<form onSubmit={async e=>{e.preventDefault();try{await register(e.target.name.value,e.target.email.value,e.target.password.value);nav('/');}catch{alert('Fail')}}>}><input name="name" value={n} onChange={e=>sN(e.target.value)} placeholder="Name"/><input name="email" value={e} onChange={e2=>sE(e2.target.value)} placeholder="Email"/><input name="password" type="password" value={p} onChange={e2=>sP(e2.target.value)} placeholder="Password"/><button>Register</button></form>);
}
EOF

# src/pages/Dashboard.jsx
cat > "$FRONTEND_DIR/src/pages/Dashboard.jsx" << 'EOF'
import React,{useState,useEffect} from 'react';
import TodoItem from '../components/TodoItem';
import * as svc from '../services/todoService';
export default()=>{const[todos,sT]=useState([]);const[t,sTt]=useState('');const f=async()=>sT(await svc.getTodos());useEffect(()=>{f()},[]);
return(<div><h1>To-Do</h1><form onSubmit={async e=>{e.preventDefault();await svc.createTodo(t);sTt('');f()}}><input value={t} onChange={e=>sTt(e.target.value)} placeholder="New task"/><button>Add</button></form><ul>{todos.map(td=><TodoItem key={td._id} todo={td} onToggle={()=>{svc.updateTodo(td._id,{completed:!td.completed}).then(f)}} onDelete={()=>{svc.deleteTodo(td._
