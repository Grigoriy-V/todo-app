import React,{createContext,useContext,useState} from 'react';
import * as authService from '../services/authService';
const C=createContext();
export function AuthProvider({children}){const[u,nU]=useState(null);
const login=async(e,p)=>{const d=await authService.login({email:e,password:p});nU({name:d.name});localStorage.setItem('token',d.token);};
const register=async(n,e,p)=>{const d=await authService.register({name:n,email:e,password:p});nU({name:d.name});localStorage.setItem('token',d.token);};
const logout=()=>{authService.logout();nU(null);};
return <C.Provider value={{user:u,login,register,logout}}>{children}</C.Provider>;}
export function useAuth(){return useContext(C);} 
