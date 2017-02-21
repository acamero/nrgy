create schema `vatia_fdm`;
create schema `vatia_tmp`;

DROP TABLE IF EXISTS `vatia_fdm`.`metadata`;
CREATE TABLE `vatia_fdm`.`metadata` (
  pk_id int auto_increment,
  file_name varchar(55),
  province varchar(55),
  surface varchar(55),
  address varchar(55),
  lat decimal(10,7),
  lng decimal(10,7),
  city varchar(55),
  name varchar(55),
  country varchar(55),
  cadastre varchar(55),
  year_of_construct int,
  comments varchar(55),
  pc int,
  state varchar(55),
  primary key( pk_id )
);

DROP TABLE IF EXISTS `vatia_fdm`.`power_consumption`;
CREATE TABLE `vatia_fdm`.`power_consumption` (
  pk_id int auto_increment,
  fk_metadata_id int,
  ts datetime,
  consumption decimal(10,4),  
  primary key( pk_id )
);

DROP TABLE IF EXISTS `vatia_fdm`.`weather_station`;
CREATE TABLE `vatia_fdm`.`weather_station` (
  pk_id int auto_increment,
  icao char(4),
  lat decimal(10,7),
  lng decimal(10,7),
  city varchar(55),
  name varchar(55),
  country varchar(55),
  province varchar(55),
  primary key( pk_id )
);

DROP TABLE IF EXISTS `vatia_fdm`.`weather_forecast`;
CREATE TABLE `vatia_fdm`.`weather_forecast` (
  pk_id int auto_increment,
  fk_weather_station_id int,
  ts datetime,
  forecast varchar(55),
  temperature int,
  wind int,
  precipitation int,
  pressure int,
  primary key( pk_id )
);

-- ---------------------------------------------------------------------------------------------------------------------------------

drop view if exists  vatia_fdm.vw_matrix_consumption;
create view vatia_fdm.vw_matrix_consumption as
select 
  meta.file_name, 
  date(con.ts) as consumption_date, 
  max( if(substr(con.ts, 12,5)='00:00', con.consumption, 0) ) as '00:00',
  max( if(substr(con.ts, 12,5)='00:15', con.consumption, 0) ) as '00:15',
  max( if(substr(con.ts, 12,5)='00:30', con.consumption, 0) ) as '00:30',
  max( if(substr(con.ts, 12,5)='00:45', con.consumption, 0) ) as '00:45',
  max( if(substr(con.ts, 12,5)='01:00', con.consumption, 0) ) as '01:00',
  max( if(substr(con.ts, 12,5)='01:15', con.consumption, 0) ) as '01:15',
  max( if(substr(con.ts, 12,5)='01:30', con.consumption, 0) ) as '01:30',
  max( if(substr(con.ts, 12,5)='01:45', con.consumption, 0) ) as '01:45',
  max( if(substr(con.ts, 12,5)='02:00', con.consumption, 0) ) as '02:00',
  max( if(substr(con.ts, 12,5)='02:15', con.consumption, 0) ) as '02:15',
  max( if(substr(con.ts, 12,5)='02:30', con.consumption, 0) ) as '02:30',
  max( if(substr(con.ts, 12,5)='02:45', con.consumption, 0) ) as '02:45',
  max( if(substr(con.ts, 12,5)='03:00', con.consumption, 0) ) as '03:00',
  max( if(substr(con.ts, 12,5)='03:15', con.consumption, 0) ) as '03:15',
  max( if(substr(con.ts, 12,5)='03:30', con.consumption, 0) ) as '03:30',
  max( if(substr(con.ts, 12,5)='03:45', con.consumption, 0) ) as '03:45',
  max( if(substr(con.ts, 12,5)='04:00', con.consumption, 0) ) as '04:00',
  max( if(substr(con.ts, 12,5)='04:15', con.consumption, 0) ) as '04:15',
  max( if(substr(con.ts, 12,5)='04:30', con.consumption, 0) ) as '04:30',
  max( if(substr(con.ts, 12,5)='04:45', con.consumption, 0) ) as '04:45',
  max( if(substr(con.ts, 12,5)='05:00', con.consumption, 0) ) as '05:00',
  max( if(substr(con.ts, 12,5)='05:15', con.consumption, 0) ) as '05:15',
  max( if(substr(con.ts, 12,5)='05:30', con.consumption, 0) ) as '05:30',
  max( if(substr(con.ts, 12,5)='05:45', con.consumption, 0) ) as '05:45',
  max( if(substr(con.ts, 12,5)='06:00', con.consumption, 0) ) as '06:00',
  max( if(substr(con.ts, 12,5)='06:15', con.consumption, 0) ) as '06:15',
  max( if(substr(con.ts, 12,5)='06:30', con.consumption, 0) ) as '06:30',
  max( if(substr(con.ts, 12,5)='06:45', con.consumption, 0) ) as '06:45',
  max( if(substr(con.ts, 12,5)='07:00', con.consumption, 0) ) as '07:00',
  max( if(substr(con.ts, 12,5)='07:15', con.consumption, 0) ) as '07:15',
  max( if(substr(con.ts, 12,5)='07:30', con.consumption, 0) ) as '07:30',
  max( if(substr(con.ts, 12,5)='07:45', con.consumption, 0) ) as '07:45',
  max( if(substr(con.ts, 12,5)='08:00', con.consumption, 0) ) as '08:00',
  max( if(substr(con.ts, 12,5)='08:15', con.consumption, 0) ) as '08:15',
  max( if(substr(con.ts, 12,5)='08:30', con.consumption, 0) ) as '08:30',
  max( if(substr(con.ts, 12,5)='08:45', con.consumption, 0) ) as '08:45',
  max( if(substr(con.ts, 12,5)='09:00', con.consumption, 0) ) as '09:00',
  max( if(substr(con.ts, 12,5)='09:15', con.consumption, 0) ) as '09:15',
  max( if(substr(con.ts, 12,5)='09:30', con.consumption, 0) ) as '09:30',
  max( if(substr(con.ts, 12,5)='09:45', con.consumption, 0) ) as '09:45',
  max( if(substr(con.ts, 12,5)='10:00', con.consumption, 0) ) as '10:00',
  max( if(substr(con.ts, 12,5)='10:15', con.consumption, 0) ) as '10:15',
  max( if(substr(con.ts, 12,5)='10:30', con.consumption, 0) ) as '10:30',
  max( if(substr(con.ts, 12,5)='10:45', con.consumption, 0) ) as '10:45',
  max( if(substr(con.ts, 12,5)='11:00', con.consumption, 0) ) as '11:00',
  max( if(substr(con.ts, 12,5)='11:15', con.consumption, 0) ) as '11:15',
  max( if(substr(con.ts, 12,5)='11:30', con.consumption, 0) ) as '11:30',
  max( if(substr(con.ts, 12,5)='11:45', con.consumption, 0) ) as '11:45',
  max( if(substr(con.ts, 12,5)='12:00', con.consumption, 0) ) as '12:00',
  max( if(substr(con.ts, 12,5)='12:15', con.consumption, 0) ) as '12:15',
  max( if(substr(con.ts, 12,5)='12:30', con.consumption, 0) ) as '12:30',
  max( if(substr(con.ts, 12,5)='12:45', con.consumption, 0) ) as '12:45',
  max( if(substr(con.ts, 12,5)='13:00', con.consumption, 0) ) as '13:00',
  max( if(substr(con.ts, 12,5)='13:15', con.consumption, 0) ) as '13:15',
  max( if(substr(con.ts, 12,5)='13:30', con.consumption, 0) ) as '13:30',
  max( if(substr(con.ts, 12,5)='13:45', con.consumption, 0) ) as '13:45',
  max( if(substr(con.ts, 12,5)='14:00', con.consumption, 0) ) as '14:00',
  max( if(substr(con.ts, 12,5)='14:15', con.consumption, 0) ) as '14:15',
  max( if(substr(con.ts, 12,5)='14:30', con.consumption, 0) ) as '14:30',
  max( if(substr(con.ts, 12,5)='14:45', con.consumption, 0) ) as '14:45',
  max( if(substr(con.ts, 12,5)='15:00', con.consumption, 0) ) as '15:00',
  max( if(substr(con.ts, 12,5)='15:15', con.consumption, 0) ) as '15:15',
  max( if(substr(con.ts, 12,5)='15:30', con.consumption, 0) ) as '15:30',
  max( if(substr(con.ts, 12,5)='15:45', con.consumption, 0) ) as '15:45',
  max( if(substr(con.ts, 12,5)='16:00', con.consumption, 0) ) as '16:00',
  max( if(substr(con.ts, 12,5)='16:15', con.consumption, 0) ) as '16:15',
  max( if(substr(con.ts, 12,5)='16:30', con.consumption, 0) ) as '16:30',
  max( if(substr(con.ts, 12,5)='16:45', con.consumption, 0) ) as '16:45',
  max( if(substr(con.ts, 12,5)='17:00', con.consumption, 0) ) as '17:00',
  max( if(substr(con.ts, 12,5)='17:15', con.consumption, 0) ) as '17:15',
  max( if(substr(con.ts, 12,5)='17:30', con.consumption, 0) ) as '17:30',
  max( if(substr(con.ts, 12,5)='17:45', con.consumption, 0) ) as '17:45',
  max( if(substr(con.ts, 12,5)='18:00', con.consumption, 0) ) as '18:00',
  max( if(substr(con.ts, 12,5)='18:15', con.consumption, 0) ) as '18:15',
  max( if(substr(con.ts, 12,5)='18:30', con.consumption, 0) ) as '18:30',
  max( if(substr(con.ts, 12,5)='18:45', con.consumption, 0) ) as '18:45',
  max( if(substr(con.ts, 12,5)='19:00', con.consumption, 0) ) as '19:00',
  max( if(substr(con.ts, 12,5)='19:15', con.consumption, 0) ) as '19:15',
  max( if(substr(con.ts, 12,5)='19:30', con.consumption, 0) ) as '19:30',
  max( if(substr(con.ts, 12,5)='19:45', con.consumption, 0) ) as '19:45',
  max( if(substr(con.ts, 12,5)='20:00', con.consumption, 0) ) as '20:00',
  max( if(substr(con.ts, 12,5)='20:15', con.consumption, 0) ) as '20:15',
  max( if(substr(con.ts, 12,5)='20:30', con.consumption, 0) ) as '20:30',
  max( if(substr(con.ts, 12,5)='20:45', con.consumption, 0) ) as '20:45',
  max( if(substr(con.ts, 12,5)='21:00', con.consumption, 0) ) as '21:00',
  max( if(substr(con.ts, 12,5)='21:15', con.consumption, 0) ) as '21:15',
  max( if(substr(con.ts, 12,5)='21:30', con.consumption, 0) ) as '21:30',
  max( if(substr(con.ts, 12,5)='21:45', con.consumption, 0) ) as '21:45',
  max( if(substr(con.ts, 12,5)='22:00', con.consumption, 0) ) as '22:00',
  max( if(substr(con.ts, 12,5)='22:15', con.consumption, 0) ) as '22:15',
  max( if(substr(con.ts, 12,5)='22:30', con.consumption, 0) ) as '22:30',
  max( if(substr(con.ts, 12,5)='22:45', con.consumption, 0) ) as '22:45',
  max( if(substr(con.ts, 12,5)='23:00', con.consumption, 0) ) as '23:00',
  max( if(substr(con.ts, 12,5)='23:15', con.consumption, 0) ) as '23:15',
  max( if(substr(con.ts, 12,5)='23:30', con.consumption, 0) ) as '23:30',
  max( if(substr(con.ts, 12,5)='23:45', con.consumption, 0) ) as '23:45'
