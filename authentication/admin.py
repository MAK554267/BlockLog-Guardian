from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, UserActivity

class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'phone_number', 'is_verified', 'account_locked', 'created_at')
    list_filter = ('is_verified', 'account_locked', 'is_active', 'is_staff')
    search_fields = ('username', 'email', 'phone_number')
    
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {'fields': ('phone_number', 'is_verified', 'otp_secret', 'failed_login_attempts', 'account_locked', 'locked_until', 'two_factor_enabled')}),
    )

class UserActivityAdmin(admin.ModelAdmin):
    list_display = ('user', 'action', 'ip_address', 'created_at')
    list_filter = ('action', 'created_at')
    search_fields = ('user__username', 'ip_address')

admin.site.register(User, CustomUserAdmin)
admin.site.register(UserActivity, UserActivityAdmin)
