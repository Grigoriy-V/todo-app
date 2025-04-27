import React from 'react';
import { Link,useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
export default()=>{const{user,logout}=useAuth();const nav=useNavigate();
return(<nav>{user?(<><span>{user.name}</span><button onClick={()=>{logout();nav('/login');}}>Logout</button></>):(<><Link to="/login">Login</Link><Link to="/register">Register</Link></>)}</nav>);
}
