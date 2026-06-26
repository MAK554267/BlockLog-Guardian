#!/bin/bash

echo "Setting up Private Ethereum Network..."

# Initialize Node 1
echo "Initializing Node 1..."
geth --datadir "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/data/node1" account new --password "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/password.txt"
geth --datadir "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/data/node1" init "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/genesis.json"

# Initialize Node 2
echo "Initializing Node 2..."
geth --datadir "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/data/node2" account new --password "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/password.txt"
geth --datadir "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/data/node2" init "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/genesis.json"

# Initialize Node 3
echo "Initializing Node 3..."
geth --datadir "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/data/node3" account new --password "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/password.txt"
geth --datadir "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/data/node3" init "E:\Projects\6th Semester Projects\Geth\blockchain-forensic-system/blockchain/genesis.json"

echo "Blockchain nodes initialized successfully!"