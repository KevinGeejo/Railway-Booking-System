#!/usr/bin/python
# -*- coding: utf-8 -*-
# @Time    : 5/6/2021 9:11 AM
# @Author  : zheng
# @FileName: mk_station.py
# @Software: PyCharm

path='../train-2016-10/all-stations.txt'
with open(path, 'r') as f:
    lines = f.readlines()
    ci=0
    for line in lines:
        count = 0
        for char in line:
            if char == ',':
                break
            else:
                count+=1
        line_t = line.lstrip(line[0:count-1])
        print(line_t)
        if ci > 2:
            break
        ci+=1