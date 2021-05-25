from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse
from django.template import loader

from django.db import connection
from .models import Stations


def index(request):
    pass
    return render(request, 'rail/welcome.html')


def findStationsInCity(request):
    pass
    return render(request, 'rail/findStationsInCity.html')


def findStationsInCityAnswer(request):
    q = request.GET.get('stations')
    error_msg = ''

    if not q:
        error_msg = '查询不成功!'
        return render(request,
                      'rail/errors.html',
                      {'error_msg': error_msg
                       })

    # orm method
    # station_list = list(Stations.objects.filter(s_city=q).values('s_city', 's_stationname'))

    # raw sql
    # station_list = list(Stations.objects.raw("select s_stationname from stations where s_city=%s;", [q]))

    # using connect

    station_list = []
    # print(q)
    cursor = connection.cursor()
    try:
        # cursor.execute("select s_stationname from stations where s_city= %s;", [q])
        cursor.execute("select city_to_station(%s)", [q])
        station_list = cursor.fetchall()
    except Exception as e:
        cursor.close()

    station_list = [s[0] for s in station_list]
    print(station_list)
    return render(request,
                  'rail/findStationsInCityAnswer.html',
                  {'error_msg': error_msg,
                   'station_list': station_list
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
