#!/bin/bash

# Node 2 Configuration - Replication/Verification Node
PROJECT_DIR="E:/Projects/6th Semester Projects/Geth/blockchain-forensic-system"
GETH_PATH="E:/Projects/6th Semester Projects/Geth"
NODE2_ADDRESS="0x8A0e46F18cccBF26024574031026ea87EB36d113"

echo "========================================="
echo "  STARTING NODE 2 (REPLICATION NODE)"
echo "========================================="
echo "Project Directory: $PROJECT_DIR"
echo "Geth Path: $GETH_PATH/geth.exe"
echo "Node Address: $NODE2_ADDRESS"
echo ""

# Check if geth exists
if [ ! -f "$GETH_PATH/geth.exe" ]; then
    echo "❌ Error: geth.exe not found at $GETH_PATH"
    exit 1
fi

# Check if data directory exists
if [ ! -d "$PROJECT_DIR/blockchain/data/node2" ]; then
    echo "❌ Error: Node 2 data directory not found"
    echo "Please run ./scripts/init_nodes.sh first"
    exit 1
fi

echo "✅ All checks passed. Starting Node 2..."
echo ""

# Start Node 2 - No WebSocket (--ws flag omitted)
"$GETH_PATH/geth.exe" \
  --datadir "$PROJECT_DIR/blockchain/data/node2" \
  --networkid 2026 \
  --port 30304 \
  --http \
  --http.addr "127.0.0.1" \
  --http.port 8548 \
  --http.api "eth,net,web3,personal,admin" \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --authrpc.port 8552 \
  --ipcdisable \
  --nat any \
  --maxpeers 25 \
  --verbosity 3 \
  --syncmode "full"