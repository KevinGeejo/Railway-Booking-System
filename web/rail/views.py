from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse
from django.template import loader

from django.db import connection
from django.shortcuts import render, redirect

import rail.models
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
    try:
        del request.session['seattype']
    except:
        pass

    return render(request,
                  'rail/welcome.html',
                  {'user_name': user_name,
                   'user_id': user_id,
                   'user_stat': user_stat})


'''
订单界面
'''


def BookingTicket(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''
    tid = request.session.get('tid', '')
    starter = request.session.get('starter', '')
    date = request.session.get('departure_date', '')
    seattype = request.session.get('seattype', '')
    terminal = request.session['terminal']

    if request.method == 'POST':
        if not terminal:
            terminal = request.POST.get('terminal')
        request.session['terminal'] = terminal
        if not seattype:
            seattype = request.POST.get('seattype')
        # request.session['seattype'] = seattype

        if (
                not tid
                or not starter
                or not terminal
                or not date
                or not seattype
        ):
            error_msg = '抱歉, 该座无票或缺少信息, 请您检查后重新提交'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())

        new_ti = rail.models.Trainitems.objects.filter(
            ti_tid=tid, ti_arrivalstation=starter)[0]
        departuretime = new_ti.ti_departuretime

        oid = str(int(
            rail.models.Orders.objects.all().order_by(
                '-o_oid')[0].o_oid) + 1).zfill(15)

        # TODO: check 是否有余票
        flag_order = 0
        try:
            with connection.cursor() as c:
                for seattype in ['ssl', 'ssu', 'hsl',
                                 'hsm', 'hsu', 'sse', 'hse']:
                    c.execute('select remaining_ticket(%s, %s, %s);',
                              [tid,
                               date,
                               seattype])
                remainingsRaw = c.fetchall()
            q = []
            for r in remainingsRaw:
                q.append(r[0].lstrip('(').rstrip(')'))
            q1 = []
            for r in q:
                q1.append(r.split(','))
            q1.sort(key=takeSeq)
            remList = [[int(s[0]), int(s[2])] for s in q1]
            for rem in remList:
                if rem[0] == new_ti.ti_seq:
                    if rem[1] > 0:
                        flag_order = 1

        except:
            pass

        if flag_order:
            try:
                with connection.cursor() as c:
                    c.execute(
                        '''
                        insert into orders values(
                        %s,%s,%s,%s,%s,%s,%s,%s,%s);
                        ''',
                        [
                            oid,
                            user_id,
                            tid,
                            date,
                            departuretime,
                            seattype,
                            'valid',
                            starter,
                            terminal
                        ]
                    )
                error_msg = '订票成功!'
                return render(request,
                              'rail/BookingTicket.html',
                              locals())
            except:
                error_msg = '订票失败!'
                return render(request,
                              'rail/BookingTicket.html',
                              locals())
        else:
            error_msg = '订票失败! 似乎没有票了!'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())
    return render(request,
                  'rail/BookingTicket.html',
                  locals())


'''
TODO: 
需求4: 车次信息查询
'''


def takeSeq(elem):
    return int(elem[0])


def AskTid(request):
    try:
        del request.session['seattype']
    except:
        pass
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''
    tid_info, starter, terminal, mids = [], [], [], []

    new_question = request.session.get('new_question', default=True)

    try:
        input_tid = request.GET.get('tid')
        departure_date = request.GET.get('departure_date')
        request.session['departure_date'] = departure_date
    except:
        return render(request,
                      'rail/AskTid.html',
                      locals(),
                      )

    request.session['tid'] = str(input_tid)

    if not input_tid:
        if not new_question:
            error_msg = '抱歉, 查询输入不成功, 请重试'
    else:
        # ORM method
        tid_info = list(
            Trainitems.objects.filter(
                ti_tid=input_tid
            ).order_by('ti_seq'))
        try:
            starter = tid_info[0]
            request.session['starter'] = str(starter.ti_arrivalstation)
        except:
            pass

        try:
            terminal = tid_info[-1]
            request.session['terminal'] = str(terminal.ti_arrivalstation)
        except:
            pass

        try:
            mids = tid_info[1:-2]
        except:
            pass

        try:
            with connection.cursor() as c:
                for seattype in ['ssl', 'ssu', 'hsl',
                                 'hsm', 'hsu', 'sse', 'hse']:
                    c.execute('select remaining_ticket(%s, %s, %s);',
                              [input_tid,
                               departure_date,
                               seattype])
                remainingsRaw = c.fetchall()
            q = []
            for r in remainingsRaw:
                q.append(r[0].lstrip('(').rstrip(')'))

            q1 = []
            for r in q:
                q1.append(r.split(','))

            q1.sort(key=takeSeq)

            remList = [[int(s[0]), int(s[2])] for s in q1]
            lastList = remList[-1]

        except:
            pass

    return render(request,
                  'rail/AskTid.html',
                  locals(),
                  )


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
