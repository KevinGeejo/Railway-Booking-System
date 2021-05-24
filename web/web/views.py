from django.http import HttpResponse


def index(request):
    return HttpResponse("这里是火车站")
