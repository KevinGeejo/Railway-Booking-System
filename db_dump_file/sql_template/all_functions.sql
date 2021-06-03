--
-- Name: check_seat_price(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.check_seat_price(input_tid character varying, departure_station character varying, arrive_station character varying) RETURNS TABLE(r_hse double precision, r_sse double precision, r_hsu double precision, r_hsm double precision, r_hsl double precision, r_ssu double precision, r_ssl double precision)
    LANGUAGE plpgsql
    AS $$
begin
return query
select
    (T2.ti_hseprice - T1.ti_hseprice) as hse,
    (T2.ti_sseprice - T1.ti_sseprice) as sse,
    (T2.ti_hsuprice - T1.ti_hsuprice) as hsu,
    (T2.ti_hsmprice - T1.ti_hsmprice) as hsm,
    (T2.ti_hslprice - T1.ti_hslprice) as hsl,
    (T2.ti_ssuprice - T1.ti_ssuprice) as ssu,
    (T2.ti_sslprice - T1.ti_sslprice) as ssl
from
    trainitems as T1,
    trainitems as T2
where T1.ti_tid = T2.ti_tid
    and T1.ti_arrivalstation = departure_station
    and T2.ti_arrivalstation = arrive_station
    and T1.ti_tid = input_tid;
end
$$;


ALTER FUNCTION public.check_seat_price(input_tid character varying, departure_station character varying, arrive_station character varying) OWNER TO dbms;

--
-- Name: check_total_price(); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.check_total_price() RETURNS TABLE(r_total_price double precision)
    LANGUAGE plpgsql
    AS $$
begin
return query
select
    (sum(
        case
    when o_seattype = 'ssl'
        then T2.ti_sslprice - T1.ti_sslprice
    when o_seattype = 'ssu'
        then T2.ti_ssuprice - T1.ti_ssuprice
    when o_seattype = 'hsl'
        then T2.ti_hslprice - T1.ti_hslprice
    when o_seattype = 'hsm'
        then T2.ti_hsmprice - T1.ti_hsmprice
    when o_seattype = 'hsu'
        then T2.ti_hsuprice - T1.ti_hsuprice
    when o_seattype = 'sse'
        then T2.ti_sseprice - T1.ti_sseprice
    when o_seattype = 'hse'
        then T2.ti_hseprice - T1.ti_hseprice
    end) + (count(*)::float) * 5) as total_price
from
    orders,
    trainitems as T1,
    trainitems as T2
where
    o_orderstatus != 'cancelled'
    and o_tid = T1.ti_tid
    and o_tid = T2.ti_tid
    and o_arrivalstation = T2.ti_arrivalstation
    and o_departurestation = T1.ti_arrivalstation;
end
$$;


ALTER FUNCTION public.check_total_price() OWNER TO dbms;

--
-- Name: city_to_city(character varying, character varying, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.city_to_city(departure_city character varying, arrive_city character varying, departure_time time without time zone) RETURNS TABLE(start_dayoffset integer, arrival_dayoffset integer, match_tid character varying, start_time time without time zone, arrive_time time without time zone, start_seq integer, start_station character varying, terminal_seq integer, terminal_station character varying, hse double precision, sse double precision, hsu double precision, hsm double precision, hsl double precision, ssu double precision, ssl double precision)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.city_to_city(departure_city character varying, arrive_city character varying, departure_time time without time zone) OWNER TO dbms;

--
-- Name: city_to_city_none_stop_total(character varying, character varying, time without time zone, date); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.city_to_city_none_stop_total(start_city character varying, arrive_city character varying, input_time time without time zone, input_date date) RETURNS TABLE(tid character varying, gap_time interval, sta_time time without time zone, arr_time time without time zone, sta_station character varying, arr_station character varying, pr_ssl double precision, pr_ssu double precision, pr_hsl double precision, pr_hsm double precision, pr_hsu double precision, pr_sse double precision, pr_hse double precision, ssl_r bigint, ssu_r bigint, hsl_r bigint, hsm_r bigint, hsu_r bigint, sse_r bigint, hse_r bigint, no_use1 double precision, no_use2 double precision, no_use3 double precision, no_use4 double precision, no_use5 double precision, no_use6 double precision, no_use7 double precision, cheapest_price double precision)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.city_to_city_none_stop_total(start_city character varying, arrive_city character varying, input_time time without time zone, input_date date) OWNER TO dbms;

--
-- Name: city_to_city_one_stop(character varying, character varying, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.city_to_city_one_stop(citystart character varying, cityto character varying, inputime time without time zone) RETURNS TABLE(func_tid1 character varying, func_start1_offset_day integer, func_arrive1_offset_day integer, func_start2_offset_day integer, func_arrive2_offset_day integer, func_t1start_time time without time zone, func_t1arrive_time time without time zone, func_t1start_seq integer, func_t1start_station character varying, func_t1arrive_seq integer, func_t1arrive_station character varying, func_hse1 double precision, func_sse1 double precision, func_hsu1 double precision, func_hsm1 double precision, func_hsl1 double precision, func_ssu1 double precision, func_ssl1 double precision, func_tid2 character varying, func_t2start_time time without time zone, func_t2arrive_time time without time zone, func_t2start_seq integer, func_t2start_station character varying, func_t2arrive_seq integer, func_t2arrive_station character varying, func_hse2 double precision, func_sse2 double precision, func_hsu2 double precision, func_hsm2 double precision, func_hsl2 double precision, func_ssu2 double precision, func_ssl2 double precision)
    LANGUAGE plpgsql
    AS $$
begin
return query
select
    T1start.ti_tid,
    T1start.ti_offsetday,
    T1arrive.ti_offsetday,
    T2start.ti_offsetday,
    T2arrive.ti_offsetday,
    T1start.ti_departuretime as T1start_time,
    T1arrive.ti_arrivaltime as T1arrive_time,
    T1start.ti_seq as T1start_seq,
    T1start.ti_arrivalstation as T1start_station,
    T1arrive.ti_seq as arrive_seq,
    T1arrive.ti_arrivalstation as T1arrive_station,
    (T1arrive.ti_hseprice - T1start.ti_hseprice) as hse,
    (T1arrive.ti_sseprice - T1start.ti_sseprice) as sse,
    (T1arrive.ti_hsuprice - T1start.ti_hsuprice) as hsu,
	(T1arrive.ti_hsmprice - T1start.ti_hsmprice) as hsm,
    (T1arrive.ti_hslprice - T1start.ti_hslprice) as hsl,
	(T1arrive.ti_ssuprice - T1start.ti_ssuprice) as ssu,
	(T1arrive.ti_sslprice - T1start.ti_sslprice) as sslp,
    T2start.ti_tid,
    T2start.ti_departuretime as T2start_time,
    T2arrive.ti_arrivaltime as T2arrive_time,
    T2start.ti_seq as T2start_seq,
    T2start.ti_arrivalstation as T2start_station,
    T2arrive.ti_seq as arrive_seq,
    T2arrive.ti_arrivalstation as T2arrive_station,
    (T2arrive.ti_hseprice - T2start.ti_hseprice) as hse,
    (T2arrive.ti_sseprice - T2start.ti_sseprice) as sse,
    (T2arrive.ti_hsuprice - T2start.ti_hsuprice) as hsu,
	(T2arrive.ti_hsmprice - T2start.ti_hsmprice) as hsm,
    (T2arrive.ti_hslprice - T2start.ti_hslprice) as hsl,
	(T2arrive.ti_ssuprice - T2start.ti_ssuprice) as ssu,
	(T2arrive.ti_sslprice - T2start.ti_sslprice) as sslp
from
    trainitems as T1start,
    trainitems as T1arrive,
    trainitems as T2start,
    trainitems as T2arrive,
    stations as S1s,
    stations as S1a,
    stations as S2s,
    stations as S2a
where
    S1s.s_stationname = T1start.ti_arrivalstation
    and S1a.s_stationname = T1arrive.ti_arrivalstation
    and S2s.s_stationname = T2start.ti_arrivalstation
    and S2a.s_stationname = T2arrive.ti_arrivalstation
    and S2a.s_stationname != S1a.s_stationname
    and S1s.s_city = cityStart
    and S2a.s_city = cityTo
    and T1start.ti_tid != T2start.ti_tid
    and T1start.ti_tid = T1arrive.ti_tid
    and T2start.ti_tid = T2arrive.ti_tid
    and S1a.s_city = S2s.s_city
    and T1arrive.ti_seq > T1start.ti_seq
    and T2arrive.ti_seq > T2start.ti_seq
    and T2start.ti_departuretime <=  T1arrive.ti_arrivaltime + interval '4 hour'
    and     (
            (T1arrive.ti_arrivalstation = T2start.ti_arrivalstation
            and T2start.ti_departuretime >= T1arrive.ti_arrivaltime + interval '1 hour')
        or
            (T1arrive.ti_arrivalstation != T2start.ti_arrivalstation
            and T2start.ti_departuretime >= T1arrive.ti_arrivaltime + interval '2 hour')
            )
    and T1start.ti_departuretime > inputime;
end
$$;


ALTER FUNCTION public.city_to_city_one_stop(citystart character varying, cityto character varying, inputime time without time zone) OWNER TO dbms;

--
-- Name: city_to_city_one_stop_total(character varying, character varying, time without time zone, date); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.city_to_city_one_stop_total(city_start character varying, city_to character varying, input_time time without time zone, input_date date) RETURNS TABLE(ctc_time_gap interval, ctc_t2_start_offsetday integer, ctc_t1_arrive_offsetday integer, ctc_t1_tid character varying, ctc_t2_tid character varying, ctc_t1_starttime time without time zone, ctc_t1_arrivetime time without time zone, ctc_t1_startstation character varying, ctc_t1_arrivestation character varying, ctc_t2_starttime time without time zone, ctc_t2_arrivetime time without time zone, ctc_t2_startstation character varying, ctc_t2_arrivestation character varying, ctc_ssl_1 double precision, ctc_ssu_1 double precision, ctc_hsl_1 double precision, ctc_hsm_1 double precision, ctc_hsu_1 double precision, ctc_sse_1 double precision, ctc_hse_1 double precision, ctc_ssl_2 double precision, ctc_ssu_2 double precision, ctc_hsl_2 double precision, ctc_hsm_2 double precision, ctc_hsu_2 double precision, ctc_sse_2 double precision, ctc_hse_2 double precision, ctc_ssl_remain1 bigint, ctc_ssu_remain1 bigint, ctc_hsl_remain1 bigint, ctc_hsm_remain1 bigint, ctc_hsu_remain1 bigint, ctc_sse_remain1 bigint, ctc_hse_remain1 bigint, ctc_ssl_remain2 bigint, ctc_ssu_remain2 bigint, ctc_hsl_remain2 bigint, ctc_hsm_remain2 bigint, ctc_hsu_remain2 bigint, ctc_sse_remain2 bigint, ctc_hse_remain2 bigint, ctc_processed_ssl double precision, ctc_processed_ssu double precision, ctc_processed_hsl double precision, ctc_processed_hsm double precision, ctc_processed_hsu double precision, ctc_processed_sse double precision, ctc_processed_hse double precision, ctc_cheapest_price double precision)
    LANGUAGE plpgsql
    AS $$
begin
    return query
select
    total.time_gap,
    total.t2_start_offsetday,
    total.t1_arrive_offsetday,
    total.T1_tid,
    total.T2_tid,
    T1_starttime,
    T1_arrivetime,
    T1_startstation,
    T1_arrivestation,
    T2_starttime,
    T2_arrivetime,
    T2_startstation,
    T2_arrivestation,
    total.ssl_1,
    total.ssu_1,
    total.hsl_1,
    total.hsm_1,
    total.hsu_1,
    total.sse_1,
    total.hse_1,
    total.ssl_2,
    total.ssu_2,
    total.hsl_2,
    total.hsm_2,
    total.hsu_2,
    total.sse_2,
    total.hse_2,
    total.ssl_remain1,
    total.ssu_remain1,
    total.hsl_remain1,
    total.hsm_remain1,
    total.hsu_remain1,
    total.sse_remain1,
    total.hse_remain1,
    total.ssl_remain2,
    total.ssu_remain2,
    total.hsl_remain2,
    total.hsm_remain2,
    total.hsu_remain2,
    total.sse_remain2,
    total.hse_remain2,
    get_2price_processed(ssl_remain1,ssl_remain2,ssl_1,ssl_2) as processed_ssl,
    get_2price_processed(ssu_remain1,ssu_remain2,ssu_1,ssu_2) as processed_ssu,
    get_2price_processed(hsl_remain1,hsl_remain2,hsl_1,hsl_2) as processed_hsl,
    get_2price_processed(hsm_remain1,hsm_remain2,hsm_1,hsm_2) as processed_hsm,
    get_2price_processed(hsu_remain1,hsu_remain2,hsu_1,hsu_2) as processed_hsu,
    get_2price_processed(sse_remain1,sse_remain2,sse_1,sse_2) as processed_sse,
    get_2price_processed(hse_remain1,hse_remain2,hse_1,hse_2) as processed_hse,
    get_cheapest_price(get_2price_processed(ssl_remain1,ssl_remain2,ssl_1,ssl_2) ,
                       get_2price_processed(ssu_remain1,ssu_remain2,ssu_1,ssu_2) ,
                        get_2price_processed(hsl_remain1,hsl_remain2,hsl_1,hsl_2) ,
                        get_2price_processed(hsm_remain1,hsm_remain2,hsm_1,hsm_2) ,
                        get_2price_processed(hsu_remain1,hsu_remain2,hsu_1,hsu_2) ,
                         get_2price_processed(sse_remain1,sse_remain2,sse_1,sse_2) ,
                        get_2price_processed(hse_remain1,hse_remain2,hse_1,hse_2)) as cheapest_price
from
     ((select
            time_gap,
            t2_start_offsetday,
            t1_arrive_offsetday,
            T1_tid,
            T2_tid,
            T1_starttime,
            T1_arrivetime,
            T1_startstation,
            T1_arrivestation,
            T2_starttime,
            T2_arrivetime,
            T2_startstation,
            T2_arrivestation,
            ssl_1,
            ssl_2,
            ssu_1,
            ssu_2,
            hsl_1,
            hsl_2,
            hsm_1,
            hsm_2,
            hsu_1,
            hsu_2,
            sse_1,
            sse_2,
            hse_1,
            hse_2,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'ssl'))
              as ssl_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'ssu'))
              as ssu_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'hsl'))
              as hsl_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'hsm'))
              as hsm_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'hsu'))
              as hsu_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'sse'))
              as sse_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T1_tid, T1start_seq, T1arrive_seq, input_date, 'hse'))
              as hse_remain1,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'ssl'))
              as ssl_remain2,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'ssu'))
              as ssu_remain2,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'hsl'))
              as hsl_remain2,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'hsm'))
              as hsm_remain2,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'hsu'))
              as hsu_remain2,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'sse'))
              as sse_remain2,
             (select remaining
              from
                  ctc_remaining_tickets(T2_tid, T2start_seq, T2arrive_seq, input_date + (func_arrive1_offset_day - func_start1_offset_day)+ cast(T1_arrivetime > T2_starttime as integer), 'hse'))
              as hse_remain2
    from
        (select
            get_2city_interval(func_start1_offset_day,
                              func_arrive1_offset_day,
                               func_start2_offset_day,
                              func_arrive2_offset_day,
                                    func_T1start_time,
                                    func_T1arrive_time,
                                              func_T2start_time,
                                              func_T2arrive_time
                                   ) as time_gap,
            get_item2_start_offset(func_start1_offset_day,
                                  func_arrive1_offset_day,
                                    func_T1arrive_time,
                                    func_T2start_time
                                )as t2_start_offsetday,
            (func_arrive1_offset_day - func_start1_offset_day) as t1_arrive_offsetday,
            func_start1_offset_day,
            func_arrive1_offset_day,
            func_tid1 as T1_tid,
            func_tid2 as T2_tid,
            func_T1start_time as T1_starttime,
            func_T1arrive_time as T1_arrivetime,
            func_T1start_station as T1_startstation,
            func_T1arrive_station as T1_arrivestation,
            func_T2start_time as T2_starttime,
            func_T2arrive_time as T2_arrivetime,
            func_T2start_station as T2_startstation,
            func_T2arrive_station as T2_arrivestation,
            func_T1start_seq as T1start_seq,
            func_T1arrive_seq as T1arrive_seq,
            func_T2start_seq as T2start_seq,
            func_T2arrive_seq as T2arrive_seq,
            func_ssl1 as ssl_1,
            func_ssl2 as ssl_2,
            func_ssu1 as ssu_1,
            func_ssu2 as ssu_2,
            func_hsl1 as hsl_1,
            func_hsl2 as hsl_2,
            func_hsm1 as hsm_1,
            func_hsm2 as hsm_2,
            func_hsu1 as hsu_1,
            func_hsu2 as hsu_2,
            func_sse1 as sse_1,
            func_sse2 as sse_2,
            func_hse1 as hse_1,
            func_hse2 as hse_2,
            get_cheapest_price(
                   get_processed_price(func_ssl1) + get_processed_price(func_ssl2),
                   get_processed_price(func_ssu1) + get_processed_price(func_ssu2),
                    get_processed_price(func_hsl1) + get_processed_price(func_hsl2),
                    get_processed_price(func_hsm1) + get_processed_price(func_hsm2),
                    get_processed_price(func_hsu1) + get_processed_price(func_hsu2),
                     get_processed_price(func_sse1) + get_processed_price(func_sse2),
                         get_processed_price(func_hse1) + get_processed_price(func_hse2)) as cheapest
        from
            city_to_city_one_stop(city_start,city_to,input_time)
        order by cheapest
        limit 100)
        as transfer_info)
    )as total
