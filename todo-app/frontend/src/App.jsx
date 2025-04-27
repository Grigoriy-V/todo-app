import React from 'react';
import { BrowserRouter,Routes,Route } from 'react-router-dom';
import { AuthProvider } from './hooks/useAuth';
import Header from './components/Header';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
export default function App(){return(<AuthProvider><BrowserRouter><Header/><Routes><Route path="/login" element={<Login/>}/><Route path="/register" element={<Register/>}/><Route path="/" element={<ProtectedRoute><Dashboard/></ProtectedRoute>}/></Routes></BrowserRouter></AuthProvider>);}
