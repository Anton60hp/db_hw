-- Задача 1
select maker, m.model
from motorcycle m join vehicle v on m.model = v.model
where m.type = 'Sport' and price < 20000 and m.horsepower > 150;


-- Задача 2
(select v.maker, c.model, c.horsepower, c.engine_capacity, v.type
from car c join vehicle v on c.model = v.model
where c.engine_capacity < 3 and c.price < 35000 and horsepower > 150
union 
select v.maker, m.model, m.horsepower, m.engine_capacity, v.type
from motorcycle m join vehicle v on m.model = v.model
where m.engine_capacity < 1.5 and m.price < 20000 and m.horsepower > 150
union 
select v.maker, b.model, null, null, v.type
from bicycle b join vehicle v on b.model = v.model
where b.price < 4000 and b.gear_count > 18)
order by horsepower desc NULLS LAST;
