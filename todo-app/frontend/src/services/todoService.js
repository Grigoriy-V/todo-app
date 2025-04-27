import axios from 'axios';
const URL='http://localhost:5000/api/todos';
const auth=()=>({headers:{Authorization:`Bearer ${localStorage.getItem('token')}`}});
export const getTodos=()=>axios.get(URL,auth()).then(r=>r.data);
export const createTodo=text=>axios.post(URL,{text},auth()).then(r=>r.data);
export const updateTodo=(id,data)=>axios.put(`${URL}/${id}`,data,auth()).then(r=>r.data);
export const deleteTodo=id=>axios.delete(`${URL}/${id}`,auth()).then(r=>r.data);
