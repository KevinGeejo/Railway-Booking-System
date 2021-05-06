-- create tables

create table station(
	s_stationname varchar(20),
	s_city        varchar(20)
	);

create table user(
	u_idnumber    char(18),
	u_name        varchar(15),
	u_phone       char(11),
	u_creditcard  char(16),
	u_username    varchar(15)
	);

create table trainstartstation(
	-- tid 应该用varchar吗
	tss_tid          varchar(6),
	tss_startstation varchar(20),
	tss_starttime    time
	);

create table trainitem(
	ti_tid            varchar(6),
	ti_arrivalstation varchar(20),
	ti_arrivaltime    time,
	-- arrival和departure时间恰好分属两天的情况则如何?
	ti_departuretime  time,
	ti_sslprice       decimal,
	ti_ssuprice       decimal,
	ti_hslprice       decimal,
	ti_hsmprice       decimal,
	ti_hsuprice       decimal,
	ti_sseprice       decimal,
	ti_hseprice       decimal
	);

create table orders(
	o_oid              char(15),
	o_idnumber         char(18),
	-- tid 应该用varchar吗
	o_tid              varchar(6),
	o_departuredate    date,
	o_departuretime    time,
	-- seattype类型需要检查
	o_seattype         ENUM('ssl','ssu','hsl','hsm','hsu','sse', 'hse'),
	o_orderstatus      ENUM('cancelled', 'expired', 'valid'),
	o_departurestation varchar(20),
	o_arrivalstation   varchar(20)
	);