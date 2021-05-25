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