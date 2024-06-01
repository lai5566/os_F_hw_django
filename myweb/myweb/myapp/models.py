from django.db import models
from django.utils.timezone import now

# Create your models here.

class UserProfile(models.Model):

    institutionID=models.TextField(default="-")
    userID=models.TextField(default="-")
    email=models.TextField(default="-")
    userpwd=models.TextField(default="-")
    
    created = models.DateTimeField(default=now)
    
    class Meta:
        db_table = "UserProfile"
    def _str_(self):
        return self.userID

from django.contrib.auth.models import User

class BloodPressureEntry(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    subject = models.CharField(max_length=100)
    systolic = models.IntegerField()
    diastolic = models.IntegerField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.subject} - {self.systolic}/{self.diastolic} at {self.timestamp}"