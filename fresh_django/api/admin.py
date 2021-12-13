from django.contrib import admin
from django.contrib.admin.sites import site
from .models import *
# Register your models here.
admin.site.register(Country)
admin.site.register(Role)
admin.site.register(Business)
admin.site.register(UserRoles)
admin,site.register()