from vatia_fdm.power_consumption con
	join vatia_fdm.metadata meta
    on con.fk_metadata_id = meta.pk_id
group by 1,2;

create view vatia_fdm.vw_unique_consumption as
select meta.file_name, con.ts, max(con.consumption)
from vatia_fdm.power_consumption con
	join vatia_fdm.metadata meta
    on con.fk_metadata_id = meta.pk_id
group by 1,2;

-- ---------------------------------------------------------------------------------------------------------------------------------

drop view if exists  vatia_fdm.vw_matrix_weather_temperature_tmp;
create view vatia_fdm.vw_matrix_weather_temperature_tmp as
select 
  con.fk_weather_station_id, 
  date(con.ts) as forecast_date,
  max( if(substr(con.ts, 12,5)='00:00', con.temperature, -99999) ) as '00:00',  
  max( if(substr(con.ts, 12,5)='00:30', con.temperature, -99999) ) as '00:30',
  max( if(substr(con.ts, 12,5)='01:00', con.temperature, -99999) ) as '01:00',
  max( if(substr(con.ts, 12,5)='01:30', con.temperature, -99999) ) as '01:30',
  max( if(substr(con.ts, 12,5)='02:00', con.temperature, -99999) ) as '02:00',
  max( if(substr(con.ts, 12,5)='02:30', con.temperature, -99999) ) as '02:30',
  max( if(substr(con.ts, 12,5)='03:00', con.temperature, -99999) ) as '03:00',
  max( if(substr(con.ts, 12,5)='03:30', con.temperature, -99999) ) as '03:30',
  max( if(substr(con.ts, 12,5)='04:00', con.temperature, -99999) ) as '04:00',
  max( if(substr(con.ts, 12,5)='04:30', con.temperature, -99999) ) as '04:30',
  max( if(substr(con.ts, 12,5)='05:00', con.temperature, -99999) ) as '05:00',
  max( if(substr(con.ts, 12,5)='05:30', con.temperature, -99999) ) as '05:30',
  max( if(substr(con.ts, 12,5)='06:00', con.temperature, -99999) ) as '06:00',
  max( if(substr(con.ts, 12,5)='06:30', con.temperature, -99999) ) as '06:30',
  max( if(substr(con.ts, 12,5)='07:00', con.temperature, -99999) ) as '07:00',
  max( if(substr(con.ts, 12,5)='07:30', con.temperature, -99999) ) as '07:30',
  max( if(substr(con.ts, 12,5)='08:00', con.temperature, -99999) ) as '08:00',
  max( if(substr(con.ts, 12,5)='08:30', con.temperature, -99999) ) as '08:30',
  max( if(substr(con.ts, 12,5)='09:00', con.temperature, -99999) ) as '09:00',
  max( if(substr(con.ts, 12,5)='09:30', con.temperature, -99999) ) as '09:30',
  max( if(substr(con.ts, 12,5)='10:00', con.temperature, -99999) ) as '10:00',
  max( if(substr(con.ts, 12,5)='10:30', con.temperature, -99999) ) as '10:30',
  max( if(substr(con.ts, 12,5)='11:00', con.temperature, -99999) ) as '11:00',
  max( if(substr(con.ts, 12,5)='11:30', con.temperature, -99999) ) as '11:30',
  max( if(substr(con.ts, 12,5)='12:00', con.temperature, -99999) ) as '12:00',
  max( if(substr(con.ts, 12,5)='12:30', con.temperature, -99999) ) as '12:30',
  max( if(substr(con.ts, 12,5)='13:00', con.temperature, -99999) ) as '13:00',
  max( if(substr(con.ts, 12,5)='13:30', con.temperature, -99999) ) as '13:30',
  max( if(substr(con.ts, 12,5)='14:00', con.temperature, -99999) ) as '14:00',
  max( if(substr(con.ts, 12,5)='14:30', con.temperature, -99999) ) as '14:30',
  max( if(substr(con.ts, 12,5)='15:00', con.temperature, -99999) ) as '15:00',
  max( if(substr(con.ts, 12,5)='15:30', con.temperature, -99999) ) as '15:30',
  max( if(substr(con.ts, 12,5)='16:00', con.temperature, -99999) ) as '16:00',
  max( if(substr(con.ts, 12,5)='16:30', con.temperature, -99999) ) as '16:30',
  max( if(substr(con.ts, 12,5)='17:00', con.temperature, -99999) ) as '17:00',
  max( if(substr(con.ts, 12,5)='17:30', con.temperature, -99999) ) as '17:30',
  max( if(substr(con.ts, 12,5)='18:00', con.temperature, -99999) ) as '18:00',
  max( if(substr(con.ts, 12,5)='18:30', con.temperature, -99999) ) as '18:30',
  max( if(substr(con.ts, 12,5)='19:00', con.temperature, -99999) ) as '19:00',
  max( if(substr(con.ts, 12,5)='19:30', con.temperature, -99999) ) as '19:30',
  max( if(substr(con.ts, 12,5)='20:00', con.temperature, -99999) ) as '20:00',
  max( if(substr(con.ts, 12,5)='20:30', con.temperature, -99999) ) as '20:30',
  max( if(substr(con.ts, 12,5)='21:00', con.temperature, -99999) ) as '21:00',
  max( if(substr(con.ts, 12,5)='21:30', con.temperature, -99999) ) as '21:30',
  max( if(substr(con.ts, 12,5)='22:00', con.temperature, -99999) ) as '22:00',
  max( if(substr(con.ts, 12,5)='22:30', con.temperature, -99999) ) as '22:30',
  max( if(substr(con.ts, 12,5)='23:00', con.temperature, -99999) ) as '23:00',
  max( if(substr(con.ts, 12,5)='23:30', con.temperature, -99999) ) as '23:30'
from vatia_fdm.weather_forecast con
group by 1,2;


