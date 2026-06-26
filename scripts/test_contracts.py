import json
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
print(f"✅ Connected: {w3.is_connected()}\n")

# Load addresses
with open('blockchain/build/contract_addresses.json', 'r') as f:
    addresses = json.load(f)

print("="*60)
print("  TESTING CONTRACTS")
print("="*60)
print()

# Test SecurityLog
print("1. Testing SecurityLog...")
with open('blockchain/build/SecurityLog.json', 'r') as f:
    security_data = json.load(f)

security = w3.eth.contract(address=addresses['SecurityLog'], abi=security_data['abi'])
try:
    owner = security.functions.owner().call()
    total_logs = security.functions.getTotalLogs().call()
    print(f"   ✅ SecurityLog deployed at: {addresses['SecurityLog']}")
    print(f"      Owner: {owner}")
    print(f"      Total logs: {total_logs}")
except Exception as e:
    print(f"   ❌ Error: {e}")

print()

# Test ForensicEvidence
print("2. Testing ForensicEvidence...")
with open('blockchain/build/ForensicEvidence.json', 'r') as f:
    evidence_data = json.load(f)

evidence = w3.eth.contract(address=addresses['ForensicEvidence'], abi=evidence_data['abi'])
try:
    owner = evidence.functions.owner().call()
    count = evidence.functions.getEvidenceCount().call()
    print(f"   ✅ ForensicEvidence deployed at: {addresses['ForensicEvidence']}")
    print(f"      Owner: {owner}")
    print(f"      Evidence count: {count}")
except Exception as e:
    print(f"   ❌ Error: {e}")

print()
print("="*60)
print("  ✅ TEST COMPLETE")
print("="*60)
