from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse
from django.template import loader

from django.db import connection
from django.shortcuts import render, redirect
from .models import Users, Stations, Trainitems

'''
主页
'''


def index(request):
    if not request.session.get('user_stat', None):
        return redirect("/login/")

    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)

    request.session['new_question'] = True

    return render(request,
                  'rail/welcome.html',
                  {'user_name': user_name,
                   'user_id': user_id,
                   'user_stat': user_stat})


'''
需求4: 查询
'''


def AskTid(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''
    tid_info, starter, terminal, mids = [], [], [], []

    new_question = request.session.get('new_question', default=True)

    try:
        input_tid = request.GET.get('tid')
    except:
        return render(request,
                      'rail/AskTid.html',
                      {
                          'error_msg': '',
                          'user_name': user_name,
                          'user_id': user_id,
                          'user_stat': user_stat,
                      })

    if not input_tid:
        if not new_question:
            error_msg = '抱歉, 查询输入不成功, 请重试'
    else:
        # ORM method
        tid_info = list(
            Trainitems.objects.filter(
                ti_tid=input_tid
            ).order_by('ti_seq'))
        starter = tid_info[0]
        terminal = tid_info[len(tid_info) - 1]
        mids = tid_info[1:len(tid_info) - 2]

    return render(request,
                  'rail/AskTid.html',
                  {
                      'error_msg': error_msg,
                      'ask_tid': input_tid,
                      'starter': starter,
                      'terminal': terminal,
                      'tid_info': mids,
                      'user_name': user_name,
                      'user_id': user_id,
                      'user_stat': user_stat,
                  })


'''
(已通过) 测试: station-city查询
'''


def findStationsInCity(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''
    station_list = []

    new_question = request.session.get('new_question', default=True)

    try:
        input_city = request.GET.get('city')
    except:
        return render(request,
                      'rail/findStationsInCity.html',
                      {
                          'error_msg': '',
                          'user_name': user_name,
                          'user_id': user_id,
                          'user_stat': user_stat,
                      })

    if not input_city:
        if not new_question:
            error_msg = '抱歉, 查询输入不成功, 请重试'
    else:
        # using connect method
        with connection.cursor() as cursor:
            try:
                cursor.execute("select city_to_station(%s)",
                               [input_city])
                station_list = cursor.fetchall()
            except:
                cursor.close()

        station_list = [s[0] for s in station_list]
    return render(request,
                  'rail/findStationsInCity.html',
                  {
                      'error_msg': error_msg,
                      'ask_city': input_city,
                      'station_list': station_list,
                      'user_name': user_name,
                      'user_id': user_id,
                      'user_stat': user_stat,
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
