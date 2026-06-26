import json
import os
from eth_account import Account

# Find the keystore file
keystore_dir = "blockchain/data/node1/keystore"
keystore_files = [f for f in os.listdir(keystore_dir) if f.startswith("UTC--")]

if not keystore_files:
    print("❌ No keystore files found!")
    exit(1)

keystore_path = os.path.join(keystore_dir, keystore_files[0])
print(f"📁 Found keystore: {keystore_path}")

# Read the password
password_file = "blockchain/password.txt"
with open(password_file, 'r') as f:
    password = f.read().strip()
print(f"🔑 Using password from: {password_file}")

# Read and decrypt the keystore
with open(keystore_path, 'r') as f:
    keystore = json.load(f)

try:
    # Decrypt the private key
    private_key = Account.decrypt(keystore, password)
    private_key_hex = "0x" + private_key.hex()
    
    # Verify the address matches
    account = Account.from_key(private_key)
    
    print("\n" + "="*50)
    print("✅ SUCCESS! Private Key Extracted")
    print("="*50)
    print(f"Private Key: {private_key_hex}")
    print(f"Address:     {account.address}")
    print("="*50)
    
    # Save to file (be careful with this!)
    output_file = "blockchain/private_key.txt"
    with open(output_file, 'w') as f:
        f.write(private_key_hex)
    print(f"\n💾 Private key saved to: {output_file}")
    print("⚠️  KEEP THIS FILE SAFE! Never share your private key.")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    print("\nPossible issues:")
    print("1. Wrong password - check blockchain/password.txt")
    print("2. Corrupted keystore file")
    print("3. Wrong keystore format")
