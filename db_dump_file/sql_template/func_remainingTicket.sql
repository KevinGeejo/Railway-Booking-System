--demand 4
--function get_seat_type_not_have()
create or replace function get_seat_type_not_have(tid varchar(5), seq integer,seat_type seat_t) returns boolean
as $$
BEGIN
if seat_type = 'ssl' then
   return  (select ti_sslprice from
    (select ti_sslprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_sslprice = 0) IS not NULL;
end if;

if seat_type = 'ssu' then
   return  (select ti_ssuprice from
    (select ti_ssuprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_ssuprice = 0) IS not NULL;
end if;

if seat_type = 'hsl' then
   return  (select ti_hslprice from
    (select ti_hslprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_hslprice = 0) IS not NULL;
end if;

if seat_type = 'hsm' then
   return  (select ti_hsmprice from
    (select ti_hsmprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_hsmprice = 0) IS not NULL;
end if;

if seat_type = 'hsu' then
   return  (select ti_hsuprice from
    (select ti_hsuprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_hsuprice = 0) IS not NULL;
end if;

if seat_type = 'sse' then
   return  (select ti_sseprice from
    (select ti_sseprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_sseprice = 0) IS not NULL;
end if;

if seat_type = 'hse' then
   return  (select ti_hseprice from
    (select ti_hseprice from trainitems where tid = trainitems.ti_tid and seq = trainitems.ti_seq) as tmp
    where tmp.ti_hseprice = 0) IS not NULL;
end if;
END
$$ LANGUAGE plpgsql;





-- function remaining_ticket()
create function remaining_ticket(tid character varying, order_date date, seat_type seat_t)
    returns TABLE(seq integer, arrival_station character varying, remaining bigint)
as
$$
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
                              and is_date_consist(o_departuredate, order_date, o_tid, o_departurestation)
                        )
group by trainitem.ti_seq,trainitem.ti_arrivalstation
order by trainitem.ti_seq,trainitem.ti_arrivalstation);
end
$$ language plpgsql;


-- select e.g.
select remaining_ticket('1095', date '2021-5-24', 'sse');
