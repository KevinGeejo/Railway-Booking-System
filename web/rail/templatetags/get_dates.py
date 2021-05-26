#!/usr/bin/python
# -*- coding: utf-8 -*-
# @Time    : 5/27/2021 3:23 AM
# @Author  : zheng
# @FileName: get_dates.py
# @Software: PyCharm

from django import template
import datetime

register = template.Library()


@register.filter()
def addDays(days):
    newDate = datetime.date.today() \
              + datetime.timedelta(days=days)
    return newDate


@register.simple_tag
def tomorrow(fmt):
    tmr = datetime.date.today() \
          + datetime.timedelta(days=1)
    return tmr.strftime(fmt)
