import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Dashboard from './components/Dashboard';
import Login from './components/Login';
import Register from './components/Register';
import AdminPanel from './components/AdminPanel';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    if (token) {
      setIsAuthenticated(true);
      try {
        const user = JSON.parse(localStorage.getItem('user') || '{}');
        setUserData(user);
        setIsAdmin(user.is_superuser || false);
        console.log('User data from localStorage:', user);
        console.log('Is Admin from localStorage:', user.is_superuser);
      } catch (e) {
        console.error('Error parsing user data:', e);
        localStorage.removeItem('user');
      }
    }
    setLoading(false);
  }, [token]);

  const handleLogin = (token, user) => {
    console.log('handleLogin called with:', user);
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(user));
    setToken(token);
    setUserData(user);
    setIsAuthenticated(true);
    setIsAdmin(user.is_superuser || false);
    console.log('User after login:', user);
    console.log('isAdmin set to:', user.is_superuser);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setToken(null);
    setUserData(null);
    setIsAuthenticated(false);
    setIsAdmin(false);
  };

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  return (
    <Router>
      <div className="App">
        {!isAuthenticated ? (
          <Routes>
            <Route path="/register" element={<Register />} />
            <Route path="/" element={<Login onLogin={handleLogin} />} />
          </Routes>
        ) : (
          <Routes>
            <Route path="/" element={<Dashboard token={token} onLogout={handleLogout} isAdmin={isAdmin} user={userData} />} />
            <Route path="/admin" element={<AdminPanel token={token} onLogout={handleLogout} isAdmin={isAdmin} />} />
          </Routes>
        )}
      </div>
    </Router>
  );
}

export default App;