drop view if exists  vatia_fdm.vw_matrix_weather_temperature;
create view vatia_fdm.vw_matrix_weather_temperature as
select
  tmp.fk_weather_station_id,
  tmp.forecast_date,
  tmp.`00:00`,
  case 
    when tmp.`00:00` = -99999 then tmp.`00:30`
    when tmp.`00:30` = -99999 then tmp.`00:00`
    else (tmp.`00:00` + tmp.`00:30`) / 2
  end
  as '00:15',
  tmp.`00:30`,
  case 
    when tmp.`00:30` = -99999 then tmp.`01:00`
    when tmp.`01:00` = -99999 then tmp.`00:30`
    else (tmp.`00:30` + tmp.`01:00`) / 2
  end
  as '00:45',
  tmp.`01:00`,
  case 
    when tmp.`01:00` = -99999 then tmp.`01:30`
    when tmp.`01:30` = -99999 then tmp.`01:00`
    else (tmp.`01:00` + tmp.`01:30`) / 2
  end
  as '01:15',
  tmp.`01:30`,
  case 
    when tmp.`01:30` = -99999 then tmp.`02:00`
    when tmp.`02:00` = -99999 then tmp.`01:30`
    else (tmp.`01:30` + tmp.`02:00`) / 2
  end
  as '01:45',
  tmp.`02:00`,
  case 
    when tmp.`02:00` = -99999 then tmp.`02:30`
    when tmp.`02:30` = -99999 then tmp.`02:00`
    else (tmp.`02:00` + tmp.`02:30`) / 2
  end
  as '02:15',
  tmp.`02:30`,
  case 
    when tmp.`02:30` = -99999 then tmp.`03:00`
    when tmp.`03:00` = -99999 then tmp.`02:30`
    else (tmp.`02:30` + tmp.`03:00`) / 2
  end
  as '02:45',
  tmp.`03:00`,
  case 
    when tmp.`03:00` = -99999 then tmp.`03:30`
    when tmp.`03:30` = -99999 then tmp.`03:00`
    else (tmp.`03:00` + tmp.`03:30`) / 2
  end
  as '03:15',
  tmp.`03:30`,
  case 
    when tmp.`03:30` = -99999 then tmp.`04:00`
    when tmp.`04:00` = -99999 then tmp.`03:30`
    else (tmp.`03:30` + tmp.`04:00`) / 2
  end
  as '03:45',
  tmp.`04:00`,
  case 
    when tmp.`04:00` = -99999 then tmp.`04:30`
    when tmp.`04:30` = -99999 then tmp.`04:00`
    else (tmp.`04:00` + tmp.`04:30`) / 2
  end
  as '04:15',
  tmp.`04:30`,
  case 
    when tmp.`04:30` = -99999 then tmp.`05:00`
    when tmp.`05:00` = -99999 then tmp.`04:30`
    else (tmp.`04:30` + tmp.`05:00`) / 2
  end
  as '04:45',
  tmp.`05:00`,
  case 
    when tmp.`05:00` = -99999 then tmp.`05:30`
    when tmp.`05:30` = -99999 then tmp.`05:00`
    else (tmp.`05:00` + tmp.`05:30`) / 2
  end
  as '05:15',
  tmp.`05:30`,
  case 
    when tmp.`05:30` = -99999 then tmp.`06:00`
    when tmp.`06:00` = -99999 then tmp.`05:30`
    else (tmp.`05:30` + tmp.`06:00`) / 2
  end
  as '05:45',
  tmp.`06:00`,
  case 
    when tmp.`06:00` = -99999 then tmp.`06:30`
    when tmp.`06:30` = -99999 then tmp.`06:00`
    else (tmp.`06:00` + tmp.`06:30`) / 2
  end
  as '06:15',
  tmp.`06:30`,
  case 
    when tmp.`06:30` = -99999 then tmp.`07:00`
    when tmp.`07:00` = -99999 then tmp.`06:30`
    else (tmp.`06:30` + tmp.`07:00`) / 2
  end
  as '06:45',
  tmp.`07:00`,
  case 
    when tmp.`07:00` = -99999 then tmp.`07:30`
    when tmp.`07:30` = -99999 then tmp.`07:00`
    else (tmp.`07:00` + tmp.`07:30`) / 2
  end
  as '07:15',
  tmp.`07:30`,
  case 
    when tmp.`07:30` = -99999 then tmp.`08:00`
    when tmp.`08:00` = -99999 then tmp.`07:30`
    else (tmp.`07:30` + tmp.`08:00`) / 2
  end
  as '07:45',
  tmp.`08:00`,
  case 
    when tmp.`08:00` = -99999 then tmp.`08:30`
    when tmp.`08:30` = -99999 then tmp.`08:00`
    else (tmp.`08:00` + tmp.`08:30`) / 2
  end
  as '08:15',
  tmp.`08:30`,
  case 
    when tmp.`08:30` = -99999 then tmp.`09:00`
    when tmp.`09:00` = -99999 then tmp.`08:30`
    else (tmp.`08:30` + tmp.`09:00`) / 2
  end
  as '08:45',
  tmp.`09:00`,
  case 
    when tmp.`09:00` = -99999 then tmp.`09:30`
    when tmp.`09:30` = -99999 then tmp.`09:00`
    else (tmp.`09:00` + tmp.`09:30`) / 2
  end
  as '09:15',
  tmp.`09:30`,
  case 
    when tmp.`09:30` = -99999 then tmp.`10:00`
    when tmp.`10:00` = -99999 then tmp.`09:30`
    else (tmp.`09:30` + tmp.`10:00`) / 2
  end
  as '09:45',
  
  tmp.`10:00`,
  case 
    when tmp.`10:00` = -99999 then tmp.`10:30`
    when tmp.`10:30` = -99999 then tmp.`10:00`
    else (tmp.`10:00` + tmp.`10:30`) / 2
  end
  as '10:15',
  tmp.`10:30`,
  case 
    when tmp.`10:30` = -99999 then tmp.`11:00`
    when tmp.`11:00` = -99999 then tmp.`10:30`
    else (tmp.`10:30` + tmp.`11:00`) / 2
  end
  as '10:45',
  tmp.`11:00`,
  case 
    when tmp.`11:00` = -99999 then tmp.`11:30`
    when tmp.`11:30` = -99999 then tmp.`11:00`
    else (tmp.`11:00` + tmp.`11:30`) / 2
  end
  as '11:15',
  tmp.`11:30`,
  case 
    when tmp.`11:30` = -99999 then tmp.`12:00`
    when tmp.`12:00` = -99999 then tmp.`11:30`
    else (tmp.`11:30` + tmp.`12:00`) / 2
  end
  as '11:45',
  tmp.`12:00`,
  case 
    when tmp.`12:00` = -99999 then tmp.`12:30`
    when tmp.`12:30` = -99999 then tmp.`12:00`
    else (tmp.`12:00` + tmp.`12:30`) / 2
  end
  as '12:15',
  tmp.`12:30`,
  case 
    when tmp.`12:30` = -99999 then tmp.`13:00`
    when tmp.`13:00` = -99999 then tmp.`12:30`
    else (tmp.`12:30` + tmp.`13:00`) / 2
  end
  as '12:45',
  tmp.`13:00`,
  case 
    when tmp.`13:00` = -99999 then tmp.`13:30`
    when tmp.`13:30` = -99999 then tmp.`13:00`
    else (tmp.`13:00` + tmp.`13:30`) / 2
  end
  as '13:15',
  tmp.`13:30`,
  case 
    when tmp.`13:30` = -99999 then tmp.`14:00`
    when tmp.`14:00` = -99999 then tmp.`13:30`
    else (tmp.`13:30` + tmp.`14:00`) / 2
  end
  as '13:45',
  tmp.`14:00`,
  case 
    when tmp.`14:00` = -99999 then tmp.`14:30`
    when tmp.`14:30` = -99999 then tmp.`14:00`
    else (tmp.`14:00` + tmp.`14:30`) / 2
  end
  as '14:15',
  tmp.`14:30`,
  case 
    when tmp.`14:30` = -99999 then tmp.`15:00`
    when tmp.`15:00` = -99999 then tmp.`14:30`
    else (tmp.`14:30` + tmp.`15:00`) / 2
  end
  as '14:45',
  tmp.`15:00`,
  case 
    when tmp.`15:00` = -99999 then tmp.`15:30`
    when tmp.`15:30` = -99999 then tmp.`15:00`
    else (tmp.`15:00` + tmp.`15:30`) / 2
  end
  as '15:15',
  tmp.`15:30`,
  case 
    when tmp.`15:30` = -99999 then tmp.`16:00`
    when tmp.`16:00` = -99999 then tmp.`15:30`
    else (tmp.`15:30` + tmp.`16:00`) / 2
  end
  as '15:45',
  tmp.`16:00`,
  case 
    when tmp.`16:00` = -99999 then tmp.`16:30`
    when tmp.`16:30` = -99999 then tmp.`16:00`
    else (tmp.`16:00` + tmp.`16:30`) / 2
  end
  as '16:15',
  tmp.`16:30`,
  case 
    when tmp.`16:30` = -99999 then tmp.`17:00`
    when tmp.`17:00` = -99999 then tmp.`16:30`
    else (tmp.`16:30` + tmp.`17:00`) / 2
  end
  as '16:45',
  tmp.`17:00`,
  case 
    when tmp.`17:00` = -99999 then tmp.`17:30`
    when tmp.`17:30` = -99999 then tmp.`17:00`
    else (tmp.`17:00` + tmp.`17:30`) / 2
  end
  as '17:15',
  tmp.`17:30`,
  case 
    when tmp.`17:30` = -99999 then tmp.`18:00`
    when tmp.`18:00` = -99999 then tmp.`17:30`
    else (tmp.`17:30` + tmp.`18:00`) / 2
  end
  as '17:45',
  tmp.`18:00`,
  case 
    when tmp.`18:00` = -99999 then tmp.`18:30`
    when tmp.`18:30` = -99999 then tmp.`18:00`
    else (tmp.`18:00` + tmp.`18:30`) / 2
  end
  as '18:15',
  tmp.`18:30`,
  case 
    when tmp.`18:30` = -99999 then tmp.`19:00`
    when tmp.`19:00` = -99999 then tmp.`18:30`
    else (tmp.`18:30` + tmp.`19:00`) / 2
  end
  as '18:45',
  tmp.`19:00`,
  case 
    when tmp.`19:00` = -99999 then tmp.`19:30`
    when tmp.`19:30` = -99999 then tmp.`19:00`
    else (tmp.`19:00` + tmp.`19:30`) / 2
  end
  as '19:15',
  tmp.`19:30`,
  case 
    when tmp.`19:30` = -99999 then tmp.`20:00`
    when tmp.`20:00` = -99999 then tmp.`19:30`
    else (tmp.`19:30` + tmp.`20:00`) / 2
  end
  as '19:45',
  
  tmp.`20:00`,
  case 
    when tmp.`20:00` = -99999 then tmp.`20:30`
    when tmp.`20:30` = -99999 then tmp.`20:00`
    else (tmp.`20:00` + tmp.`20:30`) / 2
  end
  as '20:15',
  tmp.`20:30`,
  case 
    when tmp.`20:30` = -99999 then tmp.`21:00`
    when tmp.`21:00` = -99999 then tmp.`20:30`
    else (tmp.`20:30` + tmp.`21:00`) / 2
  end
  as '20:45',
  tmp.`21:00`,
  case 
    when tmp.`21:00` = -99999 then tmp.`21:30`
    when tmp.`21:30` = -99999 then tmp.`21:00`
    else (tmp.`21:00` + tmp.`21:30`) / 2
  end
  as '21:15',
  tmp.`21:30`,
  case 
    when tmp.`21:30` = -99999 then tmp.`22:00`
    when tmp.`22:00` = -99999 then tmp.`21:30`
    else (tmp.`21:30` + tmp.`22:00`) / 2
  end
  as '21:45',
  tmp.`22:00`,
  case 
    when tmp.`22:00` = -99999 then tmp.`22:30`
    when tmp.`22:30` = -99999 then tmp.`22:00`
    else (tmp.`22:00` + tmp.`22:30`) / 2
  end
  as '22:15',
  tmp.`22:30`,
  case 
    when tmp.`22:30` = -99999 then tmp.`23:00`
    when tmp.`23:00` = -99999 then tmp.`22:30`
    else (tmp.`22:30` + tmp.`23:00`) / 2
  end
  as '22:45',
  tmp.`23:00`,
  case 
    when tmp.`23:00` = -99999 then tmp.`23:30`
    when tmp.`23:30` = -99999 then tmp.`23:00`
    else (tmp.`23:00` + tmp.`23:30`) / 2
  end
  as '23:15',
  tmp.`23:30`,
  tmp.`23:30` as '23:45'
from vatia_fdm.vw_matrix_weather_temperature_tmp tmp;

-- ---------------------------------------------------------------------------------------------------------------------------------

