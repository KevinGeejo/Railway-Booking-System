from django.shortcuts import render

# Create your views here.

from django.http import HttpResponse
from django.template import loader

from django.db import connection
from django.shortcuts import render, redirect

import datetime

import rail.models
from .models import Stations, Trainitems

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
    request.session['tid'] = ''
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
需求6: 翻转需求 5 的双城
'''

#
# def reverseBooking(request):
#     date = request.session.get('date', '')
#     if date :
#         request.session['date'] = date
#     time = "00:00:00"
#
#     a = request.session.get('starterCity', '')
#     b = request.session.get('terminalCity', '')
#
#     terminalCity = request.session.get('starterCity', '')
#     starterCity = request.session.get('terminalCity', '')
#     if terminalCity:
#         request.session['terminalCity']=terminalCity
#
#     if starterCity:
#         request.session['starterCity']:starterCity
#     return render(request,
#                   'rail/AskCities.html',
#                   locals())


'''
需求 5: A to B
'''


def AskCities(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''

    # new_question = request.session.get('new_question', default='False')

    if request.method == 'POST':
        terminalCity = request.POST.get('terminalCity')
        if not terminalCity:
            terminalCity = request.session.get('terminalCity', '')
        else:
            request.session['terminalCity'] = terminalCity

        starterCity = request.POST.get('starterCity', '')
        if not starterCity:
            starterCity = request.session.get('starterCity')
        else:
            request.session['starterCity'] = starterCity

        date = request.POST.get('date', '')
        if not date:
            date = request.session.get('date')
        else:
            request.session['date'] = date

        time = request.POST.get('time', '')
        if not time:
            time = request.session.get('time')
        else:
            request.session['time'] = time

        askCity = request.POST.get('askCity')
        if not askCity:
            askCity = request.session['askCity'] if request.session['askCity'] else '0'
        else:
            request.session['askCity'] = askCity

        if askCity == '1':
            tmp = starterCity
            starterCity = terminalCity
            terminalCity = tmp
        print(starterCity, terminalCity)

        # TODO: 查找nonstop
        try:
            with connection.cursor() as c0:
                c0.execute(
                    """
                    select *
                    from
                        city_to_city_none_stop_total(%s,%s,%s,%s)
                        as total
                    where
                        total.cheapest_price < 10000
                    """
                    , [starterCity, terminalCity, time, date]
                )
                f0 = c0.fetchall()
        except:
            pass

        # TODO: 查找onestop
        try:
            with connection.cursor() as c1:
                c1.execute(
                    """
                    select *
                    from
                        city_to_city_one_stop_total(%s,%s,%s,%s)
                        as total
                    where
                        total.ctc_cheapest_price < 10000
                    """,
                    [starterCity, terminalCity, time, date]
                )
                f1 = c1.fetchall()
        except:
            pass

    return render(request,
                  'rail/AskCities.html',
                  locals())


'''
需求 9: 管理员
'''


def findNum(elem):
    return elem[1]


def AdminPage(request):
    # 1. 总订单数
    order_number = rail.models.Orders.objects.count()
    # 2. 总金额
    try:
        with connection.cursor() as c:
            c.execute("select check_total_price();")
            f = c.fetchall()
            cost = float(f[0][0])
    except:
        cost = 0

    # 3. 热点车次 Top 10
    hot_list = list(rail.models.Orders.objects.all().values('o_tid'))
    tidList = []
    for hot in hot_list:
        tidList.append(hot['o_tid'])
    hots = []
    for item in list(set(tidList)):
        hots.append([item, tidList.count(item)])
    hots.sort(key=findNum, reverse=True)
    if len(hots) > 10:
        true_hot = hots[0:9]
    else:
        true_hot = hots
    # 4. 注册用户列表
    userList = list(rail.models.Users.objects.all())
    # 5. 所有用户的订单
    user_order_dict = {}
    for user in userList:
        userId = user.u_idnumber
        user_order_dict[user] = list(
            rail.models.Orders.objects.filter(
                o_idnumber=userId))
    print(user_order_dict)

    # 结束
    return render(request,
                  'rail/AdminPage.html',
                  locals())


'''
需求 8: 管理订单
'''


def SeeOrderCosts(orderList, seattype):
    p1 = orderList
    p2 = [a[0] for a in p1]
    p3 = [a.strip(')').strip('(') for a in p2]
    p4 = [a.split(',') for a in p3]
    p5 = [[float(b) for b in a] for a in p4]
    # print(p5)
    costList = 0
    for order in p5:
        if seattype == 'hse':
            costList = order[0]
        elif seattype == 'sse':
            costList = order[1]
        elif seattype == 'hsu':
            costList = order[2]
        elif seattype == 'hsm':
            costList = order[3]
        elif seattype == 'hsl':
            costList = order[4]
        elif seattype == 'ssu':
            costList = order[5]
        elif seattype == 'ssl':
            costList = order[6]
        else:
            costList = 0
    return costList


def CancelMyOrders(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)

    if request.method == 'POST':
        date = request.POST.get('date', '')
        if not date:
            date = request.session.get('date')
        else:
            request.session['date'] = date
        cancel_oid = request.POST.get('cancel', default='')
        # print(cancel_oid)
        try:
            order_cc = rail.models.Orders.objects.get(
                o_oid=cancel_oid)
            if order_cc:
                print(order_cc)
                order_cc.o_orderstatus = 'cancelled'
                order_cc.save()
                msg = '取消成功!'
                if date:
                    orderList = list(rail.models.Orders.objects.filter(
                        o_idnumber=user_id, o_departuredate__gte=date
                    ).values('o_oid', 'o_tid',
                             'o_departuredate',
                             'o_departuretime',
                             'o_departurestation', 'o_seattype',
                             'o_arrivalstation', 'o_orderstatus',
                             ))
                return render(request,
                              'rail/ShowMyOrders.html',
                              locals())
        except:
            pass
        if date:
            orderList = list(rail.models.Orders.objects.filter(
                o_idnumber=user_id, o_departuredate__gte=date
            ).values('o_oid', 'o_tid',
                     'o_departuredate',
                     'o_departuretime',
                     'o_departurestation', 'o_seattype',
                     'o_arrivalstation', 'o_orderstatus',
                     ))
    msg = 'Maybe flaw here...'
    return render(request,
                  'rail/ShowMyOrders.html',
                  locals())


def ShowMyOrders(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)

    date = request.POST.get('date', '')
    if not date:
        date = request.session.get('date')
    else:
        request.session['date'] = date

    if not date:
        return render(request,
                      'rail/ShowMyOrders.html',
                      locals())

    # order_list: 订单号，日期、出发到达站、订单状态（是否已经取消）
    orderList = list(rail.models.Orders.objects.filter(
        o_idnumber=user_id, o_departuredate__gte=date
    ).values('o_oid', 'o_tid',
             'o_departuredate',
             'o_departuretime',
             'o_departurestation', 'o_seattype',
             'o_arrivalstation', 'o_orderstatus',
             ))

    if not orderList:
        return render(request,
                      'rail/ShowMyOrders.html',
                      locals())
    else:
        for item in orderList:
            o_tid = item['o_tid']
            o_oid = item['o_oid']
            o_departurestation = item['o_departurestation']
            o_arrivalstation = item['o_arrivalstation']
            o_seattype = str(item['o_seattype'])
            o_orderstatus = item['o_orderstatus']
            cost = 0

            try:
                with connection.cursor() as c:
                    c.execute(
                        '''
                        select check_seat_price(%s,%s,%s);
                        ''',
                        [o_tid,
                         o_departurestation,
                         o_arrivalstation]
                    )
                    f = list(c.fetchall())
                    cost = SeeOrderCosts(f, o_seattype)
            except:
                pass

            item['o_cost'] = cost

    return render(request,
                  'rail/ShowMyOrders.html',
                  locals())


'''
通用工具人: 订单界面
'''


def BookingTicket(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''

    new_question = request.session.get('new_question', default='False')

    if request.method == 'POST':
        tid = request.POST.get('tid')
        if not tid:
            tid = request.session.get('tid', '')
        else:
            request.session['tid'] = tid

        terminal = request.POST.get('terminal')
        if not terminal:
            terminal = request.session.get('terminal', '')
        else:
            request.session['terminal'] = terminal

        seattype = request.POST.get('seattype', '')
        if not seattype:
            seattype = request.session.get('seattype')
        else:
            request.session['seattype'] = seattype

        date = request.POST.get('date', '')
        if not date:
            date = request.session.get('date')
        else:
            request.session['date'] = date

        starter = request.POST.get('starter', '')
        if not starter:
            starter = request.session.get('starter')
        else:
            request.session['starter'] = starter

        if (
                not tid
                or not starter
                or not terminal
                or not date
                or not seattype
        ):
            if not new_question:
                error_msg = '抱歉, 该座无票或缺少信息, 请您检查后重新提交'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())

        new_ti_start = rail.models.Trainitems.objects.filter(
            ti_tid=tid, ti_arrivalstation=starter)[0]

        new_ti_arrive = rail.models.Trainitems.objects.filter(
            ti_tid=tid, ti_arrivalstation=terminal)[0]

        departuretime = new_ti_start.ti_departuretime

        oid = str(int(
            rail.models.Orders.objects.all().order_by(
                '-o_oid')[0].o_oid) + 1).zfill(15)

        flag_order = 0
        try:
            with connection.cursor() as c:
                c.execute(
                    '''
                    select ctc_remaining_tickets(
                    %s, %s, %s, %s, %s);
                    '''
                    ,
                    [tid,
                     new_ti_start.ti_seq,
                     new_ti_arrive.ti_seq,
                     date,
                     seattype]
                )
                remRaw = c.fetchall()
            q = []
            for r in remRaw:
                q.append(r[0].lstrip('(').rstrip(')'))
            q1 = q[0].split(',')
            if int(q1[1]) > 0:
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
                error_msg = '订票成功! 请管理员喝一杯靓靓的 beer'
                return render(request,
                              'rail/BookingTicket.html',
                              locals())
            except:
                error_msg = '订票失败! 数据库正在饮茶, 请立刻通知管理员'
                return render(request,
                              'rail/BookingTicket.html',
                              locals())
        else:
            error_msg = '订票失败! 似乎没有票了!'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())
    error_msg = '订票失败! 请尝试再次订票'
    return render(request,
                  'rail/BookingTicket.html',
                  locals())


'''
需求 4 引入的工具人 * 2
'''


def takeSeq(elem):
    return int(elem[0])


def AskTidSeeRemain(rt_list):
    temp_list = []
    for rt_item in rt_list:
        q = []
        for r_item in rt_item:
            # res: ['13,北京南,0', ...]
            q.append(r_item[0].lstrip('(').rstrip(')'))

        q1 = []
        for r in q:
            # res: [['13','北京南','0'], ...]
            q1.append(r.split(','))

        # res: [['1','xxx','num'], ...]
        q1.sort(key=takeSeq)

        # res: [[1, num], ...]
        remList = [[int(s[0]), int(s[2])] for s in q1]
        temp_list.append(remList)

    ret_list = temp_list[0]
    for ret in ret_list:
        ret[1] = 0

    for i in range(1, len(ret_list), 1):
        ret_list[i][1] = sum([a[i][1] for a in temp_list])

    return ret_list


'''
(已验证) 需求4: 车次信息查询
'''


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

    input_tid = request.GET.get('tid')
    if input_tid:
        request.session['tid'] = input_tid
    else:
        input_tid = request.session['tid']

    date = request.GET.get('date')
    if date:
        request.session['date'] = date
    else:
        input_tid = request.session['tid']

    if not input_tid:
        if not new_question:
            error_msg = '抱歉, 查询输入获取失败, 请重试'

    else:
        # ORM method
        tid_info = list(
            Trainitems.objects.filter(
                ti_tid=input_tid
            ).order_by('ti_seq'))

        if not tid_info:
            error_msg = '抱歉, 查询输入获取结果为空, 请重试'
            return render(request,
                          'rail/AskTid.html',
                          locals(),
                          )

        starter = tid_info[0]
        request.session['starter'] = str(starter.ti_arrivalstation)

        terminal = tid_info[-1]
        request.session['terminal'] = str(terminal.ti_arrivalstation)
        mids = tid_info[1:-2]

        try:
            f = []
            with connection.cursor() as c:
                for seattype in ['ssl', 'ssu', 'hsl',
                                 'hsm', 'hsu', 'sse', 'hse']:
                    c.execute('select remaining_ticket(%s, %s, %s);',
                              [input_tid,
                               date,
                               seattype])
                    f.append(c.fetchall())

            remList = AskTidSeeRemain(f)
            lastList = remList[-1]
            # print(lastList)

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
