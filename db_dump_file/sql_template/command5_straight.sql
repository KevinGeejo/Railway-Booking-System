--努力修改中--
create or replace function city_to_city_none_stop_total(start_city varchar(20),arrive_city varchar(20),input_time time, input_date date)
returns table(
     tid varchar(5),
     gap_time interval,
     sta_time time,
     arr_time time,
     sta_station varchar(20),
     arr_station varchar(20),
     pr_ssl float,
     pr_ssu float,
     pr_hsl float,
     pr_hsm float,
     pr_hsu float,
     pr_sse float,
     pr_hse float,
     ssl_r bigint,
     ssu_r bigint,
     hsl_r bigint,
     hsm_r bigint,
     hsu_r bigint,
     sse_r bigint,
     hse_r bigint,
	 no_use1 float,
     no_use2 float,
	 no_use3 float,
     no_use4 float,
	 no_use5 float,
     no_use6 float,
     no_use7 float,
     cheapest_price float
     )
as $$
begin
return query
select
    total.match_tid,
    total.time_gap,
    total.start_time,
    total.arrive_time,
    total.start_station,
    total.terminal_station,
    total.ssl,
    total.ssu,
    total.hsl,
    total.hsm,
    total.hsu,
    total.sse,
    total.hse,
    total.ssl_remain,
    total.ssu_remain,
    total.hsl_remain,
    total.hsm_remain,
    total.hsu_remain,
    total.sse_remain,
    total.hse_remain,
    get_price_processed(ssl_remain,ssl) as processed_ssl,
    get_price_processed(ssu_remain,ssu) as processed_ssu,
    get_price_processed(hsl_remain,hsl) as processed_hsl,
    get_price_processed(hsm_remain,hsm) as processed_hsm,
    get_price_processed(hsu_remain,hsu) as processed_hsu,
    get_price_processed(sse_remain,sse) as processed_sse,
    get_price_processed(hse_remain,hse) as processed_hse,
    get_cheapest_price(get_price_processed(ssl_remain,ssl),
                       get_price_processed(ssu_remain,ssu),
                        get_price_processed(hsl_remain,hsl),
                        get_price_processed(hsm_remain,hsm),
                        get_price_processed(hsu_remain,hsu),
                        get_price_processed(sse_remain,sse),
                        get_price_processed(hse_remain,hse)) as cheapest_price
from
     ((select
             match_tid,
             time_gap,
             start_time,
             arrive_time,
             start_station,
             terminal_station,
             ssl,
             ssu,
             hsl,
             hsm,
             hsu,
             sse,
             hse,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'ssl'))
              as ssl_remain,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'ssu'))
              as ssu_remain,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'hsl'))
              as hsl_remain,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'hsm'))
              as hsm_remain,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'hsu'))
              as hsu_remain,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'sse'))
              as sse_remain,
             (select remaining
              from
                  ctc_remaining_tickets(match_tid, start_seq, terminal_seq, input_date, 'hse'))
              as hse_remain
     from
        (select
            get_interval(start_dayoffset, arrival_dayoffset, start_time,arrive_time) as time_gap,
            start_time,
            arrive_time,
            match_tid,
            start_station,
            terminal_station,
            start_seq,
            terminal_seq,
            ssl,
            ssu,
            hsl,
            hsm,
            hsu,
            sse,
            hse
        from
            city_to_city(start_city,arrive_city,input_time))
        as static_info)
     )as total
order by cheapest_price,time_gap,start_time
limit 10;
end
$$
language plpgsql volatile;

select
       *
from
       city_to_city_none_stop_total('杭州','北京',time '00:00:00',date '2021-5-22') as total
where
       total.cheapest_price < 10000;


create function city_to_city(departure_city character varying, arrive_city character varying, departure_time time without time zone)
    returns TABLE(start_dayoffset integer, arrival_dayoffset integer, match_tid character varying, start_time time without time zone, arrive_time time without time zone, start_seq integer, start_station character varying, terminal_seq integer, terminal_station character varying, hse double precision, sse double precision, hsu double precision, hsm double precision, hsl double precision, ssu double precision, ssl double precision)
as
$$
begin
return query
select
    T1.ti_offsetday,
    T2.ti_offsetday,
    T1.ti_tid,
    T1.ti_departuretime as start_time,
    T2.ti_arrivaltime as arrive_time,
    T1.ti_seq as start_seq,
    T1.ti_arrivalstation as start_station,
    T2.ti_seq as terminal_seq,
    T2.ti_arrivalstation as terminal_station,
    (T2.ti_hseprice - T1.ti_hseprice) as hse,
    (T2.ti_sseprice - T1.ti_sseprice) as sse,
    (T2.ti_hsuprice - T1.ti_hsuprice) as hsu,
    (T2.ti_hsmprice - T1.ti_hsmprice) as hsm,
    (T2.ti_hslprice - T1.ti_hslprice) as hsl,
    (T2.ti_ssuprice - T1.ti_ssuprice) as ssu,
    (T2.ti_sslprice - T1.ti_sslprice) as ssl
