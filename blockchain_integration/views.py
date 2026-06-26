import json
import os
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from web3 import Web3
from eth_account import Account
from dotenv import load_dotenv
from authentication.models import User, UserActivity

load_dotenv()

class BlockchainService:
    def __init__(self):
        self.w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
        self.chain_id = 2026
        
        self.security_log_address = os.getenv('SECURITY_LOG_CONTRACT')
        self.forensic_evidence_address = os.getenv('FORENSIC_EVIDENCE_CONTRACT')
        
        self.private_key = os.getenv('DEPLOYER_PRIVATE_KEY')
        if self.private_key:
            self.account = Account.from_key(self.private_key)
            print(f"✅ Account: {self.account.address}")
        
        try:
            with open('blockchain/build/SecurityLog.json', 'r') as f:
                security_data = json.load(f)
            self.security_log = self.w3.eth.contract(
                address=self.security_log_address,
                abi=security_data['abi']
            )
        except Exception as e:
            print(f"❌ SecurityLog error: {e}")
            self.security_log = None
        
        try:
            with open('blockchain/build/ForensicEvidence.json', 'r') as f:
                evidence_data = json.load(f)
            self.forensic_evidence = self.w3.eth.contract(
                address=self.forensic_evidence_address,
                abi=evidence_data['abi']
            )
        except Exception as e:
            print(f"❌ ForensicEvidence error: {e}")
            self.forensic_evidence = None
    
    def get_status(self):
        if not self.w3.is_connected():
            return {'status': 'disconnected'}
        
        try:
            total_logs = self.security_log.functions.getTotalLogs().call() if self.security_log else 0
            total_evidence = self.forensic_evidence.functions.getEvidenceCount().call() if self.forensic_evidence else 0
            
            return {
                'status': 'connected',
                'chain_id': self.w3.eth.chain_id,
                'block_number': hex(self.w3.eth.block_number),
                'peer_count': hex(self.w3.net.peer_count),
                'contracts': {
                    'SecurityLog': {
                        'address': self.security_log_address,
                        'total_logs': total_logs
                    },
                    'ForensicEvidence': {
                        'address': self.forensic_evidence_address,
                        'total_evidence': total_evidence
                    }
                }
            }
        except Exception as e:
            return {'status': 'error', 'message': str(e)}
    
    def get_all_logs(self):
        if not self.security_log:
            return []
        
        try:
            total_logs = self.security_log.functions.getTotalLogs().call()
            logs = []
            
            for i in range(total_logs):
                try:
                    log = self.security_log.functions.getLog(i).call()
                    logs.append({
                        'index': i,
                        'timestamp': log[0],
                        'event_type': log[1],
                        'description': log[2],
                        'user_address': log[3],
                        'metadata': log[4],
                        'hash': log[5].hex() if isinstance(log[5], bytes) else log[5],
                        'verified': log[6]
                    })
                except Exception as e:
                    print(f"Error getting log {i}: {e}")
            
            return logs
        except Exception as e:
            print(f"Error getting logs: {e}")
            return []
    
    def add_security_log(self, event_type, description, user_address):
        if not self.private_key or not self.security_log or not self.account:
            return {'status': 'error', 'message': 'Service not properly initialized'}
        
        try:
            nonce = self.w3.eth.get_transaction_count(self.account.address)
            
            tx = self.security_log.functions.addLog(
                event_type,
                description,
                user_address,
                json.dumps({'source': 'django'})
            ).build_transaction({
                'chainId': self.chain_id,
                'gas': 300000,
                'gasPrice': self.w3.to_wei('10', 'gwei'),
                'nonce': nonce,
                'from': self.account.address
            })
            
            signed = self.w3.eth.account.sign_transaction(tx, self.private_key)
            tx_hash = self.w3.eth.send_raw_transaction(signed.raw_transaction)
            receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)
            
            if receipt.status == 1:
                return {
                    'status': 'success',
                    'tx_hash': tx_hash.hex(),
                    'block_number': hex(receipt.blockNumber),
                    'message': 'Log added to blockchain!'
                }
            else:
                return {'status': 'error', 'message': f'Transaction failed with status: {receipt.status}'}
                
        except Exception as e:
            return {'status': 'error', 'message': str(e)}
    
    def add_evidence(self, evidence_id, evidence_type, description, hash_value, collector):
        if not self.private_key or not self.forensic_evidence or not self.account:
            return {'status': 'error', 'message': 'Service not properly initialized'}
        
        try:
            nonce = self.w3.eth.get_transaction_count(self.account.address)
            
            tx = self.forensic_evidence.functions.addEvidence(
                evidence_id,
                evidence_type,
                description,
                hash_value,
                collector
            ).build_transaction({
                'chainId': self.chain_id,
                'gas': 300000,
                'gasPrice': self.w3.to_wei('10', 'gwei'),
                'nonce': nonce,
                'from': self.account.address
            })
            
            signed = self.w3.eth.account.sign_transaction(tx, self.private_key)
            tx_hash = self.w3.eth.send_raw_transaction(signed.raw_transaction)
            receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)
            
            if receipt.status == 1:
                return {
                    'status': 'success',
                    'tx_hash': tx_hash.hex(),
                    'block_number': hex(receipt.blockNumber),
                    'message': 'Evidence added to blockchain!'
                }
            else:
                return {'status': 'error', 'message': f'Transaction failed with status: {receipt.status}'}
                
        except Exception as e:
            return {'status': 'error', 'message': str(e)}
    
    def verify_chain(self):
        if not self.security_log:
            return {'status': 'error', 'message': 'Contract not loaded'}
        
        try:
            total_logs = self.security_log.functions.getTotalLogs().call()
            tampered = []
            
            for i in range(total_logs):
                is_valid = self.security_log.functions.verifyLogIntegrity(i).call()
                if not is_valid:
                    tampered.append(i)
            
            return {
                'status': 'success',
                'total_logs': total_logs,
                'tampered_blocks': tampered,
                'is_chain_intact': len(tampered) == 0
            }
        except Exception as e:
            return {'status': 'error', 'message': str(e)}

