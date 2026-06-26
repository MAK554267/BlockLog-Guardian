#!/bin/bash

echo "========================================="
echo "  BLOCKCHAIN NETWORK STATUS"
echo "========================================="
echo ""

# Get block numbers
BLOCK1=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545 | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
BLOCK2=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8548 | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
BLOCK3=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8550 | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

# Get peer counts
PEER1=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' http://localhost:8545 | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
PEER2=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' http://localhost:8548 | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
PEER3=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' http://localhost:8550 | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

echo "📊 NETWORK SUMMARY:"
echo "─────────────────────────────"
printf "Node 1 (Miner):    Block: %-8s Peers: %s\n" "$BLOCK1" "$PEER1"
printf "Node 2 (Replica):  Block: %-8s Peers: %s\n" "$BLOCK2" "$PEER2"
printf "Node 3 (Audit):    Block: %-8s Peers: %s\n" "$BLOCK3" "$PEER3"
echo "─────────────────────────────"

# Check if all nodes are synced
if [ "$BLOCK1" == "$BLOCK2" ] && [ "$BLOCK2" == "$BLOCK3" ] && [ -n "$BLOCK1" ] && [ "$BLOCK1" != "0x0" ]; then
    echo "✅ All nodes are SYNCED!"
elif [ -n "$BLOCK1" ] && [ -n "$BLOCK2" ] && [ -n "$BLOCK3" ]; then
    echo "🔄 Nodes are syncing..."
    echo "   Wait a moment and run again."
else
    echo "⚠️  Some nodes are not responding."
fi

echo ""

# Show mining status
MINING=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}' http://localhost:8545 | grep -o '"result":[^,}]*' | cut -d':' -f2 | tr -d '"')
echo "🔨 Node 1 Mining: $MINING"

# Show contract addresses
echo ""
echo "📋 Contract Addresses:"
cat blockchain/build/contract_addresses.json 2>/dev/null || echo "   Not available"

echo ""
echo "========================================="
