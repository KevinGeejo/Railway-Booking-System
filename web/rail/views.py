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
    request.session['new_order'] = True
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

需求 5: A to B
'''


def dictfetchall(cursor):
    # 将游标返回的结果保存到一个字典对象中
    desc = cursor.description
    return [
        dict(zip([col[0] for col in desc], row))
        for row in cursor.fetchall()
    ]


def AskCities(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''

    new_question = request.session['new_question']
    request.session['new_order'] = True

    try:
        del request.session['seattype']
    except:
        pass

    if request.method == 'POST':
        arrivalCity = request.POST.get('arrivalCity')
        if not arrivalCity:
            arrivalCity = request.session.get('arrivalCity', '')
        else:
            request.session['arrivalCity'] = arrivalCity

        departureCity = request.POST.get('departureCity', '')
        if not departureCity:
            departureCity = request.session.get('departureCity')
        else:
            request.session['departureCity'] = departureCity

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

        try:
            askCitySeq = request.POST.get('askCitySeq')
            request.session['askCitySeq'] = askCitySeq
        except:
            askCitySeq = "normal"

        if askCitySeq == "reverse":
            tmp = departureCity
            departureCity = arrivalCity
            arrivalCity = tmp
            current_date = datetime.datetime.strptime(date, '%Y-%m-%d')
            next_date = current_date + datetime.timedelta(days=1)
            date = next_date.strftime('%Y-%m-%d')
        # 查找直达方案
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
                    , [departureCity, arrivalCity, time, date]
                )
                fetch_tmp_0 = dictfetchall(c0)
                for f in fetch_tmp_0:
                    f['offset_day'] = f['gap_time'].days
        except:
            fetch_tmp_0 = {}

        # 查找中转方案
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
                    [departureCity, arrivalCity, time, date]
                )
                fetch_tmp_1 = dictfetchall(c1)
                for f in fetch_tmp_1:
                    f['offset_day_2'] = f['ctc_time_gap'].days
        except:
            fetch_tmp_1 = {}

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
    hot_list = list(
        rail.models.Orders.objects.all().values('o_tid'))
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
                o_idnumber=userId
            ).order_by(
                '-o_orderstatus',
                'o_departuredate', 'o_departuretime', 'o_oid'
            ))

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


# order_list: 订单号，日期、出发到达站、订单状态（是否已经取消）
def calcMyOrdersSingle(request, user_id, date):
    orderList = list(rail.models.Orders.objects.filter(
        o_idnumber=user_id, o_departuredate__gte=date
    ).order_by(
        '-o_orderstatus',
        'o_departuredate', 'o_departuretime', 'o_oid'
    ).values('o_oid', 'o_tid',
             'o_departuredate',
             'o_departuretime',
             'o_departurestation', 'o_seattype',
             'o_arrivalstation', 'o_orderstatus',
             ))

    if not orderList:
        orderList = []
    else:
        for item in orderList:
            o_tid = item['o_tid']
            o_departurestation = item['o_departurestation']
            o_arrivalstation = item['o_arrivalstation']
            o_seattype = str(item['o_seattype'])
            cost = 0

            try:
                with connection.cursor() as c:
                    c.execute("select check_seat_price(%s,%s,%s);",
                              [o_tid,
                               o_departurestation,
                               o_arrivalstation])
                    f = list(c.fetchall())
                    cost = SeeOrderCosts(f, o_seattype)
            except:
                pass

            item['o_cost'] = cost + 5 if cost else cost
            if o_seattype == 'hse':
                item['o_seattype_name'] = '硬座'
            elif o_seattype == 'sse':
                item['o_seattype_name'] = '软座'
            elif o_seattype == 'hsu':
                item['o_seattype_name'] = '硬卧(上)'
            elif o_seattype == 'hsm':
                item['o_seattype_name'] = '硬卧(中)'
            elif o_seattype == 'hsl':
                item['o_seattype_name'] = '硬卧(下)'
            elif o_seattype == 'ssu':
                item['o_seattype_name'] = '软卧(上)'
            elif o_seattype == 'ssl':
                item['o_seattype_name'] = '软卧(下)'
            else:
                item['o_seattype_name'] = '-'

    return orderList


def CancelMyOrders(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    print(request.POST)
    if request.method == 'POST':
        print("check 01")
        date = request.POST.get('date', '')
        if not date:
            try:
                date = request.session.get('date')
            except:
                date = datetime.date.today().strftime('%Y-%m-%d')
        request.session['date'] = date

        cancel_oid = request.POST.get('cancel', default='')
        print(cancel_oid)
        try:
            order_cc = rail.models.Orders.objects.get(
                o_oid=cancel_oid)
            if order_cc:
                order_cc.o_orderstatus = 'cancelled'
                order_cc.save()
                msg = '取消成功!'
        except:
            msg = '抱歉, 订单取消失败, 请联系管理员'

        if not date:
            date = datetime.date.today().strftime('%Y-%m-%d')

        orderList = calcMyOrdersSingle(request, user_id, date)

    return render(request,
                  'rail/ShowMyOrders.html',
                  locals())


def ShowMyOrders(request):
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)

    try:
        date = request.POST.get('date', '')
        orderList = calcMyOrdersSingle(request, user_id, date)
    except:
        date = request.session.get('date')
        orderList = []

    request.session['date'] = date

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
    pop_msg = ''

    new_order = request.session.get('new_order', default=False)

    if request.method == 'POST':
        tid = request.POST.get('tid')
        if not tid:
            tid = request.session.get('tid', '')
        else:
            request.session['tid'] = tid

        date = request.POST.get('date', '')
        if not date:
            date = request.session.get('date')
        else:
            request.session['date'] = date

        departure = request.POST.get('departure', '')
        if not departure:
            departure = request.session.get('departure')
        else:
            request.session['departure'] = departure

        arrival = request.POST.get('arrival')
        if not arrival:
            arrival = request.session.get('arrival', '')
        else:
            request.session['arrival'] = arrival

        seattype = request.POST.get('seattype', '')
        request.session['seattype'] = seattype
        if (
                not tid
                or not departure
                or not arrival
                or not date
                or not seattype
        ):
            if not new_order:
                pop_msg = '抱歉, 该座无票或缺少信息, 请您检查后重新提交'
            else:
                new_order = False
            return render(request,
                          'rail/BookingTicket.html',
                          locals())

        if not rail.models.Trainitems.objects.filter(ti_tid=tid):
            pop_msg = '不存在符合要求的车票, 请尝试再次订票'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())

        try:
            new_ti_start = rail.models.Trainitems.objects.filter(
                ti_tid=tid, ti_arrivalstation=departure)[0]
        except:
            pop_msg = '不存在符合要求的车票, 请检查您的输入'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())
        try:
            new_ti_arrive = rail.models.Trainitems.objects.filter(
                ti_tid=tid, ti_arrivalstation=arrival)[0]
        except:
            pop_msg = '不存在符合要求的车票, 请检查您的输入'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())

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
                remRawRes = dictfetchall(c)
            remRes = remRawRes[0]['ctc_remaining_tickets'].lstrip('(').rstrip(')').split(',')
            if int(remRes[1]) > 0:
                flag_order = 1

        except:
            pass

        oid = str(
            int(rail.models.Orders.objects.all().order_by('-o_oid')[0].o_oid) + 1).zfill(15)
        departuretime = new_ti_start.ti_departuretime
        if flag_order == 1:
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
                            departure,
                            arrival
                        ]
                    )
                pop_msg = '订票成功! 请管理员喝一杯靓靓的 beer'
                return render(request,
                              'rail/BookingTicket.html',
                              locals())
            except:
                pop_msg = '订票失败! 数据库正在饮茶, 请立刻通知管理员'
                return render(request,
                              'rail/BookingTicket.html',
                              locals())
        else:
            pop_msg = '该票种已售完, 请重新填写订单'
            return render(request,
                          'rail/BookingTicket.html',
                          locals())

    if not new_order:
        pop_msg = '订票失败! 请尝试再次订票'
    else:
        new_order = False
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
    user_name = request.session.get('user_name', default='')
    user_id = request.session.get('user_id', default='')
    user_stat = request.session.get('user_stat', default=False)
    error_msg = ''
    tid_info, departure, arrival, mids = [], [], [], []

    try:
        del request.session['seattype']
    except:
        pass

    new_question = request.session.get('new_question', default=True)
    request.session['new_order'] = True

    try:
        input_tid = request.GET.get('tid')
        request.session['tid'] = input_tid
    except:
        input_tid = request.session['tid']

    try:
        date = request.GET.get('date')
        request.session['date'] = date
    except:
        date = request.session['date']

    if not input_tid:
        if not new_question:
            error_msg = '抱歉, 查询输入失败, 请重试'
        else:
            new_question = False

    else:
        # ORM method
        tid_info = list(
            Trainitems.objects.filter(
                ti_tid=input_tid).order_by('ti_seq'))

        if not tid_info:
            error_msg = '抱歉, 查询结果为空, 请重试'
            return render(request,
                          'rail/AskTid.html',
                          locals(),
                          )

        departure = tid_info[0]
        request.session['departure'] = str(departure.ti_arrivalstation)

        arrival = tid_info[-1]
        request.session['arrival'] = str(arrival.ti_arrivalstation)
        mids = tid_info[1:-1]

        try:
            tmp_fetch = []
            with connection.cursor() as c:
                for seattype in ['ssl', 'ssu', 'hsl',
                                 'hsm', 'hsu', 'sse', 'hse']:
                    c.execute('select remaining_ticket(%s, %s, %s);',
                              [input_tid,
                               date,
                               seattype])
                    tmp_fetch.append(c.fetchall())

            remList = AskTidSeeRemain(tmp_fetch)
            lastList = remList[-1]

        except:
            remList = []
            lastList = []

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
            new_question = False
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
                  locals())
