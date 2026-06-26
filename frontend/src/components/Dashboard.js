import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Line, Doughnut } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js';
import './Dashboard.css';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

function Dashboard({ token, onLogout, isAdmin, user }) {
  const [status, setStatus] = useState(null);
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStatus();
    fetchLogs();
    const interval = setInterval(() => {
      fetchStatus();
      fetchLogs();
    }, 10000);
    return () => clearInterval(interval);
  }, []);

  const fetchStatus = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/blockchain/status/');
      setStatus(response.data);
    } catch (error) {
      console.error('Error fetching status:', error);
    }
  };

  const fetchLogs = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/blockchain/logs/');
      setLogs(response.data.logs || []);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching logs:', error);
      setLoading(false);
    }
  };

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = new Date(timestamp * 1000);
    return date.toLocaleString();
  };

  const chartData = {
    labels: logs.map((_, i) => `Event ${i+1}`),
    datasets: [
      {
        label: 'Security Events',
        data: logs.map((log, i) => (i + 1) * 1.5),
        borderColor: 'rgb(75, 192, 192)',
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        tension: 0.4,
      }
    ]
  };

  const doughnutData = {
    labels: ['Security Events', 'Investigations', 'Evidence'],
    datasets: [
      {
        data: [
          logs.length || 0,
          0,
          status?.contracts?.ForensicEvidence?.total_evidence || 0
        ],
        backgroundColor: ['#36A2EB', '#FF6384', '#FFCE56'],
        borderWidth: 2,
        borderColor: '#fff',
      }
    ]
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>🛡️ Blockchain Security Monitor</h1>
        <div className="header-actions">
          {isAdmin && (
            <a href="/admin" className="admin-link">⚙️ Admin Panel</a>
          )}
          <button onClick={onLogout} className="logout-btn">Logout</button>
        </div>
      </header>

      <div className="stats-grid">
        <div className="stat-card">
          <h3>Blockchain Status</h3>
          <div className="stat-value">{status?.status || 'Loading...'}</div>
          <div className="stat-label">Chain ID: {status?.chain_id || 'N/A'}</div>
        </div>
        <div className="stat-card">
          <h3>Block Number</h3>
          <div className="stat-value">{status?.block_number || '0x0'}</div>
          <div className="stat-label">Peers: {status?.peer_count || '0'}</div>
        </div>
        <div className="stat-card">
          <h3>Security Logs</h3>
          <div className="stat-value">{logs.length}</div>
          <div className="stat-label">Total Events on Blockchain</div>
        </div>
        <div className="stat-card">
          <h3>Forensic Evidence</h3>
          <div className="stat-value">{status?.contracts?.ForensicEvidence?.total_evidence || 0}</div>
          <div className="stat-label">Evidence Records</div>
        </div>
      </div>

      <div className="charts-grid">
        <div className="chart-card">
          <h3>Activity Trends</h3>
          {logs.length > 0 ? (
            <Line data={chartData} options={{ responsive: true }} />
          ) : (
            <p>No data yet. Add some logs!</p>
          )}
        </div>
        <div className="chart-card">
          <h3>Security Overview</h3>
          <Doughnut data={doughnutData} options={{ responsive: true }} />
        </div>
      </div>

      <div className="recent-activity">
        <h3>🔗 Blockchain Security Events</h3>
        <table className="activity-table">
          <thead>
            <tr>
              <th>Type</th>
              <th>Description</th>
              <th>User Address</th>
              <th>Timestamp</th>
              <th>Verified</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="5">Loading events...</td></tr>
            ) : logs.length === 0 ? (
              <tr><td colSpan="5">No security events recorded yet</td></tr>
            ) : (
              logs.slice(0, 20).map((log, index) => (
                <tr key={index}>
                  <td><span className={`event-badge ${log.event_type}`}>{log.event_type}</span></td>
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
    </div>
  );
}

export default Dashboard;
