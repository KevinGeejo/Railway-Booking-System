#!/usr/bin/python
# -*- coding: utf-8 -*-
# @Time    : 5/18/2021 10:19 AM
# @Author  : zheng
# @FileName: urls.py
# @Software: PyCharm

from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
]