--function of get_price_processed()
create or replace function get_price_processed(remaining_ticket_num bigint,seat_price float)
returns float
as $$
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
$$ LANGUAGE plpgsql;

--function of bubble sort increase()
create or replace function get_cheapest_price(ssl float, ssu float, hsl float, hsm float, hsu float, sse float, hse float)
returns float
as $$
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
$$ LANGUAGE plpgsql;


create function is_date_consist(departure_date date, order_date date, tid character varying, departure_station character varying) returns boolean
as
$$
begin
        return (select ti_offsetday from trainitems
        where   ti_tid = tid
            and ti_arrivalstation = departure_station
            and ti_offsetday = departure_date - order_date
               )is not null;
    end
$$
language plpgsql;



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


create function get_shortest_time(start_dayoffset integer, arrival_dayoffset integer, start_time time without time zone, arrive_time time without time zone) returns time without time zone

as
$$
begin

END
$$  language plpgsql;


create or replace function get_interval(start_dayoffset integer,arrival_dayoffset integer,start_time time,arrive_time time)
returns interval
as $$
begin
    return ((date '2021-5-22' + arrival_dayoffset - start_dayoffset) + (arrive_time - start_time)) - date '2021-5-22';
END
$$ LANGUAGE plpgsql;