drop view if exists  vatia_fdm.vw_matrix_weather_wind_tmp;
create view vatia_fdm.vw_matrix_weather_wind_tmp as
select 
  con.fk_weather_station_id, 
  date(con.ts) as forecast_date,
  max( if(substr(con.ts, 12,5)='00:00', con.wind, -99999) ) as '00:00',  
  max( if(substr(con.ts, 12,5)='00:30', con.wind, -99999) ) as '00:30',
  max( if(substr(con.ts, 12,5)='01:00', con.wind, -99999) ) as '01:00',
  max( if(substr(con.ts, 12,5)='01:30', con.wind, -99999) ) as '01:30',
  max( if(substr(con.ts, 12,5)='02:00', con.wind, -99999) ) as '02:00',
  max( if(substr(con.ts, 12,5)='02:30', con.wind, -99999) ) as '02:30',
  max( if(substr(con.ts, 12,5)='03:00', con.wind, -99999) ) as '03:00',
  max( if(substr(con.ts, 12,5)='03:30', con.wind, -99999) ) as '03:30',
  max( if(substr(con.ts, 12,5)='04:00', con.wind, -99999) ) as '04:00',
  max( if(substr(con.ts, 12,5)='04:30', con.wind, -99999) ) as '04:30',
  max( if(substr(con.ts, 12,5)='05:00', con.wind, -99999) ) as '05:00',
  max( if(substr(con.ts, 12,5)='05:30', con.wind, -99999) ) as '05:30',
  max( if(substr(con.ts, 12,5)='06:00', con.wind, -99999) ) as '06:00',
  max( if(substr(con.ts, 12,5)='06:30', con.wind, -99999) ) as '06:30',
  max( if(substr(con.ts, 12,5)='07:00', con.wind, -99999) ) as '07:00',
  max( if(substr(con.ts, 12,5)='07:30', con.wind, -99999) ) as '07:30',
  max( if(substr(con.ts, 12,5)='08:00', con.wind, -99999) ) as '08:00',
  max( if(substr(con.ts, 12,5)='08:30', con.wind, -99999) ) as '08:30',
  max( if(substr(con.ts, 12,5)='09:00', con.wind, -99999) ) as '09:00',
  max( if(substr(con.ts, 12,5)='09:30', con.wind, -99999) ) as '09:30',
  max( if(substr(con.ts, 12,5)='10:00', con.wind, -99999) ) as '10:00',
  max( if(substr(con.ts, 12,5)='10:30', con.wind, -99999) ) as '10:30',
  max( if(substr(con.ts, 12,5)='11:00', con.wind, -99999) ) as '11:00',
  max( if(substr(con.ts, 12,5)='11:30', con.wind, -99999) ) as '11:30',
  max( if(substr(con.ts, 12,5)='12:00', con.wind, -99999) ) as '12:00',
  max( if(substr(con.ts, 12,5)='12:30', con.wind, -99999) ) as '12:30',
  max( if(substr(con.ts, 12,5)='13:00', con.wind, -99999) ) as '13:00',
  max( if(substr(con.ts, 12,5)='13:30', con.wind, -99999) ) as '13:30',
  max( if(substr(con.ts, 12,5)='14:00', con.wind, -99999) ) as '14:00',
  max( if(substr(con.ts, 12,5)='14:30', con.wind, -99999) ) as '14:30',
  max( if(substr(con.ts, 12,5)='15:00', con.wind, -99999) ) as '15:00',
  max( if(substr(con.ts, 12,5)='15:30', con.wind, -99999) ) as '15:30',
  max( if(substr(con.ts, 12,5)='16:00', con.wind, -99999) ) as '16:00',
  max( if(substr(con.ts, 12,5)='16:30', con.wind, -99999) ) as '16:30',
  max( if(substr(con.ts, 12,5)='17:00', con.wind, -99999) ) as '17:00',
  max( if(substr(con.ts, 12,5)='17:30', con.wind, -99999) ) as '17:30',
  max( if(substr(con.ts, 12,5)='18:00', con.wind, -99999) ) as '18:00',
  max( if(substr(con.ts, 12,5)='18:30', con.wind, -99999) ) as '18:30',
  max( if(substr(con.ts, 12,5)='19:00', con.wind, -99999) ) as '19:00',
  max( if(substr(con.ts, 12,5)='19:30', con.wind, -99999) ) as '19:30',
  max( if(substr(con.ts, 12,5)='20:00', con.wind, -99999) ) as '20:00',
  max( if(substr(con.ts, 12,5)='20:30', con.wind, -99999) ) as '20:30',
  max( if(substr(con.ts, 12,5)='21:00', con.wind, -99999) ) as '21:00',
  max( if(substr(con.ts, 12,5)='21:30', con.wind, -99999) ) as '21:30',
  max( if(substr(con.ts, 12,5)='22:00', con.wind, -99999) ) as '22:00',
  max( if(substr(con.ts, 12,5)='22:30', con.wind, -99999) ) as '22:30',
  max( if(substr(con.ts, 12,5)='23:00', con.wind, -99999) ) as '23:00',
  max( if(substr(con.ts, 12,5)='23:30', con.wind, -99999) ) as '23:30'
from vatia_fdm.weather_forecast con
group by 1,2;

drop view if exists  vatia_fdm.vw_matrix_weather_wind;
create view vatia_fdm.vw_matrix_weather_wind as
select
  tmp.fk_weather_station_id,
  tmp.forecast_date,
  tmp.`00:00`,
  case 
    when tmp.`00:00` = -99999 then tmp.`00:30`
    when tmp.`00:30` = -99999 then tmp.`00:00`
    else (tmp.`00:00` + tmp.`00:30`) / 2
  end
  as '00:15',
  tmp.`00:30`,
  case 
    when tmp.`00:30` = -99999 then tmp.`01:00`
    when tmp.`01:00` = -99999 then tmp.`00:30`
    else (tmp.`00:30` + tmp.`01:00`) / 2
  end
  as '00:45',
  tmp.`01:00`,
  case 
    when tmp.`01:00` = -99999 then tmp.`01:30`
    when tmp.`01:30` = -99999 then tmp.`01:00`
    else (tmp.`01:00` + tmp.`01:30`) / 2
  end
  as '01:15',
  tmp.`01:30`,
  case 
    when tmp.`01:30` = -99999 then tmp.`02:00`
    when tmp.`02:00` = -99999 then tmp.`01:30`
    else (tmp.`01:30` + tmp.`02:00`) / 2
  end
  as '01:45',
  tmp.`02:00`,
  case 
    when tmp.`02:00` = -99999 then tmp.`02:30`
    when tmp.`02:30` = -99999 then tmp.`02:00`
    else (tmp.`02:00` + tmp.`02:30`) / 2
  end
  as '02:15',
  tmp.`02:30`,
  case 
    when tmp.`02:30` = -99999 then tmp.`03:00`
    when tmp.`03:00` = -99999 then tmp.`02:30`
    else (tmp.`02:30` + tmp.`03:00`) / 2
  end
  as '02:45',
  tmp.`03:00`,
  case 
    when tmp.`03:00` = -99999 then tmp.`03:30`
    when tmp.`03:30` = -99999 then tmp.`03:00`
    else (tmp.`03:00` + tmp.`03:30`) / 2
  end
  as '03:15',
  tmp.`03:30`,
  case 
    when tmp.`03:30` = -99999 then tmp.`04:00`
    when tmp.`04:00` = -99999 then tmp.`03:30`
    else (tmp.`03:30` + tmp.`04:00`) / 2
  end
  as '03:45',
  tmp.`04:00`,
  case 
    when tmp.`04:00` = -99999 then tmp.`04:30`
    when tmp.`04:30` = -99999 then tmp.`04:00`
    else (tmp.`04:00` + tmp.`04:30`) / 2
  end
  as '04:15',
  tmp.`04:30`,
  case 
    when tmp.`04:30` = -99999 then tmp.`05:00`
    when tmp.`05:00` = -99999 then tmp.`04:30`
    else (tmp.`04:30` + tmp.`05:00`) / 2
  end
  as '04:45',
  tmp.`05:00`,
  case 
    when tmp.`05:00` = -99999 then tmp.`05:30`
    when tmp.`05:30` = -99999 then tmp.`05:00`
    else (tmp.`05:00` + tmp.`05:30`) / 2
  end
  as '05:15',
  tmp.`05:30`,
  case 
    when tmp.`05:30` = -99999 then tmp.`06:00`
    when tmp.`06:00` = -99999 then tmp.`05:30`
    else (tmp.`05:30` + tmp.`06:00`) / 2
  end
  as '05:45',
  tmp.`06:00`,
  case 
    when tmp.`06:00` = -99999 then tmp.`06:30`
    when tmp.`06:30` = -99999 then tmp.`06:00`
    else (tmp.`06:00` + tmp.`06:30`) / 2
  end
  as '06:15',
  tmp.`06:30`,
  case 
    when tmp.`06:30` = -99999 then tmp.`07:00`
    when tmp.`07:00` = -99999 then tmp.`06:30`
    else (tmp.`06:30` + tmp.`07:00`) / 2
  end
  as '06:45',
  tmp.`07:00`,
  case 
    when tmp.`07:00` = -99999 then tmp.`07:30`
    when tmp.`07:30` = -99999 then tmp.`07:00`
    else (tmp.`07:00` + tmp.`07:30`) / 2
  end
  as '07:15',
  tmp.`07:30`,
  case 
    when tmp.`07:30` = -99999 then tmp.`08:00`
    when tmp.`08:00` = -99999 then tmp.`07:30`
    else (tmp.`07:30` + tmp.`08:00`) / 2
  end
  as '07:45',
  tmp.`08:00`,
  case 
    when tmp.`08:00` = -99999 then tmp.`08:30`
    when tmp.`08:30` = -99999 then tmp.`08:00`
    else (tmp.`08:00` + tmp.`08:30`) / 2
  end
  as '08:15',
  tmp.`08:30`,
  case 
    when tmp.`08:30` = -99999 then tmp.`09:00`
    when tmp.`09:00` = -99999 then tmp.`08:30`
    else (tmp.`08:30` + tmp.`09:00`) / 2
  end
  as '08:45',
  tmp.`09:00`,
  case 
    when tmp.`09:00` = -99999 then tmp.`09:30`
    when tmp.`09:30` = -99999 then tmp.`09:00`
    else (tmp.`09:00` + tmp.`09:30`) / 2
  end
  as '09:15',
  tmp.`09:30`,
  case 
    when tmp.`09:30` = -99999 then tmp.`10:00`
    when tmp.`10:00` = -99999 then tmp.`09:30`
    else (tmp.`09:30` + tmp.`10:00`) / 2
  end
  as '09:45',
  
  tmp.`10:00`,
  case 
    when tmp.`10:00` = -99999 then tmp.`10:30`
    when tmp.`10:30` = -99999 then tmp.`10:00`
    else (tmp.`10:00` + tmp.`10:30`) / 2
  end
  as '10:15',
  tmp.`10:30`,
  case 
    when tmp.`10:30` = -99999 then tmp.`11:00`
    when tmp.`11:00` = -99999 then tmp.`10:30`
    else (tmp.`10:30` + tmp.`11:00`) / 2
  end
  as '10:45',
  tmp.`11:00`,
  case 
    when tmp.`11:00` = -99999 then tmp.`11:30`
    when tmp.`11:30` = -99999 then tmp.`11:00`
    else (tmp.`11:00` + tmp.`11:30`) / 2
  end
  as '11:15',
  tmp.`11:30`,
  case 
    when tmp.`11:30` = -99999 then tmp.`12:00`
    when tmp.`12:00` = -99999 then tmp.`11:30`
    else (tmp.`11:30` + tmp.`12:00`) / 2
  end
  as '11:45',
  tmp.`12:00`,
  case 
    when tmp.`12:00` = -99999 then tmp.`12:30`
    when tmp.`12:30` = -99999 then tmp.`12:00`
    else (tmp.`12:00` + tmp.`12:30`) / 2
  end
  as '12:15',
  tmp.`12:30`,
  case 
    when tmp.`12:30` = -99999 then tmp.`13:00`
    when tmp.`13:00` = -99999 then tmp.`12:30`
    else (tmp.`12:30` + tmp.`13:00`) / 2
  end
  as '12:45',
  tmp.`13:00`,
  case 
    when tmp.`13:00` = -99999 then tmp.`13:30`
    when tmp.`13:30` = -99999 then tmp.`13:00`
    else (tmp.`13:00` + tmp.`13:30`) / 2
  end
  as '13:15',
  tmp.`13:30`,
  case 
    when tmp.`13:30` = -99999 then tmp.`14:00`
    when tmp.`14:00` = -99999 then tmp.`13:30`
    else (tmp.`13:30` + tmp.`14:00`) / 2
  end
  as '13:45',
  tmp.`14:00`,
  case 
    when tmp.`14:00` = -99999 then tmp.`14:30`
    when tmp.`14:30` = -99999 then tmp.`14:00`
    else (tmp.`14:00` + tmp.`14:30`) / 2
  end
  as '14:15',
  tmp.`14:30`,
  case 
    when tmp.`14:30` = -99999 then tmp.`15:00`
    when tmp.`15:00` = -99999 then tmp.`14:30`
    else (tmp.`14:30` + tmp.`15:00`) / 2
  end
  as '14:45',
  tmp.`15:00`,
  case 
    when tmp.`15:00` = -99999 then tmp.`15:30`
    when tmp.`15:30` = -99999 then tmp.`15:00`
    else (tmp.`15:00` + tmp.`15:30`) / 2
  end
  as '15:15',
  tmp.`15:30`,
  case 
    when tmp.`15:30` = -99999 then tmp.`16:00`
    when tmp.`16:00` = -99999 then tmp.`15:30`
    else (tmp.`15:30` + tmp.`16:00`) / 2
  end
  as '15:45',
  tmp.`16:00`,
  case 
    when tmp.`16:00` = -99999 then tmp.`16:30`
    when tmp.`16:30` = -99999 then tmp.`16:00`
    else (tmp.`16:00` + tmp.`16:30`) / 2
  end
  as '16:15',
  tmp.`16:30`,
  case 
    when tmp.`16:30` = -99999 then tmp.`17:00`
    when tmp.`17:00` = -99999 then tmp.`16:30`
    else (tmp.`16:30` + tmp.`17:00`) / 2
  end
  as '16:45',
  tmp.`17:00`,
  case 
    when tmp.`17:00` = -99999 then tmp.`17:30`
    when tmp.`17:30` = -99999 then tmp.`17:00`
    else (tmp.`17:00` + tmp.`17:30`) / 2
  end
  as '17:15',
  tmp.`17:30`,
  case 
    when tmp.`17:30` = -99999 then tmp.`18:00`
    when tmp.`18:00` = -99999 then tmp.`17:30`
    else (tmp.`17:30` + tmp.`18:00`) / 2
  end
  as '17:45',
  tmp.`18:00`,
  case 
    when tmp.`18:00` = -99999 then tmp.`18:30`
    when tmp.`18:30` = -99999 then tmp.`18:00`
    else (tmp.`18:00` + tmp.`18:30`) / 2
  end
  as '18:15',
  tmp.`18:30`,
  case 
    when tmp.`18:30` = -99999 then tmp.`19:00`
    when tmp.`19:00` = -99999 then tmp.`18:30`
    else (tmp.`18:30` + tmp.`19:00`) / 2
  end
  as '18:45',
  tmp.`19:00`,
  case 
    when tmp.`19:00` = -99999 then tmp.`19:30`
    when tmp.`19:30` = -99999 then tmp.`19:00`
    else (tmp.`19:00` + tmp.`19:30`) / 2
  end
  as '19:15',
  tmp.`19:30`,
  case 
    when tmp.`19:30` = -99999 then tmp.`20:00`
    when tmp.`20:00` = -99999 then tmp.`19:30`
    else (tmp.`19:30` + tmp.`20:00`) / 2
  end
  as '19:45',
  
  tmp.`20:00`,
  case 
    when tmp.`20:00` = -99999 then tmp.`20:30`
    when tmp.`20:30` = -99999 then tmp.`20:00`
    else (tmp.`20:00` + tmp.`20:30`) / 2
  end
  as '20:15',
  tmp.`20:30`,
  case 
    when tmp.`20:30` = -99999 then tmp.`21:00`
    when tmp.`21:00` = -99999 then tmp.`20:30`
    else (tmp.`20:30` + tmp.`21:00`) / 2
  end
  as '20:45',
  tmp.`21:00`,
  case 
    when tmp.`21:00` = -99999 then tmp.`21:30`
    when tmp.`21:30` = -99999 then tmp.`21:00`
    else (tmp.`21:00` + tmp.`21:30`) / 2
  end
  as '21:15',
  tmp.`21:30`,
  case 
    when tmp.`21:30` = -99999 then tmp.`22:00`
    when tmp.`22:00` = -99999 then tmp.`21:30`
    else (tmp.`21:30` + tmp.`22:00`) / 2
  end
  as '21:45',
  tmp.`22:00`,
  case 
    when tmp.`22:00` = -99999 then tmp.`22:30`
    when tmp.`22:30` = -99999 then tmp.`22:00`
    else (tmp.`22:00` + tmp.`22:30`) / 2
  end
  as '22:15',
  tmp.`22:30`,
  case 
    when tmp.`22:30` = -99999 then tmp.`23:00`
    when tmp.`23:00` = -99999 then tmp.`22:30`
    else (tmp.`22:30` + tmp.`23:00`) / 2
  end
  as '22:45',
  tmp.`23:00`,
  case 
    when tmp.`23:00` = -99999 then tmp.`23:30`
    when tmp.`23:30` = -99999 then tmp.`23:00`
    else (tmp.`23:00` + tmp.`23:30`) / 2
  end
  as '23:15',
  tmp.`23:30`,
  tmp.`23:30` as '23:45'
