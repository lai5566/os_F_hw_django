from django.contrib import admin
from myapp import models
# Register your models here.


class UserProfileAdmin(admin.ModelAdmin):
    list_display=('userID','created')

admin.site.register(models.UserProfile,UserProfileAdmin)