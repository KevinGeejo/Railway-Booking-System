--demand 5
--function: get static info of station2station directly
create or replace function city_to_city(departure_city varchar(20), arrive_city varchar(20), departure_time time)
returns table(
    match_tid varchar(5),
    start_time time,
    arrive_time time,
    start_seq integer,
    start_station varchar(20),
    terminal_seq integer,
    terminal_station varchar(20),
    hse float,
    sse float,
    hsu float,
    hsm float,
    hsl float,
    ssu float,
    ssl float
             )
as $$
begin
return query
select
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
$$
language plpgsql volatile;

--select e.g.
select
    city_to_city('南京','杭州',time '00:00:00');


-- A function: get static info of station2station with one stop
-- city_to_city_one_stop()
create or replace function city_to_city_one_stop(cityStart varchar(20),cityTo varchar(20),inputime time)
returns table(
     func_tid1 varchar(5),
     func_T1start_time time,
     func_T1arrive_time time,
     func_T1start_seq integer,
     func_T1start_station varchar(20),
     func_T1arrive_seq integer,
     func_T1arrive_station varchar(20),
     func_hse1 float,
     func_sse1 float,
     func_hsu1 float,
     func_hsm1 float,
     func_hsl1 float,
	 func_ssu1 float,
	 func_sslp1 float,
     func_tid2 varchar(5),
     func_T2start_time time,
     func_T2arrive_time time,
     func_T2start_seq integer,
     func_T2start_station varchar(20),
     func_T2arrive_seq integer,
     func_T2arrive_station varchar(20),
     hse2 float,
     sse2 float,
     hsu2 float,
	 hsm2 float,
     hsl2 float,
	 ssu2 float,
	 sslp2 float)
as $$
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
    $$
language plpgsql volatile ;

--select e.g.
select city_to_city_one_stop('北京', '天津', time '00:00:00');



