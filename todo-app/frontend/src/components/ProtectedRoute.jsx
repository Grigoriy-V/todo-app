import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
export default ({children})=>useAuth().user?children:<Navigate to="/login"/>;
