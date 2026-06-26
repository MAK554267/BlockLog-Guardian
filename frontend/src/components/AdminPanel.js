import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './AdminPanel.css';

function AdminPanel({ token, onLogout, isAdmin }) {
  const [users, setUsers] = useState([]);
  const [logs, setLogs] = useState([]);
  const [evidence, setEvidence] = useState([]);
  const [chainStatus, setChainStatus] = useState(null);
  const [newUser, setNewUser] = useState({ username: '', email: '', password: '' });
  const [newEvidence, setNewEvidence] = useState({
    evidence_id: '',
    evidence_type: '',
    description: '',
    hash: '',
    collector: ''
  });
  const [message, setMessage] = useState({ text: '', type: '' });
  const [activeTab, setActiveTab] = useState('logs');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is admin
    if (!isAdmin) {
      setMessage({ text: 'You do not have admin access!', type: 'error' });
      return;
    }
    fetchAllData();
  }, [isAdmin]);

  const fetchAllData = async () => {
    setLoading(true);
    try {
      await Promise.all([
        fetchUsers(),
        fetchLogs(),
        fetchEvidence(),
        verifyChain()
      ]);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchUsers = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/blockchain/admin/users/');
      setUsers(response.data.users || []);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const fetchLogs = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/blockchain/logs/');
      setLogs(response.data.logs || []);
    } catch (error) {
      console.error('Error fetching logs:', error);
    }
  };

  const fetchEvidence = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/blockchain/evidence/');
      setEvidence(response.data.evidence || []);
    } catch (error) {
      console.error('Error fetching evidence:', error);
    }
  };

  const verifyChain = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/blockchain/verify-chain/');
      setChainStatus(response.data);
    } catch (error) {
      console.error('Error verifying chain:', error);
    }
  };

  const handleCreateUser = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'http://localhost:8000/api/blockchain/admin/add-user/',
        newUser
      );
      setMessage({ text: response.data.message || 'User created!', type: 'success' });
      setNewUser({ username: '', email: '', password: '' });
      fetchAllData();
      setTimeout(() => setMessage({ text: '', type: '' }), 5000);
    } catch (error) {
      setMessage({ text: error.response?.data?.error || 'Error creating user', type: 'error' });
    }
  };

  const handleAddEvidence = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'http://localhost:8000/api/blockchain/add-evidence/',
        newEvidence
      );
      setMessage({ text: response.data.message || 'Evidence added!', type: 'success' });
      setNewEvidence({
        evidence_id: '',
        evidence_type: '',
        description: '',
        hash: '',
        collector: ''
      });
      fetchAllData();
      setTimeout(() => setMessage({ text: '', type: '' }), 5000);
    } catch (error) {
      setMessage({ text: error.response?.data?.message || 'Error adding evidence', type: 'error' });
    }
  };

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = new Date(timestamp * 1000);
    return date.toLocaleString();
  };

  if (!isAdmin) {
    return (
      <div className="admin-panel">
        <header className="admin-header">
          <h1>⚠️ Access Denied</h1>
          <button onClick={onLogout} className="logout-btn">Logout</button>
        </header>
        <div className="admin-content">
          <p style={{ color: 'red', fontSize: '18px', padding: '20px' }}>
            You do not have administrator privileges.
          </p>
          <a href="/" className="btn-primary">Go to Dashboard</a>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-panel">
      <header className="admin-header">
        <h1>⚙️ Admin Panel</h1>
        <div className="admin-header-actions">
          <span className={`admin-status ${chainStatus?.is_chain_intact ? 'intact' : 'tampered'}`}>
            {chainStatus?.is_chain_intact ? '🔒 Chain Intact' : '⚠️ Chain Tampered'}
          </span>
          <a href="/" className="admin-link">📊 Dashboard</a>
          <button onClick={onLogout} className="logout-btn">Logout</button>
        </div>
      </header>

      {message.text && (
        <div className={`admin-message ${message.type}`}>
          {message.text}
          <button onClick={() => setMessage({ text: '', type: '' })}>×</button>
        </div>
      )}

      <div className="admin-tabs">
        <button className={activeTab === 'users' ? 'active' : ''} onClick={() => setActiveTab('users')}>
          👥 Users ({users.length})
        </button>
        <button className={activeTab === 'logs' ? 'active' : ''} onClick={() => setActiveTab('logs')}>
          📋 Security Logs ({logs.length})
        </button>
        <button className={activeTab === 'evidence' ? 'active' : ''} onClick={() => setActiveTab('evidence')}>
          🔍 Evidence ({evidence.length})
        </button>
        <button className={activeTab === 'add-user' ? 'active' : ''} onClick={() => setActiveTab('add-user')}>
          ➕ Add User
        </button>
        <button className={activeTab === 'add-evidence' ? 'active' : ''} onClick={() => setActiveTab('add-evidence')}>
          📎 Add Evidence
        </button>
      </div>

      <div className="admin-content">
        {activeTab === 'users' && (
          <div className="admin-section">
            <h2>Registered Users</h2>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Username</th>
                  <th>Email</th>
                  <th>Verified</th>
                  <th>Joined</th>
                </tr>
              </thead>
              <tbody>
                {users.map(user => (
                  <tr key={user.id}>
                    <td>{user.id}</td>
                    <td>{user.username}</td>
                    <td>{user.email}</td>
                    <td>{user.is_verified ? '✅' : '❌'}</td>
                    <td>{user.created_at ? new Date(user.created_at).toLocaleDateString() : 'N/A'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'logs' && (
          <div className="admin-section">
            <h2>Security Logs ({logs.length})</h2>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Type</th>
                  <th>Description</th>
                  <th>User</th>
                  <th>Timestamp</th>
                  <th>Verified</th>
                </tr>
              </thead>
              <tbody>
                {logs.length === 0 ? (
                  <tr><td colSpan="6">No logs found</td></tr>
                ) : (
                  logs.map((log, index) => (
                    <tr key={index}>
                      <td>{index}</td>
                      <td><span className={`badge badge-${log.event_type}`}>{log.event_type}</span></td>
                      <td>{log.description}</td>
                      <td>{log.user_address?.slice(0, 10)}...</td>
                      <td>{formatTimestamp(log.timestamp)}</td>
                      <td>{log.verified ? '✅' : '⏳'}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'evidence' && (
          <div className="admin-section">
            <h2>Forensic Evidence ({evidence.length})</h2>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>ID</th>
                  <th>Type</th>
                  <th>Description</th>
                  <th>Collector</th>
                  <th>Verified</th>
                </tr>
              </thead>
              <tbody>
                {evidence.length === 0 ? (
                  <tr><td colSpan="6">No evidence found</td></tr>
                ) : (
                  evidence.map((ev, index) => (
                    <tr key={index}>
                      <td>{index}</td>
                      <td>{ev.evidence_id}</td>
                      <td>{ev.evidence_type}</td>
                      <td>{ev.description}</td>
                      <td>{ev.collector}</td>
                      <td>{ev.verified ? '✅' : '⏳'}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'add-user' && (
          <div className="admin-section">
            <h2>Create New User</h2>
            <form onSubmit={handleCreateUser} className="admin-form">
              <div className="form-group">
                <label>Username *</label>
                <input
                  type="text"
                  value={newUser.username}
                  onChange={(e) => setNewUser({ ...newUser, username: e.target.value })}
                  required
                  placeholder="Enter username"
                />
              </div>
              <div className="form-group">
                <label>Email *</label>
                <input
                  type="email"
                  value={newUser.email}
                  onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                  required
                  placeholder="Enter email"
                />
              </div>
              <div className="form-group">
                <label>Password *</label>
                <input
                  type="password"
                  value={newUser.password}
                  onChange={(e) => setNewUser({ ...newUser, password: e.target.value })}
                  required
                  placeholder="Enter password"
                />
              </div>
              <button type="submit" className="btn-primary">Create User</button>
            </form>
          </div>
        )}

        {activeTab === 'add-evidence' && (
          <div className="admin-section">
            <h2>Add Forensic Evidence</h2>
            <form onSubmit={handleAddEvidence} className="admin-form">
              <div className="form-group">
                <label>Evidence ID *</label>
                <input
                  type="text"
                  value={newEvidence.evidence_id}
                  onChange={(e) => setNewEvidence({ ...newEvidence, evidence_id: e.target.value })}
                  required
                  placeholder="EVID-001"
                />
              </div>
              <div className="form-group">
                <label>Evidence Type *</label>
                <input
                  type="text"
                  value={newEvidence.evidence_type}
                  onChange={(e) => setNewEvidence({ ...newEvidence, evidence_type: e.target.value })}
                  required
                  placeholder="LOGIN_RECORD"
                />
              </div>
              <div className="form-group">
                <label>Description *</label>
                <textarea
                  value={newEvidence.description}
                  onChange={(e) => setNewEvidence({ ...newEvidence, description: e.target.value })}
                  required
                  placeholder="Describe the evidence"
                />
              </div>
              <div className="form-group">
                <label>Hash *</label>
                <input
                  type="text"
                  value={newEvidence.hash}
                  onChange={(e) => setNewEvidence({ ...newEvidence, hash: e.target.value })}
                  required
                  placeholder="0x..."
                />
              </div>
              <div className="form-group">
                <label>Collector *</label>
                <input
                  type="text"
                  value={newEvidence.collector}
                  onChange={(e) => setNewEvidence({ ...newEvidence, collector: e.target.value })}
                  required
                  placeholder="Admin name"
                />
              </div>
              <button type="submit" className="btn-primary">Add Evidence</button>
            </form>
          </div>
        )}
      </div>
    </div>
  );
}

export default AdminPanel;
