import json
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
print(f"✅ Connected: {w3.is_connected()}")

# Load contract
with open('blockchain/build/contract_addresses.json', 'r') as f:
    addresses = json.load(f)

with open('blockchain/build/SecurityLog.json', 'r') as f:
    contract_data = json.load(f)

contract = w3.eth.contract(address=addresses['SecurityLog'], abi=contract_data['abi'])

try:
    owner = contract.functions.owner().call()
    print(f"✅ SecurityLog deployed at: {addresses['SecurityLog']}")
    print(f"✅ Owner: {owner}")
    print(f"✅ Total logs: {contract.functions.getTotalLogs().call()}")
except Exception as e:
    print(f"❌ Error: {e}")