from vatia_fdm.vw_matrix_weather_wind_tmp tmp;

-- ---------------------------------------------------------------------------------------------------------------------------------

drop view if exists  vatia_fdm.vw_matrix_weather_pressure_tmp;
create view vatia_fdm.vw_matrix_weather_pressure_tmp as
select 
  con.fk_weather_station_id, 
  date(con.ts) as forecast_date,
  max( if(substr(con.ts, 12,5)='00:00', con.pressure, -99999) ) as '00:00',  
  max( if(substr(con.ts, 12,5)='00:30', con.pressure, -99999) ) as '00:30',
  max( if(substr(con.ts, 12,5)='01:00', con.pressure, -99999) ) as '01:00',
  max( if(substr(con.ts, 12,5)='01:30', con.pressure, -99999) ) as '01:30',
  max( if(substr(con.ts, 12,5)='02:00', con.pressure, -99999) ) as '02:00',
  max( if(substr(con.ts, 12,5)='02:30', con.pressure, -99999) ) as '02:30',
  max( if(substr(con.ts, 12,5)='03:00', con.pressure, -99999) ) as '03:00',
  max( if(substr(con.ts, 12,5)='03:30', con.pressure, -99999) ) as '03:30',
  max( if(substr(con.ts, 12,5)='04:00', con.pressure, -99999) ) as '04:00',
  max( if(substr(con.ts, 12,5)='04:30', con.pressure, -99999) ) as '04:30',
  max( if(substr(con.ts, 12,5)='05:00', con.pressure, -99999) ) as '05:00',
  max( if(substr(con.ts, 12,5)='05:30', con.pressure, -99999) ) as '05:30',
  max( if(substr(con.ts, 12,5)='06:00', con.pressure, -99999) ) as '06:00',
  max( if(substr(con.ts, 12,5)='06:30', con.pressure, -99999) ) as '06:30',
  max( if(substr(con.ts, 12,5)='07:00', con.pressure, -99999) ) as '07:00',
  max( if(substr(con.ts, 12,5)='07:30', con.pressure, -99999) ) as '07:30',
  max( if(substr(con.ts, 12,5)='08:00', con.pressure, -99999) ) as '08:00',
  max( if(substr(con.ts, 12,5)='08:30', con.pressure, -99999) ) as '08:30',
  max( if(substr(con.ts, 12,5)='09:00', con.pressure, -99999) ) as '09:00',
  max( if(substr(con.ts, 12,5)='09:30', con.pressure, -99999) ) as '09:30',
  max( if(substr(con.ts, 12,5)='10:00', con.pressure, -99999) ) as '10:00',
  max( if(substr(con.ts, 12,5)='10:30', con.pressure, -99999) ) as '10:30',
  max( if(substr(con.ts, 12,5)='11:00', con.pressure, -99999) ) as '11:00',
  max( if(substr(con.ts, 12,5)='11:30', con.pressure, -99999) ) as '11:30',
  max( if(substr(con.ts, 12,5)='12:00', con.pressure, -99999) ) as '12:00',
  max( if(substr(con.ts, 12,5)='12:30', con.pressure, -99999) ) as '12:30',
  max( if(substr(con.ts, 12,5)='13:00', con.pressure, -99999) ) as '13:00',
  max( if(substr(con.ts, 12,5)='13:30', con.pressure, -99999) ) as '13:30',
  max( if(substr(con.ts, 12,5)='14:00', con.pressure, -99999) ) as '14:00',
  max( if(substr(con.ts, 12,5)='14:30', con.pressure, -99999) ) as '14:30',
  max( if(substr(con.ts, 12,5)='15:00', con.pressure, -99999) ) as '15:00',
  max( if(substr(con.ts, 12,5)='15:30', con.pressure, -99999) ) as '15:30',
  max( if(substr(con.ts, 12,5)='16:00', con.pressure, -99999) ) as '16:00',
  max( if(substr(con.ts, 12,5)='16:30', con.pressure, -99999) ) as '16:30',
  max( if(substr(con.ts, 12,5)='17:00', con.pressure, -99999) ) as '17:00',
  max( if(substr(con.ts, 12,5)='17:30', con.pressure, -99999) ) as '17:30',
  max( if(substr(con.ts, 12,5)='18:00', con.pressure, -99999) ) as '18:00',
  max( if(substr(con.ts, 12,5)='18:30', con.pressure, -99999) ) as '18:30',
  max( if(substr(con.ts, 12,5)='19:00', con.pressure, -99999) ) as '19:00',
  max( if(substr(con.ts, 12,5)='19:30', con.pressure, -99999) ) as '19:30',
  max( if(substr(con.ts, 12,5)='20:00', con.pressure, -99999) ) as '20:00',
  max( if(substr(con.ts, 12,5)='20:30', con.pressure, -99999) ) as '20:30',
  max( if(substr(con.ts, 12,5)='21:00', con.pressure, -99999) ) as '21:00',
  max( if(substr(con.ts, 12,5)='21:30', con.pressure, -99999) ) as '21:30',
  max( if(substr(con.ts, 12,5)='22:00', con.pressure, -99999) ) as '22:00',
  max( if(substr(con.ts, 12,5)='22:30', con.pressure, -99999) ) as '22:30',
  max( if(substr(con.ts, 12,5)='23:00', con.pressure, -99999) ) as '23:00',
  max( if(substr(con.ts, 12,5)='23:30', con.pressure, -99999) ) as '23:30'
from vatia_fdm.weather_forecast con
group by 1,2;


