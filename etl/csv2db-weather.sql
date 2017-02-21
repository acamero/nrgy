DROP TABLE IF EXISTS `vatia_tmp`.`weather`;
CREATE TABLE `vatia_tmp`.`weather` (
  date_day varchar(55),
  date_hour varchar(55),
  forecast varchar(55),
  temperature varchar(55),
  wind varchar(55),
  precipitation varchar(55),
  pressure varchar(55),  
  primary key( date_day, date_hour )
);


-- 'tmp/leam.csv'
-- 'tmp/leba.csv'
-- 'tmp/lega.csv'
-- 'tmp/legr.csv'
-- 'tmp/lejr.csv'
-- 'tmp/lemg.csv'
-- 'tmp/lezl.csv'

SET @ICAO = 'lezl';

LOAD DATA LOCAL INFILE 'tmp/lezl.csv' INTO TABLE `vatia_tmp`.`weather`
  CHARACTER SET utf8
  FIELDS TERMINATED BY '|';

insert into `vatia_fdm`.`weather_forecast` 
( 
  fk_weather_station_id,
  ts,
  forecast,
  temperature,
  wind,
  precipitation,
  pressure
)
select 
  wst.pk_id as fk_weather_station_id,
  concat(wtmp.date_day, ' ', wtmp.date_hour),
  wtmp.forecast,
  replace(wtmp.temperature,'N/D','0') as temp,
  case
    when wtmp.wind='En calma' then 0
    when position(' a ' in wtmp.wind) >0 then substr(wtmp.wind, 1, position(' a ' in wtmp.wind))
    else trim(replace(wtmp.wind, 'km/h',''))
  end as wind,
  trim(replace(replace(wtmp.precipitation,'%',''),'N/D','0')) as precipitation,
  trim(replace(replace(wtmp.pressure, 'hPa', ''),'-','0')) as pressure
from vatia_tmp.weather wtmp
  join vatia_fdm.weather_station wst
    on wst.icao = @ICAO;