blockchain_service = BlockchainService()

# ============================================================
# API VIEWS
# ============================================================

def status_view(request):
    return JsonResponse(blockchain_service.get_status())

def logs_view(request):
    logs = blockchain_service.get_all_logs()
    return JsonResponse({'logs': logs, 'count': len(logs)})

@csrf_exempt
def add_log_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            result = blockchain_service.add_security_log(
                data.get('event_type', ''),
                data.get('description', ''),
                data.get('user_address', '')
            )
            return JsonResponse(result)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    return JsonResponse({'error': 'POST required'}, status=405)

@csrf_exempt
def add_evidence_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            result = blockchain_service.add_evidence(
                data.get('evidence_id', ''),
                data.get('evidence_type', ''),
                data.get('description', ''),
                data.get('hash', ''),
                data.get('collector', '')
            )
            return JsonResponse(result)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    return JsonResponse({'error': 'POST required'}, status=405)

def verify_chain_view(request):
    result = blockchain_service.verify_chain()
    return JsonResponse(result)

def get_all_evidence_view(request):
    if not blockchain_service.forensic_evidence:
        return JsonResponse({'error': 'Contract not loaded'}, status=500)
    
    try:
        count = blockchain_service.forensic_evidence.functions.getEvidenceCount().call()
        evidence_list = []
        
        for i in range(count):
            ev = blockchain_service.forensic_evidence.functions.getEvidence(i).call()
            evidence_list.append({
                'index': i,
                'timestamp': ev[0],
                'evidence_id': ev[1],
                'evidence_type': ev[2],
                'description': ev[3],
                'hash': ev[4],
                'collector': ev[5],
                'verified': ev[6]
            })
        
        return JsonResponse({'evidence': evidence_list, 'count': count})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
def admin_add_user_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            email = data.get('email')
            password = data.get('password')
            
            if not username or not email or not password:
                return JsonResponse({'error': 'Username, email and password required'}, status=400)
            
            if User.objects.filter(username=username).exists():
                return JsonResponse({'error': 'Username already exists'}, status=400)
            
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password
            )
            
            blockchain_service.add_security_log(
                'ADMIN_ACTION',
                f'Admin created user: {username}',
                '0x4e0A20b9e3D7FaC87743f76dBA08b4f8CdF55Dba'
            )
            
            return JsonResponse({
                'status': 'success',
                'message': f'User {username} created successfully',
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'email': user.email
                }
            })
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)
    
    return JsonResponse({'error': 'POST required'}, status=405)

def get_users_view(request):
    try:
        users = User.objects.all()
        data = []
        for user in users:
            data.append({
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'is_verified': user.is_verified,
                'created_at': user.created_at.isoformat() if user.created_at else None
            })
        return JsonResponse({'users': data})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def user_activities_view(request):
    """Get user activity logs"""
    try:
        activities = UserActivity.objects.all().order_by('-created_at')[:50]
        data = []
        for activity in activities:
            data.append({
                'id': activity.id,
                'user': activity.user.username if activity.user else 'Unknown',
                'action': activity.action,
                'ip_address': activity.ip_address,
                'timestamp': activity.created_at.isoformat()
            })
        return JsonResponse({'activities': data})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
