import json
import time
from web3 import Web3
from eth_account import Account
import os

print("="*60)
print("  DEPLOYING SMART CONTRACTS")
print("="*60)
print()

# 1. Connect to blockchain
print("📡 Connecting to blockchain...")
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

if not w3.is_connected():
    print("❌ Failed to connect to blockchain!")
    print("   Make sure Node 1 is running: ./scripts/start_node1.sh")
    exit(1)

print(f"✅ Connected to blockchain")
print(f"   Chain ID: {w3.eth.chain_id}")
print(f"   Block number: {w3.eth.block_number}")
print()

# 2. Load private key
print("🔑 Loading private key...")
try:
    with open('blockchain/private_key.txt', 'r') as f:
        private_key = f.read().strip()
except FileNotFoundError:
    print("❌ Private key file not found!")
    print("   Please run: python scripts/extract_private_key.py")
    exit(1)

account = Account.from_key(private_key)
print(f"✅ Account loaded")
print(f"   Address: {account.address}")

# Check balance
balance = w3.eth.get_balance(account.address)
print(f"   Balance: {w3.from_wei(balance, 'ether')} ETH")
print()

if balance == 0:
    print("⚠️  Warning: Account balance is 0!")
    print("   You may need to mine some blocks first.")
    print()

# 3. Load contract ABIs and bytecodes
print("📄 Loading contract files...")

def load_contract_file(contract_name):
    file_path = f'blockchain/build/{contract_name}.json'
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
            if 'abi' not in data or 'bytecode' not in data:
                print(f"   ❌ {contract_name}: Missing ABI or bytecode")
                return None
            if not data['bytecode'] or len(data['bytecode']) < 10:
                print(f"   ❌ {contract_name}: Invalid bytecode")
                return None
            print(f"   ✅ {contract_name}: Loaded successfully")
            return data
    except FileNotFoundError:
        print(f"   ❌ {contract_name}: File not found")
        return None
    except json.JSONDecodeError:
        print(f"   ❌ {contract_name}: Invalid JSON")
        return None

security_log_data = load_contract_file('SecurityLog')
forensic_evidence_data = load_contract_file('ForensicEvidence')

if not security_log_data or not forensic_evidence_data:
    print("\n❌ Failed to load contract data!")
    print("   Please run: python scripts/compile_contracts.py")
    exit(1)

print()

# 4. Deploy SecurityLog
print("🚀 Deploying SecurityLog contract...")
try:
    SecurityLog = w3.eth.contract(
        abi=security_log_data['abi'],
        bytecode=security_log_data['bytecode']
    )
    
    nonce = w3.eth.get_transaction_count(account.address)
    print(f"   Nonce: {nonce}")
    
    transaction = SecurityLog.constructor().build_transaction({
        'chainId': 2026,
        'gas': 2000000,
        'gasPrice': w3.to_wei('1', 'gwei'),
        'nonce': nonce,
        'from': account.address
    })
    
    signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
    tx_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)
    print(f"   Transaction hash: {tx_hash.hex()}")
    
    print("   ⏳ Waiting for confirmation...")
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)
    
    if tx_receipt.status == 1:
        security_log_address = tx_receipt.contractAddress
        print(f"   ✅ SecurityLog deployed at: {security_log_address}")
    else:
        print("   ❌ Deployment failed!")
        exit(1)
        
except Exception as e:
    print(f"   ❌ Error: {e}")
    exit(1)

print()

# 5. Deploy ForensicEvidence
print("🚀 Deploying ForensicEvidence contract...")
try:
    ForensicEvidence = w3.eth.contract(
        abi=forensic_evidence_data['abi'],
        bytecode=forensic_evidence_data['bytecode']
    )
    
    nonce = w3.eth.get_transaction_count(account.address)
    print(f"   Nonce: {nonce}")
    
    transaction = ForensicEvidence.constructor().build_transaction({
        'chainId': 2026,
        'gas': 2000000,
        'gasPrice': w3.to_wei('1', 'gwei'),
        'nonce': nonce,
        'from': account.address
    })
    
    signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
    tx_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)
    print(f"   Transaction hash: {tx_hash.hex()}")
    
    print("   ⏳ Waiting for confirmation...")
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)
    
    if tx_receipt.status == 1:
        forensic_evidence_address = tx_receipt.contractAddress
        print(f"   ✅ ForensicEvidence deployed at: {forensic_evidence_address}")
    else:
        print("   ❌ Deployment failed!")
        exit(1)
        
except Exception as e:
    print(f"   ❌ Error: {e}")
    exit(1)

print()

# 6. Save contract addresses
print("💾 Saving contract addresses...")
contract_addresses = {
    'SecurityLog': security_log_address,
    'ForensicEvidence': forensic_evidence_address,
    'deployer': account.address,
    'network': 'private',
    'chain_id': 2026
}

with open('blockchain/build/contract_addresses.json', 'w') as f:
    json.dump(contract_addresses, f, indent=2)

print(f"✅ Saved to: blockchain/build/contract_addresses.json")
print()

# 7. Display summary
print("="*60)
print("  ✅ DEPLOYMENT COMPLETE!")
print("="*60)
print()
print("📋 Contract Addresses:")
print(f"   SecurityLog:       {security_log_address}")
print(f"   ForensicEvidence:  {forensic_evidence_address}")
print(f"   Deployer:          {account.address}")
print()
print("📁 Addresses saved to: blockchain/build/contract_addresses.json")
print()
print("🔗 RPC Endpoint: http://localhost:8545")
print("🆔 Chain ID: 2026")
print("="*60)
