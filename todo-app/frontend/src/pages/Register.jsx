import React,{useState} from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
export default()=>{const[n, sN]=useState('');const[e,sE]=useState('');const[p,sP]=useState('');const{register}=useAuth();const nav=useNavigate();return(<form onSubmit={async e=>{e.preventDefault();try{await register(e.target.name.value,e.target.email.value,e.target.password.value);nav('/');}catch{alert('Fail')}}>}><input name="name" value={n} onChange={e=>sN(e.target.value)} placeholder="Name"/><input name="email" value={e} onChange={e2=>sE(e2.target.value)} placeholder="Email"/><input name="password" type="password" value={p} onChange={e2=>sP(e2.target.value)} placeholder="Password"/><button>Register</button></form>);
}
