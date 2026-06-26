from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def home(request):
    return JsonResponse({
        'message': '🛡️ BlockLog Guardian: Decentralized Blockchain Security System',
        'status': 'running',
        'version': '2.0',
        'network': {
            'chain_id': 2026,
            'nodes': 3,
            'rpc': 'http://localhost:8545'
        },
        'contracts': {
            'SecurityLog': '0xc00bE64D3f1049188a85cedCF07F909DA953590a',
            'ForensicEvidence': '0xd270bF3A111912910F405bAEBb9A09df494Ba2d0'
        },
        'endpoints': {
            'admin': '/admin/',
            'auth': '/api/auth/',
            'blockchain': '/api/blockchain/',
        }
    })

urlpatterns = [
    path('', home, name='home'),
    path('admin/', admin.site.urls),
    path('api/auth/', include('authentication.urls')),  # Add this line
    path('api/blockchain/', include('blockchain_integration.urls')),
]
