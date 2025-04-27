import axios from 'axios';
const URL='http://localhost:5000/api/auth';
export const register=data=>axios.post(`${URL}/register`,data).then(r=>r.data);
export const login=data=>axios.post(`${URL}/login`,data).then(r=>r.data);
export const logout=()=>localStorage.removeItem('token');
