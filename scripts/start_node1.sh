#!/bin/bash

# Node 1 Configuration - Primary Miner/Signer
PROJECT_DIR="E:/Projects/6th Semester Projects/Geth/blockchain-forensic-system"
GETH_PATH="E:/Projects/6th Semester Projects/Geth"
NODE1_ADDRESS="0x4e0A20b9e3D7FaC87743f76dBA08b4f8CdF55Dba"

echo "========================================="
echo "  STARTING NODE 1 (MINER/SIGNER)"
echo "========================================="
echo "Project Directory: $PROJECT_DIR"
echo "Geth Path: $GETH_PATH/geth.exe"
echo "Node Address: $NODE1_ADDRESS"
echo ""

# Check if geth exists
if [ ! -f "$GETH_PATH/geth.exe" ]; then
    echo "❌ Error: geth.exe not found at $GETH_PATH"
    exit 1
fi

# Check if data directory exists
if [ ! -d "$PROJECT_DIR/blockchain/data/node1" ]; then
    echo "❌ Error: Node 1 data directory not found"
    echo "Please run ./scripts/init_nodes.sh first"
    exit 1
fi

echo "✅ All checks passed. Starting Node 1..."
echo ""

# Start Node 1 with WebSocket enabled on port 8546
"$GETH_PATH/geth.exe" \
  --datadir "$PROJECT_DIR/blockchain/data/node1" \
  --networkid 2026 \
  --port 30303 \
  --http \
  --http.addr "127.0.0.1" \
  --http.port 8545 \
  --http.api "eth,net,web3,personal,admin,miner" \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --ws \
  --ws.addr "127.0.0.1" \
  --ws.port 8546 \
  --ws.api "eth,net,web3,personal,admin" \
  --ws.origins "*" \
  --authrpc.port 8551 \
  --ipcdisable \
  --allow-insecure-unlock \
  --mine \
  --miner.etherbase "$NODE1_ADDRESS" \
  --unlock "$NODE1_ADDRESS" \
  --password "$PROJECT_DIR/blockchain/password.txt" \
  --nat any \
  --maxpeers 25 \
  --verbosity 3