from
    trainitems as T1,
    trainitems as T2,
    stations as S1,
    stations as S2
where T1.ti_tid = T2.ti_tid
    and S1.s_stationname = T1.ti_arrivalstation
    and S2.s_stationname = T2.ti_arrivalstation
    and S1.s_city = departure_city
    and S2.s_city = arrive_city
    and T2.ti_seq > T1.ti_seq
    and T1.ti_departuretime > departure_time;
end
$$ language plpgsql;


create or replace function get_interval(start_dayoffset integer,arrival_dayoffset integer,start_time time,arrive_time time)
returns interval
as $$
begin
    return ((date '2021-5-22' + arrival_dayoffset - start_dayoffset) + (arrive_time - start_time)) - date '2021-5-22';
END
$$ LANGUAGE plpgsql;


create or replace function ctc_remaining_tickets(match_tid character varying, start_seq integer, terminal_seq integer, departure_date date, seat_type seat_t)
    returns TABLE(
        match__tid character varying,
        remaining bigint)
as
$$
begin
return query
select
    total.match_tid,
    case
    when get_seat_type_not_have(total.match_tid, start_seq, seat_type) or get_seat_type_not_have(total.match_tid, terminal_seq, seat_type)
        then 0
    else total.Remaining
    end
from
    ((select
        match_tid,
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
        and o_tid = match_tid
        and is_date_consist_one_stop(o_departuredate,departure_date,match_tid, o_departurestation,start_seq)
        and o_seattype = seat_type
        and (
                (Seq1.ti_seq >= start_seq
                and
                Seq1.ti_seq < terminal_seq)
            or
                (Seq2.ti_seq > start_seq
                and
                Seq2.ti_seq <= terminal_seq)
            )
    group by match_tid)
    union
    (select
        match_tid,
        5 as Remaining
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
        and o_tid = match_tid
        and is_date_consist_one_stop(o_departuredate,departure_date,match_tid, o_departurestation,start_seq)
        and o_seattype = seat_type
        and (
                Seq1.ti_seq >= terminal_seq
            or
                Seq2.ti_seq <= start_seq
            )
    group by match_tid)
    union
    (select
        match_tid,
        5 as Remaining
    where
        match_tid not in (
                            select orders.o_tid
                            from orders
                            where
                                 is_date_consist_one_stop(o_departuredate,departure_date,match_tid, o_departurestation,start_seq)
                            and  o_seattype = seat_type
                        )
    group by match_tid)) as total;
end
$$ language plpgsql;


create or replace function get_seat_type_not_have(tid varchar(5), seq integer,seat_type seat_t) returns boolean
as $$
BEGIN
if seat_type = 'ssl' then
   return  (select
                ti_sslprice
            from
                (select
                    ti_sslprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_sslprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;

if seat_type = 'ssu' then
   return  (select
                ti_ssuprice
            from
                (select
                    ti_ssuprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_ssuprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;

if seat_type = 'hsl' then
   return  (select
                ti_hslprice
            from
                (select
                    ti_hslprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_hslprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;

if seat_type = 'hsm' then
   return  (select
                ti_hsmprice
            from
                (select
                    ti_hsmprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_hsmprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;

if seat_type = 'hsu' then
   return  (select
                ti_hsuprice
            from
                (select
                    ti_hsuprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_hsuprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;

if seat_type = 'sse' then
   return  (select
                ti_sseprice
            from
                (select
                    ti_sseprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_sseprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;

if seat_type = 'hse' then
   return  (select
                ti_hseprice
            from
                (select
                    ti_hseprice
                from
                    trainitems
                where
                    tid = trainitems.ti_tid
                    and seq = trainitems.ti_seq)
                as tmp
            where
                tmp.ti_hseprice = 0
                and seq != (
                        select
                            min(ti_seq)
                        from
                            trainitems
                         )
            ) IS not NULL;
end if;
END
$$ LANGUAGE plpgsql;



create function is_date_consist_one_stop(departure_date date, order_date date, tid character varying, departure_station character varying, start_seq integer) returns boolean
as
$$
begin
        return (select
                    tid
                from
                    (select
                        ti_tid,
                        ti_arrivalstation,
                        ti_offsetday
                    from
                        trainitems)
                    as train_station_day,
                    (select
                        ti_tid,
                        ti_seq,
                        ti_offsetday
                    from
                        trainitems)
                    as train_seq_day
                where
                    train_station_day.ti_tid = tid
                    and ti_arrivalstation = departure_station --
                    and train_seq_day.ti_tid = tid
                    and train_seq_day.ti_seq = start_seq --query -- order_date -- train_seq
                    and departure_date - order_date =  train_station_day.ti_offsetday - train_seq_day.ti_offsetday
                )is not null;
    end
$$
language plpgsql;


