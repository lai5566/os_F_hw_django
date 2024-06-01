from django import forms
from .models import BloodPressureEntry

class BloodPressureEntryForm(forms.ModelForm):
    class Meta:
        model = BloodPressureEntry
        fields = ['subject', 'systolic', 'diastolic']
