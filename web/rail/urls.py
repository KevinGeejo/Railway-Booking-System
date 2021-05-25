#!/usr/bin/python
# -*- coding: utf-8 -*-
# @Time    : 5/24/2021 7:39 PM
# @Author  : zheng
# @FileName: urls.py
# @Software: PyCharm

from django.urls import path

from . import views

urlpatterns = [
    # 例如: /polls/
    # path('', views.index, name='index'),

    # test
    path('', views.query_for_stations_in_city_test, name='query_for_stations_in_city_test'),

    # # 例如: /polls/
    # path('', views.index, name='index'),
    #
    # # 例如: /polls/5/
    # path('<int:question_id>/', views.detail, name='detail'),
    #
    # # 例如: /polls/5/results/
    # path('<int:question_id>/results/', views.results, name='results'),
    #
    # # 例如: /polls/5/vote/
    # path('<int:question_id>/vote/', views.vote, name='vote'),
]
