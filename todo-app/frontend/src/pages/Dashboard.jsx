import React,{useState,useEffect} from 'react';
import TodoItem from '../components/TodoItem';
import * as svc from '../services/todoService';
export default()=>{const[todos,sT]=useState([]);const[t,sTt]=useState('');const f=async()=>sT(await svc.getTodos());useEffect(()=>{f()},[]);
return(<div><h1>To-Do</h1><form onSubmit={async e=>{e.preventDefault();await svc.createTodo(t);sTt('');f()}}><input value={t} onChange={e=>sTt(e.target.value)} placeholder="New task"/><button>Add</button></form><ul>{todos.map(td=><TodoItem key={td._id} todo={td} onToggle={()=>{svc.updateTodo(td._id,{completed:!td.completed}).then(f)}} onDelete={()=>{svc.deleteTodo(td._
