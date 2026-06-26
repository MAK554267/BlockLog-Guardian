#!/bin/bash

PROJECT_DIR="E:/Projects/6th Semester Projects/Geth/blockchain-forensic-system"
GETH_PATH="E:/Projects/6th Semester Projects/Geth"

echo "========================================="
echo "  INITIALIZING BLOCKCHAIN NODES"
echo "========================================="
echo ""

# Check if geth exists
if [ ! -f "$GETH_PATH/geth.exe" ]; then
    echo "❌ Error: geth.exe not found at $GETH_PATH"
    exit 1
fi

# Check if genesis file exists
if [ ! -f "$PROJECT_DIR/blockchain/genesis.json" ]; then
    echo "❌ Error: genesis.json not found at $PROJECT_DIR/blockchain/"
    exit 1
fi

echo "✅ Genesis file found"
echo ""

# Stop any running nodes
echo "Stopping any running nodes..."
pkill -f geth.exe 2>/dev/null
sleep 2
echo "✅ Stopped existing processes"
echo ""

# Clean ALL old data (including ancient)
echo "Cleaning ALL blockchain data..."
rm -rf "$PROJECT_DIR/blockchain/data/node1/geth"
rm -rf "$PROJECT_DIR/blockchain/data/node2/geth"
rm -rf "$PROJECT_DIR/blockchain/data/node3/geth"
rm -rf "$PROJECT_DIR/blockchain/data/node1/geth/chaindata/ancient" 2>/dev/null
rm -rf "$PROJECT_DIR/blockchain/data/node2/geth/chaindata/ancient" 2>/dev/null
rm -rf "$PROJECT_DIR/blockchain/data/node3/geth/chaindata/ancient" 2>/dev/null
echo "✅ Cleaned all data"
echo ""

# Initialize Node 1
echo "Initializing Node 1..."
"$GETH_PATH/geth.exe" --datadir "$PROJECT_DIR/blockchain/data/node1" init "$PROJECT_DIR/blockchain/genesis.json"
if [ $? -eq 0 ]; then
    echo "✅ Node 1 initialized"
else
    echo "❌ Node 1 initialization failed"
    exit 1
fi
echo ""

# Initialize Node 2
echo "Initializing Node 2..."
"$GETH_PATH/geth.exe" --datadir "$PROJECT_DIR/blockchain/data/node2" init "$PROJECT_DIR/blockchain/genesis.json"
if [ $? -eq 0 ]; then
    echo "✅ Node 2 initialized"
else
    echo "❌ Node 2 initialization failed"
    exit 1
fi
echo ""

# Initialize Node 3
echo "Initializing Node 3..."
"$GETH_PATH/geth.exe" --datadir "$PROJECT_DIR/blockchain/data/node3" init "$PROJECT_DIR/blockchain/genesis.json"
if [ $? -eq 0 ]; then
    echo "✅ Node 3 initialized"
else
    echo "❌ Node 3 initialization failed"
    exit 1
fi
echo ""

echo "========================================="
echo "  ✅ ALL NODES INITIALIZED SUCCESSFULLY!"
echo "========================================="
echo ""
echo "You can now start the nodes:"
echo "  Terminal 1: ./scripts/start_node1.sh"
echo "  Terminal 2: ./scripts/start_node2.sh"
echo "  Terminal 3: ./scripts/start_node3.sh"
echo ""
echo "After all nodes are running:"
echo "  Terminal 4: ./scripts/connect_nodes.sh"