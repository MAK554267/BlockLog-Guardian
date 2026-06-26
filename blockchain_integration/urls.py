from django.urls import path
from . import views

urlpatterns = [
    path('status/', views.status_view, name='blockchain_status'),
    path('logs/', views.logs_view, name='blockchain_logs'),
    path('add-log/', views.add_log_view, name='add_log'),
    path('add-evidence/', views.add_evidence_view, name='add_evidence'),
    path('evidence/', views.get_all_evidence_view, name='get_evidence'),
    path('verify-chain/', views.verify_chain_view, name='verify_chain'),
    path('admin/add-user/', views.admin_add_user_view, name='admin_add_user'),
    path('admin/users/', views.get_users_view, name='get_users'),
    path('activities/', views.user_activities_view, name='user_activities'),
]
