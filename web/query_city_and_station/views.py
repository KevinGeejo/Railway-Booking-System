from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse

def index(request):
    return HttpResponse("在这里, 你可以查询火车站与城市的对应关系.")