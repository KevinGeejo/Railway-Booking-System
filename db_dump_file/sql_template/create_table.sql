-- create tables

create table stations(
	s_stationname varchar(20) primary key,
	s_city        varchar(20) not null
	);

create table users(
	u_idnumber    char(18) primary key,
	u_name        varchar(20) not null,
	u_phone       char(11) not null,
	u_creditcard  char(16) not null,
	u_username    varchar(20) not null,
    unique(u_phone)
	);

create table trainitems(
	ti_tid            varchar(5),
    ti_seq            integer not null,
	ti_arrivalstation varchar(20) not null,
	ti_arrivaltime    time default time '00:00:00',
    -- 后续考虑arrival和departure时间恰好分属两天的情况
	ti_departuretime  time default time '00:00:00',
    -- 硬座
	ti_hseprice       float  default 0,
    -- 软座
	ti_sseprice       float  default 0,
    -- 硬卧 上-中-下
	ti_hsuprice       float  default 0,
	ti_hsmprice       float  default 0,
    ti_hslprice       float  default 0,
    -- 软卧 上-下
	ti_ssuprice       float  default 0,
	ti_sslprice       float  default 0,
	ti_offsetday      integer default 0,
	primary key(ti_tid, ti_arrivalstation),
	foreign key(ti_arrivalstation) references stations(s_stationname)
	);

create table orders(
	o_oid              char(15) primary key,
	o_idnumber         char(18) not null,
	o_tid              varchar(5) not null,
	o_departuredate    date not null,
	o_departuretime    time not null,
	o_seattype         seat_t not null,
	o_orderstatus      stat_t default 'valid',
	o_departurestation varchar(20) not null,
	o_arrivalstation   varchar(20) not null,
	foreign key(o_idnumber) references users(u_idnumber),
	foreign key(o_tid, o_arrivalstation) references trainitems(ti_tid, ti_arrivalstation)
	);