-- DEMAND 1: record train information
insert into
    trainstaticinfo
values();

insert into
    trainitems
values();



-- DEMAND 3: record user information
insert into
    users
values();



-- DEMAND 4: query trainitem (given tid)
-- static info
select
    tsi_startstation,
    ti_arrivalstation,
    ti_arrivaltime,
    ti_departuretime,
    ti_hseprice,
    ti_sseprice,
    ti_hsuprice,
    ti_hsmprice,
    ti_hslprice,
    ti_ssuprice,
    ti_sslprice
from
    trainstaticinfo as Info,
    trainitems as Items
where
    Info.tsi_tid = Items.ti_tid
    and Info.tsi_tid = :1
order by
    ti_seq;

-- 修改后
select
    ti_seq,
    ti_arrivalstation,
    ti_arrivaltime,
    ti_departuretime,
    ti_hseprice,
    ti_sseprice,
    ti_hsuprice,
    ti_hsmprice,
    ti_hslprice,
    ti_ssuprice,
    ti_sslprice
from
    trainitems
where
    ti_tid = :1
order by
    ti_seq;


-- dynamic info

-- 修改后
select
    ssl.ti_seq,
    sslp.Remaining,
    ssu.Remaining,
    hsl.Remaining,
    hsm.Remaining,
    hsu.Remaining,
    sse.Remaining,
    hse.Remaining
from (
    select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'ssl'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as sslp,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'ssu'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as ssu,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hsl'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hsl,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hsm'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hsm,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hsu'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hsu,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'sse'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as sse,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hse'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hse;



-- DEMAND 5: query trainitem(given start and terminal)
-- nonstop
    -- static info
-- 修改后
select
    T1.ti_tid,
    case
        when T1.ti_seq < T2.ti_seq then T1.ti_seq
        when T1.ti_seq > T2.ti_seq then T2.ti_seq
        else T1.ti_seq end as start_seq,
    case
        when T1.ti_seq > T2.ti_seq then T1.ti_seq
        when T1.ti_seq < T2.ti_seq then T2.ti_seq
        else T1.ti_seq end as terminal_seq,
    abs(T1.ti_hseprice - T2.ti_hseprice) as hse,
    abs(T1.ti_sseprice - T2.ti_sseprice) as sse,
    abs(T1.ti_hsuprice - T2.ti_hsuprice) as hsu,
	abs(T1.ti_hsmprice - T2.ti_hsmprice) as hsm,
    abs(T1.ti_hslprice - T2.ti_hslprice) as hsl,
	abs(T1.ti_ssuprice - T2.ti_ssuprice) as ssu,
	abs(T1.ti_sslprice - T2.ti_sslprice) as sslp
into
    backup_tid
from
    trainitems as T1,
    trainitems as T2,
    stations as S1,
    stations as S2
where T1.ti_tid = T2.ti_tid
  and S1.s_stationname = T1.ti_arrivalstation
  and S2.s_stationname = T2.ti_arrivalstation
  and S1.s_city = :1
  and S2.s_city = :2;

-- how [a,b] intersect [c,d] = kong
-- 这边之后考虑写个循环弄出来
select
    o_tid,
    5 - count(*) as Remaining
from
    orders,
    (
    select
        ti_tid,
        ti_arrivalstation,
        ti_seq
    from
        trainitems
    )as Seq1,
    (
    select
        ti_tid,
        ti_arrivalstation,
        ti_seq
    from
        trainitems
    )as Seq2
where
    o_tid = Seq1.ti_tid
    and o_departurestation = Seq1.ti_arrivalstation
    and o_tid = Seq2.ti_tid
    and o_arrivalstation = Seq2.ti_arrivalstation
    and o_seattype = :1
    and o_tid in (
            select
                ti_tid
            from
                backup_tid
            )
    and ((Seq1.ti_seq >= (
            select
                start_seq
            from backup_tid
            where
                ti_tid = o_tid
            )
            and Seq1.ti_seq < (
            select
                terminal_seq
            from backup_tid
            where
                ti_tid = o_tid
            )
            )
        or (Seq2.ti_seq > (
            select
                start_seq
            from backup_tid
            where
                ti_tid = o_tid
            )
            and Seq2.ti_seq <= (
            select
                terminal_seq
            from backup_tid
            where
                ti_tid = o_tid
            )
            )
        )
group by o_tid;

--问题是怎么导出ti_tid,现在假设这个导出的表叫做avail_tid,它的属性有tid和所有票的价格
(select T1.ti_tid,
        abs(T1.ti_hseprice - T2.ti_hseprice) as hse,
        abs(T1.ti_sseprice - T2.ti_sseprice) as sse,
        abs(T1.ti_hsuprice - T2.ti_hsuprice) as hsu,
	    abs(T1.ti_hsmprice - T2.ti_hsmprice) as hsm,
        abs(T1.ti_hslprice - T2.ti_hslprice) as hsl,
	    abs(T1.ti_ssuprice - T2.ti_ssuprice) as ssu,
	    abs(T1.ti_sslprice - T2.ti_sslprice) as sslp
from
    trainitems as T1,
    trainitems as T2,
    stations as S1,
    stations as S2
where T1.ti_tid = T2.ti_tid
  and S1.s_stationname = T1.ti_arrivalstation
  and S2.s_stationname = T2.ti_arrivalstation
  and S1.s_city = :1
  and S2.s_city = :2)
intersect
(select ti_tid,
        ti_hseprice,
        ti_sseprice,
        ti_hsuprice,
	    ti_hsmprice,
        ti_hslprice,
	    ti_ssuprice,
	    ti_sslprice
from
    trainitems,
    trainstaticinfo,
    stations as S1,
    stations as S2
where ti_tid = tsi_tid
  and S1.s_stationname = ti_arrivalstation
  and S2.s_stationname = tsi_startstation
  and S1.s_city = :1
  and S2.s_city = :2)

--dynamic info
select
    ssl.ti_seq,
    sslp.Remaining,
    ssu.Remaining,
    hsl.Remaining,
    hsm.Remaining,
    hsu.Remaining,
    sse.Remaining,
    hse.Remaining
from (
    select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as Seq1
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as Seq2
    where
        o_tid = Seq1.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'ssl'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as sslp,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'ssu'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as ssu,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hsl'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hsl,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hsm'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hsm,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hsu'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hsu,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'sse'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as sse,
    (select
        trainitem.ti_seq,
        5 - count(*) as Remaining
    from
        orders,
        (
        select
            ti_tid,
            ti_arrivalstation,
            ti_seq
        from
            trainitems
        )as seq
        (
        select
            ti_tid,
            ti_seq
        from
            trainitems
        )as trainitem
    where
        o_tid = seq.ti_tid
        and o_departurestation = seq.ti_arrivalstation
        and o_tid = trainitem.ti_tid
        and o_tid = :1
        and o_departuredate = :2
        and o_seattype = 'hse'
        and seq.ti_seq < trainitem.ti_seq
    group by trainitem.ti_seq
    order by trainitem.ti_seq
    )as hse;