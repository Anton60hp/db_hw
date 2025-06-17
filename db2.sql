-- Задача 1
with avg_pos as (
	select 
		c."name",
		c."class",
		avg(r."position") as avg_pos,
		count(*) as race_count
	from results r join cars c on r.car = c."name"
	group by  c."name", c."class"
),
min_pos as (
	select
		"class",
		min(avg_pos) as avg_pos
	from avg_pos 
	group by "class" 
)
select 
	p."name" as car_name,
	p."class" as car_class,
	p.avg_pos as average_position,
	p.race_count
from avg_pos p join min_pos m on p."class" = m."class" and p.avg_pos = m.avg_pos
order by p.avg_pos;



-- Задача 2
with avg_pos as (
	select 
		c."name",
		c."class",
		avg(r."position") as avg_pos,
		count(*) as race_count
	from results r join cars c on r.car = c."name"
	group by  c."name", c."class"
),
min_avg_pos as (
	select min(avg_pos) as min_pos
	from avg_pos a
)
select a."name", a."class", a.avg_pos, a.race_count, c.country
from avg_pos a join classes c on a."class" = c."class"
where avg_pos = (select min_pos from min_avg_pos)
limit 1;

