DROP TABLE IF EXISTS `vatia_tmp`.`metadata`;
CREATE TABLE `vatia_tmp`.`metadata` (
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
  year_of_construct varchar(55),
  comments varchar(55),
  pc varchar(55),
  state varchar(55),
  primary key( file_name )
);

LOAD DATA LOCAL INFILE 'tmp/meta.csv' INTO TABLE `vatia_tmp`.`metadata`
  CHARACTER SET utf8
  FIELDS TERMINATED BY '|'
  IGNORE 1 LINES;

DROP TABLE IF EXISTS `vatia_tmp`.`data`;
CREATE TABLE `vatia_tmp`.`data` (
  file_name varchar(55),
  ts varchar(55),
  consumption varchar(55),  
  primary key( file_name, ts )
);

LOAD DATA LOCAL INFILE 'tmp/data.csv' INTO TABLE `vatia_tmp`.`data`
  CHARACTER SET utf8
  FIELDS TERMINATED BY ';';

insert into vatia_fdm.metadata (
  file_name,
  province,
  surface,
  address,
  lat,
  lng,
  city,
  name,
  country,
  cadastre,
  year_of_construct,
  comments,
  pc,
  state)
select 
  md.file_name,
  md.province,
  md.surface,
  md.address,
  md.lat,
  md.lng,
  md.city,
  md.name,
  md.country,
  md.cadastre,
  case 
    when trim(md.year_of_construct) = '' then 0
    else md.year_of_construct 
  end as y_o_c,
  md.comments,
  case
    when trim(md.pc) = '' then 0
    else md.pc
  end as pci,
  md.state
from vatia_tmp.metadata md
  left join vatia_fdm.metadata fdm
    on md.file_name = fdm.file_name
where
  fdm.pk_id is null;

insert into `vatia_fdm`.`power_consumption` (fk_metadata_id, ts, consumption)
select 
  md.pk_id,
  str_to_date(replace(d.ts, '24:', '00:'), '%Y-%m-%d %H:%i') as m_ts,
  cast(replace(d.consumption, 'nan', -1) as decimal(10,4))
from vatia_tmp.data d
  join vatia_fdm.metadata md
    on d.file_name = md.file_name;

