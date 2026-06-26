# 🔗 BlockLog Guardian

**🎓 Developed for Digital Forensic & Blockchain Integration — 6th Semester Project**

*Decentralized tamper-proof authentication and security logging system using Blockchain (Geth) and IPFS*

[![University](https://img.shields.io/badge/Institution-University_of_Wah-blue.svg)](#)
[![Department](https://img.shields.io/badge/Department-Cybersecurity-purple.svg)](#)
[![Course](https://img.shields.io/badge/Course-Blockchain_Technology-teal.svg)](#)
[![Semester](https://img.shields.io/badge/Semester-6th-green.svg)](#)
[![Project](https://img.shields.io/badge/Type-Blockchain_Project-orange.svg)](#)

---

> **"Secure Every Event. Trust Every Log. Verify Every Block."**

⭐ *Star this repository if it helped your Blockchain/Security learning journey!*

---

## 📌 Project Overview

**BlockLog Guardian** is a **decentralized security monitoring system** that uses blockchain technology to create tamper-proof audit logs. Every login, admin action, and security event is permanently recorded on a private Ethereum blockchain, ensuring integrity and non-repudiation.

The system combines a **Django REST backend**, a **React frontend dashboard**, and a **private Ethereum network (Geth)** with **IPFS storage** for forensic evidence.

---

## ⚙️ Technologies Used

### 🔹 Blockchain Layer

- **Geth (Go Ethereum) v1.13.15**
- **Clique Proof-of-Authority Consensus**
- **Solidity 0.8.0** (Smart Contracts)
- **Web3.py**

### 🔹 Backend

- **Python 3.11+**
- **Django 4.2 + Django REST Framework**
- **JWT Authentication**
- **SQLite3**

### 🔹 Frontend

- **React 18**
- **Chart.js**
- **Bootstrap 5**

### 🔹 Storage

- **IPFS (InterPlanetary File System)**

---

## 🧠 Key Features

- 🔐 **JWT Authentication** with account lockout protection
- 📝 **Immutable Logging** — every event written to Ethereum blockchain
- 🔍 **Forensic Evidence Management** via IPFS
- 📊 **Real-time Dashboard** with analytics and charts
- ⛓️ **Chain Verification** for tamper detection
- 🛡️ **Admin Panel** for user and event management

---

## 🔁 Implemented Security Modules

- ✅ User Authentication & Authorization
- ✅ Blockchain Security Event Logger
- ✅ Forensic Evidence Storage (IPFS)
- ✅ Chain Integrity Verifier
- ✅ Admin User Management
- ✅ Real-time Analytics Dashboard

Each module records **immutable audit events** from the server directly onto the blockchain.

---

## ▶️ Step-by-Step Guide to Run the Project

This project consists of **three parts**:

1. **Blockchain Layer (Geth Private Network)**
2. **Backend (Django REST API)**
3. **Frontend (React Dashboard)**

Follow the steps below carefully.

---

### 🔹 Step 1: Prerequisites

Make sure the following are installed on your system:

- ✅ **Python 3.11+**
- ✅ **Node.js 18+**
- ✅ **Git**
- ✅ **Geth v1.13.15**
- ✅ **Modern Browser (Chrome / Edge)**

---

### 🔹 Step 2: Clone the Repository

```bash
git clone https://github.com/yourusername/BlockLog-Guardian.git
cd BlockLog-Guardian
```

---

### 🔹 Step 3: Setup Python Backend

```bash
# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Linux/Mac)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create admin user
python manage.py createsuperuser

# Start backend server
python manage.py runserver
```

If successful, you will see:

```
Starting development server at http://127.0.0.1:8000/
```

⚠️ **Keep this terminal open**

---

### 🔹 Step 4: Setup Blockchain (Geth) — One Time Only

#### Download Geth v1.13.15

Download from: https://geth.ethereum.org/downloads

Or via script:

```bash
curl -L -o geth.zip https://gethstore.blob.core.windows.net/builds/geth-windows-amd64-1.13.15-75d67b6c.zip
unzip geth.zip -d geth/
```

#### Initialize Genesis Block

```bash
geth --datadir blockchain/data/node1 init blockchain/genesis.json
geth --datadir blockchain/data/node2 init blockchain/genesis.json
geth --datadir blockchain/data/node3 init blockchain/genesis.json
```

#### Deploy Smart Contracts

```bash
python scripts/compile_contracts.py
python scripts/deploy_simple.py
```

> ⚠️ **Save the contract addresses** displayed after deployment — you'll need them for `.env`.

---

### 🔹 Step 5: Start Blockchain Nodes

Open **4 separate terminals**:

```bash
# Terminal 1 - Node 1 (Miner)
./scripts/start_node1.sh

# Terminal 2 - Node 2 (Replication)
./scripts/start_node2.sh

# Terminal 3 - Node 3 (Audit)
./scripts/start_node3.sh

# Terminal 4 - Connect Nodes
./scripts/connect_nodes.sh
```

If successful, Node 1 will display:

```
Successfully sealed new block  number=1  hash=0x...
```

⚠️ **Keep all node windows open**

---

### 🔹 Step 6: Configure Environment Variables

Create a `.env` file in the project root:

```bash
cat > .env << 'EOF'
# Django
DJANGO_SECRET_KEY=your-secret-key-here
DEBUG=True

# Blockchain
BLOCKCHAIN_PROVIDER=http://localhost:8545
CHAIN_ID=2026

# Contract Addresses (from Step 4 deployment)
SECURITY_LOG_CONTRACT=0xYourSecurityLogAddress
FORENSIC_EVIDENCE_CONTRACT=0xYourForensicEvidenceAddress
DEPLOYER_ADDRESS=0xYourDeployerAddress
DEPLOYER_PRIVATE_KEY=0xYourPrivateKey

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
EOF
```

Generate a Django secret key:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

### 🔹 Step 7: Run the Frontend (React)

```bash
cd frontend
npm install
npm start
```

The dashboard will load at: **http://localhost:3000/**

---

### ✅ Output

- Security events are logged in real time to the blockchain
- Dashboard displays live charts and event analytics
- Chain verification confirms tamper-proof integrity
- Forensic evidence is stored and retrieved via IPFS

---

## 🌐 Access the System

| Service | URL |
|---------|-----|
| Frontend Dashboard | http://localhost:3000/ |
| Backend API | http://localhost:8000/ |
| Admin Panel | http://localhost:3000/admin |
| Django Admin | http://localhost:8000/admin/ |
| Geth Node 1 RPC | http://localhost:8545 |

---

## 📡 API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register/` | Register new user |
| POST | `/api/auth/login/` | Login user |
| POST | `/api/auth/logout/` | Logout user |

### Blockchain

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/blockchain/status/` | Blockchain status |
| GET | `/api/blockchain/logs/` | All security logs |
| POST | `/api/blockchain/add-log/` | Add security log |
| POST | `/api/blockchain/add-evidence/` | Add forensic evidence |
| GET | `/api/blockchain/evidence/` | All evidence |
| GET | `/api/blockchain/verify-chain/` | Verify chain integrity |

### Admin

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/blockchain/admin/users/` | List all users |
| POST | `/api/blockchain/admin/add-user/` | Create user |

---

## 📁 Project Structure

```
BlockLog-Guardian/
├── blockchain/
│   ├── contracts/          # Solidity smart contracts
│   ├── build/              # Compiled contracts
│   └── genesis.json        # Genesis block configuration
├── blockchain_forensic_system/
│   ├── settings.py         # Django settings
│   └── urls.py             # URL routing
├── authentication/         # Django auth app
├── blockchain_integration/ # Blockchain API app
├── frontend/               # React dashboard
│   └── src/
│       └── components/     # React components
├── scripts/                # Utility scripts
│   ├── start_node1.sh      # Node 1 startup
│   ├── start_node2.sh      # Node 2 startup
│   ├── start_node3.sh      # Node 3 startup
│   ├── connect_nodes.sh    # Peer connection script
│   ├── deploy_simple.py    # Contract deployment
│   └── network_status.sh   # Network health check
├── .env                    # Environment variables
├── requirements.txt        # Python dependencies
└── manage.py               # Django management
```

---

## 🔧 Troubleshooting

### Geth Not Found

```bash
export PATH="/path/to/geth:$PATH"
```

### CORS Error

Add to Django `settings.py`:

```python
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOWED_ORIGINS = ["http://localhost:3000"]
```

### Port Already in Use

```bash
# Find and kill process on port 8545
netstat -ano | findstr :8545
taskkill /PID <process_id> /F
```

---

## 📄 License

MIT License

---

## 🙏 Acknowledgments

- **Ma'am Muniba Khan** — Project Supervisor
- **University of Wah** — Department of Computer Science

---

[![University](https://img.shields.io/badge/Institution-University_of_Wah-blue.svg)](#)
[![Department](https://img.shields.io/badge/Department-Cybersecurity-purple.svg)](#)
[![Course](https://img.shields.io/badge/Course-Blockchain_Technology-teal.svg)](#)
[![Semester](https://img.shields.io/badge/Semester-6th-green.svg)](#)
[![Project](https://img.shields.io/badge/Type-Blockchain_Project-orange.svg)](#)

> **"Secure Every Event. Trust Every Log. Verify Every Block."**

**⭐ Star this repository if it helped your Blockchain/Security learning journey!**