drop view if exists  vatia_fdm.vw_matrix_weather_pressure;
create view vatia_fdm.vw_matrix_weather_pressure as
select
  tmp.fk_weather_station_id,
  tmp.forecast_date,
  tmp.`00:00`,
  case 
    when tmp.`00:00` = -99999 then tmp.`00:30`
    when tmp.`00:30` = -99999 then tmp.`00:00`
    else (tmp.`00:00` + tmp.`00:30`) / 2
  end
  as '00:15',
  tmp.`00:30`,
  case 
    when tmp.`00:30` = -99999 then tmp.`01:00`
    when tmp.`01:00` = -99999 then tmp.`00:30`
    else (tmp.`00:30` + tmp.`01:00`) / 2
  end
  as '00:45',
  tmp.`01:00`,
  case 
    when tmp.`01:00` = -99999 then tmp.`01:30`
    when tmp.`01:30` = -99999 then tmp.`01:00`
    else (tmp.`01:00` + tmp.`01:30`) / 2
  end
  as '01:15',
  tmp.`01:30`,
  case 
    when tmp.`01:30` = -99999 then tmp.`02:00`
    when tmp.`02:00` = -99999 then tmp.`01:30`
    else (tmp.`01:30` + tmp.`02:00`) / 2
  end
  as '01:45',
  tmp.`02:00`,
  case 
    when tmp.`02:00` = -99999 then tmp.`02:30`
    when tmp.`02:30` = -99999 then tmp.`02:00`
    else (tmp.`02:00` + tmp.`02:30`) / 2
  end
  as '02:15',
  tmp.`02:30`,
  case 
    when tmp.`02:30` = -99999 then tmp.`03:00`
    when tmp.`03:00` = -99999 then tmp.`02:30`
    else (tmp.`02:30` + tmp.`03:00`) / 2
  end
  as '02:45',
  tmp.`03:00`,
  case 
    when tmp.`03:00` = -99999 then tmp.`03:30`
    when tmp.`03:30` = -99999 then tmp.`03:00`
    else (tmp.`03:00` + tmp.`03:30`) / 2
  end
  as '03:15',
  tmp.`03:30`,
  case 
    when tmp.`03:30` = -99999 then tmp.`04:00`
    when tmp.`04:00` = -99999 then tmp.`03:30`
    else (tmp.`03:30` + tmp.`04:00`) / 2
  end
  as '03:45',
  tmp.`04:00`,
  case 
    when tmp.`04:00` = -99999 then tmp.`04:30`
    when tmp.`04:30` = -99999 then tmp.`04:00`
    else (tmp.`04:00` + tmp.`04:30`) / 2
  end
  as '04:15',
  tmp.`04:30`,
  case 
    when tmp.`04:30` = -99999 then tmp.`05:00`
    when tmp.`05:00` = -99999 then tmp.`04:30`
    else (tmp.`04:30` + tmp.`05:00`) / 2
  end
  as '04:45',
  tmp.`05:00`,
  case 
    when tmp.`05:00` = -99999 then tmp.`05:30`
    when tmp.`05:30` = -99999 then tmp.`05:00`
    else (tmp.`05:00` + tmp.`05:30`) / 2
  end
  as '05:15',
  tmp.`05:30`,
  case 
    when tmp.`05:30` = -99999 then tmp.`06:00`
    when tmp.`06:00` = -99999 then tmp.`05:30`
    else (tmp.`05:30` + tmp.`06:00`) / 2
  end
  as '05:45',
  tmp.`06:00`,
  case 
    when tmp.`06:00` = -99999 then tmp.`06:30`
    when tmp.`06:30` = -99999 then tmp.`06:00`
    else (tmp.`06:00` + tmp.`06:30`) / 2
  end
  as '06:15',
  tmp.`06:30`,
  case 
    when tmp.`06:30` = -99999 then tmp.`07:00`
    when tmp.`07:00` = -99999 then tmp.`06:30`
    else (tmp.`06:30` + tmp.`07:00`) / 2
  end
  as '06:45',
  tmp.`07:00`,
  case 
    when tmp.`07:00` = -99999 then tmp.`07:30`
    when tmp.`07:30` = -99999 then tmp.`07:00`
    else (tmp.`07:00` + tmp.`07:30`) / 2
  end
  as '07:15',
  tmp.`07:30`,
  case 
    when tmp.`07:30` = -99999 then tmp.`08:00`
    when tmp.`08:00` = -99999 then tmp.`07:30`
    else (tmp.`07:30` + tmp.`08:00`) / 2
  end
  as '07:45',
  tmp.`08:00`,
  case 
    when tmp.`08:00` = -99999 then tmp.`08:30`
    when tmp.`08:30` = -99999 then tmp.`08:00`
    else (tmp.`08:00` + tmp.`08:30`) / 2
  end
  as '08:15',
  tmp.`08:30`,
  case 
    when tmp.`08:30` = -99999 then tmp.`09:00`
    when tmp.`09:00` = -99999 then tmp.`08:30`
    else (tmp.`08:30` + tmp.`09:00`) / 2
  end
  as '08:45',
  tmp.`09:00`,
  case 
    when tmp.`09:00` = -99999 then tmp.`09:30`
    when tmp.`09:30` = -99999 then tmp.`09:00`
    else (tmp.`09:00` + tmp.`09:30`) / 2
  end
  as '09:15',
  tmp.`09:30`,
  case 
    when tmp.`09:30` = -99999 then tmp.`10:00`
    when tmp.`10:00` = -99999 then tmp.`09:30`
    else (tmp.`09:30` + tmp.`10:00`) / 2
  end
  as '09:45',
  
  tmp.`10:00`,
  case 
    when tmp.`10:00` = -99999 then tmp.`10:30`
    when tmp.`10:30` = -99999 then tmp.`10:00`
    else (tmp.`10:00` + tmp.`10:30`) / 2
  end
  as '10:15',
  tmp.`10:30`,
  case 
    when tmp.`10:30` = -99999 then tmp.`11:00`
    when tmp.`11:00` = -99999 then tmp.`10:30`
    else (tmp.`10:30` + tmp.`11:00`) / 2
  end
  as '10:45',
  tmp.`11:00`,
  case 
    when tmp.`11:00` = -99999 then tmp.`11:30`
    when tmp.`11:30` = -99999 then tmp.`11:00`
    else (tmp.`11:00` + tmp.`11:30`) / 2
  end
  as '11:15',
  tmp.`11:30`,
  case 
    when tmp.`11:30` = -99999 then tmp.`12:00`
    when tmp.`12:00` = -99999 then tmp.`11:30`
    else (tmp.`11:30` + tmp.`12:00`) / 2
  end
  as '11:45',
  tmp.`12:00`,
  case 
    when tmp.`12:00` = -99999 then tmp.`12:30`
    when tmp.`12:30` = -99999 then tmp.`12:00`
    else (tmp.`12:00` + tmp.`12:30`) / 2
  end
  as '12:15',
  tmp.`12:30`,
  case 
    when tmp.`12:30` = -99999 then tmp.`13:00`
    when tmp.`13:00` = -99999 then tmp.`12:30`
    else (tmp.`12:30` + tmp.`13:00`) / 2
  end
  as '12:45',
  tmp.`13:00`,
  case 
    when tmp.`13:00` = -99999 then tmp.`13:30`
    when tmp.`13:30` = -99999 then tmp.`13:00`
    else (tmp.`13:00` + tmp.`13:30`) / 2
  end
  as '13:15',
  tmp.`13:30`,
  case 
    when tmp.`13:30` = -99999 then tmp.`14:00`
    when tmp.`14:00` = -99999 then tmp.`13:30`
    else (tmp.`13:30` + tmp.`14:00`) / 2
  end
  as '13:45',
  tmp.`14:00`,
  case 
    when tmp.`14:00` = -99999 then tmp.`14:30`
    when tmp.`14:30` = -99999 then tmp.`14:00`
    else (tmp.`14:00` + tmp.`14:30`) / 2
  end
  as '14:15',
  tmp.`14:30`,
  case 
    when tmp.`14:30` = -99999 then tmp.`15:00`
    when tmp.`15:00` = -99999 then tmp.`14:30`
    else (tmp.`14:30` + tmp.`15:00`) / 2
  end
  as '14:45',
  tmp.`15:00`,
  case 
    when tmp.`15:00` = -99999 then tmp.`15:30`
    when tmp.`15:30` = -99999 then tmp.`15:00`
    else (tmp.`15:00` + tmp.`15:30`) / 2
  end
  as '15:15',
  tmp.`15:30`,
  case 
    when tmp.`15:30` = -99999 then tmp.`16:00`
    when tmp.`16:00` = -99999 then tmp.`15:30`
    else (tmp.`15:30` + tmp.`16:00`) / 2
  end
  as '15:45',
  tmp.`16:00`,
  case 
    when tmp.`16:00` = -99999 then tmp.`16:30`
    when tmp.`16:30` = -99999 then tmp.`16:00`
    else (tmp.`16:00` + tmp.`16:30`) / 2
  end
  as '16:15',
  tmp.`16:30`,
  case 
    when tmp.`16:30` = -99999 then tmp.`17:00`
    when tmp.`17:00` = -99999 then tmp.`16:30`
    else (tmp.`16:30` + tmp.`17:00`) / 2
  end
  as '16:45',
  tmp.`17:00`,
  case 
    when tmp.`17:00` = -99999 then tmp.`17:30`
    when tmp.`17:30` = -99999 then tmp.`17:00`
    else (tmp.`17:00` + tmp.`17:30`) / 2
  end
  as '17:15',
  tmp.`17:30`,
  case 
    when tmp.`17:30` = -99999 then tmp.`18:00`
    when tmp.`18:00` = -99999 then tmp.`17:30`
    else (tmp.`17:30` + tmp.`18:00`) / 2
  end
  as '17:45',
  tmp.`18:00`,
  case 
    when tmp.`18:00` = -99999 then tmp.`18:30`
    when tmp.`18:30` = -99999 then tmp.`18:00`
    else (tmp.`18:00` + tmp.`18:30`) / 2
  end
  as '18:15',
  tmp.`18:30`,
  case 
    when tmp.`18:30` = -99999 then tmp.`19:00`
    when tmp.`19:00` = -99999 then tmp.`18:30`
    else (tmp.`18:30` + tmp.`19:00`) / 2
  end
  as '18:45',
  tmp.`19:00`,
  case 
    when tmp.`19:00` = -99999 then tmp.`19:30`
    when tmp.`19:30` = -99999 then tmp.`19:00`
    else (tmp.`19:00` + tmp.`19:30`) / 2
  end
  as '19:15',
  tmp.`19:30`,
  case 
    when tmp.`19:30` = -99999 then tmp.`20:00`
    when tmp.`20:00` = -99999 then tmp.`19:30`
    else (tmp.`19:30` + tmp.`20:00`) / 2
  end
  as '19:45',
  
  tmp.`20:00`,
  case 
    when tmp.`20:00` = -99999 then tmp.`20:30`
    when tmp.`20:30` = -99999 then tmp.`20:00`
    else (tmp.`20:00` + tmp.`20:30`) / 2
  end
  as '20:15',
  tmp.`20:30`,
  case 
    when tmp.`20:30` = -99999 then tmp.`21:00`
    when tmp.`21:00` = -99999 then tmp.`20:30`
    else (tmp.`20:30` + tmp.`21:00`) / 2
  end
  as '20:45',
  tmp.`21:00`,
  case 
    when tmp.`21:00` = -99999 then tmp.`21:30`
    when tmp.`21:30` = -99999 then tmp.`21:00`
    else (tmp.`21:00` + tmp.`21:30`) / 2
  end
  as '21:15',
  tmp.`21:30`,
  case 
    when tmp.`21:30` = -99999 then tmp.`22:00`
    when tmp.`22:00` = -99999 then tmp.`21:30`
    else (tmp.`21:30` + tmp.`22:00`) / 2
  end
  as '21:45',
  tmp.`22:00`,
  case 
    when tmp.`22:00` = -99999 then tmp.`22:30`
    when tmp.`22:30` = -99999 then tmp.`22:00`
    else (tmp.`22:00` + tmp.`22:30`) / 2
  end
  as '22:15',
  tmp.`22:30`,
  case 
    when tmp.`22:30` = -99999 then tmp.`23:00`
    when tmp.`23:00` = -99999 then tmp.`22:30`
    else (tmp.`22:30` + tmp.`23:00`) / 2
  end
  as '22:45',
  tmp.`23:00`,
  case 
    when tmp.`23:00` = -99999 then tmp.`23:30`
    when tmp.`23:30` = -99999 then tmp.`23:00`
    else (tmp.`23:00` + tmp.`23:30`) / 2
  end
  as '23:15',
  tmp.`23:30`,
  tmp.`23:30` as '23:45'
