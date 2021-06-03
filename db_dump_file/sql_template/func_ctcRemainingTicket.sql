create function ctc_remaining_tickets(match_tid character varying, start_seq integer, terminal_seq integer, departure_date date, seat_type seat_t)
    returns TABLE(match__tid character varying, remaining bigint)
as
$$
begin
return query
(select
    match_tid,
    5 - count(*) as remaining
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
    5
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
    5
where
    match_tid not in (
                        select orders.o_tid
                        from orders
                        where
                             is_date_consist_one_stop(o_departuredate,departure_date,match_tid, o_departurestation,start_seq)
                        and  o_seattype = seat_type
                    )
group by match_tid);
end
$$ language plpgsql;
