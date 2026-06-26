#!/bin/bash

PROJECT_DIR="E:/Projects/6th Semester Projects/Geth/blockchain-forensic-system"
GETH_PATH="E:/Projects/6th Semester Projects/Geth"

echo "========================================="
echo "  CONNECTING BLOCKCHAIN NODES"
echo "========================================="
echo ""

# Function to make JSON-RPC calls
rpc_call() {
    local port=$1
    local method=$2
    local params=$3
    if [ -z "$params" ]; then
        params="[]"
    fi
    curl -s -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":$params,\"id\":1}" \
        "http://localhost:$port" 2>/dev/null
}

# Function to check if a node is running
check_node() {
    local port=$1
    local node_name=$2
    local result=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        "http://localhost:$port" 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$result" ]; then
        echo "✅ $node_name is running"
        return 0
    else
        echo "❌ $node_name is not running"
        return 1
    fi
}

# Check if nodes are running
echo "Checking node status..."
echo ""

check_node 8545 "Node 1 (Port 8545)"
NODE1_STATUS=$?

check_node 8548 "Node 2 (Port 8548)"
NODE2_STATUS=$?

check_node 8550 "Node 3 (Port 8550)"
NODE3_STATUS=$?

echo ""

if [ $NODE1_STATUS -ne 0 ]; then
    echo "❌ Node 1 must be running first!"
    echo "Please start Node 1: ./scripts/start_node1.sh"
    exit 1
fi

echo ""

# Get Node 1 enode URL and convert to localhost
echo "Getting Node 1 enode URL..."
NODE1_ENODE_RAW=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' \
    http://localhost:8545 2>/dev/null | grep -o '"enode":"[^"]*"' | cut -d'"' -f4)

# Replace external IP with localhost for local connections
NODE1_ENODE=$(echo "$NODE1_ENODE_RAW" | sed 's/@[^:]*:/@127.0.0.1:/')

if [ -z "$NODE1_ENODE" ]; then
    echo "❌ Failed to get Node 1 enode. Make sure Node 1 is running."
    exit 1
fi

echo "✅ Node 1 enode obtained successfully"
echo ""
echo "Node 1 enode: $NODE1_ENODE"
echo ""

# Connect Node 2 to Node 1 (if Node 2 is running)
if [ $NODE2_STATUS -eq 0 ]; then
    echo "Connecting Node 2 to Node 1..."
    RESULT=$(curl -s -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_addPeer\",\"params\":[\"$NODE1_ENODE\"],\"id\":1}" \
        http://localhost:8548 2>/dev/null | grep -o '"result":[^,}]*' | cut -d':' -f2 | tr -d '"')
    if [ "$RESULT" == "true" ] || [ -z "$RESULT" ]; then
        echo "✅ Node 2 connected to Node 1"
    else
        echo "⚠️  Node 2 connection attempt returned: $RESULT"
    fi
else
    echo "⏭️  Skipping Node 2 connection (not running)"
fi

echo ""

# Connect Node 3 to Node 1 (if Node 3 is running)
if [ $NODE3_STATUS -eq 0 ]; then
    echo "Connecting Node 3 to Node 1..."
    RESULT=$(curl -s -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_addPeer\",\"params\":[\"$NODE1_ENODE\"],\"id\":1}" \
        http://localhost:8550 2>/dev/null | grep -o '"result":[^,}]*' | cut -d':' -f2 | tr -d '"')
    if [ "$RESULT" == "true" ] || [ -z "$RESULT" ]; then
        echo "✅ Node 3 connected to Node 1"
    else
        echo "⚠️  Node 3 connection attempt returned: $RESULT"
    fi
else
    echo "⏭️  Skipping Node 3 connection (not running)"
fi

echo ""
echo "========================================="
echo "  VERIFYING CONNECTIONS"
echo "========================================="
echo ""

# Wait a moment for connections to establish
sleep 3

# Check peers on each node
echo "Node 1 Peers:"
PEER_COUNT=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
    http://localhost:8545 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
echo "  Peer count: $PEER_COUNT"

if [ "$PEER_COUNT" != "0x0" ]; then
    echo "  Peer details:"
    curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' \
        http://localhost:8545 2>/dev/null | grep -o '"enode":"[^"]*"' | head -2
fi

echo ""
echo "Node 2 Peers:"
if [ $NODE2_STATUS -eq 0 ]; then
    PEER_COUNT=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
        http://localhost:8548 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    echo "  Peer count: $PEER_COUNT"
    if [ "$PEER_COUNT" != "0x0" ]; then
        echo "  Peer details:"
        curl -s -X POST -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' \
            http://localhost:8548 2>/dev/null | grep -o '"enode":"[^"]*"' | head -2
    fi
else
    echo "  ⏭️  Node 2 not running"
fi

echo ""
echo "Node 3 Peers:"
if [ $NODE3_STATUS -eq 0 ]; then
    PEER_COUNT=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
        http://localhost:8550 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    echo "  Peer count: $PEER_COUNT"
    if [ "$PEER_COUNT" != "0x0" ]; then
        echo "  Peer details:"
        curl -s -X POST -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' \
            http://localhost:8550 2>/dev/null | grep -o '"enode":"[^"]*"' | head -2
    fi
else
    echo "  ⏭️  Node 3 not running"
fi

echo ""
echo "========================================="
echo "  NETWORK STATUS"
echo "========================================="
echo ""

# Show network information
echo "Node 1 (Miner):    http://localhost:8545"
echo "Node 2:            http://localhost:8548"
echo "Node 3:            http://localhost:8550"
echo ""

echo "Block Numbers:"
BLOCK1=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
BLOCK2=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8548 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
BLOCK3=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8550 2>/dev/null | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

echo "  Node 1: $BLOCK1"
if [ $NODE2_STATUS -eq 0 ]; then
    echo "  Node 2: $BLOCK2"
fi
if [ $NODE3_STATUS -eq 0 ]; then
    echo "  Node 3: $BLOCK3"
fi

echo ""
echo "Mining Status:"
MINING=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}' \
    http://localhost:8545 2>/dev/null | grep -o '"result":[^,}]*' | cut -d':' -f2 | tr -d '"')
echo "  Node 1: $MINING"

echo ""
echo "✅ Connection process complete!"