from vatia_fdm.vw_matrix_weather_pressure_tmp tmp;

-- ---------------------------------------------------------------------------------------------------------------------------------

drop view if exists  vatia_fdm.vw_matrix_weather_precipitation_tmp;
create view vatia_fdm.vw_matrix_weather_precipitation_tmp as
select 
  con.fk_weather_station_id, 
  date(con.ts) as forecast_date,
  max( if(substr(con.ts, 12,5)='00:00', con.precipitation, -99999) ) as '00:00',  
  max( if(substr(con.ts, 12,5)='00:30', con.precipitation, -99999) ) as '00:30',
  max( if(substr(con.ts, 12,5)='01:00', con.precipitation, -99999) ) as '01:00',
  max( if(substr(con.ts, 12,5)='01:30', con.precipitation, -99999) ) as '01:30',
  max( if(substr(con.ts, 12,5)='02:00', con.precipitation, -99999) ) as '02:00',
  max( if(substr(con.ts, 12,5)='02:30', con.precipitation, -99999) ) as '02:30',
  max( if(substr(con.ts, 12,5)='03:00', con.precipitation, -99999) ) as '03:00',
  max( if(substr(con.ts, 12,5)='03:30', con.precipitation, -99999) ) as '03:30',
  max( if(substr(con.ts, 12,5)='04:00', con.precipitation, -99999) ) as '04:00',
  max( if(substr(con.ts, 12,5)='04:30', con.precipitation, -99999) ) as '04:30',
  max( if(substr(con.ts, 12,5)='05:00', con.precipitation, -99999) ) as '05:00',
  max( if(substr(con.ts, 12,5)='05:30', con.precipitation, -99999) ) as '05:30',
  max( if(substr(con.ts, 12,5)='06:00', con.precipitation, -99999) ) as '06:00',
  max( if(substr(con.ts, 12,5)='06:30', con.precipitation, -99999) ) as '06:30',
  max( if(substr(con.ts, 12,5)='07:00', con.precipitation, -99999) ) as '07:00',
  max( if(substr(con.ts, 12,5)='07:30', con.precipitation, -99999) ) as '07:30',
  max( if(substr(con.ts, 12,5)='08:00', con.precipitation, -99999) ) as '08:00',
  max( if(substr(con.ts, 12,5)='08:30', con.precipitation, -99999) ) as '08:30',
  max( if(substr(con.ts, 12,5)='09:00', con.precipitation, -99999) ) as '09:00',
  max( if(substr(con.ts, 12,5)='09:30', con.precipitation, -99999) ) as '09:30',
  max( if(substr(con.ts, 12,5)='10:00', con.precipitation, -99999) ) as '10:00',
  max( if(substr(con.ts, 12,5)='10:30', con.precipitation, -99999) ) as '10:30',
  max( if(substr(con.ts, 12,5)='11:00', con.precipitation, -99999) ) as '11:00',
  max( if(substr(con.ts, 12,5)='11:30', con.precipitation, -99999) ) as '11:30',
  max( if(substr(con.ts, 12,5)='12:00', con.precipitation, -99999) ) as '12:00',
  max( if(substr(con.ts, 12,5)='12:30', con.precipitation, -99999) ) as '12:30',
  max( if(substr(con.ts, 12,5)='13:00', con.precipitation, -99999) ) as '13:00',
  max( if(substr(con.ts, 12,5)='13:30', con.precipitation, -99999) ) as '13:30',
  max( if(substr(con.ts, 12,5)='14:00', con.precipitation, -99999) ) as '14:00',
  max( if(substr(con.ts, 12,5)='14:30', con.precipitation, -99999) ) as '14:30',
  max( if(substr(con.ts, 12,5)='15:00', con.precipitation, -99999) ) as '15:00',
  max( if(substr(con.ts, 12,5)='15:30', con.precipitation, -99999) ) as '15:30',
  max( if(substr(con.ts, 12,5)='16:00', con.precipitation, -99999) ) as '16:00',
  max( if(substr(con.ts, 12,5)='16:30', con.precipitation, -99999) ) as '16:30',
  max( if(substr(con.ts, 12,5)='17:00', con.precipitation, -99999) ) as '17:00',
  max( if(substr(con.ts, 12,5)='17:30', con.precipitation, -99999) ) as '17:30',
  max( if(substr(con.ts, 12,5)='18:00', con.precipitation, -99999) ) as '18:00',
  max( if(substr(con.ts, 12,5)='18:30', con.precipitation, -99999) ) as '18:30',
  max( if(substr(con.ts, 12,5)='19:00', con.precipitation, -99999) ) as '19:00',
  max( if(substr(con.ts, 12,5)='19:30', con.precipitation, -99999) ) as '19:30',
  max( if(substr(con.ts, 12,5)='20:00', con.precipitation, -99999) ) as '20:00',
  max( if(substr(con.ts, 12,5)='20:30', con.precipitation, -99999) ) as '20:30',
  max( if(substr(con.ts, 12,5)='21:00', con.precipitation, -99999) ) as '21:00',
  max( if(substr(con.ts, 12,5)='21:30', con.precipitation, -99999) ) as '21:30',
  max( if(substr(con.ts, 12,5)='22:00', con.precipitation, -99999) ) as '22:00',
  max( if(substr(con.ts, 12,5)='22:30', con.precipitation, -99999) ) as '22:30',
  max( if(substr(con.ts, 12,5)='23:00', con.precipitation, -99999) ) as '23:00',
  max( if(substr(con.ts, 12,5)='23:30', con.precipitation, -99999) ) as '23:30'
from vatia_fdm.weather_forecast con
group by 1,2;

