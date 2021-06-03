
create function city_to_city_one_stop(citystart character varying, cityto character varying, inputime time without time zone)
    returns TABLE(func_tid1 character varying, func_t1start_time time without time zone, func_t1arrive_time time without time zone, func_t1start_seq integer, func_t1start_station character varying, func_t1arrive_seq integer, func_t1arrive_station character varying, func_hse1 double precision, func_sse1 double precision, func_hsu1 double precision, func_hsm1 double precision, func_hsl1 double precision, func_ssu1 double precision, func_sslp1 double precision, func_tid2 character varying, func_t2start_time time without time zone, func_t2arrive_time time without time zone, func_t2start_seq integer, func_t2start_station character varying, func_t2arrive_seq integer, func_t2arrive_station character varying, hse2 double precision, sse2 double precision, hsu2 double precision, hsm2 double precision, hsl2 double precision, ssu2 double precision, sslp2 double precision)
    
as
$$
begin
    return query(
select
    T1start.ti_tid,
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
    and T1start.ti_departuretime > inputime);
    end
$$ language plpgsql;