order by  cheapest_price, time_gap,T1_starttime
limit 10;
end
$$;


ALTER FUNCTION public.city_to_city_one_stop_total(city_start character varying, city_to character varying, input_time time without time zone, input_date date) OWNER TO dbms;

--
-- Name: city_to_station(character varying); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.city_to_station(city character varying) RETURNS TABLE(stationname character varying)
    LANGUAGE plpgsql
    AS $$
begin
return query
select
    s_stationname
from
    stations
where s_city=city;
end
$$;


ALTER FUNCTION public.city_to_station(city character varying) OWNER TO dbms;

--
-- Name: ctc_remaining_tickets(character varying, integer, integer, date, public.seat_t); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.ctc_remaining_tickets(match_tid character varying, start_seq integer, terminal_seq integer, departure_date date, seat_type public.seat_t) RETURNS TABLE(match__tid character varying, remaining bigint)
    LANGUAGE plpgsql
    AS $$
begin
if not exists(
    select
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
        and o_orderstatus = 'valid'
        and not(
            Seq1.ti_seq >= terminal_seq
            or
            Seq2.ti_seq <= start_seq)
    group by match_tid)
then
return query
select
    match_tid,
    case
    when get_seat_type_not_have(match_tid, start_seq, seat_type) or get_seat_type_not_have(match_tid, terminal_seq, seat_type)
        then 0::bigint
    else 5::bigint
    end;
