from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse
from django.template import loader

from .models import Stations


def index(request):
    pass
    return render(request, 'rail/welcome.html')


def findStationsInCity(request):
    pass
    return render(request, 'rail/findStationsInCity.html')


def findStationsInCityAnswer(request):
    q = request.GET.get('q')
    error_msg = ''

    if not q:
        error_msg = '查询不成功!'
        return render(request,
                      'rail/errors.html',
                      {'error_msg': error_msg
                       })

    station_list = Stations.objects.filter(s_city=q)
    return render(request,
                  'rail/findStationsInCityAnswer.html',
                  {'error_msg': error_msg,
                   'stationList': station_list
                   })


'''
-----------BELOW ARE TEST-----------
'''


def query_for_stations_in_city_static(request):
    answer_city_list = Stations.objects.filter(s_city="北京")

    # test: print stations
    # output = ', '.join([q.question_text for q in answer_city_list])
    # return HttpResponse(output)

    context = {'answer_city_list': answer_city_list}
    return render(request, 'rail/findStationsInCity.html', context)

# # 注意函数的参数
# def detail(request, question_id):
#     return HttpResponse("You're looking at question %s." % question_id)
#
# def results(request, question_id):
#     response = "You're looking at the results of question %s."
#     return HttpResponse(response % question_id)
#
# def vote(request, question_id):
#     return HttpResponse("You're voting on question %s." % question_id)

# 省略了那些没改动过的视图(detail, results, vote)