drop view if exists  vatia_fdm.vw_matrix_weather_precipitation;
create view vatia_fdm.vw_matrix_weather_precipitation as
select
  tmp.fk_weather_station_id,
  tmp.forecast_date,
  tmp.`00:00`,
  case 
    when tmp.`00:00` = -99999 then tmp.`00:30`
    when tmp.`00:30` = -99999 then tmp.`00:00`
    else (tmp.`00:00` + tmp.`00:30`) / 2
  end
  as '00:15',
  tmp.`00:30`,
  case 
    when tmp.`00:30` = -99999 then tmp.`01:00`
    when tmp.`01:00` = -99999 then tmp.`00:30`
    else (tmp.`00:30` + tmp.`01:00`) / 2
  end
  as '00:45',
  tmp.`01:00`,
  case 
    when tmp.`01:00` = -99999 then tmp.`01:30`
    when tmp.`01:30` = -99999 then tmp.`01:00`
    else (tmp.`01:00` + tmp.`01:30`) / 2
  end
  as '01:15',
  tmp.`01:30`,
  case 
    when tmp.`01:30` = -99999 then tmp.`02:00`
    when tmp.`02:00` = -99999 then tmp.`01:30`
    else (tmp.`01:30` + tmp.`02:00`) / 2
  end
  as '01:45',
  tmp.`02:00`,
  case 
    when tmp.`02:00` = -99999 then tmp.`02:30`
    when tmp.`02:30` = -99999 then tmp.`02:00`
    else (tmp.`02:00` + tmp.`02:30`) / 2
  end
  as '02:15',
  tmp.`02:30`,
  case 
    when tmp.`02:30` = -99999 then tmp.`03:00`
    when tmp.`03:00` = -99999 then tmp.`02:30`
    else (tmp.`02:30` + tmp.`03:00`) / 2
  end
  as '02:45',
  tmp.`03:00`,
  case 
    when tmp.`03:00` = -99999 then tmp.`03:30`
    when tmp.`03:30` = -99999 then tmp.`03:00`
    else (tmp.`03:00` + tmp.`03:30`) / 2
  end
  as '03:15',
  tmp.`03:30`,
  case 
    when tmp.`03:30` = -99999 then tmp.`04:00`
    when tmp.`04:00` = -99999 then tmp.`03:30`
    else (tmp.`03:30` + tmp.`04:00`) / 2
  end
  as '03:45',
  tmp.`04:00`,
  case 
    when tmp.`04:00` = -99999 then tmp.`04:30`
    when tmp.`04:30` = -99999 then tmp.`04:00`
    else (tmp.`04:00` + tmp.`04:30`) / 2
  end
  as '04:15',
  tmp.`04:30`,
  case 
    when tmp.`04:30` = -99999 then tmp.`05:00`
    when tmp.`05:00` = -99999 then tmp.`04:30`
    else (tmp.`04:30` + tmp.`05:00`) / 2
  end
  as '04:45',
  tmp.`05:00`,
  case 
    when tmp.`05:00` = -99999 then tmp.`05:30`
    when tmp.`05:30` = -99999 then tmp.`05:00`
    else (tmp.`05:00` + tmp.`05:30`) / 2
  end
  as '05:15',
  tmp.`05:30`,
  case 
    when tmp.`05:30` = -99999 then tmp.`06:00`
    when tmp.`06:00` = -99999 then tmp.`05:30`
    else (tmp.`05:30` + tmp.`06:00`) / 2
  end
  as '05:45',
  tmp.`06:00`,
  case 
    when tmp.`06:00` = -99999 then tmp.`06:30`
    when tmp.`06:30` = -99999 then tmp.`06:00`
    else (tmp.`06:00` + tmp.`06:30`) / 2
  end
  as '06:15',
  tmp.`06:30`,
  case 
    when tmp.`06:30` = -99999 then tmp.`07:00`
    when tmp.`07:00` = -99999 then tmp.`06:30`
    else (tmp.`06:30` + tmp.`07:00`) / 2
  end
  as '06:45',
  tmp.`07:00`,
  case 
    when tmp.`07:00` = -99999 then tmp.`07:30`
    when tmp.`07:30` = -99999 then tmp.`07:00`
    else (tmp.`07:00` + tmp.`07:30`) / 2
  end
  as '07:15',
  tmp.`07:30`,
  case 
    when tmp.`07:30` = -99999 then tmp.`08:00`
    when tmp.`08:00` = -99999 then tmp.`07:30`
    else (tmp.`07:30` + tmp.`08:00`) / 2
  end
  as '07:45',
  tmp.`08:00`,
  case 
    when tmp.`08:00` = -99999 then tmp.`08:30`
    when tmp.`08:30` = -99999 then tmp.`08:00`
    else (tmp.`08:00` + tmp.`08:30`) / 2
  end
  as '08:15',
  tmp.`08:30`,
  case 
    when tmp.`08:30` = -99999 then tmp.`09:00`
    when tmp.`09:00` = -99999 then tmp.`08:30`
    else (tmp.`08:30` + tmp.`09:00`) / 2
  end
  as '08:45',
  tmp.`09:00`,
  case 
    when tmp.`09:00` = -99999 then tmp.`09:30`
    when tmp.`09:30` = -99999 then tmp.`09:00`
    else (tmp.`09:00` + tmp.`09:30`) / 2
  end
  as '09:15',
  tmp.`09:30`,
  case 
    when tmp.`09:30` = -99999 then tmp.`10:00`
    when tmp.`10:00` = -99999 then tmp.`09:30`
    else (tmp.`09:30` + tmp.`10:00`) / 2
  end
  as '09:45',
  
  tmp.`10:00`,
  case 
    when tmp.`10:00` = -99999 then tmp.`10:30`
    when tmp.`10:30` = -99999 then tmp.`10:00`
    else (tmp.`10:00` + tmp.`10:30`) / 2
  end
  as '10:15',
  tmp.`10:30`,
  case 
    when tmp.`10:30` = -99999 then tmp.`11:00`
    when tmp.`11:00` = -99999 then tmp.`10:30`
    else (tmp.`10:30` + tmp.`11:00`) / 2
  end
  as '10:45',
  tmp.`11:00`,
  case 
    when tmp.`11:00` = -99999 then tmp.`11:30`
    when tmp.`11:30` = -99999 then tmp.`11:00`
    else (tmp.`11:00` + tmp.`11:30`) / 2
  end
  as '11:15',
  tmp.`11:30`,
  case 
    when tmp.`11:30` = -99999 then tmp.`12:00`
    when tmp.`12:00` = -99999 then tmp.`11:30`
    else (tmp.`11:30` + tmp.`12:00`) / 2
  end
  as '11:45',
  tmp.`12:00`,
  case 
    when tmp.`12:00` = -99999 then tmp.`12:30`
    when tmp.`12:30` = -99999 then tmp.`12:00`
    else (tmp.`12:00` + tmp.`12:30`) / 2
  end
  as '12:15',
  tmp.`12:30`,
  case 
    when tmp.`12:30` = -99999 then tmp.`13:00`
    when tmp.`13:00` = -99999 then tmp.`12:30`
    else (tmp.`12:30` + tmp.`13:00`) / 2
  end
  as '12:45',
  tmp.`13:00`,
  case 
    when tmp.`13:00` = -99999 then tmp.`13:30`
    when tmp.`13:30` = -99999 then tmp.`13:00`
    else (tmp.`13:00` + tmp.`13:30`) / 2
  end
  as '13:15',
  tmp.`13:30`,
  case 
    when tmp.`13:30` = -99999 then tmp.`14:00`
    when tmp.`14:00` = -99999 then tmp.`13:30`
    else (tmp.`13:30` + tmp.`14:00`) / 2
  end
  as '13:45',
  tmp.`14:00`,
  case 
    when tmp.`14:00` = -99999 then tmp.`14:30`
    when tmp.`14:30` = -99999 then tmp.`14:00`
    else (tmp.`14:00` + tmp.`14:30`) / 2
  end
  as '14:15',
  tmp.`14:30`,
  case 
    when tmp.`14:30` = -99999 then tmp.`15:00`
    when tmp.`15:00` = -99999 then tmp.`14:30`
    else (tmp.`14:30` + tmp.`15:00`) / 2
  end
  as '14:45',
  tmp.`15:00`,
  case 
    when tmp.`15:00` = -99999 then tmp.`15:30`
    when tmp.`15:30` = -99999 then tmp.`15:00`
    else (tmp.`15:00` + tmp.`15:30`) / 2
  end
  as '15:15',
  tmp.`15:30`,
  case 
    when tmp.`15:30` = -99999 then tmp.`16:00`
    when tmp.`16:00` = -99999 then tmp.`15:30`
    else (tmp.`15:30` + tmp.`16:00`) / 2
  end
  as '15:45',
  tmp.`16:00`,
  case 
    when tmp.`16:00` = -99999 then tmp.`16:30`
    when tmp.`16:30` = -99999 then tmp.`16:00`
    else (tmp.`16:00` + tmp.`16:30`) / 2
  end
  as '16:15',
  tmp.`16:30`,
  case 
    when tmp.`16:30` = -99999 then tmp.`17:00`
    when tmp.`17:00` = -99999 then tmp.`16:30`
    else (tmp.`16:30` + tmp.`17:00`) / 2
  end
  as '16:45',
  tmp.`17:00`,
  case 
    when tmp.`17:00` = -99999 then tmp.`17:30`
    when tmp.`17:30` = -99999 then tmp.`17:00`
    else (tmp.`17:00` + tmp.`17:30`) / 2
  end
  as '17:15',
  tmp.`17:30`,
  case 
    when tmp.`17:30` = -99999 then tmp.`18:00`
    when tmp.`18:00` = -99999 then tmp.`17:30`
    else (tmp.`17:30` + tmp.`18:00`) / 2
  end
  as '17:45',
  tmp.`18:00`,
  case 
    when tmp.`18:00` = -99999 then tmp.`18:30`
    when tmp.`18:30` = -99999 then tmp.`18:00`
    else (tmp.`18:00` + tmp.`18:30`) / 2
  end
  as '18:15',
  tmp.`18:30`,
  case 
    when tmp.`18:30` = -99999 then tmp.`19:00`
    when tmp.`19:00` = -99999 then tmp.`18:30`
    else (tmp.`18:30` + tmp.`19:00`) / 2
  end
  as '18:45',
  tmp.`19:00`,
  case 
    when tmp.`19:00` = -99999 then tmp.`19:30`
    when tmp.`19:30` = -99999 then tmp.`19:00`
    else (tmp.`19:00` + tmp.`19:30`) / 2
  end
  as '19:15',
  tmp.`19:30`,
  case 
    when tmp.`19:30` = -99999 then tmp.`20:00`
    when tmp.`20:00` = -99999 then tmp.`19:30`
    else (tmp.`19:30` + tmp.`20:00`) / 2
  end
  as '19:45',
  
  tmp.`20:00`,
  case 
    when tmp.`20:00` = -99999 then tmp.`20:30`
    when tmp.`20:30` = -99999 then tmp.`20:00`
    else (tmp.`20:00` + tmp.`20:30`) / 2
  end
  as '20:15',
  tmp.`20:30`,
  case 
    when tmp.`20:30` = -99999 then tmp.`21:00`
    when tmp.`21:00` = -99999 then tmp.`20:30`
    else (tmp.`20:30` + tmp.`21:00`) / 2
  end
  as '20:45',
  tmp.`21:00`,
  case 
    when tmp.`21:00` = -99999 then tmp.`21:30`
    when tmp.`21:30` = -99999 then tmp.`21:00`
    else (tmp.`21:00` + tmp.`21:30`) / 2
  end
  as '21:15',
  tmp.`21:30`,
  case 
    when tmp.`21:30` = -99999 then tmp.`22:00`
    when tmp.`22:00` = -99999 then tmp.`21:30`
    else (tmp.`21:30` + tmp.`22:00`) / 2
  end
  as '21:45',
  tmp.`22:00`,
  case 
    when tmp.`22:00` = -99999 then tmp.`22:30`
    when tmp.`22:30` = -99999 then tmp.`22:00`
    else (tmp.`22:00` + tmp.`22:30`) / 2
  end
  as '22:15',
  tmp.`22:30`,
  case 
    when tmp.`22:30` = -99999 then tmp.`23:00`
    when tmp.`23:00` = -99999 then tmp.`22:30`
    else (tmp.`22:30` + tmp.`23:00`) / 2
  end
  as '22:45',
  tmp.`23:00`,
  case 
    when tmp.`23:00` = -99999 then tmp.`23:30`
    when tmp.`23:30` = -99999 then tmp.`23:00`
    else (tmp.`23:00` + tmp.`23:30`) / 2
  end
  as '23:15',
  tmp.`23:30`,
  tmp.`23:30` as '23:45'
from vatia_fdm.vw_matrix_weather_precipitation_tmp tmp;

-- ---------------------------------------------------------------------------------------------------------------------------------

drop view if exists vatia_fdm.vw_metadata;
create view vatia_fdm.vw_metadata as
select mdt.*, wst.pk_id as fk_weather_forecast_id
from vatia_fdm.metadata mdt
  left join vatia_fdm.weather_station wst
    on mdt.country = wst.country 
    and mdt.province = wst.province
    and coalesce(case when mdt.city='' then null else mdt.city end , mdt.province) = wst.city ;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- LOAD DATA
insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('leam', 36.843889, -2.37, 'Almería', 'Aeropuerto Almería', 'Spain', 'Almería');

insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('leba', 37.843333, -4.841944, 'Córdoba', 'Aeropuerto de Córdoba', 'Spain', 'Córdoba');

insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('lega', 37.1330556, -3.6377443, 'Armilla', 'Armilla', 'Spain', 'Granada');

insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('legr', 37.188611, -3.777222, 'Granada', 'Aeropuerto de Granada', 'Spain', 'Granada');

insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('lejr', 36.744722, -6.06, 'Jerez', 'Aeropuerto de Jerez', 'Spain', 'Cádiz');

insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('lemg', 36.675, -4.499167, 'Málaga', 'Aeropuerto de Málaga', 'Spain', 'Málaga');

insert into `vatia_fdm`.`weather_station` (icao, lat, lng, city, name, country, province) 
values ('lezl', 37.418056, -5.898889, 'Sevilla', 'Aeropuerto de Sevilla', 'Spain', 'Sevilla');
