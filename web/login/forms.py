#!/usr/bin/python
# -*- coding: utf-8 -*-
# @Time    : 5/26/2021 12:01 PM
# @Author  : zheng
# @FileName: forms.py
# @Software: PyCharm

from django.forms import ModelForm
from django import forms
from rail import models


class RegisterForm(forms.Form):
    u_idnumber = forms.CharField(max_length=18)
    u_name = forms.CharField(max_length=20)
    u_phone = forms.CharField(max_length=11)
    u_creditcard = forms.CharField(max_length=16)
    u_username = forms.CharField(max_length=20)


class UsersForm(ModelForm):
    class Meta:
        Model = models.Users
        fields = ['u_username',
                  'u_name',
                  'u_phone',
                  'u_creditcard',
                  'u_idnumber']
