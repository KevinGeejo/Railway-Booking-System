from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse
from django.template import loader

from django.db import connection
from .models import Stations


def index(request):
    pass
    # return render(request, 'rail/welcome.html')
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    return render(request,
                  'rail/welcome.html',
                  {'user_name': user_name,
                   'user_id': user_id})


def findStationsInCity(request):
    pass
    return render(request, 'rail/findStationsInCity.html')


def findStationsInCityAnswer(request):
    input_city = request.GET.get('stations')
    error_msg = ''

    if not input_city:
        error_msg = '查询不成功!'
        return render(request,
                      'rail/errors.html',
                      {'error_msg': error_msg
                       })

    # ORM method
    # station_list = list(Stations.objects.filter(s_city=input_city).values(
    # 's_city', 's_stationname'))

    # raw sql
    # station_list = list(Stations.objects.raw(
    # "select s_stationname from stations where s_city=%s;", [input_city]))

    # using connect method
    station_list = []
    # print(input_city)
    with connection.cursor() as cursor:
        try:
            # cursor.execute(
            # "select s_stationname from stations where s_city= %s;",
            # [input_city])
            cursor.execute("select city_to_station(%s)", [input_city])
            station_list = cursor.fetchall()
        except Exception as e:
            cursor.close()

    station_list = [s[0] for s in station_list]
    return render(request,
                  'rail/findStationsInCityAnswer.html',
                  {
                      'error_msg': error_msg,
                      'ask_city': input_city,
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
