--demand 5
--function: get static info of station2station directly
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

--select e.g.
select city_to_city_one_stop('北京', '天津', time '00:00:00');



