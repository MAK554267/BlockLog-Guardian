import json
import time
from web3 import Web3
from eth_account import Account

print("="*60)
print("  DEPLOYING CONTRACTS")
print("="*60)
print()

# Connect
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
if not w3.is_connected():
    print("❌ Failed to connect!")
    exit(1)

print(f"✅ Connected - Chain ID: {w3.eth.chain_id}")
print(f"   Block: {hex(w3.eth.block_number)}")
print()

# Load account
with open('blockchain/private_key.txt', 'r') as f:
    private_key = f.read().strip()
account = Account.from_key(private_key)
print(f"✅ Account: {account.address}")
print(f"   Balance: {w3.from_wei(w3.eth.get_balance(account.address), 'ether')} ETH")
print()

# Deploy SecurityLog
print("📄 Deploying SecurityLog...")
with open('blockchain/build/SecurityLog.json', 'r') as f:
    security_data = json.load(f)

SecurityLog = w3.eth.contract(abi=security_data['abi'], bytecode=security_data['bytecode'])

nonce = w3.eth.get_transaction_count(account.address)
print(f"   Nonce: {nonce}")

tx = SecurityLog.constructor().build_transaction({
    'chainId': 2026,
    'gas': 2000000,
    'gasPrice': w3.to_wei('5', 'gwei'),
    'nonce': nonce,
    'from': account.address
})

signed = w3.eth.account.sign_transaction(tx, private_key)
tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
print(f"   TX: {tx_hash.hex()}")

print("   ⏳ Waiting for confirmation...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)

if tx_receipt.status == 1:
    security_address = tx_receipt.contractAddress
    print(f"   ✅ SecurityLog deployed at: {security_address}")
else:
    print("   ❌ Deployment failed!")
    exit(1)

print()

# Deploy ForensicEvidence
print("📄 Deploying ForensicEvidence...")
with open('blockchain/build/ForensicEvidence.json', 'r') as f:
    evidence_data = json.load(f)

ForensicEvidence = w3.eth.contract(abi=evidence_data['abi'], bytecode=evidence_data['bytecode'])

nonce = w3.eth.get_transaction_count(account.address)
print(f"   Nonce: {nonce}")

tx = ForensicEvidence.constructor().build_transaction({
    'chainId': 2026,
    'gas': 2000000,
    'gasPrice': w3.to_wei('5', 'gwei'),
    'nonce': nonce,
    'from': account.address
})

signed = w3.eth.account.sign_transaction(tx, private_key)
tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
print(f"   TX: {tx_hash.hex()}")

print("   ⏳ Waiting for confirmation...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)

if tx_receipt.status == 1:
    evidence_address = tx_receipt.contractAddress
    print(f"   ✅ ForensicEvidence deployed at: {evidence_address}")
else:
    print("   ❌ Deployment failed!")
    exit(1)

print()

# Save addresses
addresses = {
    'SecurityLog': security_address,
    'ForensicEvidence': evidence_address,
    'deployer': account.address,
    'network': 'private',
    'chain_id': 2026
}

with open('blockchain/build/contract_addresses.json', 'w') as f:
    json.dump(addresses, f, indent=2)

print("💾 Addresses saved to blockchain/build/contract_addresses.json")
print()
print("="*60)
print("  ✅ DEPLOYMENT COMPLETE!")
print("="*60)
print()
print(f"SecurityLog:      {security_address}")
print(f"ForensicEvidence: {evidence_address}")
print(f"Deployer:         {account.address}")
print("="*60)
