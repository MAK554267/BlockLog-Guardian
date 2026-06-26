import json
import os
from solcx import compile_standard, install_solc, set_solc_version

print("="*60)
print("  COMPILING SMART CONTRACTS")
print("="*60)
print()

# Install Solidity compiler
print("📦 Installing Solidity compiler v0.8.0...")
try:
    install_solc("0.8.0")
    set_solc_version("0.8.0")
    print("✅ Compiler installed successfully")
except Exception as e:
    print(f"⚠️  Error: {e}")
print()

def compile_contract(contract_file):
    """Compile a Solidity contract file"""
    with open(contract_file, 'r', encoding='utf-8') as file:
        contract_source = file.read()
    
    compiled_sol = compile_standard({
        "language": "Solidity",
        "sources": {
            contract_file: {
                "content": contract_source
            }
        },
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "evm.bytecode", "evm.sourceMap"]
                }
            }
        }
    }, solc_version="0.8.0")
    
    return compiled_sol

def save_compiled_contract(compiled_sol, contract_name, output_path):
    """Save compiled contract to file"""
    try:
        # Get the contract data
        contract_key = f'blockchain/contracts/{contract_name}.sol'
        contract_data = compiled_sol['contracts'][contract_key][contract_name]
        
        abi = contract_data['abi']
        bytecode = contract_data['evm']['bytecode']['object']
        
        # Save to file
        with open(f'{output_path}/{contract_name}.json', 'w') as f:
            json.dump({
                'abi': abi,
                'bytecode': bytecode
            }, f, indent=2)
        
        print(f"✅ Compiled {contract_name}")
        print(f"   Bytecode length: {len(bytecode)}")
        return True
    except Exception as e:
        print(f"❌ Failed to compile {contract_name}: {e}")
        return False

if __name__ == "__main__":
    project_root = os.getcwd()
    contract_files = ['SecurityLog', 'ForensicEvidence']
    output_path = 'blockchain/build'
    
    # Create output directory
    os.makedirs(output_path, exist_ok=True)
    
    # Check if contracts exist
    for contract_name in contract_files:
        contract_file = f'blockchain/contracts/{contract_name}.sol'
        if not os.path.exists(contract_file):
            print(f"❌ Contract file not found: {contract_file}")
            exit(1)
    
    print(f"📁 Output directory: {output_path}/")
    print()
    
    # Compile each contract
    for contract_name in contract_files:
        contract_file = f'blockchain/contracts/{contract_name}.sol'
        print(f"📄 Compiling {contract_name}...")
        try:
            compiled = compile_contract(contract_file)
            success = save_compiled_contract(compiled, contract_name, output_path)
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print()
    print("="*60)
    print("  COMPILATION COMPLETE")
    print("="*60)
    
    # List compiled files and verify
    print()
    print("📋 Compiled files:")
    for f in os.listdir(output_path):
        if f.endswith('.json'):
            file_path = os.path.join(output_path, f)
            size = os.path.getsize(file_path)
            print(f"   ✅ {f} ({size} bytes)")
            # Verify JSON is valid
            try:
                with open(file_path, 'r') as json_file:
                    data = json.load(json_file)
                    if 'abi' in data and 'bytecode' in data:
                        print(f"      ✅ Valid - ABI and bytecode present")
                    else:
                        print(f"      ⚠️  Missing ABI or bytecode")
            except:
                print(f"      ❌ Invalid JSON")
    
    print()
    print(f"📁 Location: {output_path}/")
