from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .forms import CustomUserCreationForm, CustomUserChangeForm
from .models import CustomUser

# Register your models here.

class CustomUserAdmin(UserAdmin):
    add_form = CustomUserCreationForm
    form = CustomUserChangeForm
    model = CustomUser
    # fields displayed
    list_display = [
        "email",
        "username",
        "age",
        "is_staff"
    ]
    # fields used when editing/updating a new user
    fieldsets = UserAdmin.fieldsets + ((None, {"fields": ("age",)}),)

    # fields used when creating a new user
    add_fieldsets = UserAdmin.add_fieldsets+ ((None, {"fields": ("age",)}),)


admin.site.register(CustomUser, CustomUserAdmin)