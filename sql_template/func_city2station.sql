--function: get static info of station2station directly
create or replace function city_to_station(city varchar(20))
returns table(
    stationname varchar(20)
             )
as $$
begin
return query
select
    s_stationname
from
    stations
where s_city=city;
end
$$
language plpgsql volatile;