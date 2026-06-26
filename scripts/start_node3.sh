#!/bin/bash

# Node 3 Configuration - Consensus/Audit Node
PROJECT_DIR="E:/Projects/6th Semester Projects/Geth/blockchain-forensic-system"
GETH_PATH="E:/Projects/6th Semester Projects/Geth"
NODE3_ADDRESS="0xEd35251FB1046Fb7dCF93416653e5938903D0Ff7"

echo "========================================="
echo "  STARTING NODE 3 (CONSENSUS/AUDIT NODE)"
echo "========================================="
echo "Project Directory: $PROJECT_DIR"
echo "Geth Path: $GETH_PATH/geth.exe"
echo "Node Address: $NODE3_ADDRESS"
echo ""

# Check if geth exists
if [ ! -f "$GETH_PATH/geth.exe" ]; then
    echo "❌ Error: geth.exe not found at $GETH_PATH"
    exit 1
fi

# Check if data directory exists
if [ ! -d "$PROJECT_DIR/blockchain/data/node3" ]; then
    echo "❌ Error: Node 3 data directory not found"
    echo "Please run ./scripts/init_nodes.sh first"
    exit 1
fi

echo "✅ All checks passed. Starting Node 3..."
echo ""

# Start Node 3 - No WebSocket (--ws flag omitted)
"$GETH_PATH/geth.exe" \
  --datadir "$PROJECT_DIR/blockchain/data/node3" \
  --networkid 2026 \
  --port 30305 \
  --http \
  --http.addr "127.0.0.1" \
  --http.port 8550 \
  --http.api "eth,net,web3,personal,admin" \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --authrpc.port 8553 \
  --ipcdisable \
  --nat any \
  --maxpeers 25 \
  --verbosity 3 \
  --syncmode "full"