else
return query
select
    total.match_tid,
    case
    when get_seat_type_not_have(total.match_tid, start_seq, seat_type) or get_seat_type_not_have(total.match_tid, terminal_seq, seat_type)
        then 0
    else total.Remaining end
from
    (select
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
        and o_orderstatus = 'valid'
        and not(
            Seq1.ti_seq >= terminal_seq
            or
            Seq2.ti_seq <= start_seq)
    group by match_tid) as total;
end if;
end
$$;


ALTER FUNCTION public.ctc_remaining_tickets(match_tid character varying, start_seq integer, terminal_seq integer, departure_date date, seat_type public.seat_t) OWNER TO dbms;

--
-- Name: get_2city_interval(integer, integer, integer, integer, time without time zone, time without time zone, time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_2city_interval(start1_day_offset integer, arrive1_day_offset integer, start2_day_offset integer, arrive2_day_offset integer, start1_time time without time zone, arrive1_time time without time zone, start2_time time without time zone, arrive2_time time without time zone) RETURNS interval
    LANGUAGE plpgsql
    AS $$
begin
    return (date '2021-5-22' + (arrive1_day_offset - start1_day_offset) + (arrive2_day_offset - start2_day_offset)) + (arrive1_time - start1_time) + (arrive2_time - start2_time) + get_wait_time(arrive1_time,start2_time) - date '2021-5-22';
END
$$;


ALTER FUNCTION public.get_2city_interval(start1_day_offset integer, arrive1_day_offset integer, start2_day_offset integer, arrive2_day_offset integer, start1_time time without time zone, arrive1_time time without time zone, start2_time time without time zone, arrive2_time time without time zone) OWNER TO dbms;

--
-- Name: get_2price_processed(bigint, bigint, double precision, double precision); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_2price_processed(remaining1 bigint, remaining2 bigint, seat_price1 double precision, seat_price2 double precision) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare
    price1 float;
    price2 float;
BEGIN
    price1 = get_price_processed(remaining1, seat_price1);
    price2 = get_price_processed(remaining2, seat_price2);
if(price1 + price2) >= 10000 then
    return 10000;
else
    return (price1 + price2);
end if;
END
$$;


ALTER FUNCTION public.get_2price_processed(remaining1 bigint, remaining2 bigint, seat_price1 double precision, seat_price2 double precision) OWNER TO dbms;

--
-- Name: get_cheapest_price(double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_cheapest_price(ssl double precision, ssu double precision, hsl double precision, hsm double precision, hsu double precision, sse double precision, hse double precision) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare
    min float;
BEGIN
if ssl < ssu
    then min = ssl;
else
    min = ssu;
end if;
if hsl < min
    then min = hsl;
end if;
if hsm < min
    then min = hsm;
end if;
if hsu < min
    then min = hsu;
end if;
if sse < min
    then min = hsl;
end if;
if hse < min
    then min = hse;
end if;
return min;
END
$$;


ALTER FUNCTION public.get_cheapest_price(ssl double precision, ssu double precision, hsl double precision, hsm double precision, hsu double precision, sse double precision, hse double precision) OWNER TO dbms;

--
-- Name: get_interval(integer, integer, time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_interval(start_dayoffset integer, arrival_dayoffset integer, start_time time without time zone, arrive_time time without time zone) RETURNS interval
    LANGUAGE plpgsql
    AS $$
begin
    return ((date '2021-5-22' + arrival_dayoffset - start_dayoffset) + (arrive_time - start_time)) - date '2021-5-22';
END
$$;


ALTER FUNCTION public.get_interval(start_dayoffset integer, arrival_dayoffset integer, start_time time without time zone, arrive_time time without time zone) OWNER TO dbms;

--
-- Name: get_item2_start_offset(integer, integer, time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_item2_start_offset(start1_day_offset integer, arrive1_day_offset integer, arrive1_time time without time zone, start2_time time without time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    return (arrive1_day_offset - start1_day_offset) + cast(arrive1_time > start2_time as integer);
END
$$;


ALTER FUNCTION public.get_item2_start_offset(start1_day_offset integer, arrive1_day_offset integer, arrive1_time time without time zone, start2_time time without time zone) OWNER TO dbms;

--
-- Name: get_price_processed(bigint, double precision); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_price_processed(remaining_ticket_num bigint, seat_price double precision) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
BEGIN
if remaining_ticket_num >= 1 then
    if seat_price <= 0
        then return 10000;
    elseif seat_price > 0
        then return seat_price;
    end if;
else
    return 10000;
end if;
END
$$;


ALTER FUNCTION public.get_price_processed(remaining_ticket_num bigint, seat_price double precision) OWNER TO dbms;

--
-- Name: get_processed_price(double precision); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_processed_price(number double precision) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
BEGIN
if number <= 0
    then return 10000;
else
    return number;
end if;
END
$$;


ALTER FUNCTION public.get_processed_price(number double precision) OWNER TO dbms;

--
-- Name: get_seat_type_not_have(character varying, integer, public.seat_t); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_seat_type_not_have(tid character varying, seq integer, seat_type public.seat_t) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.get_seat_type_not_have(tid character varying, seq integer, seat_type public.seat_t) OWNER TO dbms;

--
-- Name: get_shortest_time(integer, integer, time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_shortest_time(start_dayoffset integer, arrival_dayoffset integer, start_time time without time zone, arrive_time time without time zone) RETURNS time without time zone
    LANGUAGE plpgsql
    AS $$
begin

END
$$;


ALTER FUNCTION public.get_shortest_time(start_dayoffset integer, arrival_dayoffset integer, start_time time without time zone, arrive_time time without time zone) OWNER TO dbms;

--
-- Name: get_wait_time(time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.get_wait_time(arrive_time_station1 time without time zone, start_time_station2 time without time zone) RETURNS interval
    LANGUAGE plpgsql
    AS $$
begin
    if (start_time_station2-arrive_time_station1) > interval '0' then
       return (start_time_station2 - arrive_time_station1);
    end if;
    if (start_time_station2-arrive_time_station1) < interval '0' then
        return (start_time_station2-arrive_time_station1)+(time '24:00:00'-time '00:00:00');
    end if;
end
$$;


ALTER FUNCTION public.get_wait_time(arrive_time_station1 time without time zone, start_time_station2 time without time zone) OWNER TO dbms;

--
-- Name: is_date_consist(date, date, character varying, character varying); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.is_date_consist(departure_date date, order_date date, tid character varying, departure_station character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
        return (select ti_offsetday from trainitems
        where   ti_tid = tid
            and ti_arrivalstation = departure_station
            and ti_offsetday = departure_date - order_date
               )is not null;
    end
$$;


ALTER FUNCTION public.is_date_consist(departure_date date, order_date date, tid character varying, departure_station character varying) OWNER TO dbms;

--
-- Name: is_date_consist_one_stop(date, date, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.is_date_consist_one_stop(departure_date date, order_date date, tid character varying, departure_station character varying, start_seq integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.is_date_consist_one_stop(departure_date date, order_date date, tid character varying, departure_station character varying, start_seq integer) OWNER TO dbms;

--
-- Name: remaining_ticket(character varying, date, public.seat_t); Type: FUNCTION; Schema: public; Owner: dbms
--

CREATE FUNCTION public.remaining_ticket(tid character varying, order_date date, seat_type public.seat_t) RETURNS TABLE(seq integer, arrival_station character varying, remaining bigint)
    LANGUAGE plpgsql
    AS $$
begin
return query
(select
    trainitem.ti_seq,
    trainitem.ti_arrivalstation,
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
    )as seq,
    (
    select
        ti_tid,
        ti_arrivalstation,
        ti_seq
    from
        trainitems
    )as trainitem
where
    o_tid = seq.ti_tid
    and o_departurestation = seq.ti_arrivalstation
    and o_tid = trainitem.ti_tid
    and trainitem.ti_tid = tid
    and is_date_consist(o_departuredate, order_date, o_tid, o_departurestation)
    and o_seattype = seat_type
    and o_orderstatus != 'cancelled'
    and seq.ti_seq < trainitem.ti_seq
group by trainitem.ti_seq,trainitem.ti_arrivalstation
order by trainitem.ti_seq,trainitem.ti_arrivalstation)
union
(select
    trainitem.ti_seq,
    trainitem.ti_arrivalstation,
    case
    when get_seat_type_not_have(tid,trainitem.ti_seq,seat_type) then 0
    when not(get_seat_type_not_have(tid,trainitem.ti_seq,seat_type)) then 5 else 0
    end as Remaining
from
    (select
        ti_tid,
        ti_arrivalstation,
        ti_seq
    from
        trainitems
    )as trainitem
where
    trainitem.ti_tid = tid
    and trainitem.ti_seq <= (
                            select
                                min(seq.ti_seq)
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
                            where
                                o_tid = seq.ti_tid
                                and o_departurestation = seq.ti_arrivalstation
                                and o_tid = tid
                                and is_date_consist(o_departuredate, order_date, o_tid, o_departurestation)
                                and o_seattype = seat_type
                                and o_orderstatus != 'cancelled'
                            )
group by trainitem.ti_seq,trainitem.ti_arrivalstation
order by trainitem.ti_seq,trainitem.ti_arrivalstation)
union
(select
    trainitem.ti_seq,
    trainitem.ti_arrivalstation,
    case
    when get_seat_type_not_have(tid,trainitem.ti_seq,seat_type) then 0
    when not(get_seat_type_not_have(tid,trainitem.ti_seq,seat_type)) then 5 else 0
    end as Remaining
from
    (select
        ti_tid,
        ti_arrivalstation,
        ti_seq
    from
        trainitems
    )as trainitem,
    orders
where
    trainitem.ti_tid = tid
    and ti_tid not in(
                        select o_tid
                        from orders
                        where o_seattype = seat_type
                              and o_orderstatus = 'valid'
                              and is_date_consist(o_departuredate, order_date, o_tid, o_departurestation)
                        )
group by trainitem.ti_seq,trainitem.ti_arrivalstation
order by trainitem.ti_seq,trainitem.ti_arrivalstation);
end
$$;


ALTER FUNCTION public.remaining_ticket(tid character varying, order_date date, seat_type public.seat_t) OWNER TO dbms;
